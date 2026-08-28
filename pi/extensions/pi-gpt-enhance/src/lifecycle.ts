import type { FetchFunction, Model, SimpleStreamOptions } from "@earendil-works/pi-ai";
import type { PreviousResponseIdCapability } from "./capabilities.js";
import {
  cachedPreviousResponseIdCapability,
  cachedPreviousResponseIdCapabilitySync,
  cachedResponsesCapabilitySync,
  clearCachedCapabilities,
  recordPreviousResponseIdCapability,
  recordResponsesCapability,
} from "./capabilities.js";
import { loadConfig } from "./config.js";
import { isEligibleGptModelId } from "./model-eligibility.js";

export type CompressionCapability = "unknown" | "supported" | "unsupported";

type StatelessBoundary =
  | { kind: "id"; value: string }
  | { kind: "semantic"; value: string };

type StatelessCompactionState = {
  inputPrefix: unknown[];
  boundary: StatelessBoundary;
};

type RuntimeState = {
  capability: CompressionCapability;
  generation: number;
  capabilityGeneration: number;
  compactionInspections: Set<Promise<void>>;
  responseId?: string;
  previousResponseIdCapability?: PreviousResponseIdCapability;
  statelessCompaction?: StatelessCompactionState;
  statelessCheckpointPending?: boolean;
  serverCompactionPending?: boolean;
  serverCompactionNotificationPending?: boolean;
  serverCompactionSignature?: string;
};

type CompressionState = Pick<
  RuntimeState,
  | "capability"
  | "responseId"
  | "previousResponseIdCapability"
  | "statelessCompaction"
>;

export type PreparedStream =
  | { kind: "generic"; options: SimpleStreamOptions | undefined }
  | { kind: "enhanced"; options: SimpleStreamOptions };

export type StatelessCompactionCheckpoint = {
  version: 1;
  provider: string;
  api: string;
  modelId: string;
  baseUrl: string;
  inputPrefix: unknown[];
  boundary: StatelessBoundary;
};

export type FinishMessageOutcome =
  | { kind: "none" }
  | {
      kind: "server-compacted";
      provider: string;
      modelId: string;
      checkpoint?: StatelessCompactionCheckpoint;
    };

export type BeforeLocalCompactionOutcome =
  | { kind: "pass-through" }
  | { kind: "write-server-marker" }
  | { kind: "cancel-local"; notifyActive: boolean; provider: string; modelId: string };

const manualCompactionTokenBrand = Symbol("manualCompactionToken");

export type ManualCompactionToken = {
  readonly [manualCompactionTokenBrand]: true;
};

export type ManualCompactionPlan =
  | { kind: "previous-response"; responseId: string; token: ManualCompactionToken }
  | { kind: "input"; input: unknown; token: ManualCompactionToken };

type ManualCompactionTokenState = {
  key: string;
  state: RuntimeState;
  generation: number;
  capabilityGeneration: number;
};

type StreamCompactionTokenState = ManualCompactionTokenState;
type PayloadHook = NonNullable<SimpleStreamOptions["onPayload"]>;
type RetryPayloads = {
  uncompressed: Record<string, unknown>;
  withoutContinuation: Record<string, unknown>;
  requestModel: Model<any>;
};

const CONTINUATION_RESET_STATUSES = new Set([400, 404, 409, 422]);
const TRANSIENT_ASSISTANT_ERROR_PATTERNS = [
  /\bterminated\b/i,
  /\boverloaded\b/i,
  /\b(?:temporarily|service) unavailable\b/i,
  /\bstream ended without finish_reason\b/i,
  /\bstream[_ ]read[_ ]error\b/i,
  /\b(?:502|503|504)\b/i,
  /\b(?:connection|network|fetch|request).*(?:reset|closed|lost|timeout)\b/i,
];

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function modelKey(model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">): string {
  return JSON.stringify([model.provider, model.api, model.id, model.baseUrl]);
}

function checkpointFor(
  model: Model<any>,
  compacted: StatelessCompactionState,
): StatelessCompactionCheckpoint {
  return {
    version: 1,
    provider: model.provider,
    api: model.api,
    modelId: model.id,
    baseUrl: model.baseUrl,
    inputPrefix: structuredClone(compacted.inputPrefix),
    boundary: compacted.boundary,
  };
}

function stateFromCheckpoint(
  model: Model<any>,
  value: unknown,
): StatelessCompactionState | undefined {
  if (
    !isRecord(value) ||
    value.version !== 1 ||
    value.provider !== model.provider ||
    value.api !== model.api ||
    value.modelId !== model.id ||
    value.baseUrl !== model.baseUrl ||
    !Array.isArray(value.inputPrefix) ||
    !isRecord(value.boundary) ||
    (value.boundary.kind !== "id" && value.boundary.kind !== "semantic") ||
    typeof value.boundary.value !== "string" ||
    !value.boundary.value
  ) {
    return undefined;
  }
  return {
    inputPrefix: structuredClone(value.inputPrefix),
    boundary: { kind: value.boundary.kind, value: value.boundary.value },
  };
}

function isTransientAssistantError(message: Record<string, unknown>): boolean {
  const errorMessage = message.errorMessage;
  if (message.stopReason !== "error" || typeof errorMessage !== "string") return false;
  return TRANSIENT_ASSISTANT_ERROR_PATTERNS.some((pattern) => pattern.test(errorMessage));
}

function findServerCompactionItem(value: unknown): Record<string, unknown> | undefined {
  if (Array.isArray(value)) {
    for (let index = value.length - 1; index >= 0; index--) {
      const found = findServerCompactionItem(value[index]);
      if (found) return found;
    }
    return undefined;
  }
  if (!isRecord(value)) return undefined;
  if (value.type === "compaction" || value.type === "compaction_summary") return value;
  return (
    findServerCompactionItem(value.item) ??
    findServerCompactionItem(value.output) ??
    findServerCompactionItem(value.response)
  );
}

function serverCompactionSignature(value: unknown): string | undefined {
  const item = findServerCompactionItem(value);
  if (!item) return undefined;
  if (typeof item.id === "string" && item.id) return `${item.type}:${item.id}`;
  return `${item.type}:${JSON.stringify(item)}`;
}

function responseOutput(value: unknown): unknown[] | undefined {
  if (!isRecord(value)) return undefined;
  if (Array.isArray(value.output)) return value.output;
  return isRecord(value.response) && Array.isArray(value.response.output)
    ? value.response.output
    : undefined;
}

function canonicalJsonValue(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(canonicalJsonValue);
  if (!isRecord(value)) return value;
  return Object.fromEntries(
    Object.keys(value)
      .sort()
      .map((key) => [key, canonicalJsonValue(value[key])]),
  );
}

function semanticBoundaryValue(value: unknown): string {
  if (!isRecord(value)) return JSON.stringify(canonicalJsonValue(value));
  const comparable = { ...value };
  delete comparable.id;
  delete comparable.phase;
  return JSON.stringify(canonicalJsonValue(comparable));
}

function isReplayableResponseItem(value: unknown): value is Record<string, unknown> {
  return (
    isRecord(value) &&
    ["reasoning", "message", "function_call", "custom_tool_call"].includes(String(value.type)) &&
    typeof value.id === "string" &&
    value.id.length > 0
  );
}

function statelessCompactionState(
  output: unknown[],
  keepCompleteOutput = false,
  sourceInput?: unknown,
): StatelessCompactionState | undefined {
  let compactionIndex = -1;
  for (let index = output.length - 1; index >= 0; index--) {
    const item = output[index];
    if (isRecord(item) && (item.type === "compaction" || item.type === "compaction_summary")) {
      compactionIndex = index;
      break;
    }
  }
  if (compactionIndex < 0) return undefined;

  const inputPrefix = structuredClone(keepCompleteOutput ? output : output.slice(compactionIndex));
  if (Array.isArray(sourceInput) && sourceInput.length > 0) {
    return {
      inputPrefix,
      boundary: {
        kind: "semantic",
        value: semanticBoundaryValue(sourceInput[sourceInput.length - 1]),
      },
    };
  }
  for (let index = output.length - 1; index >= 0; index--) {
    const item = output[index];
    if (isReplayableResponseItem(item)) {
      return { inputPrefix, boundary: { kind: "id", value: item.id as string } };
    }
  }
  return undefined;
}

function markServerCompaction(state: RuntimeState, generation: number, value: unknown): void {
  if (state.generation !== generation) return;
  const signature = serverCompactionSignature(value);
  if (!signature || state.serverCompactionSignature === signature) return;
  state.serverCompactionSignature = signature;
  state.serverCompactionPending = true;
  state.serverCompactionNotificationPending = true;
}

function inspectServerCompaction(
  response: Response,
  state: RuntimeState,
  generation: number,
  stateless: boolean,
): Promise<void> {
  return response
    .clone()
    .text()
    .then((text) => {
      if (!text || state.generation !== generation) return;
      const inspect = (value: unknown): void => {
        markServerCompaction(state, generation, value);
        if (!stateless) return;
        const output = responseOutput(value);
        if (!output) return;
        const compacted = statelessCompactionState(output);
        if (!compacted) return;
        state.statelessCompaction = compacted;
        state.statelessCheckpointPending = true;
      };

      try {
        inspect(JSON.parse(text) as unknown);
        return;
      } catch {
        // Streaming Responses bodies contain one JSON object per SSE data line.
      }
      for (const line of text.split(/\r?\n/)) {
        if (!line.startsWith("data:")) continue;
        const data = line.slice(5).trim();
        if (!data || data === "[DONE]") continue;
        try {
          inspect(JSON.parse(data) as unknown);
        } catch {
          // Ignore non-JSON SSE data; Pi's parser will report protocol errors.
        }
      }
    })
    .catch(() => undefined);
}

function isAssistantResponseItem(value: unknown): boolean {
  if (!isRecord(value)) return false;
  if (value.type === "message") return value.role === "assistant";
  return [
    "reasoning",
    "function_call",
    "custom_tool_call",
    "tool_search_call",
    "web_search_call",
    "image_generation_call",
    "local_shell_call",
  ].includes(String(value.type));
}

function incrementalResponseInput(input: unknown): unknown[] | undefined {
  if (!Array.isArray(input)) return undefined;
  let lastAssistantIndex = -1;
  for (const [index, item] of input.entries()) {
    if (isAssistantResponseItem(item)) lastAssistantIndex = index;
  }
  if (lastAssistantIndex < 0 || lastAssistantIndex === input.length - 1) return undefined;
  return input.slice(lastAssistantIndex + 1);
}

function applyStatelessCompaction(
  input: unknown,
  compacted: StatelessCompactionState | undefined,
): unknown {
  if (!Array.isArray(input) || !compacted) return input;
  for (let index = input.length - 1; index >= 0; index--) {
    const item = input[index];
    const matches =
      compacted.boundary.kind === "id"
        ? isRecord(item) && item.id === compacted.boundary.value
        : semanticBoundaryValue(item) === compacted.boundary.value;
    if (matches) {
      return [...structuredClone(compacted.inputPrefix), ...input.slice(index + 1)];
    }
  }
  return input;
}

function compactThreshold(model: Model<any>, ratio: number, explicit?: number): number {
  if (explicit !== undefined) return explicit;
  return Math.max(1_000, Math.floor(model.contextWindow * Math.min(ratio, 0.95)));
}

function compressionPayload(
  payload: Record<string, unknown>,
  model: Model<any>,
  state: CompressionState,
): Record<string, unknown> {
  const config = loadConfig();
  const next: Record<string, unknown> = { ...payload, store: config.store };
  if (next.context_management === undefined) {
    next.context_management = [
      {
        type: "compaction",
        compact_threshold: compactThreshold(model, config.thresholdRatio, config.compactThreshold),
      },
    ];
  }
  if (!config.store) {
    delete next.previous_response_id;
    next.input = applyStatelessCompaction(next.input, state.statelessCompaction);
    return next;
  }
  if (
    state.capability === "supported" &&
    state.responseId &&
    state.previousResponseIdCapability !== "unsupported" &&
    next.previous_response_id === undefined
  ) {
    const incrementalInput = incrementalResponseInput(next.input);
    if (incrementalInput) {
      next.input = incrementalInput;
      next.previous_response_id = state.responseId;
    }
  }
  return next;
}

async function applyPayloadHook(
  hook: PayloadHook | undefined,
  payload: unknown,
  model: Model<any>,
): Promise<unknown> {
  if (!hook) return payload;
  const replacement = await hook(payload, model);
  return replacement === undefined ? payload : replacement;
}

function clonePayload(payload: Record<string, unknown>): Record<string, unknown> {
  return structuredClone(payload);
}

function uncompressedPayload(payload: Record<string, unknown>): Record<string, unknown> {
  const next = clonePayload(payload);
  delete next.context_management;
  return next;
}

function withoutContinuationPayload(
  payload: Record<string, unknown>,
  model: Model<any>,
): Record<string, unknown> {
  const next = compressionPayload(clonePayload(payload), model, {
    capability: "unknown",
    previousResponseIdCapability: "unknown",
  });
  delete next.previous_response_id;
  return next;
}

async function serializePayload(
  hook: PayloadHook | undefined,
  payload: Record<string, unknown>,
  model: Model<any>,
): Promise<string> {
  const processed = await applyPayloadHook(hook, payload, model);
  const serialized = JSON.stringify(processed);
  if (serialized === undefined) {
    throw new Error("Provider payload hook returned a value that cannot be serialized as JSON.");
  }
  return serialized;
}

function withPreparedPayload(
  options: SimpleStreamOptions | undefined,
  preparePayload: PayloadHook | undefined,
): SimpleStreamOptions | undefined {
  if (!preparePayload) return options;
  const finalOnPayload = options?.onPayload;
  return {
    ...options,
    onPayload: async (payload, requestModel) => {
      const prepared = await applyPayloadHook(preparePayload, payload, requestModel);
      return applyPayloadHook(finalOnPayload, prepared, requestModel);
    },
  };
}

function requestBody(init: RequestInit | undefined): Record<string, unknown> | undefined {
  if (typeof init?.body !== "string") return undefined;
  try {
    const parsed: unknown = JSON.parse(init.body);
    return isRecord(parsed) ? parsed : undefined;
  } catch {
    return undefined;
  }
}

function errorMessage(response: Response, body: unknown): string {
  if (isRecord(body) && isRecord(body.error) && typeof body.error.message === "string") {
    return body.error.message;
  }
  return `HTTP ${response.status} ${response.statusText}`.trim();
}

function isPreviousResponseIdUnsupported(response: Response, body: unknown): boolean {
  const message = errorMessage(response, body).toLowerCase();
  return (
    message.includes("previous_response_id") &&
    (message.includes("not supported") ||
      message.includes("unsupported") ||
      message.includes("only supported"))
  );
}

class CompactionLifecycle {
  private readonly runtimeByModel = new Map<string, RuntimeState>();
  private readonly manualCompactionTokens = new WeakMap<
    ManualCompactionToken,
    ManualCompactionTokenState
  >();
  private activeNotificationSent = false;

  isEligible(model: unknown): model is Model<"openai-responses"> {
    return isRecord(model) && model.api === "openai-responses" && isEligibleGptModelId(model.id);
  }

  capability(model: unknown): CompressionCapability {
    return this.isEligible(model) ? this.runtimeState(model).capability : "unsupported";
  }

  restoreContext(
    model: unknown,
    messages: readonly unknown[],
    checkpoints: readonly unknown[] = [],
  ): void {
    this.clearContext();
    this.restoreAssistantResponse(model, messages);
    if (!this.isEligible(model) || loadConfig().store) return;
    for (let index = checkpoints.length - 1; index >= 0; index--) {
      const compacted = stateFromCheckpoint(model, checkpoints[index]);
      if (!compacted) continue;
      this.runtimeState(model).statelessCompaction = compacted;
      return;
    }
  }

  clearContext(): void {
    for (const state of this.runtimeByModel.values()) {
      this.invalidateContinuationState(state);
    }
  }

  reset(): void {
    for (const state of this.runtimeByModel.values()) {
      this.invalidateContinuationState(state);
    }
    this.runtimeByModel.clear();
    this.activeNotificationSent = false;
  }

  async finishMessage(message: unknown, model: unknown): Promise<FinishMessageOutcome> {
    if (!this.isEligible(model)) return { kind: "none" };
    const key = modelKey(model);
    const state = this.runtimeState(model);
    const generation = state.generation;
    await this.waitForPendingInspections(state);
    if (!this.isCurrentContextState(key, state, generation)) return { kind: "none" };
    const serverCompacted = this.takeServerCompactionNotification(state);
    const checkpoint = this.takeStatelessCheckpoint(model, state);
    this.recordAssistantResponse(message, model, state);
    return serverCompacted
      ? {
          kind: "server-compacted",
          provider: model.provider,
          modelId: model.id,
          ...(checkpoint ? { checkpoint } : {}),
        }
      : { kind: "none" };
  }

  beforeLocalCompaction(
    model: unknown,
    notificationsEnabled: boolean,
  ): BeforeLocalCompactionOutcome {
    if (!this.isEligible(model) || this.capability(model) !== "supported") {
      return { kind: "pass-through" };
    }
    const state = this.runtimeState(model);
    if (state.serverCompactionPending === true) {
      delete state.serverCompactionPending;
      delete state.serverCompactionNotificationPending;
      return { kind: "write-server-marker" };
    }
    const notifyActive = notificationsEnabled && !this.activeNotificationSent;
    if (notifyActive) this.activeNotificationSent = true;
    return {
      kind: "cancel-local",
      notifyActive,
      provider: model.provider,
      modelId: model.id,
    };
  }

  async refreshCapabilities(model: unknown): Promise<boolean> {
    if (!this.isEligible(model)) return false;
    const key = modelKey(model);
    const state = this.runtimeState(model);
    const capabilityGeneration = state.capabilityGeneration + 1;
    state.capabilityGeneration = capabilityGeneration;
    await clearCachedCapabilities(model);
    if (!this.isCurrentCapabilityState(key, state, capabilityGeneration)) return true;
    this.invalidateContinuationState(state);
    state.capability = "unknown";
    delete state.previousResponseIdCapability;
    return true;
  }

  prepareStream(
    model: Model<any>,
    options: SimpleStreamOptions | undefined,
    preparePayload?: PayloadHook,
  ): PreparedStream {
    const config = loadConfig();
    if (!config.enabled || !config.compression || !this.isEligible(model)) {
      return { kind: "generic", options: withPreparedPayload(options, preparePayload) };
    }

    const state = this.runtimeState(model);
    if (config.store && state.previousResponseIdCapability === undefined) {
      state.previousResponseIdCapability = cachedPreviousResponseIdCapabilitySync(model);
    }
    if (config.store && state.previousResponseIdCapability === "unsupported") {
      this.disableServerCompression(state);
      return { kind: "generic", options: withPreparedPayload(options, preparePayload) };
    }
    if (state.capability === "unknown" && cachedResponsesCapabilitySync(model) === "unsupported") {
      state.capability = "unsupported";
    }
    if (state.capability === "unsupported") {
      return { kind: "generic", options: withPreparedPayload(options, preparePayload) };
    }

    const tokenState = this.captureTokenState(model, state);
    let retryPayloads: RetryPayloads | undefined;
    const finalOnPayload = options?.onPayload;
    return {
      kind: "enhanced",
      options: {
        ...options,
        onPayload: async (payload, requestModel) => {
          retryPayloads = undefined;
          const prepared = await applyPayloadHook(preparePayload, payload, requestModel);
          if (!isRecord(prepared)) {
            return applyPayloadHook(finalOnPayload, prepared, requestModel);
          }
          retryPayloads = {
            uncompressed: uncompressedPayload(prepared),
            withoutContinuation: withoutContinuationPayload(prepared, model),
            requestModel,
          };
          const compressed = this.isCurrentManualState(tokenState)
            ? compressionPayload(clonePayload(prepared), model, state)
            : clonePayload(prepared);
          return applyPayloadHook(finalOnPayload, compressed, requestModel);
        },
        fetch: this.createFallbackFetch({
          model,
          tokenState,
          ...(options?.fetch ? { originalFetch: options.fetch } : {}),
          retryPayloads: () => retryPayloads,
          ...(finalOnPayload ? { finalOnPayload } : {}),
        }),
      },
    };
  }

  async manualCompactionPlan(model: Model<any>, input: unknown): Promise<ManualCompactionPlan> {
    if (!this.isEligible(model)) {
      throw new Error("Current model is not an eligible OpenAI Responses GPT model.");
    }
    const key = modelKey(model);
    const state = this.runtimeState(model);
    const generation = state.generation;
    const capabilityGeneration = state.capabilityGeneration;
    const responseId = state.responseId;
    const store = loadConfig().store;
    const cachedCapability = store
      ? await cachedPreviousResponseIdCapability(model)
      : "unsupported";
    if (store && this.isCurrentCapabilityState(key, state, capabilityGeneration)) {
      state.previousResponseIdCapability = cachedCapability;
    }
    if (
      !this.isCurrentContextState(key, state, generation) ||
      !this.isCurrentCapabilityState(key, state, capabilityGeneration)
    ) {
      throw new Error("Manual compaction state changed while preparing the request.");
    }

    const token = this.createManualCompactionToken({
      key,
      state,
      generation,
      capabilityGeneration,
    });
    if (store && responseId && cachedCapability !== "unsupported") {
      return { kind: "previous-response", responseId, token };
    }
    if (input === undefined) {
      throw new Error("No server response chain or conversation input is available yet.");
    }
    return { kind: "input", input, token };
  }

  async recordManualContinuationUnsupported(
    model: Model<any>,
    token: ManualCompactionToken,
  ): Promise<void> {
    if (!this.isEligible(model)) return;
    const tokenState = this.manualCompactionTokenState(model, token);
    if (!tokenState || !this.isCurrentManualCapabilityState(tokenState)) return;

    tokenState.state.previousResponseIdCapability = "unsupported";
    await recordPreviousResponseIdCapability(model, "unsupported");
  }

  async recordManualCompactionSuccess(
    model: Model<any>,
    token: ManualCompactionToken,
    responseId: string,
    usedPreviousResponseId: boolean,
    output?: unknown[],
    sourceInput?: unknown,
  ): Promise<StatelessCompactionCheckpoint | undefined> {
    if (!this.isEligible(model)) return undefined;
    const tokenState = this.manualCompactionTokenState(model, token);
    if (!tokenState || !this.isCurrentManualState(tokenState)) return undefined;

    if (usedPreviousResponseId) {
      tokenState.state.previousResponseIdCapability = "supported";
      await recordPreviousResponseIdCapability(model, "supported");
      if (!this.isCurrentManualState(tokenState)) return undefined;
    }
    await recordResponsesCapability(model, "supported");
    if (!this.isCurrentManualState(tokenState)) return undefined;
    tokenState.state.capability = "supported";
    tokenState.state.responseId = responseId;

    if (!loadConfig().store && output) {
      const compacted = statelessCompactionState(output, true, sourceInput);
      if (compacted) {
        tokenState.state.statelessCompaction = compacted;
        return checkpointFor(model, compacted);
      }
    }
    return undefined;
  }

  /** @deprecated Compatibility for the public ./stream entry point. */
  legacyRecordAssistantResponse(message: unknown, model: unknown): void {
    if (!this.isEligible(model)) return;
    this.recordAssistantResponse(message, model, this.runtimeState(model));
  }

  /** @deprecated Compatibility for the public ./stream entry point. */
  legacyRestoreAssistantResponse(model: unknown, messages: readonly unknown[]): void {
    this.restoreAssistantResponse(model, messages);
  }

  /** @deprecated Compatibility for the public ./stream entry point. */
  legacyClearContinuationState(): void {
    this.clearContext();
  }

  /** @deprecated Compatibility for the public ./stream entry point. */
  async legacyWaitForServerCompaction(model: unknown): Promise<boolean> {
    if (!this.isEligible(model)) return false;
    const key = modelKey(model);
    const state = this.runtimeState(model);
    const generation = state.generation;
    await this.waitForPendingInspections(state);
    if (!this.isCurrentContextState(key, state, generation)) return false;
    return this.takeServerCompactionNotification(state);
  }

  /** @deprecated Compatibility for the public ./stream entry point. */
  legacyConsumeServerCompaction(model: unknown): boolean {
    if (!this.isEligible(model)) return false;
    const state = this.runtimeState(model);
    const pending = state.serverCompactionPending === true;
    delete state.serverCompactionPending;
    delete state.serverCompactionNotificationPending;
    return pending;
  }

  /** @deprecated Compatibility for the public ./stream entry point. */
  legacyHasServerResponseChain(model: unknown): boolean {
    return this.isEligible(model) && Boolean(this.runtimeState(model).responseId);
  }

  private runtimeState(model: Model<any>): RuntimeState {
    const key = modelKey(model);
    const existing = this.runtimeByModel.get(key);
    if (existing) return existing;
    const created: RuntimeState = {
      capability: "unknown",
      generation: 0,
      capabilityGeneration: 0,
      compactionInspections: new Set(),
    };
    this.runtimeByModel.set(key, created);
    return created;
  }

  private createManualCompactionToken(
    tokenState: ManualCompactionTokenState,
  ): ManualCompactionToken {
    const token: ManualCompactionToken = { [manualCompactionTokenBrand]: true };
    this.manualCompactionTokens.set(token, tokenState);
    return token;
  }

  private captureTokenState(model: Model<any>, state: RuntimeState): StreamCompactionTokenState {
    return {
      key: modelKey(model),
      state,
      generation: state.generation,
      capabilityGeneration: state.capabilityGeneration,
    };
  }

  private manualCompactionTokenState(
    model: Model<any>,
    token: ManualCompactionToken,
  ): ManualCompactionTokenState | undefined {
    const tokenState = this.manualCompactionTokens.get(token);
    return tokenState?.key === modelKey(model) ? tokenState : undefined;
  }

  private isCurrentContextState(key: string, state: RuntimeState, generation: number): boolean {
    return this.runtimeByModel.get(key) === state && state.generation === generation;
  }

  private isCurrentCapabilityState(
    key: string,
    state: RuntimeState,
    capabilityGeneration: number,
  ): boolean {
    return (
      this.runtimeByModel.get(key) === state && state.capabilityGeneration === capabilityGeneration
    );
  }

  private isCurrentManualState(tokenState: ManualCompactionTokenState): boolean {
    return (
      this.isCurrentContextState(tokenState.key, tokenState.state, tokenState.generation) &&
      this.isCurrentManualCapabilityState(tokenState)
    );
  }

  private isCurrentManualCapabilityState(tokenState: ManualCompactionTokenState): boolean {
    return this.isCurrentCapabilityState(
      tokenState.key,
      tokenState.state,
      tokenState.capabilityGeneration,
    );
  }

  private restoreAssistantResponse(model: unknown, messages: readonly unknown[]): void {
    if (!this.isEligible(model)) return;
    for (let index = messages.length - 1; index >= 0; index--) {
      const message = messages[index];
      if (
        isRecord(message) &&
        message.role === "assistant" &&
        message.stopReason !== "error" &&
        message.stopReason !== "aborted" &&
        message.api === model.api &&
        message.provider === model.provider &&
        message.model === model.id &&
        typeof message.responseId === "string" &&
        message.responseId
      ) {
        this.runtimeState(model).responseId = message.responseId;
        return;
      }
    }
  }

  private recordAssistantResponse(
    message: unknown,
    model: Model<"openai-responses">,
    state: RuntimeState,
  ): void {
    if (!isRecord(message) || message.role !== "assistant") return;
    // Preserve the last completed chain across user interrupts and retryable stream failures.
    if (message.stopReason === "aborted" || isTransientAssistantError(message)) return;
    if (message.stopReason === "error") {
      state.capability = "unknown";
      // Keep the identity so a retried response cannot re-notify the same item.
      this.invalidateContinuationState(state, true);
      return;
    }
    if (
      message.api !== model.api ||
      message.provider !== model.provider ||
      message.model !== model.id ||
      typeof message.responseId !== "string" ||
      !message.responseId
    ) {
      return;
    }
    state.responseId = message.responseId;
  }

  private disableServerCompression(state: RuntimeState): void {
    this.invalidateContinuationState(state);
    state.capability = "unsupported";
  }

  private invalidateContinuationState(state: RuntimeState, keepSignature = false): void {
    state.generation += 1;
    state.compactionInspections.clear();
    delete state.responseId;
    delete state.statelessCompaction;
    delete state.statelessCheckpointPending;
    delete state.serverCompactionPending;
    delete state.serverCompactionNotificationPending;
    if (!keepSignature) delete state.serverCompactionSignature;
  }

  private async waitForPendingInspections(state: RuntimeState): Promise<void> {
    await Promise.all([...state.compactionInspections]);
  }

  private takeServerCompactionNotification(state: RuntimeState): boolean {
    const shouldNotify = state.serverCompactionNotificationPending === true;
    delete state.serverCompactionNotificationPending;
    return shouldNotify;
  }

  private takeStatelessCheckpoint(
    model: Model<any>,
    state: RuntimeState,
  ): StatelessCompactionCheckpoint | undefined {
    if (!state.statelessCheckpointPending || !state.statelessCompaction) return undefined;
    delete state.statelessCheckpointPending;
    return checkpointFor(model, state.statelessCompaction);
  }

  private trackServerCompactionInspection(
    response: Response,
    tokenState: StreamCompactionTokenState,
    stateless: boolean,
  ): void {
    if (!this.isCurrentManualState(tokenState)) return;
    const inspection = inspectServerCompaction(
      response,
      tokenState.state,
      tokenState.generation,
      stateless,
    ).finally(() => {
      tokenState.state.compactionInspections.delete(inspection);
    });
    tokenState.state.compactionInspections.add(inspection);
  }

  private async setPreviousResponseIdCapability(
    model: Model<any>,
    tokenState: StreamCompactionTokenState,
    capability: Exclude<PreviousResponseIdCapability, "unknown">,
  ): Promise<boolean> {
    if (!this.isCurrentManualCapabilityState(tokenState)) return false;
    tokenState.state.previousResponseIdCapability = capability;
    await recordPreviousResponseIdCapability(model, capability);
    return this.isCurrentManualCapabilityState(tokenState);
  }

  private async setResponsesCapability(
    model: Model<any>,
    tokenState: StreamCompactionTokenState,
    capability: Exclude<CompressionCapability, "unknown">,
  ): Promise<boolean> {
    if (!this.isCurrentManualCapabilityState(tokenState)) return false;
    tokenState.state.capability = capability;
    await recordResponsesCapability(model, capability);
    return this.isCurrentManualCapabilityState(tokenState);
  }

  private async disableStreamCompression(
    model: Model<any>,
    tokenState: StreamCompactionTokenState,
  ): Promise<void> {
    if (this.isCurrentManualState(tokenState)) {
      this.disableServerCompression(tokenState.state);
    }
    await this.setResponsesCapability(model, tokenState, "unsupported");
  }

  private createFallbackFetch(params: {
    model: Model<any>;
    tokenState: StreamCompactionTokenState;
    originalFetch?: FetchFunction;
    retryPayloads: () => RetryPayloads | undefined;
    finalOnPayload?: PayloadHook;
  }): FetchFunction {
    const fetchImpl = params.originalFetch ?? globalThis.fetch;
    // A fallback is a new provider request: build the internal variant first, then run the final hook.
    const retry = async (
      input: Parameters<FetchFunction>[0],
      init: Parameters<FetchFunction>[1],
      payload: Record<string, unknown>,
      requestModel: Model<any>,
    ): Promise<Response> =>
      fetchImpl(input, {
        ...init,
        body: await serializePayload(params.finalOnPayload, payload, requestModel),
      });

    return async (input, init) => {
      const enhancedBody = requestBody(init);
      const usedCompression = Array.isArray(enhancedBody?.context_management);
      if (!usedCompression) return fetchImpl(input, init);

      const retryPayloads = params.retryPayloads();
      let first: Response;
      try {
        first = await fetchImpl(input, init);
      } catch (error) {
        if (
          init?.signal?.aborted ||
          (error instanceof DOMException && error.name === "AbortError")
        ) {
          throw error;
        }
        if (!retryPayloads) throw error;
        const fallback = await retry(
          input,
          init,
          retryPayloads.uncompressed,
          retryPayloads.requestModel,
        );
        if (fallback.ok) {
          await this.disableStreamCompression(params.model, params.tokenState);
        }
        return fallback;
      }

      if (first.ok) {
        await this.setResponsesCapability(params.model, params.tokenState, "supported");
        if (enhancedBody.previous_response_id !== undefined) {
          await this.setPreviousResponseIdCapability(params.model, params.tokenState, "supported");
        }
        this.trackServerCompactionInspection(
          first,
          params.tokenState,
          enhancedBody.store === false,
        );
        return first;
      }
      if (!retryPayloads) return first;

      const previousResponseIdUnsupported =
        enhancedBody.previous_response_id !== undefined &&
        isPreviousResponseIdUnsupported(
          first,
          await first
            .clone()
            .json()
            .catch(() => undefined),
        );
      if (previousResponseIdUnsupported) {
        await this.setPreviousResponseIdCapability(params.model, params.tokenState, "unsupported");
      }

      if (
        enhancedBody.previous_response_id !== undefined &&
        CONTINUATION_RESET_STATUSES.has(first.status)
      ) {
        if (previousResponseIdUnsupported) {
          // A stateless full-history request would compact the same transcript every turn.
          if (this.isCurrentManualState(params.tokenState)) {
            this.disableServerCompression(params.tokenState.state);
          }
          return retry(input, init, retryPayloads.uncompressed, retryPayloads.requestModel);
        }

        const continued = await retry(
          input,
          init,
          retryPayloads.withoutContinuation,
          retryPayloads.requestModel,
        );
        if (continued.ok) {
          await this.setResponsesCapability(params.model, params.tokenState, "supported");
          if (this.isCurrentManualState(params.tokenState)) {
            delete params.tokenState.state.responseId;
          }
          this.trackServerCompactionInspection(
            continued,
            params.tokenState,
            retryPayloads.withoutContinuation.store === false,
          );
          return continued;
        }
      }

      const fallback = await retry(
        input,
        init,
        retryPayloads.uncompressed,
        retryPayloads.requestModel,
      );
      if (fallback.ok) {
        await this.disableStreamCompression(params.model, params.tokenState);
      }
      return fallback;
    };
  }
}

export const compactionLifecycle = new CompactionLifecycle();
