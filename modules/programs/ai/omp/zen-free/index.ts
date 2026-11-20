import { existsSync, readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createHash, randomBytes } from 'node:crypto';
import { tmpdir } from 'node:os';
import { dirname, join, resolve as resolvePath } from 'node:path';
import { createAssistantMessageEventStream } from '@oh-my-pi/pi-ai';
import { streamZenNative } from './transport';
import { buildModel } from '@oh-my-pi/pi-catalog/build';
import { getAgentDir } from '@oh-my-pi/pi-utils';
import type { ExtensionAPI, ProviderConfig } from '@oh-my-pi/pi-coding-agent';
import type { AssistantMessage, Context, Message, Tool, ToolChoice } from '@oh-my-pi/pi-ai/types';
import type { Api } from '@oh-my-pi/pi-ai/types';

// Native OMP tools, selectors, history and execution permissions stay unchanged.
// The free-lane gateway fingerprints OpenCode's official `read` and `shell`
// declarations. We always declare those two byte-identical tools. A caller tool
// with the same name but a different definition is exposed under `<name>_client`
// and mapped back before OMP sees it, so the gate is satisfied without losing the
// caller's tool. The injected declarations are protocol metadata only: the stream
// guard aborts on any call outside the caller's allowlist.
const customApi = 'zen-free-native';
// The free lane's v2.0.26 fingerprint validates a minted session id:
// `ses_` + 12 hex time bits + 14 base62 characters. OpenCode 2.1.4's local DB
// uses a newer `ses_<64 hex>` shape, but the wire gate still accepts (and the
// live endpoint has verified) the minted form, so keep the gate-compatible one.
const BASE62 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
// Session ids are cached per OMP session; bound the cache so a long-lived process
// with many sessions and subagents cannot grow it without limit.
const SESSION_CACHE_LIMIT = 256;
const PROJECT_CACHE_LIMIT = 64;
// A stream that emits nothing for this long is aborted instead of hanging forever.
// OMP's own stream watchdogs are disabled by default (`streamIdleTimeoutSeconds: -1`).
const DEFAULT_IDLE_TIMEOUT_MS = 300_000;
const MIN_IDLE_TIMEOUT_MS = 50;
const GIT_SEARCH_DEPTH = 32;

// The free-lane gateway rejects with FreeUsageLimitError (HTTP 429) any request
// whose tool declarations contain both `context_notes` and `new_context` by name.
// Sending `new_context` under an equivalent wire name keeps every tool available;
// the name is mapped back before OMP sees a tool call, and the transcript is
// rewritten on the way out so replayed calls match the declaration.
const NATIVE_CONTEXT_TOOL = 'new_context';
const WIRE_CONTEXT_TOOL = 'fresh_context';

/**
 * Official v2.0.26 free-lane gate definitions, verbatim from the OpenCode client.
 * Do not reword, reorder keys, or drop `additionalProperties: false`: the gateway
 * compares the description and parameters JSON and answers 403 on any difference.
 */
export const OFFICIAL_GATE_TOOL_DEFINITIONS = Object.freeze({
 read: {
  description:
   'Read the contents of a file or directory. Supports text files, images, and PDFs. Images and PDFs are presented directly to the model. Each text line is prefixed by its 1-based line number as <line>: <content>. The prefix is for reference and is not part of the file content. Directory entries are returned one per line. Use offset and limit to read large files or directories in sections. Prefer one larger read over many small slices, and use grep to find specific content in large files.',
  parameters: {
   type: 'object',
   properties: {
    path: { type: 'string', description: 'File or directory to read' },
    offset: {
     type: 'integer',
     minimum: 0,
     description: 'The line or directory entry to start reading from (1-based)',
    },
    limit: {
     type: 'integer',
     minimum: 0,
     description: 'The maximum number of lines or directory entries to read (defaults to and capped at 2000)',
    },
   },
   required: ['path'],
   additionalProperties: false,
  },
 },
 shell: {
  description:
   'Execute a shell command and return its output. Commands run on Linux using bash. Quote file paths containing spaces or special characters. Prefer dedicated tools over shell commands when possible. When output is large, the full result is saved to a file and a truncated preview is returned. Rely on automatic truncation unless filtering the output is more useful. Commands accept an optional timeout, background commands have no timeout by default. Background commands return immediately, and you will be notified when they complete.',
  parameters: {
   type: 'object',
   properties: {
    command: { type: 'string', description: 'Shell command string to execute' },
    workdir: {
     type: 'string',
     description:
      'Working directory to execute the command in. Defaults to the current working directory. When possible, avoid changing directories in the command and set the working directory here instead.',
    },
    timeout: {
     type: 'integer',
     minimum: 0,
     description:
      'Timeout in milliseconds. Set to 0 to disable the timeout. Defaults to 120000 for foreground commands. Background commands have no timeout by default.',
    },
    background: {
     type: 'boolean',
     description:
      "Run the command in the background and return immediately (useful for dev servers and long-running builds). You do not need to use '&' at the end of the command when using this parameter. You will be notified when it completes. DO NOT poll for completion.",
    },
   },
   required: ['command'],
   additionalProperties: false,
  },
 },
} as const);

type GateName = keyof typeof OFFICIAL_GATE_TOOL_DEFINITIONS;

function gateTool(name: GateName): Tool {
 const definition = OFFICIAL_GATE_TOOL_DEFINITIONS[name];
 return {
  name,
  description: definition.description,
  parameters: definition.parameters as Tool['parameters'],
  // Strict-mode rewriting would mutate the official schema and break the gate.
  strict: false,
 };
}

export const OFFICIAL_GATE_TOOLS: readonly Tool[] = Object.freeze([gateTool('read'), gateTool('shell')]);

/** True only for a tool whose name, description and schema are the official gate shape. */
export function isOfficialGateTool(tool: Pick<Tool, 'name' | 'description' | 'parameters'>): boolean {
 if (tool.name !== 'read' && tool.name !== 'shell') return false;
 const definition = OFFICIAL_GATE_TOOL_DEFINITIONS[tool.name];
 return tool.description === definition.description &&
  JSON.stringify(tool.parameters) === JSON.stringify(definition.parameters);
}

export interface WireToolMap {
 /** Caller tools under their wire names, followed by any missing official gate tools. */
 tools: Tool[];
 /** Native tool name -> wire name, only for renamed caller tools. */
 toWire: Map<string, string>;
 /** Wire name -> native tool name, only for renamed caller tools. */
 toNative: Map<string, string>;
 /** Caller tool names that OMP may execute. Gate-only declarations are excluded. */
 allowed: Set<string>;
}

/**
 * Build the wire tool list. Official `read`/`shell` are always present exactly once;
 * conflicting caller tools are aliased rather than dropped. Aliases are unique so a
 * caller that already owns `read_client` still keeps that tool.
 */
export function buildWireTools(tools: Tool[] | undefined): WireToolMap {
 const input = tools ?? [];
 const used = new Set(input.map(tool => tool.name));
 const toWire = new Map<string, string>();
 const toNative = new Map<string, string>();
 const allowed = new Set<string>();
 const output: Tool[] = [];
 const unique = (base: string): string => {
  let name = base;
  for (let index = 2; used.has(name); index += 1) name = `${base}_${index}`;
  used.add(name);
  return name;
 };
 for (const tool of input) {
  allowed.add(tool.name);
  let wireName = tool.name;
  if (tool.name === NATIVE_CONTEXT_TOOL) wireName = WIRE_CONTEXT_TOOL;
  if ((tool.name === 'read' || tool.name === 'shell') && !isOfficialGateTool(tool)) {
   wireName = `${tool.name}_client`;
  }
  if (wireName === tool.name) {
   output.push(tool);
   continue;
  }
  wireName = unique(wireName);
  toWire.set(tool.name, wireName);
  toNative.set(wireName, tool.name);
  // Preserve prototype getters (some host tools render their description lazily)
  // and every own descriptor while replacing only the wire-visible name.
  const descriptors = Object.getOwnPropertyDescriptors(tool);
  descriptors.name = { value: wireName, enumerable: true, configurable: true, writable: true };
  output.push(Object.create(Object.getPrototypeOf(tool), descriptors) as Tool);
 }
 for (const gate of OFFICIAL_GATE_TOOLS) {
  if (output.some(tool => tool.name === gate.name)) continue;
  output.push(gate);
 }
 return { tools: output, toWire, toNative, allowed };
}

/** Native tool name -> the name this gateway accepts on the wire. */
export function toWireToolName(name: string): string {
 return name === NATIVE_CONTEXT_TOOL ? WIRE_CONTEXT_TOOL : name;
}

/** Wire tool name -> the native name OMP executes and records in history. */
export function toNativeToolName(name: string): string {
 return name === WIRE_CONTEXT_TOOL ? NATIVE_CONTEXT_TOOL : name;
}

function wireName(name: string, map?: WireToolMap): string {
 return map?.toWire.get(name) ?? toWireToolName(name);
}

function nativeName(name: string, map?: WireToolMap): string {
 return map?.toNative.get(name) ?? toNativeToolName(name);
}

/** Replay earlier tool calls and results under their declared wire names. */
export function toWireMessages(messages: Message[], map?: WireToolMap): Message[] {
 return messages.map(message => {
  if (message.role === 'assistant') {
   if (!message.content.some(part => part.type === 'toolCall' && wireName(part.name, map) !== part.name)) return message;
   return {
    ...message,
    content: message.content.map(part =>
     part.type === 'toolCall' ? { ...part, name: wireName(part.name, map) } : part),
   };
  }
  if (message.role === 'toolResult' && wireName(message.toolName, map) !== message.toolName) {
   return { ...message, toolName: wireName(message.toolName, map) };
  }
  return message;
 });
}

export function toWireToolChoice(choice: ToolChoice | undefined, map?: WireToolMap): ToolChoice | undefined {
 if (!choice || typeof choice === 'string' || choice.type === 'computer') return choice;
 if ('function' in choice) {
  const mapped = wireName(choice.function.name, map);
  return mapped === choice.function.name
   ? choice
   : { ...choice, function: { ...choice.function, name: mapped } };
 }
 const mapped = wireName(choice.name, map);
 return mapped === choice.name ? choice : { ...choice, name: mapped };
}

/** Rewrite a streamed message's tool calls from the wire name back to the native one. */
function toNativeToolCalls(message: AssistantMessage, map: WireToolMap): void {
 for (const part of message.content) {
  if (part.type === 'toolCall') part.name = nativeName(part.name, map);
 }
}

export function sessionSuffix(bytes: number): string {
 let out = '';
 for (const byte of randomBytes(bytes)) out += BASE62[byte % 62];
 return out;
}

/** Insert with recency ordering and evict the oldest entry once the cache is full. */
export function rememberSession(cache: Map<string, string>, key: string, value: string): void {
 if (cache.has(key)) cache.delete(key);
 cache.set(key, value);
 while (cache.size > SESSION_CACHE_LIMIT) {
  const oldest = cache.keys().next();
  if (oldest.done) return;
  cache.delete(oldest.value);
 }
}

/**
 * Stable OpenCode session id for one OMP session. An existing entry is re-touched so a
 * long-running session keeps its id while short-lived subagents flood the cache.
 */
export function sessionFor(cache: Map<string, string>, key: string): string {
 const existing = cache.get(key);
 if (existing !== undefined) {
  rememberSession(cache, key, existing);
  return existing;
 }
 const time = ((~(BigInt(Date.now()) * 4096n + 1n)) & 0xffffffffffffn).toString(16).padStart(12, '0');
 const created = 'ses_' + time + sessionSuffix(14);
 rememberSession(cache, key, created);
 return created;
}

/** Nearest ancestor containing `.git`, so a nested working directory still reports a repo. */
export function findGitRoot(cwd: string): string | undefined {
 let current = cwd;
 for (let depth = 0; depth < GIT_SEARCH_DEPTH; depth += 1) {
  if (existsSync(join(current, '.git'))) return current;
  const parent = dirname(current);
  if (parent === current) return undefined;
  current = parent;
 }
 return undefined;
}

function gitOutput(cwd: string, args: string[]): string | undefined {
 try {
  const output = execFileSync('git', args, {
   cwd,
   encoding: 'utf8',
   stdio: ['ignore', 'pipe', 'ignore'],
   timeout: 2000,
  }).trim();
  return output || undefined;
 } catch {
  return undefined;
 }
}

function joinRemote(host: string, path: string): string | undefined {
 const cleaned = path.replace(/^\/+/, '').replace(/\.git\/?$/, '').replace(/\/+$/, '');
 if (!host || !cleaned) return undefined;
 return `${host.toLowerCase()}/${cleaned}`;
}

/** Normalize an OpenCode git remote to `host/path`, or undefined for local/file remotes. */
export function normalizeGitRemote(remote: string): string | undefined {
 const value = remote.trim();
 if (!value) return undefined;
 try {
  const url = new URL(value);
  if (url.protocol === 'file:') return undefined;
  return joinRemote(url.hostname, url.pathname);
 } catch {
  // SCP-style remotes (git@host:owner/repo.git) are not valid URLs.
 }
 const match = /^(?:[^@/:]+@)?([^/:]+):(.+)$/.exec(value);
 return match ? joinRemote(match[1], match[2]) : undefined;
}

/**
 * OpenCode's project identity: a git repository hashes its normalized remote (or
 * uses `.git/opencode` / the root commit), while a non-git directory hashes its
 * resolved working directory. Keeping this exact matters for gateway quota and
 * cache grouping, especially when OMP runs from a repository subdirectory.
 */
export function resolveProjectId(cwd: string): string {
 const root = findGitRoot(cwd);
 if (!root) return createHash('sha1').update(`directory:${cwd}`).digest('hex');
 const common = gitOutput(root, ['rev-parse', '--git-common-dir']);
 const commonDir = common ? resolvePath(root, common) : join(root, '.git');
 const opencodeFile = join(commonDir, 'opencode');
 if (existsSync(opencodeFile)) {
  const stored = readFileSync(opencodeFile, 'utf8').trim();
  // The gateway expects a 40-hex project id. OpenCode normally stores one
  // verbatim; hash any other content rather than emitting an invalid header.
  if (stored) return /^[0-9a-f]{40}$/i.test(stored)
   ? stored.toLowerCase()
   : createHash('sha1').update(stored).digest('hex');
 }
 const remote = gitOutput(root, ['remote', 'get-url', 'origin']);
 if (remote) {
  const normalized = normalizeGitRemote(remote);
  if (normalized) return createHash('sha1').update(`git-remote:${normalized}`).digest('hex');
 }
 const rootCommit = gitOutput(root, ['rev-list', '--max-parents=0', 'HEAD']);
 if (rootCommit) {
  const first = rootCommit.split('\n').map(line => line.trim()).filter(Boolean).sort()[0];
  if (first) return first;
 }
 return createHash('sha1').update(`directory:${cwd}`).digest('hex');
}

const projectCache = new Map<string, string>();

function projectFor(cwd: string): string {
 const cached = projectCache.get(cwd);
 if (cached !== undefined) return cached;
 const id = resolveProjectId(cwd);
 if (projectCache.size >= PROJECT_CACHE_LIMIT) {
  const oldest = projectCache.keys().next();
  if (!oldest.done) projectCache.delete(oldest.value);
 }
 projectCache.set(cwd, id);
 return id;
}

/** The OpenCode system-prompt environment block, including the free-lane date/temp hints. */
export function environmentBlock(cwd: string): string {
 const repoRoot = findGitRoot(cwd);
 const temp = process.env.ZEN_FREE_TMP_DIR?.trim() || process.env.TMPDIR?.trim() || tmpdir();
 return [
  `Today's date: ${new Date().toDateString()}`,
  'Here is some useful information about the environment you are running in:',
  '<env>',
  `  Working directory: ${cwd}`,
  `  Workspace root folder: ${repoRoot ?? cwd}`,
  `  Is directory a git repo: ${repoRoot ? 'yes' : 'no'}`,
  `  Platform: ${process.platform}`,
  `  Prefer ${temp} over generic system temporary directories such as /tmp; it is pre-created and approved for external access.`,
  '</env>',
 ].join('\n');
}

/** Header names are case-insensitive on the wire, so removal has to be as well. */
function removeHeader(headers: Record<string, string>, name: string): void {
 const target = name.toLowerCase();
 for (const key of Object.keys(headers)) {
  if (key.toLowerCase() === target) delete headers[key];
 }
}

/** Test hook: an explicit override lets a test drive the watchdog without a 5-minute wait. */
export function idleTimeoutMs(): number {
 const override = Number(process.env.ZEN_FREE_IDLE_TIMEOUT_MS);
 return Number.isFinite(override) && override >= MIN_IDLE_TIMEOUT_MS ? override : DEFAULT_IDLE_TIMEOUT_MS;
}

type ProviderModel = NonNullable<ProviderConfig['models']>[number];
type ProviderBlock = ProviderConfig & { models: ProviderModel[] };
type ZenCompatConfig = NonNullable<Parameters<typeof buildModel>[0]['compat']>;
type ZenReasoningPolicy = {
 supportsForcedToolChoice?: boolean;
 requiresReasoningContentForToolCalls?: boolean;
 requiresReasoningContentForAllAssistantTurns?: boolean;
 allowsSyntheticReasoningContentForToolCalls?: boolean;
};

/**
 * OMP's built-in opencode-zen policy for reasoning replay. The sparse models.yml
 * compat cannot carry every flag (notably requiresReasoningContentForAllAssistantTurns),
 * so merge the full provider policy here for every reasoning chat model.
 */
export const ZEN_REASONING_COMPAT: Readonly<Record<string, ZenReasoningPolicy>> = Object.freeze({
 'big-pickle': {
  supportsForcedToolChoice: false,
  requiresReasoningContentForToolCalls: true,
  requiresReasoningContentForAllAssistantTurns: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
 'deepseek-v4.1-flash-free': {
  supportsForcedToolChoice: false,
  requiresReasoningContentForToolCalls: true,
  requiresReasoningContentForAllAssistantTurns: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
 'beam-free': {
  requiresReasoningContentForToolCalls: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
 'mimo-v2.6-flash-free': {
  requiresReasoningContentForToolCalls: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
 'nemotron-3.5-lightning-free': {
  requiresReasoningContentForToolCalls: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
 'nemotron-3.5-super-vl-free': {
  requiresReasoningContentForToolCalls: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
 'glm-5.3-flash-free': {
  requiresReasoningContentForToolCalls: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
 'flint-40b-free': {
  requiresReasoningContentForToolCalls: true,
  allowsSyntheticReasoningContentForToolCalls: false,
 },
});

function compatFor(modelId: string, compat: ZenCompatConfig | undefined): ZenCompatConfig | undefined {
 const policy = ZEN_REASONING_COMPAT[modelId];
 return policy ? { ...compat, ...policy } : compat;
}

/**
 * Validate the block OMP already loaded from models.yml before trusting it. The YAML is
 * external input, so only the shape this extension actually reads is checked.
 */
export function readProviderBlock(raw: unknown): ProviderBlock | undefined {
 if (!raw || typeof raw !== 'object' || !('providers' in raw)) return undefined;
 const providers = raw.providers;
 if (!providers || typeof providers !== 'object' || !('zen-free' in providers)) return undefined;
 const block = providers['zen-free'];
 if (!block || typeof block !== 'object' || !('models' in block) || !Array.isArray(block.models)) return undefined;
 if (block.models.length === 0) return undefined;
 for (const model of block.models) {
  if (!model || typeof model !== 'object' || !('id' in model) || typeof model.id !== 'string') return undefined;
 }
 // Every entry carries a string id; the remaining fields are OMP's own model spec.
 return block as ProviderBlock;
}

export default function zenFree(pi: ExtensionAPI) {
 pi.on('session_start', async (_event, ctx) => {
  if (ctx.model?.provider !== 'zen-free' || ctx.model.api === 'typesafe') return;
  const model = ctx.modelRegistry.find('zen-free', ctx.model.id);
  if (model) await pi.setModel(model);
 });
 const provider = readProviderBlock(Bun.YAML.parse(readFileSync(join(getAgentDir(), 'models.yml'), 'utf8')));
 if (!provider) {
  pi.logger?.warn?.('zen-free: no provider block in models.yml; extension inactive');
  return;
 }
 const nativeApis = new Map<string, Api | undefined>(provider.models.map(model => [model.id, model.api ?? provider.api]));
 const sessions = new Map<string, string>();
 const adaptedStream: NonNullable<ProviderConfig['streamSimple']> = (model, context, options = {}) => {
  const output = createAssistantMessageEventStream();
  void (async () => {
   let idle: Timer | undefined;
   try {
    const key = options.sessionId ?? 'default';
    const session = sessionFor(sessions, key);
    const parent = options.parentSessionId;
    // OpenCode uses the parent as the affinity/session key for a child session,
    // while x-opencode-session-id carries the child itself.
    const affinity = sessionFor(sessions, parent ?? key);
    const parentSession = parent ? sessionFor(sessions, parent) : undefined;
    const userAgent = (model.headers && typeof model.headers['User-Agent'] === 'string')
     ? model.headers['User-Agent']
     : 'opencode/latest/2.1.4/cli';
    const cwd = options.cwd ?? process.cwd();
    const project = projectFor(cwd);
    const headers: Record<string, string> = {
     ...model.headers,
     ...options.headers,
     'User-Agent': userAgent,
     'x-opencode-client': 'cli',
     'x-opencode-project': project,
     Authorization: 'Bearer public',
     'x-opencode-session': affinity,
     'x-opencode-session-id': session,
     'x-session-affinity': affinity,
     'X-Session-Id': affinity,
     ...(parentSession ? {
      'x-opencode-parent-session-id': parentSession,
      'x-parent-session-id': parentSession,
     } : {}),
    };
    removeHeader(headers, 'x-opencode-request');
    // The OpenAI transports add `Accept: text/event-stream`; drop any custom
    // value first so the wire carries exactly one streaming accept header.
    removeHeader(headers, 'accept');
    const nativeApi = nativeApis.get(model.id);
    if (!nativeApi) throw new Error(`zen-free: no API declared for model ${model.id}`);
    const nativeModel = buildModel({
     ...model,
     api: nativeApi,
     compat: compatFor(model.id, model.compatConfig),
     headers,
    });
    const textOnly = options.toolChoice === 'none' || !context.tools?.length;
    const wireTools = buildWireTools(context.tools);
    const allowed = new Set(textOnly ? [] : wireTools.allowed);
    // A caller-provided official gate tool needs no duplicate; a caller tool with
    // the same name but a different definition is aliased, so it still needs policy.
    const missing = OFFICIAL_GATE_TOOLS
     .filter(gate => !(context.tools ?? []).some(tool => tool.name === gate.name && isOfficialGateTool(tool)))
     .map(gate => gate.name);
    let wireContext: Context = {
     ...context,
     messages: toWireMessages(context.messages, wireTools),
     tools: wireTools.tools,
    };
    const appended = [...(context.systemPrompt ?? []), environmentBlock(cwd)];
    if (textOnly || missing.length > 0 || wireTools.toWire.size > 0) {
     const enabled = [...wireTools.allowed].map(name => wireTools.toWire.get(name) ?? name);
     const policy = textOnly
      ? 'Tools are disabled for this request. Answer directly in text; do not call any tools. The read and shell declarations are protocol metadata only and must not be called.'
      : `Only these tools are enabled: ${enabled.join(', ')}. Any additional tool declarations are protocol metadata only; they are disabled and must not be called.`;
     appended.push(policy);
    }
    wireContext = { ...wireContext, systemPrompt: appended };
    const controller = new AbortController();
    const signal = options.signal ? AbortSignal.any([options.signal, controller.signal]) : controller.signal;
    const nativeToolChoice = textOnly
     ? (nativeModel.api === 'openai-responses' ? 'auto' : undefined)
     : options.toolChoice;
    const toolChoice = toWireToolChoice(nativeToolChoice, wireTools);
    const inner = streamZenNative(nativeModel, wireContext, {
     ...options,
     headers,
     apiKey: 'public',
     toolChoice,
     signal,
    });
    const timeout = idleTimeoutMs();
    const armIdle = () => {
     clearTimeout(idle);
     idle = setTimeout(() => {
      controller.abort(new Error(`Zen stream emitted no event for ${timeout}ms`));
     }, timeout);
     idle.unref?.();
    };
    armIdle();
    for await (const event of inner) {
     armIdle();
     if (event.type === 'toolcall_end') event.toolCall.name = nativeName(event.toolCall.name, wireTools);
     const message = event.type === 'done' ? event.message : event.type === 'error' ? undefined : event.partial;
     if (message) toNativeToolCalls(message, wireTools);
     const denied = message?.content.find(part => part.type === 'toolCall' && part.name && !allowed.has(part.name));
     if (denied?.type === 'toolCall') {
      const error = new Error(`Zen requested disabled tool: ${denied.name} (enabled: ${[...allowed].join(', ') || 'none'})`);
      controller.abort(error);
      throw error;
     }
     output.push(event);
    }
    output.end();
   } catch (error) { output.fail(error); }
   finally { clearTimeout(idle); }
  })();
  return output;
 };
 pi.registerProvider('zen-free', {
  ...provider,
  apiKey: 'public',
  api: customApi,
  streamSimple: adaptedStream,
  models: provider.models.map(model => ({ ...model, api: model.api === 'typesafe' ? 'typesafe' : customApi })),
 });
}