import { afterEach, beforeEach, describe, expect, test } from 'bun:test';
import { mkdtemp, readdir, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { type as schema } from '@oh-my-pi/omptype';
import { registerCustomApi, unregisterCustomApis } from '@oh-my-pi/pi-ai/api-registry';
import { __providerInFlightForTesting, streamSimple } from '@oh-my-pi/pi-ai/stream';
import type { Api, Context, FetchImpl, Model, SimpleStreamOptions, ToolChoice } from '@oh-my-pi/pi-ai/types';
import { buildModel } from '@oh-my-pi/pi-catalog/build';

import { streamZenNative } from './transport';

const sourceId = 'zen-free-transport-regression';
const providerId = sourceId;
const customApi = `${sourceId}-api`;
const apis = ['openai-completions', 'openai-responses'] as const;
type NativeApi = (typeof apis)[number];
const encoder = new TextEncoder();
const context: Context = {
  systemPrompt: [],
  messages: [{ role: 'user', content: 'reply', timestamp: 0 }],
  tools: [
    { name: 'read', description: 'Native read fixture', parameters: schema({ path: 'string' }) },
    { name: 'bash', description: 'Native bash fixture', parameters: schema({ command: 'string' }) },
  ],
};

function model(api: NativeApi): Model<NativeApi> {
  return buildModel({
    id: 'zen-local-fixture', name: 'Zen local fixture', provider: providerId, api,
    baseUrl: 'https://api.openai.com/v1', reasoning: true,
    thinking: { mode: 'effort', efforts: ['low', 'high'], effortMap: { max: 'high' } },
    input: ['text'], contextWindow: 8192, maxTokens: 128,
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    compat: { supportsReasoningEffort: true, supportsSamplingParams: true },
  });
}

function completionChunk(choices: unknown[], usage?: object): Uint8Array {
  return encoder.encode(`data: ${JSON.stringify({ id: 'local', object: 'chat.completion.chunk', choices, usage })}\n\n`);
}

function completionBody(text = 'reply'): Uint8Array[] {
  return [
    completionChunk([{ index: 0, delta: { content: text } }]),
    completionChunk([{ index: 0, delta: {}, finish_reason: 'stop' }]),
    completionChunk([], { prompt_tokens: 11, completion_tokens: 3, total_tokens: 14 }),
  ];
}

function response(api: NativeApi, text = 'reply'): Response {
  if (api === 'openai-completions') {
    return new Response(new Blob([...completionBody(text), encoder.encode('data: [DONE]\n\n')]), {
      headers: { 'content-type': 'text/event-stream' },
    });
  }
  const events = [
    { type: 'response.output_item.added', item: { type: 'message', id: 'msg_1', role: 'assistant', status: 'in_progress', content: [] } },
    { type: 'response.content_part.added', part: { type: 'output_text', text: '' } },
    { type: 'response.output_text.delta', delta: text },
    { type: 'response.output_item.done', item: { type: 'message', id: 'msg_1', role: 'assistant', status: 'completed', content: [{ type: 'output_text', text }] } },
    { type: 'response.completed', response: { status: 'completed', usage: { input_tokens: 11, output_tokens: 3, total_tokens: 14, input_tokens_details: { cached_tokens: 0 } } } },
  ];
  return new Response(events.map(event => `data: ${JSON.stringify(event)}\n\n`).join(''), {
    headers: { 'content-type': 'text/event-stream' },
  });
}

function registerAdapter(native: Model<NativeApi>): Model<Api> {
  registerCustomApi(customApi, (_model, ctx, options = {}) => streamZenNative(native, ctx, options), sourceId);
  return { ...native, api: customApi };
}

function options(signal: AbortSignal, fetch: FetchImpl): SimpleStreamOptions {
  return { apiKey: 'public', signal, fetch, sessionId: 'local-session', maxInFlightRequests: { [providerId]: 1 } };
}

let root: string;
let controller: AbortController;
let clearDeadline: () => void;
beforeEach(async () => {
  root = await mkdtemp(join(tmpdir(), 'zen-free-transport-'));
  __providerInFlightForTesting.setRoot(root);
  controller = new AbortController();
  // Real filesystem leases and stream watchdogs use platform timers; this is only a failure deadline, not a timing assertion.
  const deadline = setTimeout(() => controller.abort(new Error('deterministic transport test deadline')), 1000);
  clearDeadline = () => clearTimeout(deadline);
});
afterEach(async () => {
  clearDeadline();
  controller.abort();
  unregisterCustomApis(sourceId);
  __providerInFlightForTesting.setWaitObserver(undefined);
  __providerInFlightForTesting.setRoot(undefined);
  await rm(root, { recursive: true, force: true });
});

async function remainingLeases(): Promise<number> {
  const entries = await readdir(__providerInFlightForTesting.providerDir(providerId), { withFileTypes: true });
  return entries.filter(entry => entry.isDirectory()).length;
}

for (const api of apis) {
  describe(api, () => {
    test('acquires one outer provider permit and preserves usage', async () => {
      const custom = registerAdapter(model(api));
      let requests = 0;
      const result = await streamSimple(custom, context, options(controller.signal, async () => {
        requests++;
        return response(api);
      })).result();
      expect(result.stopReason).toBe('stop');
      expect(result.content.some(part => part.type === 'text' && part.text === 'reply')).toBe(true);
      expect(result.usage).toMatchObject({ input: 11, output: 3, totalTokens: 14 });
      expect(requests).toBe(1);
      expect(await remainingLeases()).toBe(0);
    });

    test('releases the provider permit after a caller abort', async () => {
      const custom = registerAdapter(model(api));
      const started = Promise.withResolvers<void>();
      const cancelled = new AbortController();
      const pending = streamSimple(custom, context, options(AbortSignal.any([controller.signal, cancelled.signal]), async (_url, init) => {
        started.resolve();
        const interrupted = Promise.withResolvers<Response>();
        const signal = init?.signal;
        signal?.addEventListener('abort', () => interrupted.reject(signal.reason), { once: true });
        return interrupted.promise;
      })).result();
      await Promise.race([started.promise, pending]);
      cancelled.abort(new Error('cancel the active transport'));
      const result = await pending;
      expect(result.stopReason).toBe('aborted');
      const next = await streamSimple(custom, context, options(controller.signal, async () => response(api))).result();
      expect(next.stopReason).toBe('stop');
      expect(await remainingLeases()).toBe(0);
    });

    test('preserves a provider error and releases the permit for the next request', async () => {
      const custom = registerAdapter(model(api));
      const denied = await streamSimple(custom, context, options(controller.signal, async () =>
        new Response(JSON.stringify({ error: { message: 'local forbidden fixture' } }), {
          status: 403, headers: { 'content-type': 'application/json' },
        }),
      )).result();
      expect(denied.stopReason).toBe('error');
      expect(denied.errorMessage).toContain('local forbidden fixture');
      const next = await streamSimple(custom, context, options(controller.signal, async () => response(api))).result();
      expect(next.stopReason).toBe('stop');
      expect(await remainingLeases()).toBe(0);
    });

    test('matches generic reasoning, forced tool choice, cache and sampling payloads', async () => {
      const native = model(api);
      const payloads: unknown[] = [];
      const headers: Headers[] = [];
      const fetch: FetchImpl = async (_url, init) => {
        headers.push(new Headers(init?.headers));
        return response(api);
      };
      const simple: SimpleStreamOptions = {
        apiKey: 'public', signal: controller.signal, fetch, sessionId: 'parity-session',
        headers: { 'X-Zen-Fixture': 'preserved' }, promptCacheKey: 'parity-cache', cacheRetention: 'long',
        reasoning: 'max', toolChoice: { type: 'tool', name: 'read' }, hideThinkingSummary: true,
        maxTokens: 17, temperature: 0.2, topP: 0.8, serviceTier: 'default',
        statefulResponses: false, storeResponses: false, textVerbosity: 'low',
        onPayload(payload) { payloads.push(payload); },
      };
      await streamSimple(native, context, simple).result();
      await streamZenNative(native, context, simple).result();
      expect(payloads).toHaveLength(2);
      expect(payloads[1]).toEqual(payloads[0]);
      expect(headers.map(value => value.get('x-zen-fixture'))).toEqual(['preserved', 'preserved']);
      expect(payloads[1]).toMatchObject(api === 'openai-completions'
        ? { reasoning_effort: 'high', tool_choice: { type: 'function', function: { name: 'read' } } }
        : { reasoning: { effort: 'high' }, tool_choice: { type: 'function', name: 'read' } });
    });

    for (const choice of ['any', { type: 'function', name: 'bash' }, { type: 'computer' }] satisfies ToolChoice[]) {
      test(`matches generic tool-choice conversion for ${JSON.stringify(choice)}`, async () => {
        const native = model(api);
        const payloads: unknown[] = [];
        const simple: SimpleStreamOptions = {
          apiKey: 'public', signal: controller.signal, sessionId: 'tool-parity', toolChoice: choice,
          fetch: async () => response(api), onPayload(payload) { payloads.push(payload); },
        };
        await streamSimple(native, context, simple).result();
        await streamZenNative(native, context, simple).result();
        expect(payloads).toHaveLength(2);
        expect(payloads[1]).toEqual(payloads[0]);
      });
    }

    test('matches generic force-off and mandatory-reasoning policy', async () => {
      for (const mandatory of [false, true]) {
        const native = model(api);
        native.thinking = { mode: 'effort', efforts: ['low', 'high'], requiresEffort: mandatory };
        const payloads: unknown[] = [];
        const simple: SimpleStreamOptions = {
          apiKey: 'public', signal: controller.signal, sessionId: 'disable-parity', reasoning: 'high', forceReasoningOff: true,
          fetch: async () => response(api), onPayload(payload) { payloads.push(payload); },
        };
        await streamSimple(native, context, simple).result();
        await streamZenNative(native, context, simple).result();
        expect(payloads).toHaveLength(2);
        expect(payloads[1]).toEqual(payloads[0]);
      }
    });
  });
}

test('holds the outer permit through the completions trailing terminal drain', async () => {
  const custom = registerAdapter(model('openai-completions'));
  const usageSeen = Promise.withResolvers<void>();
  const releaseDone = Promise.withResolvers<void>();
  const secondQueued = Promise.withResolvers<void>();
  let requests = 0;
  let doneSent = false;
  let overlapped = false;
  const fetch: FetchImpl = async () => {
    requests++;
    if (requests > 1) {
      overlapped = !doneSent;
      return response('openai-completions', 'second');
    }
    return new Response(new ReadableStream<Uint8Array>({ async start(sink) {
      for (const chunk of completionBody('first')) sink.enqueue(chunk);
      await releaseDone.promise;
      doneSent = true;
      sink.enqueue(encoder.encode('data: [DONE]\n\n'));
      sink.close();
    } }), { headers: { 'content-type': 'text/event-stream' } });
  };
  const simple = { ...options(controller.signal, fetch), onSseEvent(event: { data: string }) {
    if (event.data.includes('"choices":[]')) usageSeen.resolve();
  } };
  const first = streamSimple(custom, context, simple).result();
  try {
    await Promise.race([usageSeen.promise, first]);
    __providerInFlightForTesting.setWaitObserver(() => secondQueued.resolve());
    const second = streamSimple(custom, context, simple).result();
    await Promise.race([secondQueued.promise, second]);
    expect(requests).toBe(1);
    releaseDone.resolve();
    const results = await Promise.all([first, second]);
    expect(results.map(message => message.stopReason)).toEqual(['stop', 'stop']);
    expect(requests).toBe(2);
    expect(overlapped).toBe(false);
    expect(await remainingLeases()).toBe(0);
  } finally {
    releaseDone.resolve();
    await first.catch(() => {});
  }
});

test('cancels a queued request without dispatching a second transport', async () => {
  const custom = registerAdapter(model('openai-completions'));
  const started = Promise.withResolvers<void>();
  const release = Promise.withResolvers<Response>();
  const queued = Promise.withResolvers<void>();
  const cancelled = new AbortController();
  let requests = 0;
  const first = streamSimple(custom, context, options(controller.signal, async () => {
    requests++;
    started.resolve();
    return release.promise;
  })).result();
  try {
    await Promise.race([started.promise, first]);
    __providerInFlightForTesting.setWaitObserver(() => queued.resolve());
    const second = streamSimple(custom, context, options(AbortSignal.any([controller.signal, cancelled.signal]), async () => {
      requests++;
      return response('openai-completions');
    })).result();
    await Promise.race([queued.promise, second]);
    cancelled.abort(new Error('cancel queued transport'));
    await expect(second).rejects.toThrow('cancel queued transport');
    expect(requests).toBe(1);
    release.resolve(response('openai-completions'));
    expect((await first).stopReason).toBe('stop');
    expect(await remainingLeases()).toBe(0);
  } finally {
    release.resolve(response('openai-completions'));
    await first.catch(() => {});
  }
});

test('requires credential resolution to remain in the public provider dispatcher', () => {
  expect(() => streamZenNative(model('openai-completions'), context, { apiKey: async () => 'public' }))
    .toThrow('API key resolved by the provider dispatcher');
});

test('rejects unrecognized native APIs instead of selecting a different transport', () => {
  const unsupported: Model<Api> = { ...model('openai-completions'), api: 'zen-unsupported-test-api' };
  expect(() => streamZenNative(unsupported, context, { apiKey: 'public' })).toThrow('Unsupported Zen native API');
});
