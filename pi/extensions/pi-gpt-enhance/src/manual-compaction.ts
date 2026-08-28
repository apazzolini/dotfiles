import { convertToLlm, sessionEntryToContextMessages } from "@earendil-works/pi-coding-agent";
import type { FetchFunction, Model, ProviderHeaders } from "@earendil-works/pi-ai";
import { loadConfig } from "./config.js";
import { promoteSystemPromptToInstructions } from "./instructions.js";
import {
  compactionLifecycle,
  type StatelessCompactionCheckpoint,
} from "./lifecycle.js";

export type ManualCompactionResult = {
  responseId: string;
  usage?: unknown;
  checkpoint?: StatelessCompactionCheckpoint;
};

export type RequestAuth = {
  apiKey?: string;
  headers?: ProviderHeaders;
};

export type ManualCompactionOptions = {
  input?: unknown;
  instructions?: string;
  promoteSystemPromptToInstructions?: boolean;
  fetch?: FetchFunction;
};

export type ManualCompactionOptionsInput = ManualCompactionOptions | FetchFunction;

export type CurrentBranchCompactionOptions = {
  fetch?: FetchFunction;
  promoteSystemPromptToInstructions?: boolean;
};

export type CurrentBranchCompactionOptionsInput = CurrentBranchCompactionOptions | FetchFunction;

export type EffectiveBranchContext = {
  sessionManager: {
    buildContextEntries(): Array<Parameters<typeof sessionEntryToContextMessages>[0]>;
  };
};

export type ManualCompactionContext = EffectiveBranchContext & {
  getSystemPrompt(): string;
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function effectiveBranchMessages(ctx: EffectiveBranchContext): unknown[] {
  return convertToLlm(
    ctx.sessionManager.buildContextEntries().flatMap((entry) => {
      return sessionEntryToContextMessages(entry);
    }),
  );
}

function sanitizeSurrogates(value: string): string {
  return value.replace(/[\uD800-\uDFFF]/g, "\uFFFD");
}

export function buildManualCompactionInput(
  model: Model<any>,
  ctx: ManualCompactionContext,
): unknown {
  const messages = effectiveBranchMessages(ctx);
  if (messages.length === 0) {
    throw new Error("No conversation messages are available for server compaction.");
  }

  const input: Array<Record<string, unknown>> = [];
  const systemPrompt = ctx.getSystemPrompt();
  if (systemPrompt) {
    const supportsDeveloperRole =
      !isRecord(model.compat) || model.compat.supportsDeveloperRole !== false;
    input.push({
      role: model.reasoning && supportsDeveloperRole ? "developer" : "system",
      content: sanitizeSurrogates(systemPrompt),
    });
  }

  for (const message of messages) {
    if (!isRecord(message)) continue;
    if (message.role === "user") {
      if (typeof message.content === "string") {
        input.push({
          role: "user",
          content: [{ type: "input_text", text: sanitizeSurrogates(message.content) }],
        });
      } else if (Array.isArray(message.content)) {
        const content: Array<Record<string, unknown>> = [];
        for (const item of message.content) {
          if (!isRecord(item)) continue;
          if (item.type === "text" && typeof item.text === "string") {
            content.push({ type: "input_text", text: sanitizeSurrogates(item.text) });
          } else if (item.type === "image" && typeof item.data === "string") {
            content.push({
              type: "input_image",
              detail: "auto",
              image_url: `data:${typeof item.mimeType === "string" ? item.mimeType : "image/png"};base64,${item.data}`,
            });
          }
        }
        if (content.length > 0) input.push({ role: "user", content });
      }
      continue;
    }

    if (message.role === "assistant" && Array.isArray(message.content)) {
      for (const block of message.content) {
        if (!isRecord(block)) continue;
        if (block.type === "thinking" && typeof block.thinkingSignature === "string") {
          try {
            input.push(JSON.parse(block.thinkingSignature) as Record<string, unknown>);
          } catch {
            // Ignore malformed provider signatures when rebuilding standalone input.
          }
        } else if (block.type === "text" && typeof block.text === "string") {
          input.push({
            type: "message",
            role: "assistant",
            content: [
              { type: "output_text", text: sanitizeSurrogates(block.text), annotations: [] },
            ],
            status: "completed",
          });
        } else if (block.type === "toolCall") {
          const id = typeof block.id === "string" ? block.id.split("|") : [];
          if (typeof block.name !== "string") continue;
          input.push({
            type: "function_call",
            call_id: id[0] ?? "pi_tool_call",
            ...(id[1] ? { id: id[1] } : {}),
            name: block.name,
            arguments: JSON.stringify(block.arguments ?? {}),
          });
        }
      }
      continue;
    }

    if (message.role === "toolResult" && typeof message.toolCallId === "string") {
      const callId = message.toolCallId.split("|")[0];
      const output = Array.isArray(message.content)
        ? message.content
            .filter(
              (item) => isRecord(item) && item.type === "text" && typeof item.text === "string",
            )
            .map((item) => item.text)
            .join("\\n")
        : String(message.content ?? "");
      input.push({ type: "function_call_output", call_id: callId, output });
    }
  }

  return input;
}

function hasHeader(headers: Record<string, string>, name: string): boolean {
  return Object.keys(headers).some((key) => key.toLowerCase() === name);
}

function compactEndpoint(baseUrl: string): string {
  return `${baseUrl.replace(/\/+$/, "")}/responses/compact`;
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

function prepareManualPayload(
  input: unknown,
  instructions: string | undefined,
  promote: boolean,
): { input: unknown; instructions?: string } {
  const payload = {
    input,
    ...(instructions === undefined ? {} : { instructions }),
  };
  if (!promote || input === undefined) return payload;

  const promoted = promoteSystemPromptToInstructions(payload);
  if (!isRecord(promoted)) return payload;
  return {
    input: promoted.input,
    ...(typeof promoted.instructions === "string" ? { instructions: promoted.instructions } : {}),
  };
}

/** Compact a response chain or supplied provider input without invoking Pi local compaction. */
export async function compactResponseChain(
  model: Model<any>,
  auth: RequestAuth,
  options: ManualCompactionOptionsInput = {},
): Promise<ManualCompactionResult> {
  const compactOptions: ManualCompactionOptions =
    typeof options === "function" ? { fetch: options } : options;
  const config = loadConfig();
  const shouldPromote =
    compactOptions.promoteSystemPromptToInstructions ??
    (config.enabled && config.promoteSystemPromptToInstructions);
  const preparedPayload = prepareManualPayload(
    compactOptions.input,
    compactOptions.instructions,
    shouldPromote,
  );
  const plan = await compactionLifecycle.manualCompactionPlan(model, preparedPayload.input);

  const headers: Record<string, string> = {};
  for (const [name, value] of Object.entries({ ...(model.headers ?? {}), ...(auth.headers ?? {}) })) {
    if (value !== null) headers[name] = value;
  }
  if (auth.apiKey && !hasHeader(headers, "authorization")) {
    headers.Authorization = `Bearer ${auth.apiKey}`;
  }
  headers["Content-Type"] ??= "application/json";

  const fetchImpl = compactOptions.fetch ?? globalThis.fetch;
  const request = async (payload: Record<string, unknown>) => {
    const response = await fetchImpl(compactEndpoint(model.baseUrl), {
      method: "POST",
      headers,
      body: JSON.stringify(payload),
    });
    const body: unknown = await response.json().catch(() => undefined);
    return { response, body };
  };

  const basePayload: Record<string, unknown> = {
    model: model.id,
    ...(preparedPayload.instructions === undefined
      ? {}
      : { instructions: preparedPayload.instructions }),
  };
  let usedPreviousResponseId = plan.kind === "previous-response";
  let result = await request(
    plan.kind === "previous-response"
      ? { ...basePayload, previous_response_id: plan.responseId }
      : { ...basePayload, input: plan.input },
  );

  if (
    usedPreviousResponseId &&
    !result.response.ok &&
    preparedPayload.input !== undefined &&
    isPreviousResponseIdUnsupported(result.response, result.body)
  ) {
    await compactionLifecycle.recordManualContinuationUnsupported(model, plan.token);
    usedPreviousResponseId = false;
    result = await request({ ...basePayload, input: preparedPayload.input });
  }

  if (!result.response.ok) {
    throw new Error(`Server compaction failed: ${errorMessage(result.response, result.body)}`);
  }
  if (!isRecord(result.body) || typeof result.body.id !== "string" || !result.body.id) {
    throw new Error("Server compaction returned no response id.");
  }

  const checkpoint = await compactionLifecycle.recordManualCompactionSuccess(
    model,
    plan.token,
    result.body.id,
    usedPreviousResponseId,
    Array.isArray(result.body.output) ? result.body.output : undefined,
    preparedPayload.input,
  );
  if (!loadConfig().store && !checkpoint) {
    throw new Error("Server compaction returned no replayable stateless context window.");
  }
  return {
    responseId: result.body.id,
    ...("usage" in result.body ? { usage: result.body.usage } : {}),
    ...(checkpoint ? { checkpoint } : {}),
  };
}

export async function compactCurrentBranch(
  model: Model<any>,
  auth: RequestAuth,
  ctx: ManualCompactionContext,
  options: CurrentBranchCompactionOptionsInput = {},
): Promise<ManualCompactionResult> {
  const compactOptions: CurrentBranchCompactionOptions =
    typeof options === "function" ? { fetch: options } : options;
  const input = buildManualCompactionInput(model, ctx);
  const config = loadConfig();
  const shouldPromote =
    compactOptions.promoteSystemPromptToInstructions ??
    (config.enabled && config.promoteSystemPromptToInstructions);
  const prepared = shouldPromote ? promoteSystemPromptToInstructions({ input }) : { input };
  const preparedPayload = isRecord(prepared) ? prepared : { input };

  return compactResponseChain(model, auth, {
    input: preparedPayload.input,
    ...(typeof preparedPayload.instructions === "string"
      ? { instructions: preparedPayload.instructions }
      : {}),
    promoteSystemPromptToInstructions: shouldPromote,
    ...(compactOptions.fetch ? { fetch: compactOptions.fetch } : {}),
  });
}

export const manualCompaction = {
  compact: compactCurrentBranch,
};
