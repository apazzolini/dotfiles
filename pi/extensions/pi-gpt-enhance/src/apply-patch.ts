/*
 * Derived from OpenAI Codex apply_patch.
 * Copyright 2025 OpenAI
 * Modified for pi-gpt-enhance.
 * SPDX-License-Identifier: Apache-2.0
 */

import { mkdir, readFile, realpath, rm, stat, writeFile } from "node:fs/promises";
import { TextDecoder } from "node:util";
import { dirname, isAbsolute, normalize, parse as parsePath, resolve } from "node:path";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";

const BEGIN_PATCH = "*** Begin Patch";
const END_PATCH = "*** End Patch";
const ADD_FILE = "*** Add File: ";
const DELETE_FILE = "*** Delete File: ";
const UPDATE_FILE = "*** Update File: ";
const MOVE_TO = "*** Move to: ";
const END_OF_FILE = "*** End of File";

export interface ApplyPatchChunk {
  changeContext: string | undefined;
  oldLines: string[];
  newLines: string[];
  isEndOfFile: boolean;
}

export type ApplyPatchHunk =
  | { kind: "add"; path: string; contents: string }
  | { kind: "delete"; path: string }
  | {
      kind: "update";
      path: string;
      movePath: string | undefined;
      chunks: ApplyPatchChunk[];
    };

export interface ParsedApplyPatch {
  hunks: ApplyPatchHunk[];
}

class ApplyPatchError extends Error {
  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = "ApplyPatchError";
  }
}

function invalidPatch(message: string): never {
  throw new ApplyPatchError(`Invalid patch: ${message}`);
}

function invalidHunk(lineNumber: number, message: string): never {
  throw new ApplyPatchError(`Invalid patch hunk on line ${lineNumber}: ${message}`);
}

function stripSingleLeadingAt(path: string): string {
  return path.startsWith("@") ? path.slice(1) : path;
}

function parseHunkPath(value: string, lineNumber: number): string {
  const path = stripSingleLeadingAt(value);
  if (path.length === 0) invalidHunk(lineNumber, "file path cannot be empty");
  return path;
}

function headerAt(line: string, lineNumber: number): ApplyPatchHunk | undefined {
  if (line.startsWith(ADD_FILE)) {
    return {
      kind: "add",
      path: parseHunkPath(line.slice(ADD_FILE.length), lineNumber),
      contents: "",
    };
  }
  if (line.startsWith(DELETE_FILE)) {
    return { kind: "delete", path: parseHunkPath(line.slice(DELETE_FILE.length), lineNumber) };
  }
  if (line.startsWith(UPDATE_FILE)) {
    return {
      kind: "update",
      path: parseHunkPath(line.slice(UPDATE_FILE.length), lineNumber),
      movePath: undefined,
      chunks: [],
    };
  }
  return undefined;
}

function assertCompleteHunk(hunk: ApplyPatchHunk, hunkLine: number, nextLine: number): void {
  if (hunk.kind === "add") {
    if (hunk.contents.length === 0) {
      invalidHunk(hunkLine, `Add file hunk for path '${hunk.path}' is empty`);
    }
    return;
  }
  if (hunk.kind === "delete") return;
  if (hunk.chunks.length === 0) {
    invalidHunk(hunkLine, `Update file hunk for path '${hunk.path}' is empty`);
  }
  const last = hunk.chunks.at(-1);
  if (last && last.oldLines.length === 0 && last.newLines.length === 0) {
    invalidHunk(nextLine, "Update hunk does not contain any lines");
  }
}

function newChunk(changeContext: string | undefined): ApplyPatchChunk {
  return { changeContext, oldLines: [], newLines: [], isEndOfFile: false };
}

/** Parse one complete Codex apply_patch envelope. */
export function parseApplyPatch(input: string): ParsedApplyPatch {
  const trimmedInput = input.trim();
  const lines =
    trimmedInput.length === 0
      ? []
      : trimmedInput.split("\n").map((line) => (line.endsWith("\r") ? line.slice(0, -1) : line));

  if (lines[0]?.trim() !== BEGIN_PATCH) {
    invalidPatch("The first line of the patch must be '*** Begin Patch'");
  }
  if (lines.at(-1)?.trim() !== END_PATCH) {
    invalidPatch("The last line of the patch must be '*** End Patch'");
  }

  const hunks: ApplyPatchHunk[] = [];
  let current: ApplyPatchHunk | undefined;
  let currentLine = 0;

  for (let index = 1; index < lines.length - 1; index += 1) {
    const line = lines[index] ?? "";
    const lineNumber = index + 1;
    const headerLine = current?.kind === "update" ? line.trimEnd() : line.trim();
    const nextHunk = headerAt(headerLine, lineNumber);

    if (nextHunk) {
      if (current) assertCompleteHunk(current, currentLine, lineNumber);
      current = nextHunk;
      currentLine = lineNumber;
      hunks.push(current);
      continue;
    }

    if (!current) {
      invalidHunk(
        lineNumber,
        `'${line.trim()}' is not a valid hunk header. Valid hunk headers: ` +
          "'*** Add File: {path}', '*** Delete File: {path}', '*** Update File: {path}'",
      );
    }

    if (current.kind === "add") {
      if (!line.startsWith("+")) {
        invalidHunk(lineNumber, `Unexpected line in add file hunk: '${line.trim()}'`);
      }
      current.contents += `${line.slice(1)}\n`;
      continue;
    }

    if (current.kind === "delete") {
      invalidHunk(lineNumber, `Unexpected line after delete file hunk: '${line.trim()}'`);
    }

    const updateLine = line.trimEnd();
    const previousChunk = current.chunks.at(-1);
    if (previousChunk?.isEndOfFile) {
      if (updateLine.length === 0) continue;
      if (updateLine !== "@@" && !updateLine.startsWith("@@ ")) {
        invalidHunk(
          lineNumber,
          `Expected update hunk to start with a @@ context marker, got: '${line}'`,
        );
      }
    }

    if (
      current.chunks.length === 0 &&
      current.movePath === undefined &&
      updateLine.startsWith(MOVE_TO)
    ) {
      current.movePath = parseHunkPath(updateLine.slice(MOVE_TO.length), lineNumber);
      continue;
    }

    if (updateLine === "@@" || updateLine.startsWith("@@ ")) {
      if (
        previousChunk &&
        previousChunk.oldLines.length === 0 &&
        previousChunk.newLines.length === 0
      ) {
        invalidHunk(
          lineNumber,
          `Unexpected line found in update hunk: '${line}'. Every line should start with ` +
            "' ' (context line), '+' (added line), or '-' (removed line)",
        );
      }
      current.chunks.push(newChunk(updateLine === "@@" ? undefined : updateLine.slice(3)));
      continue;
    }

    if (updateLine === END_OF_FILE) {
      if (
        !previousChunk ||
        (previousChunk.oldLines.length === 0 && previousChunk.newLines.length === 0)
      ) {
        invalidHunk(lineNumber, "Update hunk does not contain any lines");
      }
      previousChunk.isEndOfFile = true;
      continue;
    }

    if (
      previousChunk &&
      (previousChunk.oldLines.length > 0 || previousChunk.newLines.length > 0) &&
      line.length > 0 &&
      !line.startsWith(" ") &&
      !line.startsWith("+") &&
      !line.startsWith("-")
    ) {
      invalidHunk(
        lineNumber,
        `Expected update hunk to start with a @@ context marker, got: '${line}'`,
      );
    }

    let chunk = current.chunks.at(-1);
    if (!chunk) {
      chunk = newChunk(undefined);
      current.chunks.push(chunk);
    }

    if (line.length === 0) {
      chunk.oldLines.push("");
      chunk.newLines.push("");
    } else if (line.startsWith(" ")) {
      const context = line.slice(1);
      chunk.oldLines.push(context);
      chunk.newLines.push(context);
    } else if (line.startsWith("+")) {
      chunk.newLines.push(line.slice(1));
    } else if (line.startsWith("-")) {
      chunk.oldLines.push(line.slice(1));
    } else {
      invalidHunk(
        lineNumber,
        `Unexpected line found in update hunk: '${line}'. Every line should start with ` +
          "' ' (context line), '+' (added line), or '-' (removed line)",
      );
    }
  }

  if (current) assertCompleteHunk(current, currentLine, lines.length);
  return { hunks };
}

interface ResolvedPath {
  absolute: string;
  display: string;
  queueKey: string;
}

type ResolvedHunk =
  | { kind: "add"; path: ResolvedPath; contents: string }
  | { kind: "delete"; path: ResolvedPath }
  | {
      kind: "update";
      path: ResolvedPath;
      movePath: ResolvedPath | undefined;
      chunks: ApplyPatchChunk[];
    };

type VirtualNode =
  | { kind: "missing" }
  | { kind: "directory" }
  | { kind: "file"; contents: string | undefined }
  | { kind: "other" };

type CommitAction =
  | { kind: "add"; path: string; contents: string }
  | { kind: "delete"; path: string }
  | { kind: "update"; path: string; contents: string }
  | { kind: "move"; source: string; destination: string; contents: string };

interface PreflightResult {
  actions: CommitAction[];
  added: string[];
  modified: string[];
  deleted: string[];
}

function isMissingPathError(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    (error.code === "ENOENT" || error.code === "ENOTDIR")
  );
}

function errorText(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function resolvePatchPath(cwd: string, patchPath: string): string {
  return normalize(isAbsolute(patchPath) ? patchPath : resolve(cwd, patchPath));
}

async function canonicalizePath(path: string): Promise<string> {
  try {
    return await realpath(path);
  } catch (error) {
    if (isMissingPathError(error)) return path;
    throw new ApplyPatchError(`Failed to resolve path ${path}: ${errorText(error)}`, {
      cause: error,
    });
  }
}

async function resolveHunks(hunks: ApplyPatchHunk[], cwd: string): Promise<ResolvedHunk[]> {
  const canonical = new Map<string, Promise<string>>();
  const makePath = async (patchPath: string): Promise<ResolvedPath> => {
    const absolute = resolvePatchPath(cwd, patchPath);
    let pending = canonical.get(absolute);
    if (!pending) {
      pending = canonicalizePath(absolute);
      canonical.set(absolute, pending);
    }
    return { absolute, display: patchPath, queueKey: await pending };
  };

  return Promise.all(
    hunks.map(async (hunk): Promise<ResolvedHunk> => {
      if (hunk.kind === "add") return { ...hunk, path: await makePath(hunk.path) };
      if (hunk.kind === "delete") return { ...hunk, path: await makePath(hunk.path) };
      return {
        ...hunk,
        path: await makePath(hunk.path),
        movePath: hunk.movePath === undefined ? undefined : await makePath(hunk.movePath),
      };
    }),
  );
}

function normaliseForMatch(value: string): string {
  const replacements: Record<string, string> = {
    "\u2010": "-",
    "\u2011": "-",
    "\u2012": "-",
    "\u2013": "-",
    "\u2014": "-",
    "\u2015": "-",
    "\u2212": "-",
    "\u2018": "'",
    "\u2019": "'",
    "\u201a": "'",
    "\u201b": "'",
    "\u201c": '"',
    "\u201d": '"',
    "\u201e": '"',
    "\u201f": '"',
    "\u00a0": " ",
    "\u2002": " ",
    "\u2003": " ",
    "\u2004": " ",
    "\u2005": " ",
    "\u2006": " ",
    "\u2007": " ",
    "\u2008": " ",
    "\u2009": " ",
    "\u200a": " ",
    "\u202f": " ",
    "\u205f": " ",
    "\u3000": " ",
  };
  return Array.from(value.trim(), (character) => replacements[character] ?? character).join("");
}

function sequenceMatches(
  lines: string[],
  pattern: string[],
  index: number,
  compare: (left: string, right: string) => boolean,
): boolean {
  for (let offset = 0; offset < pattern.length; offset += 1) {
    if (!compare(lines[index + offset] ?? "", pattern[offset] ?? "")) return false;
  }
  return true;
}

function seekSequence(
  lines: string[],
  pattern: string[],
  start: number,
  eof: boolean,
): number | undefined {
  if (pattern.length === 0) return start;
  if (pattern.length > lines.length) return undefined;

  const finalStart = lines.length - pattern.length;
  const comparisons: Array<(left: string, right: string) => boolean> = [
    (left, right) => left === right,
    (left, right) => left.trimEnd() === right.trimEnd(),
    (left, right) => left.trim() === right.trim(),
    (left, right) => normaliseForMatch(left) === normaliseForMatch(right),
  ];
  const search = (searchStart: number): number | undefined => {
    for (const compare of comparisons) {
      for (let index = searchStart; index <= finalStart; index += 1) {
        if (sequenceMatches(lines, pattern, index, compare)) return index;
      }
    }
    return undefined;
  };

  // Codex prefers the final occurrence for an EOF hunk, but falls back to the
  // normal forward search when the requested lines are not actually at EOF.
  return search(eof ? finalStart : start) ?? (eof ? search(start) : undefined);
}

function deriveUpdatedContents(original: string, path: string, chunks: ApplyPatchChunk[]): string {
  const originalLines = original.split("\n");
  if (originalLines.at(-1) === "") originalLines.pop();

  const replacements: Array<{ index: number; oldLength: number; newLines: string[] }> = [];
  let lineIndex = 0;

  for (const chunk of chunks) {
    if (chunk.changeContext !== undefined) {
      const contextIndex = seekSequence(originalLines, [chunk.changeContext], lineIndex, false);
      if (contextIndex === undefined) {
        throw new ApplyPatchError(`Failed to find context '${chunk.changeContext}' in ${path}`);
      }
      lineIndex = contextIndex + 1;
    }

    if (chunk.oldLines.length === 0) {
      const insertionIndex =
        originalLines.at(-1) === "" ? originalLines.length - 1 : originalLines.length;
      replacements.push({ index: insertionIndex, oldLength: 0, newLines: [...chunk.newLines] });
      continue;
    }

    let pattern = chunk.oldLines;
    let newLines = chunk.newLines;
    let found = seekSequence(originalLines, pattern, lineIndex, chunk.isEndOfFile);
    if (found === undefined && pattern.at(-1) === "") {
      pattern = pattern.slice(0, -1);
      if (newLines.at(-1) === "") newLines = newLines.slice(0, -1);
      found = seekSequence(originalLines, pattern, lineIndex, chunk.isEndOfFile);
    }

    if (found === undefined) {
      throw new ApplyPatchError(
        `Failed to find expected lines in ${path}:\n${chunk.oldLines.join("\n")}`,
      );
    }
    replacements.push({ index: found, oldLength: pattern.length, newLines: [...newLines] });
    lineIndex = found + pattern.length;
  }

  replacements.sort((left, right) => left.index - right.index);
  for (let index = replacements.length - 1; index >= 0; index -= 1) {
    const replacement = replacements[index];
    if (replacement) {
      originalLines.splice(replacement.index, replacement.oldLength, ...replacement.newLines);
    }
  }
  if (originalLines.at(-1) !== "") originalLines.push("");
  return originalLines.join("\n");
}

async function preflight(hunks: ResolvedHunk[]): Promise<PreflightResult> {
  const nodes = new Map<string, VirtualNode>();
  const directKeys = new Map<string, string>();
  for (const hunk of hunks) {
    directKeys.set(hunk.path.absolute, hunk.path.queueKey);
    if (hunk.kind === "update" && hunk.movePath) {
      directKeys.set(hunk.movePath.absolute, hunk.movePath.queueKey);
    }
  }

  const nodeKey = (path: string) => directKeys.get(path) ?? path;
  const getNode = async (path: string): Promise<VirtualNode> => {
    const key = nodeKey(path);
    const existing = nodes.get(key);
    if (existing) return existing;
    let loaded: VirtualNode;
    try {
      const metadata = await stat(path);
      loaded = metadata.isDirectory()
        ? { kind: "directory" }
        : metadata.isFile()
          ? { kind: "file", contents: undefined }
          : { kind: "other" };
    } catch (error) {
      if (isMissingPathError(error)) loaded = { kind: "missing" };
      else {
        throw new ApplyPatchError(`Failed to inspect ${path}: ${errorText(error)}`, {
          cause: error,
        });
      }
    }
    nodes.set(key, loaded);
    return loaded;
  };
  const setNode = (path: string, node: VirtualNode): void => {
    nodes.set(nodeKey(path), node);
  };
  const readContents = async (path: string, node: VirtualNode): Promise<string> => {
    if (node.kind !== "file") throw new ApplyPatchError(`Cannot update non-file path ${path}`);
    if (node.contents !== undefined) return node.contents;
    try {
      const contents = new TextDecoder("utf-8", { fatal: true }).decode(await readFile(path));
      node.contents = contents;
      return contents;
    } catch (error) {
      throw new ApplyPatchError(`Failed to read file to update ${path}: ${errorText(error)}`, {
        cause: error,
      });
    }
  };
  const ensureWriteTarget = async (path: string): Promise<void> => {
    const target = await getNode(path);
    if (target.kind === "directory") {
      throw new ApplyPatchError(`Failed to write file ${path}: path is a directory`);
    }

    const ancestors: string[] = [];
    const root = parsePath(path).root;
    for (let parent = dirname(path); parent !== root; parent = dirname(parent))
      ancestors.push(parent);
    if (root) ancestors.push(root);
    ancestors.reverse();
    for (const parent of ancestors) {
      const parentNode = await getNode(parent);
      if (parentNode.kind === "missing") setNode(parent, { kind: "directory" });
      else if (parentNode.kind !== "directory") {
        throw new ApplyPatchError(
          `Failed to create parent directories for ${path}: ${parent} is not a directory`,
        );
      }
    }
  };

  const actions: CommitAction[] = [];
  const added: string[] = [];
  const modified: string[] = [];
  const deleted: string[] = [];

  for (const hunk of hunks) {
    if (hunk.kind === "add") {
      await ensureWriteTarget(hunk.path.absolute);
      setNode(hunk.path.absolute, { kind: "file", contents: hunk.contents });
      actions.push({ kind: "add", path: hunk.path.absolute, contents: hunk.contents });
      added.push(hunk.path.display);
      continue;
    }

    if (hunk.kind === "delete") {
      const node = await getNode(hunk.path.absolute);
      if (node.kind === "missing")
        throw new ApplyPatchError(
          `Failed to delete file ${hunk.path.absolute}: file does not exist`,
        );
      if (node.kind === "directory")
        throw new ApplyPatchError(
          `Failed to delete file ${hunk.path.absolute}: path is a directory`,
        );
      setNode(hunk.path.absolute, { kind: "missing" });
      actions.push({ kind: "delete", path: hunk.path.absolute });
      deleted.push(hunk.path.display);
      continue;
    }

    const sourceNode = await getNode(hunk.path.absolute);
    const original = await readContents(hunk.path.absolute, sourceNode);
    const contents = deriveUpdatedContents(original, hunk.path.absolute, hunk.chunks);
    if (hunk.movePath) {
      await ensureWriteTarget(hunk.movePath.absolute);
      setNode(hunk.movePath.absolute, { kind: "file", contents });
      setNode(hunk.path.absolute, { kind: "missing" });
      actions.push({
        kind: "move",
        source: hunk.path.absolute,
        destination: hunk.movePath.absolute,
        contents,
      });
      modified.push(hunk.movePath.display);
    } else {
      setNode(hunk.path.absolute, { kind: "file", contents });
      actions.push({ kind: "update", path: hunk.path.absolute, contents });
      modified.push(hunk.path.display);
    }
  }

  return { actions, added, modified, deleted };
}

function checkAbort(signal: AbortSignal | undefined): void {
  signal?.throwIfAborted();
}

async function writeWithParents(path: string, contents: string): Promise<void> {
  try {
    await writeFile(path, contents, "utf8");
  } catch (error) {
    if (!isMissingPathError(error)) throw error;
    await mkdir(dirname(path), { recursive: true });
    await writeFile(path, contents, "utf8");
  }
}

async function commit(actions: CommitAction[], signal: AbortSignal | undefined): Promise<void> {
  for (const action of actions) {
    checkAbort(signal);
    try {
      if (action.kind === "add") await writeWithParents(action.path, action.contents);
      else if (action.kind === "delete") await rm(action.path);
      else if (action.kind === "update") await writeFile(action.path, action.contents, "utf8");
      else {
        await writeWithParents(action.destination, action.contents);
        await rm(action.source);
      }
    } catch (error) {
      const description =
        action.kind === "move"
          ? `Failed to move ${action.source} to ${action.destination}`
          : action.kind === "delete"
            ? `Failed to delete file ${action.path}`
            : `Failed to write file ${action.path}`;
      throw new ApplyPatchError(`${description}: ${errorText(error)}`, { cause: error });
    }
  }
}

function formatSummary(result: PreflightResult): string {
  const lines = ["Success. Updated the following files:"];
  for (const path of result.added) lines.push(`A ${path}`);
  for (const path of result.modified) lines.push(`M ${path}`);
  for (const path of result.deleted) lines.push(`D ${path}`);
  return `${lines.join("\n")}\n`;
}

async function withOrderedMutationQueues<T>(
  paths: string[],
  operation: () => Promise<T>,
  index = 0,
): Promise<T> {
  const path = paths[index];
  if (path === undefined) return operation();
  return withFileMutationQueue(path, () => withOrderedMutationQueues(paths, operation, index + 1));
}

/** Apply one complete patch relative to cwd and return Codex's grouped success summary. */
export async function applyPatch(
  input: string,
  cwd: string,
  signal?: AbortSignal,
): Promise<string> {
  checkAbort(signal);
  const parsed = parseApplyPatch(input);
  if (parsed.hunks.length === 0) throw new ApplyPatchError("No files were modified.");

  const absoluteCwd = resolve(cwd);
  const hunks = await resolveHunks(parsed.hunks, absoluteCwd);
  const queuePaths = [
    ...new Set(
      hunks.flatMap((hunk) =>
        hunk.kind === "update" && hunk.movePath
          ? [hunk.path.queueKey, hunk.movePath.queueKey]
          : [hunk.path.queueKey],
      ),
    ),
  ].sort((left, right) => (left < right ? -1 : left > right ? 1 : 0));

  return withOrderedMutationQueues(queuePaths, async () => {
    checkAbort(signal);
    const result = await preflight(hunks);
    await commit(result.actions, signal);
    return formatSummary(result);
  });
}
