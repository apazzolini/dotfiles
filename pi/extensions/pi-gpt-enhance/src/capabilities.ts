import { readFileSync, renameSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { Model } from "@earendil-works/pi-ai";

export type PreviousResponseIdCapability = "unknown" | "supported" | "unsupported";
type ResponsesCapability = "unknown" | "supported" | "unsupported";

type CapabilityEntry = {
  provider: string;
  api: string;
  model: string;
  baseUrl: string;
  responses: ResponsesCapability;
  previousResponseId: PreviousResponseIdCapability;
  updatedAt: string;
};

type CapabilityFile = {
  version: 1;
  entries: Record<string, CapabilityEntry>;
};

const DEFAULT_CACHE_PATH = join(homedir(), ".pi", "agent", "gpt-enhance-capabilities.json");

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function cachePath(): string {
  return process.env.PI_GPT_ENHANCE_CAPABILITIES_FILE || DEFAULT_CACHE_PATH;
}

function modelKey(model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">): string {
  return JSON.stringify([model.provider, model.api, model.id, model.baseUrl]);
}

function emptyCache(): CapabilityFile {
  return { version: 1, entries: {} };
}

function readCache(): CapabilityFile {
  try {
    const parsed: unknown = JSON.parse(readFileSync(cachePath(), "utf8"));
    if (!isRecord(parsed) || parsed.version !== 1 || !isRecord(parsed.entries)) return emptyCache();
    return { version: 1, entries: parsed.entries as Record<string, CapabilityEntry> };
  } catch {
    return emptyCache();
  }
}

function updateCache(mutator: (cache: CapabilityFile) => void): void {
  const cache = readCache();
  mutator(cache);
  const path = cachePath();
  const temporaryPath = `${path}.${process.pid}.tmp`;
  writeFileSync(temporaryPath, `${JSON.stringify(cache, null, 2)}\n`, "utf8");
  renameSync(temporaryPath, path);
}

export function cachedResponsesCapabilitySync(
  model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">,
): ResponsesCapability {
  return readCache().entries[modelKey(model)]?.responses ?? "unknown";
}

export function cachedPreviousResponseIdCapabilitySync(
  model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">,
): PreviousResponseIdCapability {
  return readCache().entries[modelKey(model)]?.previousResponseId ?? "unknown";
}

export async function cachedPreviousResponseIdCapability(
  model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">,
): Promise<PreviousResponseIdCapability> {
  return cachedPreviousResponseIdCapabilitySync(model);
}

export async function recordResponsesCapability(
  model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">,
  capability: Exclude<ResponsesCapability, "unknown">,
): Promise<void> {
  updateCache((cache) => {
    const key = modelKey(model);
    const previous = cache.entries[key];
    cache.entries[key] = {
      provider: model.provider,
      api: model.api,
      model: model.id,
      baseUrl: model.baseUrl,
      responses: capability,
      previousResponseId: previous?.previousResponseId ?? "unknown",
      updatedAt: new Date().toISOString(),
    };
  });
}

export async function recordPreviousResponseIdCapability(
  model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">,
  capability: Exclude<PreviousResponseIdCapability, "unknown">,
): Promise<void> {
  updateCache((cache) => {
    const key = modelKey(model);
    const previous = cache.entries[key];
    cache.entries[key] = {
      provider: model.provider,
      api: model.api,
      model: model.id,
      baseUrl: model.baseUrl,
      responses: previous?.responses ?? "unknown",
      previousResponseId: capability,
      updatedAt: new Date().toISOString(),
    };
  });
}

export async function clearCachedCapabilities(
  model: Pick<Model<any>, "provider" | "api" | "id" | "baseUrl">,
): Promise<void> {
  updateCache((cache) => {
    delete cache.entries[modelKey(model)];
  });
}
