import type { Model, SimpleStreamOptions, StreamFunction } from "@earendil-works/pi-ai";
import {
  streamSimple as streamSimpleByApi,
  streamSimpleOpenAIResponses,
} from "@earendil-works/pi-ai/compat";
import {
  compactionLifecycle,
  type CompressionCapability as LifecycleCompressionCapability,
} from "./lifecycle.js";
import { loadConfig } from "./config.js";
import { fastPayloadHook } from "./fast-mode.js";
import { promoteSystemPromptToInstructions } from "./instructions.js";
import {
  compactResponseChain as compactManualResponseChain,
  type ManualCompactionOptionsInput,
  type ManualCompactionResult,
  type RequestAuth,
} from "./manual-compaction.js";

/** @deprecated Import CompressionCapability from ./lifecycle instead. */
export type CompressionCapability = LifecycleCompressionCapability;

export type { ManualCompactionResult } from "./manual-compaction.js";

/** @deprecated Use compactionLifecycle.isEligible() from ./lifecycle instead. */
export function isEnhanceableModel(model: unknown): model is Model<"openai-responses"> {
  return compactionLifecycle.isEligible(model);
}

/** @deprecated Use compactionLifecycle.capability() from ./lifecycle instead. */
export function compressionCapability(model: unknown): CompressionCapability {
  return compactionLifecycle.capability(model);
}

/** @deprecated Use compactionLifecycle.beforeLocalCompaction() from ./lifecycle instead. */
export function isCompressionActive(model: unknown): boolean {
  return compressionCapability(model) === "supported";
}

/** @deprecated Use compactionLifecycle.finishMessage() from ./lifecycle instead. */
export function recordAssistantResponse(message: unknown, model: unknown): void {
  compactionLifecycle.legacyRecordAssistantResponse(message, model);
}

/** @deprecated Use compactionLifecycle.restoreContext() from ./lifecycle instead. */
export function restoreAssistantResponse(model: unknown, messages: readonly unknown[]): void {
  compactionLifecycle.legacyRestoreAssistantResponse(model, messages);
}

/** @deprecated Use compactionLifecycle.clearContext() from ./lifecycle instead. */
export function clearContinuationState(): void {
  compactionLifecycle.legacyClearContinuationState();
}

/** @deprecated Use compactionLifecycle.finishMessage() from ./lifecycle instead. */
export async function waitForServerCompaction(model: unknown): Promise<boolean> {
  return compactionLifecycle.legacyWaitForServerCompaction(model);
}

/** @deprecated Use compactionLifecycle.beforeLocalCompaction() from ./lifecycle instead. */
export function consumeServerCompaction(model: unknown): boolean {
  return compactionLifecycle.legacyConsumeServerCompaction(model);
}

/** @deprecated Use intention-level lifecycle methods from ./lifecycle instead. */
export function hasServerResponseChain(model: unknown): boolean {
  return compactionLifecycle.legacyHasServerResponseChain(model);
}

/** @deprecated Use compactionLifecycle.refreshCapabilities() from ./lifecycle instead. */
export async function refreshCachedCapabilities(model: unknown): Promise<boolean> {
  return compactionLifecycle.refreshCapabilities(model);
}

/** @deprecated Use compactionLifecycle.reset() from ./lifecycle instead. */
export function resetRuntimeState(): void {
  compactionLifecycle.reset();
}

/** @deprecated Import compactResponseChain from ./manual-compaction instead. */
export async function compactResponseChain(
  model: Model<any>,
  auth: RequestAuth,
  options: ManualCompactionOptionsInput = {},
): Promise<ManualCompactionResult> {
  return compactManualResponseChain(model, auth, options);
}

function internalPayloadHook(model: Model<"openai-responses">): SimpleStreamOptions["onPayload"] {
  const config = loadConfig();
  const shouldPromote =
    config.enabled &&
    config.promoteSystemPromptToInstructions &&
    compactionLifecycle.isEligible(model);
  const applyFast = fastPayloadHook(model);
  if (!shouldPromote) return applyFast;

  return async (payload, requestModel) => {
    const promoted = promoteSystemPromptToInstructions(payload);
    if (!applyFast) return promoted;
    const fast = await applyFast(promoted, requestModel);
    return fast === undefined ? promoted : fast;
  };
}

/** Pi's standard OpenAI Responses stream with capability probing and fallback. */
export const streamGptEnhancedResponses: StreamFunction = (model, context, options) => {
  const typedModel = model as Model<"openai-responses">;
  const prepared = compactionLifecycle.prepareStream(
    typedModel,
    options as SimpleStreamOptions | undefined,
    internalPayloadHook(typedModel),
  );
  if (prepared.kind === "generic") {
    return streamSimpleByApi(model, context, prepared.options);
  }
  return streamSimpleOpenAIResponses(typedModel, context, prepared.options);
};
