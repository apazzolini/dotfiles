type JsonRecord = Record<string, unknown>;

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Move Pi's leading system/developer message to the Responses instructions field. */
export function promoteSystemPromptToInstructions(payload: unknown): unknown {
  if (!isRecord(payload) || !Array.isArray(payload.input)) return payload;
  if (typeof payload.instructions === "string" && payload.instructions.trim()) return payload;

  const [first, ...remaining] = payload.input;
  if (
    !isRecord(first) ||
    (first.role !== "developer" && first.role !== "system") ||
    typeof first.content !== "string" ||
    !first.content.trim()
  ) {
    return payload;
  }

  return {
    ...payload,
    instructions: first.content,
    input: remaining,
  };
}
