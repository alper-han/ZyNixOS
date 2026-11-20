import { afterAll, expect, test } from 'bun:test';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdtemp, mkdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { buildModel } from '@oh-my-pi/pi-catalog/build';
import { Effort } from '@oh-my-pi/pi-catalog/effort';
import { getAgentDir, setAgentDir } from '@oh-my-pi/pi-utils';
import type { ExtensionAPI, ProviderConfig } from '@oh-my-pi/pi-coding-agent';
import { ReadTool } from '@oh-my-pi/pi-coding-agent/tools/read';
import { Settings } from '@oh-my-pi/pi-coding-agent/config/settings';
import type { Message, Tool } from '@oh-my-pi/pi-ai/types';
import zenFree, {
 buildWireTools,
 environmentBlock,
 findGitRoot,
 normalizeGitRemote,
 OFFICIAL_GATE_TOOL_DEFINITIONS,
 rememberSession,
 resolveProjectId,
 sessionFor,
 sessionSuffix,
 toWireMessages,
 toWireToolChoice,
 ZEN_REASONING_COMPAT,
} from './index';
import { clampMaxTokens } from './transport';

const root = await mkdtemp(join(tmpdir(), 'zen-extension-'));
const file = join(root, 'data.txt');
await writeFile(file, 'FIRST\nSECOND\nTHIRD\nFOURTH\nFIFTH\nSIXTH\nSEVENTH');
const directory = join(root, 'folder');
await mkdir(directory);
for (const name of ['a.txt', 'b.txt', 'c.txt']) await writeFile(join(directory, name), '');
let requestedPath = '';
let responseMode: 'text' | 'call' = 'call';
let hangMode = false;
type WireTool = {
 type?: string;
 name?: string;
 description?: string;
 parameters?: unknown;
 function?: { name?: string; description?: string; parameters?: unknown; strict?: unknown };
};
type WirePayload = {
 messages?: Array<{
  role?: string;
  content?: unknown;
  tool_calls?: Array<{ function?: { name?: string } }>;
  reasoning_content?: unknown;
 }>;
 tools?: WireTool[];
 tool_choice?: unknown;
 max_tokens?: unknown;
};
let lastPayload: WirePayload | undefined;
let lastHeaders: Headers | undefined;

function declaredTools(payload: WirePayload, responses: boolean): Array<{ name?: string; description?: string; parameters?: unknown }> {
 return (payload.tools ?? []).map(tool => responses ? tool : tool.function ?? {});
}

const server = Bun.serve({
 hostname: '127.0.0.1',
 port: 0,
 async fetch(request) {
  const payload: unknown = await request.json();
  lastPayload = payload as WirePayload;
  lastHeaders = request.headers;
  if (hangMode) return new Response(new ReadableStream({ start() {} }), { headers: { 'content-type': 'text/event-stream' } });
  const responses = new URL(request.url).pathname.endsWith('/responses');
  if (!lastPayload || typeof lastPayload !== 'object' || !Array.isArray(lastPayload.tools)) {
   return Response.json({ error: { message: 'GATEWAY_DENIED_NO_TOOLS', type: 'invalid_request_error' } }, { status: 403 });
  }
  const tools = declaredTools(lastPayload, responses);
  const names = tools.map(tool => tool.name);
  if (!names.includes('read') || !names.includes('shell')) {
   return Response.json({ error: { message: 'GATEWAY_DENIED_MISSING_GATE_TOOL', type: 'invalid_request_error' } }, { status: 403 });
  }
  if (names.includes('new_context') || names.includes('context_notes')) {
   return Response.json({ error: { message: 'GATEWAY_DENIED_CONTEXT_TOOL_NAME', type: 'invalid_request_error' } }, { status: 403 });
  }
  if (lastPayload.tool_choice === 'none') {
   return Response.json({ error: { message: 'GATEWAY_DENIED_TOOL_CHOICE_NONE', type: 'invalid_request_error' } }, { status: 403 });
  }
  for (const gate of ['read', 'shell'] as const) {
   const declared = tools.find(tool => tool.name === gate);
   const expected = OFFICIAL_GATE_TOOL_DEFINITIONS[gate];
   if (!declared || declared.description !== expected.description ||
    JSON.stringify(declared.parameters) !== JSON.stringify(expected.parameters)) {
    return Response.json({ error: { message: `GATEWAY_DENIED_GATE_SHAPE_${gate}`, type: 'invalid_request_error' } }, { status: 403 });
   }
  }
  if (responses && 'tool_choice' in lastPayload && lastPayload.tool_choice !== 'auto') {
   return Response.json({ error: { message: 'ONLY_AUTO_SUPPORTED' } }, { status: 400 });
  }
  const text = responseMode === 'text';
  const callName = names.includes('read_client') ? 'read_client' : 'read';
  const chunks = responses ? [
   ...(text ? [
    { type: 'response.output_item.added', item: { type: 'message', id: 'msg_fixture', role: 'assistant', status: 'in_progress', content: [] } },
    { type: 'response.content_part.added', part: { type: 'output_text', text: '' } },
    { type: 'response.output_text.delta', delta: 'TEXT_ONLY_OK' },
    { type: 'response.output_item.done', item: { type: 'message', id: 'msg_fixture', role: 'assistant', status: 'completed', content: [{ type: 'output_text', text: 'TEXT_ONLY_OK' }] } },
   ] : [
    { type: 'response.output_item.added', item: { type: 'function_call', id: 'item_fixture', call_id: 'read_fixture', name: callName, arguments: '' } },
    { type: 'response.function_call_arguments.delta', delta: JSON.stringify({ path: requestedPath }) },
    { type: 'response.output_item.done', item: { type: 'function_call', id: 'item_fixture', call_id: 'read_fixture', name: callName, arguments: JSON.stringify({ path: requestedPath }) } },
   ]),
   { type: 'response.completed', response: { status: 'completed', usage: { input_tokens: 5, output_tokens: 2, total_tokens: 7 } } },
  ] : [
   { id: 'fixture', object: 'chat.completion.chunk', created: 1, model: 'fixture', choices: [{ index: 0, delta: text ? { role: 'assistant', content: 'TEXT_ONLY_OK' } : { role: 'assistant', tool_calls: [{ index: 0, id: 'read_fixture', type: 'function', function: { name: callName, arguments: JSON.stringify({ path: requestedPath }) } }] }, finish_reason: null }] },
   { id: 'fixture', object: 'chat.completion.chunk', created: 1, model: 'fixture', choices: [{ index: 0, delta: {}, finish_reason: text ? 'stop' : 'tool_calls' }], usage: { prompt_tokens: 5, completion_tokens: 2, total_tokens: 7 } },
  ];
  return new Response(chunks.map(chunk => 'data: ' + JSON.stringify(chunk) + '\n\n').join('') + (responses ? '' : 'data: [DONE]\n\n'), { headers: { 'content-type': 'text/event-stream' } });
 },
});

const baseSpec = {
 cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
 contextWindow: 8192,
 maxTokens: 256,
};
const fixtures = [
 { ...baseSpec, id: 'fixture', name: 'fixture', api: 'openai-completions', reasoning: false, input: ['text'] },
 { ...baseSpec, id: 'fixture-responses', name: 'fixture-responses', api: 'openai-responses', reasoning: false, input: ['text'] },
 {
  ...baseSpec,
  id: 'big-pickle',
  name: 'Big Pickle',
  api: 'openai-completions',
  reasoning: true,
  input: ['text'],
  contextWindow: 200000,
  maxTokens: 32000,
  thinking: { mode: 'effort', efforts: ['high', 'max'] },
  compat: { reasoningContentField: 'reasoning_content' },
 },
];
await writeFile(join(root, 'models.yml'), JSON.stringify({
 providers: {
  'zen-free': {
   baseUrl: `http://127.0.0.1:${server.port}/v1`,
   api: 'openai-completions',
   compat: {
    maxTokensField: 'max_tokens',
    supportsStrictMode: false,
    reasoningContentField: 'reasoning_content',
   },
   models: fixtures,
  },
 },
}));
let provider: ProviderConfig | undefined;
// Loading only needs these three host methods; the stream and native tools below are real.
const host = { on() {}, registerProvider(_name: string, config: ProviderConfig) { provider = config; }, async setModel() { return true; } };
const previousDir = getAgentDir();
try {
 setAgentDir(root);
 zenFree(host as unknown as ExtensionAPI);
} finally {
 setAgentDir(previousDir);
}
if (!provider?.streamSimple) throw new Error('Extension did not register its stream');
const stream = provider.streamSimple;
const model = buildModel({
 provider: 'zen-free',
 id: 'fixture',
 name: 'Fixture',
 api: 'zen-free-native',
 baseUrl: `http://127.0.0.1:${server.port}/v1`,
 reasoning: false,
 input: ['text'],
 ...baseSpec,
});
const reader = new ReadTool({
 cwd: root,
 hasUI: false,
 getSessionFile: () => join(root, 'session.jsonl'),
 getSessionSpawns: () => '*',
 getArtifactsDir: () => join(root, 'artifacts'),
 settings: Settings.isolated(),
});
afterAll(async () => {
 server.stop(true);
 await rm(root, { recursive: true, force: true });
});

for (const [name, path, expected, excluded] of [
 ['raw exact text', file + ':raw:3-4', ['THIRD\nFOURTH'], ['SECOND', 'FIFTH']],
 ['native context and editable anchors', file + ':3-4', ['SECOND', 'THIRD', 'FOURTH', 'SEVENTH'], ['FIRST']],
] as const) {
 test('read-only context executes ' + name, async () => {
  requestedPath = path;
  const result = await stream(model, {
   messages: [{ role: 'user', content: 'Read the fixture', timestamp: 1 }],
   tools: [reader],
  }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
  expect(result.stopReason).toBe('toolUse');
  const call = result.content.find(part => part.type === 'toolCall');
  if (!call || call.type !== 'toolCall' || typeof call.arguments.path !== 'string') throw new Error('Expected native read call');
  expect(call.name).toBe('read');
  const output = await reader.execute(call.id, { path: call.arguments.path });
  const text = output.content.filter(part => part.type === 'text').map(part => part.text).join('\n');
  for (const content of expected) expect(text).toContain(content);
  for (const content of excluded) expect(text).not.toContain(content);
 });
}

test('directory pagination preserves native rendered-line selection and continuation', async () => {
 const full = await reader.execute('full-listing', { path: directory });
 const lines = full.content.filter(part => part.type === 'text').map(part => part.text).join('\n').split('\n');
 requestedPath = directory + ':3-3';
 const result = await stream(model, {
  messages: [{ role: 'user', content: 'Read the directory page', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
 const call = result.content.find(part => part.type === 'toolCall');
 if (!call || call.type !== 'toolCall' || typeof call.arguments.path !== 'string') throw new Error('Expected native directory read');
 const page = await reader.execute(call.id, { path: call.arguments.path });
 const text = page.content.filter(part => part.type === 'text').map(part => part.text).join('\n');
 expect(text.split('\n')[0]).toBe(lines[2]);
 const next = await reader.execute('next-page', { path: directory + ':4-4' });
 expect(next.content.filter(part => part.type === 'text').map(part => part.text).join('\n').split('\n')[0]).toBe(lines[3]);
});

for (const id of ['fixture', 'fixture-responses']) {
 const target = buildModel({ ...model, id });
 for (const tools of [undefined, []]) {
  test(id + ' returns text with ' + (tools ? 'empty' : 'omitted') + ' executable tools', async () => {
   responseMode = 'text';
   const result = await stream(target, {
    messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
    tools,
   }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
   expect(result.stopReason).toBe('stop');
   expect(result.content.filter(part => part.type === 'text').map(part => part.text).join('')).toBe('TEXT_ONLY_OK');
   const names = declaredTools(lastPayload!, id === 'fixture-responses').map(tool => tool.name);
   expect(names).toEqual(['read', 'shell']);
  });
 }
 test(id + ' honors explicit tool-choice none without sending none', async () => {
  responseMode = 'text';
  const result = await stream(target, {
   messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
   tools: [reader],
  }, { apiKey: 'public', toolChoice: 'none', signal: AbortSignal.timeout(5000) }).result();
  expect(result.stopReason).toBe('stop');
  expect(result.content.filter(part => part.type === 'text').map(part => part.text).join('')).toBe('TEXT_ONLY_OK');
  expect(lastPayload?.tool_choice).toBe(id === 'fixture-responses' ? 'auto' : undefined);
 });
 for (const tools of [[], [{ name: 'lookup', description: 'A permitted lookup', parameters: reader.parameters }], [reader]]) {
  test(id + ' blocks a disallowed read before exposing tool events (' + tools.map(tool => tool.name).join(',') + ')', async () => {
   responseMode = 'call';
   const events = stream(target, {
    messages: [{ role: 'user', content: 'Request a read', timestamp: 1 }],
    tools,
   }, { apiKey: 'public', ...(tools[0]?.name === 'read' ? { toolChoice: 'none' as const } : {}), signal: AbortSignal.timeout(5000) });
   const observed: string[] = [];
   const consume = (async () => {
    for await (const event of events) observed.push(event.type);
   })();
   await expect(consume).rejects.toBeInstanceOf(Error);
   expect(observed.some(type => type.startsWith('toolcall_') || type === 'done')).toBe(false);
  });
 }
}

// The free-tier gateway answers 429 FreeUsageLimitError unless the system prompt carries
// OpenCode's environment block, so every request must append one.
test('appends the full OpenCode environment block to the system prompt', async () => {
 responseMode = 'text';
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
 const system = lastPayload?.messages?.filter(message => message.role === 'system').map(message => String(message.content)).join('\n') ?? '';
 expect(system).toContain(`Today's date: ${new Date().toDateString()}`);
 expect(system).toContain('<env>');
 expect(system).toContain('Working directory: ');
 expect(system).toContain('Workspace root folder: ');
 expect(system).toContain('Is directory a git repo: ');
 expect(system).toContain(`Platform: ${process.platform}`);
 expect(system).toContain('Prefer ');
 expect(system).toContain('over generic system temporary directories such as /tmp');
 expect(system).toContain('</env>');
});

test('declares the official read and shell gate byte-identically', async () => {
 responseMode = 'text';
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [{ name: 'lookup', description: 'A permitted lookup', parameters: reader.parameters }],
 }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
 const tools = declaredTools(lastPayload!, false);
 expect(tools.map(tool => tool.name)).toEqual(['lookup', 'read', 'shell']);
 for (const gate of ['read', 'shell'] as const) {
  const declared = tools.find(tool => tool.name === gate);
  const expected = OFFICIAL_GATE_TOOL_DEFINITIONS[gate];
  expect(declared?.description).toBe(expected.description);
  expect(JSON.stringify(declared?.parameters)).toBe(JSON.stringify(expected.parameters));
 }
 const system = lastPayload?.messages?.filter(message => message.role === 'system').map(message => String(message.content)).join('\n') ?? '';
 expect(system).toContain('Only these tools are enabled: lookup');
 expect(system).toContain('protocol metadata only');
});

test('aliases a caller read and keeps exactly one official read declaration', async () => {
 responseMode = 'text';
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
 const tools = declaredTools(lastPayload!, false);
 expect(tools.map(tool => tool.name)).toEqual(['read_client', 'read', 'shell']);
 const official = tools.find(tool => tool.name === 'read');
 expect(official?.description).toBe(OFFICIAL_GATE_TOOL_DEFINITIONS.read.description);
 const caller = tools.find(tool => tool.name === 'read_client');
 expect(caller?.description).toBe(reader.description);
});

test('does not duplicate official caller-provided gate tools', async () => {
 responseMode = 'text';
 const official = (['read', 'shell'] as const).map(name => ({
  name,
  description: OFFICIAL_GATE_TOOL_DEFINITIONS[name].description,
  parameters: OFFICIAL_GATE_TOOL_DEFINITIONS[name].parameters,
 })) as Tool[];
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: official,
 }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
 const tools = declaredTools(lastPayload!, false);
 expect(tools.map(tool => tool.name)).toEqual(['read', 'shell']);
});

test('maps a forced caller tool choice to its wire alias', async () => {
 responseMode = 'text';
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, {
  apiKey: 'public',
  toolChoice: { type: 'tool', name: 'read' },
  signal: AbortSignal.timeout(5000),
 }).result();
 const choice = lastPayload?.tool_choice as { function?: { name?: string } } | undefined;
 expect(choice?.function?.name).toBe('read_client');
});

test('replays renamed tool calls and results under the wire name', () => {
 const map = buildWireTools([reader as unknown as Tool]);
 const assistant = {
  role: 'assistant',
  content: [{ type: 'toolCall', id: 'call_1', name: 'read', arguments: { path: file } }],
  timestamp: 1,
 } as unknown as Message;
 const result: Message = {
  role: 'toolResult',
  toolCallId: 'call_1',
  toolName: 'read',
  content: [{ type: 'text', text: 'ok' }],
  isError: false,
  timestamp: 2,
 };
 const wire = toWireMessages([assistant, result], map);
 const wireAssistant = wire[0];
 if (wireAssistant.role !== 'assistant' || wireAssistant.content[0]?.type !== 'toolCall') throw new Error('Expected assistant tool call');
 expect(wireAssistant.content[0].name).toBe('read_client');
 const wireResult = wire[1];
 if (wireResult.role !== 'toolResult') throw new Error('Expected tool result');
 expect(wireResult.toolName).toBe('read_client');
 expect(toWireToolChoice({ type: 'tool', name: 'read' }, map)).toEqual({ type: 'tool', name: 'read_client' });
});

test('maps new_context to fresh_context in tools, history, and tool choice', () => {
 const contextTool = { ...reader, name: 'new_context' } as unknown as Tool;
 const map = buildWireTools([contextTool]);
 expect(map.tools.map(tool => tool.name)).toEqual(['fresh_context', 'read', 'shell']);
 expect(map.toNative.get('fresh_context')).toBe('new_context');
 const assistant = {
  role: 'assistant',
  content: [{ type: 'toolCall', id: 'call_ctx', name: 'new_context', arguments: {} }],
  timestamp: 1,
 } as unknown as Message;
 const wire = toWireMessages([assistant], map);
 if (wire[0]?.role !== 'assistant' || wire[0].content[0]?.type !== 'toolCall') throw new Error('Expected context tool call');
 expect(wire[0].content[0].name).toBe('fresh_context');
 expect(toWireToolChoice({ type: 'tool', name: 'new_context' }, map)).toEqual({ type: 'tool', name: 'fresh_context' });
});

test('never sends the forbidden new_context name on the wire', async () => {
 responseMode = 'text';
 const contextTool = { ...reader, name: 'new_context' } as unknown as Tool;
 const result = await stream(model, {
  messages: [{ role: 'user', content: 'Do not call a tool', timestamp: 1 }],
  tools: [contextTool],
 }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
 expect(result.stopReason).toBe('stop');
 const names = declaredTools(lastPayload!, false).map(tool => tool.name);
 expect(names).toContain('fresh_context');
 expect(names).not.toContain('new_context');
});

test('clamps max_tokens below the context window', async () => {
 responseMode = 'text';
 const wide = buildModel({
  ...model,
  contextWindow: 10000,
  maxTokens: 20000,
  compat: { maxTokensField: 'max_tokens', supportsStrictMode: false },
 } as Parameters<typeof buildModel>[0]);
 const result = await stream(wide, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [],
 }, { apiKey: 'public', maxTokens: 20000, signal: AbortSignal.timeout(5000) }).result();
 expect(result.stopReason).toBe('stop');
 expect(lastPayload?.max_tokens).toBe(8976);
 expect(clampMaxTokens(20000, 10000)).toBe(8976);
 expect(clampMaxTokens(500, 10000)).toBe(500);
 expect(clampMaxTokens(undefined, 10000)).toBeUndefined();
});

test('merges OMP opencode-zen reasoning replay policy for Big Pickle', async () => {
 responseMode = 'text';
 expect(ZEN_REASONING_COMPAT['big-pickle']?.requiresReasoningContentForToolCalls).toBe(true);
 expect(ZEN_REASONING_COMPAT['big-pickle']?.allowsSyntheticReasoningContentForToolCalls).toBe(false);
 const bigPickle = buildModel({
  provider: 'zen-free',
  id: 'big-pickle',
  name: 'Big Pickle',
  api: 'zen-free-native',
  baseUrl: `http://127.0.0.1:${server.port}/v1`,
  reasoning: true,
  input: ['text'],
  ...baseSpec,
  contextWindow: 200000,
  maxTokens: 32000,
  thinking: { mode: 'effort', efforts: [Effort.High, Effort.Max] },
  compat: { reasoningContentField: 'reasoning_content' },
 } as Parameters<typeof buildModel>[0]);
 await stream(bigPickle, {
  messages: [
   { role: 'user', content: 'Use the lookup tool', timestamp: 1 },
   {
    role: 'assistant',
    content: [{ type: 'toolCall', id: 'call_lookup', name: 'lookup', arguments: {} }],
    timestamp: 2,
   } as unknown as Message,
   { role: 'toolResult', toolCallId: 'call_lookup', toolName: 'lookup', content: [{ type: 'text', text: 'ok' }], isError: false, timestamp: 3 },
   { role: 'user', content: 'Continue', timestamp: 4 },
  ],
  tools: [{ name: 'lookup', description: 'A permitted lookup', parameters: reader.parameters }],
 }, { apiKey: 'public', reasoning: Effort.High, signal: AbortSignal.timeout(5000) }).result();
 const assistant = lastPayload?.messages?.find(message => message.role === 'assistant' && Array.isArray(message.tool_calls));
 expect(assistant?.reasoning_content).toBe('');
});

test('strips x-opencode-request whatever its header case', async () => {
 responseMode = 'text';
 const tagged = buildModel({ ...model, headers: { 'X-OpenCode-Request': '1', 'x-opencode-request': '1', 'User-Agent': 'custom/1' } });
 await stream(tagged, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', signal: AbortSignal.timeout(5000) }).result();
 expect(lastHeaders?.get('x-opencode-request')).toBeNull();
 expect(lastHeaders?.get('user-agent')).toBe('custom/1');
 expect(lastHeaders?.get('accept')).toBe('text/event-stream');
 expect(lastHeaders?.get('traceparent')).toBeNull();
 expect(lastHeaders?.get('b3')).toBeNull();
 expect(lastHeaders?.get('x-opencode-project')).toMatch(/^[0-9a-f]{40}$/);
});

test('reports the nearest git root in the environment block', async () => {
 responseMode = 'text';
 const repo = join(root, 'repo');
 const nested = join(repo, 'src', 'deep');
 await mkdir(nested, { recursive: true });
 await mkdir(join(repo, '.git'), { recursive: true });
 expect(findGitRoot(nested)).toBe(repo);
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', cwd: nested, signal: AbortSignal.timeout(5000) }).result();
 const system = lastPayload?.messages?.filter(message => message.role === 'system').map(message => String(message.content)).join('\n') ?? '';
 expect(system).toContain(`Working directory: ${nested}`);
 expect(system).toContain(`Workspace root folder: ${repo}`);
 expect(system).toContain('Is directory a git repo: yes');
});

test('derives the project id from a git remote and uses it on the wire', async () => {
 responseMode = 'text';
 const repo = join(root, 'remote-repo');
 const nested = join(repo, 'src', 'deep');
 await mkdir(nested, { recursive: true });
 execFileSync('git', ['init', '-q', repo]);
 execFileSync('git', ['-C', repo, 'remote', 'add', 'origin', 'git@github.com:Example/Repo.git']);
 expect(normalizeGitRemote('git@github.com:Example/Repo.git')).toBe('github.com/Example/Repo');
 expect(normalizeGitRemote('https://github.com/Example/Repo.git')).toBe('github.com/Example/Repo');
 expect(normalizeGitRemote('file:///tmp/repo')).toBeUndefined();
 const expected = createHash('sha1').update('git-remote:github.com/Example/Repo').digest('hex');
 expect(resolveProjectId(nested)).toBe(expected);
 expect(resolveProjectId(root)).toBe(createHash('sha1').update(`directory:${root}`).digest('hex'));
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', cwd: nested, signal: AbortSignal.timeout(5000) }).result();
 expect(lastHeaders?.get('x-opencode-project')).toBe(expected);
});

test('sends parent session headers and keeps the child session id separate', async () => {
 responseMode = 'text';
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', sessionId: 'child', parentSessionId: 'parent', signal: AbortSignal.timeout(5000) }).result();
 const child = lastHeaders?.get('x-opencode-session-id');
 const affinity = lastHeaders?.get('x-opencode-session');
 expect(child).toMatch(/^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/);
 expect(affinity).toMatch(/^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/);
 expect(child).not.toBe(affinity);
 expect(lastHeaders?.get('x-session-affinity')).toBe(affinity);
 expect(lastHeaders?.get('X-Session-Id')).toBe(affinity);
 expect(lastHeaders?.get('x-opencode-parent-session-id')).toBe(affinity);
 expect(lastHeaders?.get('x-parent-session-id')).toBe(affinity);
});

test('uses one session id for a top-level request', async () => {
 responseMode = 'text';
 await stream(model, {
  messages: [{ role: 'user', content: 'Answer without tools', timestamp: 1 }],
  tools: [reader],
 }, { apiKey: 'public', sessionId: 'solo', signal: AbortSignal.timeout(5000) }).result();
 const session = lastHeaders?.get('x-opencode-session-id');
 expect(session).toMatch(/^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/);
 expect(lastHeaders?.get('x-opencode-session')).toBe(session);
 expect(lastHeaders?.get('x-session-affinity')).toBe(session);
 expect(lastHeaders?.get('X-Session-Id')).toBe(session);
 expect(lastHeaders?.get('x-opencode-parent-session-id')).toBeNull();
});

test('aborts a stream that stops emitting events', async () => {
 hangMode = true;
 process.env.ZEN_FREE_IDLE_TIMEOUT_MS = '60';
 try {
  const startedAt = Date.now();
  // The outer deadline is far beyond the watchdog, so only the watchdog can end this.
  const result = await stream(model, {
   messages: [{ role: 'user', content: 'Wait forever', timestamp: 1 }],
   tools: [reader],
  }, { apiKey: 'public', signal: AbortSignal.timeout(30000) }).result();
  expect(result.stopReason).toBe('aborted');
  expect(Date.now() - startedAt).toBeLessThan(2000);
 } finally {
  hangMode = false;
  delete process.env.ZEN_FREE_IDLE_TIMEOUT_MS;
 }
});

test('bounds the session cache and keeps the most recent entry', () => {
 const cache = new Map<string, string>();
 for (let index = 0; index < 300; index += 1) rememberSession(cache, `k${index}`, `v${index}`);
 expect(cache.size).toBe(256);
 expect(cache.has('k0')).toBe(false);
 expect(cache.get('k299')).toBe('v299');
 rememberSession(cache, 'k100', 'fresh');
 expect([...cache.keys()].at(-1)).toBe('k100');
});

test('session suffixes match the OpenCode id shape', () => {
 expect(sessionSuffix(14)).toMatch(/^[0-9A-Za-z]{14}$/);
});

test('environment block includes the free-lane date and temp hints', () => {
 const block = environmentBlock(root);
 expect(block).toContain(`Today's date: ${new Date().toDateString()}`);
 expect(block).toContain('Prefer ');
 expect(block).toContain('over generic system temporary directories such as /tmp');
});

// A long-running session must keep one id even while subagents churn through the cache.
test('keeps an active session id under cache pressure', () => {
 const cache = new Map<string, string>();
 const active = sessionFor(cache, 'active');
 for (let index = 0; index < 400; index += 1) {
  sessionFor(cache, `subagent-${index}`);
  expect(sessionFor(cache, 'active')).toBe(active);
 }
 expect(cache.size).toBeLessThanOrEqual(256);
 expect(active).toMatch(/^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/);
});