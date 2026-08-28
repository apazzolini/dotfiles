import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export interface GptEnhanceConfig {
  enabled: boolean;
  compression: boolean;
  store: boolean;
  applyPatch: boolean;
  promoteSystemPromptToInstructions: boolean;
  compactThreshold?: number;
  thresholdRatio: number;
  notify: boolean;
  statusBar: boolean;
}

const DEFAULT_CONFIG: GptEnhanceConfig = {
  enabled: true,
  compression: true,
  store: false,
  applyPatch: false,
  promoteSystemPromptToInstructions: true,
  thresholdRatio: 0.9,
  notify: true,
  statusBar: true,
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readConfigFile(path: string): Record<string, unknown> {
  if (!existsSync(path)) return {};
  try {
    const parsed: unknown = JSON.parse(readFileSync(path, "utf8"));
    return isRecord(parsed) ? parsed : {};
  } catch (error) {
    console.warn(`[pi-gpt-enhance] Ignoring invalid JSON config at ${path}: ${String(error)}`);
    return {};
  }
}

function booleanValue(value: unknown): boolean | undefined {
  if (typeof value === "boolean") return value;
  if (typeof value !== "string") return undefined;
  if (["1", "true", "yes", "on"].includes(value.toLowerCase())) return true;
  if (["0", "false", "no", "off"].includes(value.toLowerCase())) return false;
  return undefined;
}

function positiveNumber(value: unknown): number | undefined {
  const number = typeof value === "string" ? Number(value) : value;
  return typeof number === "number" && Number.isFinite(number) && number > 0 ? number : undefined;
}

export function loadConfig(cwd = process.cwd()): GptEnhanceConfig {
  const globalConfig = readConfigFile(join(homedir(), ".pi", "agent", "gpt-enhance.json"));
  const projectConfig = readConfigFile(join(cwd, ".pi", "gpt-enhance.json"));
  const merged = { ...globalConfig, ...projectConfig };
  const compactThreshold =
    positiveNumber(process.env.PI_GPT_ENHANCE_COMPACT_THRESHOLD) ??
    positiveNumber(merged.compactThreshold);

  return {
    enabled:
      booleanValue(process.env.PI_GPT_ENHANCE_ENABLED) ??
      booleanValue(merged.enabled) ??
      DEFAULT_CONFIG.enabled,
    compression:
      booleanValue(process.env.PI_GPT_ENHANCE_COMPRESSION) ??
      booleanValue(merged.compression) ??
      DEFAULT_CONFIG.compression,
    store:
      booleanValue(process.env.PI_GPT_ENHANCE_STORE) ??
      booleanValue(merged.store) ??
      DEFAULT_CONFIG.store,
    applyPatch:
      booleanValue(process.env.PI_GPT_ENHANCE_APPLY_PATCH) ??
      booleanValue(merged.applyPatch) ??
      DEFAULT_CONFIG.applyPatch,
    promoteSystemPromptToInstructions:
      booleanValue(process.env.PI_GPT_ENHANCE_PROMOTE_SYSTEM_PROMPT_TO_INSTRUCTIONS) ??
      booleanValue(merged.promoteSystemPromptToInstructions) ??
      DEFAULT_CONFIG.promoteSystemPromptToInstructions,
    ...(compactThreshold === undefined ? {} : { compactThreshold: Math.floor(compactThreshold) }),
    thresholdRatio:
      positiveNumber(process.env.PI_GPT_ENHANCE_THRESHOLD_RATIO) ??
      positiveNumber(merged.thresholdRatio) ??
      DEFAULT_CONFIG.thresholdRatio,
    notify:
      booleanValue(process.env.PI_GPT_ENHANCE_NOTIFY) ??
      booleanValue(merged.notify) ??
      DEFAULT_CONFIG.notify,
    statusBar:
      booleanValue(process.env.PI_GPT_ENHANCE_STATUS_BAR) ??
      booleanValue(merged.statusBar) ??
      DEFAULT_CONFIG.statusBar,
  };
}
