import { streamOpenAICompletions } from '@oh-my-pi/pi-ai/providers/openai-completions';
import { streamOpenAIResponses } from '@oh-my-pi/pi-ai/providers/openai-responses';
import type { OpenAICompletionsOptions } from '@oh-my-pi/pi-ai/providers/openai-completions';
import type { OpenAIResponsesOptions } from '@oh-my-pi/pi-ai/providers/openai-responses';
import type { Api, AssistantMessageEventStream, Context, Model, SimpleStreamOptions, ToolChoice } from '@oh-my-pi/pi-ai/types';
import type { Effort } from '@oh-my-pi/pi-catalog/effort';
import { defaultSupportedEffort, requireSupportedEffort } from '@oh-my-pi/pi-catalog/model-thinking';

function openAiToolChoice(choice?: ToolChoice): ToolChoice | undefined {
  if (typeof choice === 'string') return choice === 'any' ? 'required' : choice;
  if (choice?.type === 'tool') return choice.name ? { type: 'function', function: { name: choice.name } } : undefined;
  if (choice?.type === 'function') {
    const name = 'function' in choice ? choice.function.name : choice.name;
    return name ? { type: 'function', function: { name } } : undefined;
  }
  return undefined;
}

/**
 * Keep the requested output budget inside the model's context window. The
 * OpenAI-compatible wire has no separate "input budget"; leaving a small reserve
 * avoids sending `max_tokens` that leaves no room for the prompt at all.
 */
export function clampMaxTokens(maxTokens: number | undefined, contextWindow: number | null | undefined): number | undefined {
  if (maxTokens === undefined) return undefined;
  if (!contextWindow || !Number.isFinite(contextWindow) || contextWindow <= 0) return maxTokens;
  return Math.max(1, Math.min(maxTokens, contextWindow - 1024));
}

function openAiReasoning(model: Model<Api>, reasoning?: Effort): Effort | undefined {
  if (!reasoning || !model.reasoning || !model.thinking) return undefined;
  if (model.thinking.efforts.includes(reasoning)) return reasoning;
  const compat = model.compat;
  const effortMap = compat && 'reasoningEffortMap' in compat ? compat.reasoningEffortMap : undefined;
  const mapped = effortMap?.[reasoning];
  if (mapped) {
    for (const effort of model.thinking.efforts) if (effort === mapped) return effort;
  }
  if (effortMap?.[reasoning] !== undefined || model.thinking.effortMap?.[reasoning] !== undefined) return reasoning;
  return requireSupportedEffort(model, reasoning);
}

/** The caller supplies the original API and resolved compat via buildModel. */
export function streamZenNative(
  model: Model<Api>,
  context: Context,
  options: SimpleStreamOptions = {},
): AssistantMessageEventStream {
  // The public custom-provider dispatcher has already resolved credential callbacks.
  const apiKey = options.apiKey;
  if (apiKey !== undefined && typeof apiKey !== 'string') {
    throw new Error('Zen native transport requires the API key resolved by the provider dispatcher.');
  }

  // OMP 18.8 has no public per-API streamSimple helpers. Keep only the OpenAI
  // option translations from its generic dispatcher; spread all other options
  // through, including the outer permit's terminal-drain flag. Re-entering
  // streamSimple would acquire the same provider permit a second time.
  const nativeOptions: OpenAICompletionsOptions & OpenAIResponsesOptions = {
    ...options,
    apiKey,
    maxTokens: clampMaxTokens(options.maxTokens ?? model.maxTokens ?? undefined, model.contextWindow),
    maxTokensExplicit: options.maxTokens !== undefined,
    toolChoice: openAiToolChoice(options.toolChoice),
  };
  if (
    model.reasoning && model.thinking?.requiresEffort && !model.thinking.suppressWhenOff &&
    (options.reasoning === undefined || options.disableReasoning || options.forceReasoningOff)
  ) {
    const floor = defaultSupportedEffort(model);
    if (floor !== undefined) {
      nativeOptions.reasoning = floor;
      nativeOptions.disableReasoning = undefined;
      nativeOptions.forceReasoningOff = undefined;
    }
  }
  // `OpenAICompletionsOptions.reasoning` re-declares Effort's levels as plain strings;
  // the members are identical, so this only reconciles the two declarations.
  nativeOptions.reasoning = openAiReasoning(model, nativeOptions.reasoning as Effort | undefined);

  if (model.api === 'openai-completions') {
    nativeOptions.disableReasoning = nativeOptions.disableReasoning || nativeOptions.forceReasoningOff;
    // The API check above narrows the runtime model; Model<Api> is not a discriminated union.
    const nativeModel = model as Model<'openai-completions'>;
    return streamOpenAICompletions(nativeModel, context, nativeOptions);
  }
  if (model.api === 'openai-responses') {
    nativeOptions.reasoningSummary = options.hideThinkingSummary ? null : undefined;
    const nativeModel = model as Model<'openai-responses'>;
    return streamOpenAIResponses(nativeModel, context, nativeOptions);
  }
  throw new Error(`Unsupported Zen native API: ${model.api}`);
}