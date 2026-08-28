export function isEligibleGptModelId(modelId: unknown): boolean {
  return (
    typeof modelId === "string" && (modelId.startsWith("gpt-") || modelId.startsWith("openai/gpt-"))
  );
}
