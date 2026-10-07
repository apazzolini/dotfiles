import { randomUUID } from "node:crypto";
import {
  mkdirSync,
  readdirSync,
  readFileSync,
  renameSync,
  rmSync,
  rmdirSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { setTimeout } from "node:timers/promises";
import type { Model, SimpleStreamOptions } from "@earendil-works/pi-ai";
import type { CompressionCapability } from "./lifecycle.js";
import { isEligibleGptModelId } from "./model-eligibility.js";

const FAST_STATUS_KEY = "gpt-enhance.fast";
const COMPRESSION_STATUS_KEY = "gpt-enhance.compression";
const PREFERENCE_LOCK_RETRIES = 30;
const PREFERENCE_LOCK_RETRY_MS = 100;
const DEFAULT_PREFERENCES_PATH = join(homedir(), ".pi", "agent", "gpt-enhance-preferences.json");

type JsonRecord = Record<string, unknown>;
type FastModel = Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">;

type PreferenceEntry = {
  provider: string;
  api: string;
  model: string;
  baseUrl: string;
  enabled: boolean;
};

type PreferenceFile = {
  version: 1;
  entries: Record<string, PreferenceEntry>;
};

type StatusContext = {
  model?: unknown;
  hasUI?: boolean;
  ui?: {
    setStatus?: (key: string, text: string | undefined) => void;
    theme?: unknown;
  };
};

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isFastModel(value: unknown): value is FastModel {
  return (
    isRecord(value) &&
    typeof value.provider === "string" &&
    value.api === "openai-responses" &&
    typeof value.id === "string" &&
    isEligibleGptModelId(value.id) &&
    typeof value.baseUrl === "string"
  );
}

function preferencesPath(): string {
  return process.env.PI_GPT_ENHANCE_PREFERENCES_FILE || DEFAULT_PREFERENCES_PATH;
}

function modelKey(model: FastModel): string {
  return JSON.stringify([model.provider, model.api, model.id, model.baseUrl]);
}

function emptyPreferences(): PreferenceFile {
  return { version: 1, entries: {} };
}

function readPreferences(): PreferenceFile {
  try {
    const parsed: unknown = JSON.parse(readFileSync(preferencesPath(), "utf8"));
    if (!isRecord(parsed) || parsed.version !== 1 || !isRecord(parsed.entries)) {
      return emptyPreferences();
    }
    return { version: 1, entries: parsed.entries as Record<string, PreferenceEntry> };
  } catch {
    return emptyPreferences();
  }
}

function writePreferences(preferences: PreferenceFile): void {
  const path = preferencesPath();
  const temporaryPath = `${path}.${process.pid}.tmp`;
  writeFileSync(temporaryPath, `${JSON.stringify(preferences, null, 2)}\n`, "utf8");
  renameSync(temporaryPath, path);
}

async function updatePreferences<T>(mutator: (preferences: PreferenceFile) => T): Promise<T> {
  const path = preferencesPath();
  mkdirSync(dirname(path), { recursive: true });
  const lockPath = `${path}.lock`;
  const owner = `${process.pid}-${randomUUID()}`;
  const candidatePath = `${lockPath}.${owner}.tmp`;
  let acquired = false;
  mkdirSync(candidatePath);
  try {
    // Publish a nonempty directory atomically, so cleanup cannot remove a new owner's lock.
    writeFileSync(join(candidatePath, owner), "");
    for (let attempt = 0; attempt <= PREFERENCE_LOCK_RETRIES; attempt++) {
      try {
        renameSync(candidatePath, lockPath);
        acquired = true;
        break;
      } catch (error) {
        const code = (error as NodeJS.ErrnoException).code;
        if (code !== "EEXIST" && code !== "ENOTEMPTY") throw error;
      }

      try {
        for (const entry of readdirSync(lockPath)) {
          const match = /^(\d+)-[0-9a-f-]{36}$/.exec(entry);
          if (!match) continue;
          try {
            process.kill(Number(match[1]), 0);
          } catch (error) {
            if ((error as NodeJS.ErrnoException).code !== "ESRCH") continue;
            try {
              unlinkSync(join(lockPath, entry));
            } catch (error) {
              if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
            }
          }
        }
        // Remove only an empty lock, never a replacement owner's marker.
        rmdirSync(lockPath);
      } catch (error) {
        const code = (error as NodeJS.ErrnoException).code;
        if (code !== "ENOENT" && code !== "ENOTEMPTY" && code !== "EEXIST") throw error;
      }

      if (attempt === PREFERENCE_LOCK_RETRIES) {
        throw new Error(`Timed out waiting for preferences lock: ${lockPath}`);
      }
      await setTimeout(PREFERENCE_LOCK_RETRY_MS);
    }
    const preferences = readPreferences();
    const result = mutator(preferences);
    writePreferences(preferences);
    return result;
  } finally {
    if (acquired) {
      unlinkSync(join(lockPath, owner));
      try {
        rmdirSync(lockPath);
      } catch (error) {
        const code = (error as NodeJS.ErrnoException).code;
        if (code !== "ENOENT" && code !== "ENOTEMPTY" && code !== "EEXIST") throw error;
      }
    } else {
      rmSync(candidatePath, { recursive: true, force: true });
    }
  }
}

function writeFastEntry(preferences: PreferenceFile, model: FastModel, enabled: boolean): void {
  preferences.entries[modelKey(model)] = {
    provider: model.provider,
    api: model.api,
    model: model.id,
    baseUrl: model.baseUrl,
    enabled,
  };
}

export function isFastEnabled(model: unknown): boolean {
  if (!isFastModel(model)) return false;
  return readPreferences().entries[modelKey(model)]?.enabled === true;
}

export async function setFast(model: unknown, enabled: boolean): Promise<boolean> {
  if (!isFastModel(model)) return false;
  return updatePreferences((preferences) => {
    writeFastEntry(preferences, model, enabled);
    return enabled;
  });
}

export async function toggleFast(model: unknown): Promise<boolean> {
  if (!isFastModel(model)) return false;
  return updatePreferences((preferences) => {
    const enabled = preferences.entries[modelKey(model)]?.enabled !== true;
    writeFastEntry(preferences, model, enabled);
    return enabled;
  });
}

export function augmentFastPayload(payload: unknown, model: unknown): unknown {
  if (!isFastEnabled(model) || !isRecord(payload)) return payload;
  return { ...payload, service_tier: "priority" };
}

export function fastPayloadHook(model: FastModel): SimpleStreamOptions["onPayload"] {
  return isFastEnabled(model) ? (payload) => augmentFastPayload(payload, model) : undefined;
}

function themedStatus(ctx: StatusContext, color: string, text: string): string {
  const theme = ctx.ui?.theme;
  return isRecord(theme) && typeof theme.fg === "function"
    ? (theme.fg as (color: string, text: string) => string)(color, text)
    : text;
}

export function updateFastStatus(
  ctx: StatusContext | undefined,
  model = ctx?.model,
  statusBar = true,
): void {
  if (!ctx || ctx.hasUI === false || typeof ctx.ui?.setStatus !== "function") return;
  if (!statusBar || !isFastEnabled(model)) {
    ctx.ui.setStatus(FAST_STATUS_KEY, undefined);
    return;
  }
  ctx.ui.setStatus(FAST_STATUS_KEY, themedStatus(ctx, "accent", "FAST"));
}

export type CompressionStatusOptions = {
  statusBar: boolean;
  compression: boolean;
  eligible: boolean;
};

export function updateCompressionStatus(
  ctx: StatusContext | undefined,
  capability: CompressionCapability,
  options: CompressionStatusOptions,
): void {
  if (!ctx || ctx.hasUI === false || typeof ctx.ui?.setStatus !== "function") return;
  if (!options.statusBar || !options.eligible) {
    ctx.ui.setStatus(COMPRESSION_STATUS_KEY, undefined);
    return;
  }

  const [color, text] = !options.compression
    ? ["dim", "COMPACT:OFF"]
    : capability === "supported"
      ? ["success", "COMPACT:ON"]
      : capability === "unsupported"
        ? ["warning", "COMPACT:OFF"]
        : ["warning", "COMPACT:?"];
  ctx.ui.setStatus(COMPRESSION_STATUS_KEY, themedStatus(ctx, color, text));
}

export function clearFastStatus(ctx: StatusContext | undefined): void {
  if (!ctx || ctx.hasUI === false || typeof ctx.ui?.setStatus !== "function") return;
  ctx.ui.setStatus(FAST_STATUS_KEY, undefined);
}

export function clearCompressionStatus(ctx: StatusContext | undefined): void {
  if (!ctx || ctx.hasUI === false || typeof ctx.ui?.setStatus !== "function") return;
  ctx.ui.setStatus(COMPRESSION_STATUS_KEY, undefined);
}

export function clearStatusBar(ctx: StatusContext | undefined): void {
  clearFastStatus(ctx);
  clearCompressionStatus(ctx);
}

export function fastStatusKey(): string {
  return FAST_STATUS_KEY;
}

export function compressionStatusKey(): string {
  return COMPRESSION_STATUS_KEY;
}

export type { FastModel };
