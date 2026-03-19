---
name: code-review
description: Perform a thorough code review on a specified file, set of files, or expression like "uncommitted changes" or "staged changes". Use when the user asks for a code review, CR, or to review code.
---

# Code Review

## 1. Resolve the target

The user may specify the review target as:

- A file path or glob (e.g. `src/auth.ts`, `src/**/*.go`)
- `uncommitted changes` or `unstaged changes` → run `git diff`
- `staged changes` → run `git diff --cached`
- `last commit` → run `git diff HEAD~1..HEAD`
- `branch` or a branch name → run `git diff main...<branch>` (detect the default branch name first with `git symbolic-ref refs/remotes/origin/HEAD`)
- A PR number → use `gh pr diff <number>`

Gather the full diff or file contents BEFORE starting any analysis.

If the diff is large (>500 lines changed), summarize the scope first, then review file-by-file using the Task tool to parallelize analysis across files.

## 2. Gather context before judging

Before writing ANY feedback, silently perform ALL of these steps:

1. **Read the full file(s)** being changed, not just the diff hunks. Diff context is often insufficient to judge correctness. If a file is very large, read at minimum the surrounding 200 lines above and below each changed region.
2. **Identify the language, framework, and project-local conventions.** Check for linter configs (`.eslintrc`, `golangci-lint.yml`, `ruff.toml`, `.prettierrc`, etc.), `.editorconfig`, and existing patterns in adjacent files.
3. **Check for related tests.** If the changed code has a corresponding test file, read it. Common conventions: `foo_test.go`, `foo.test.ts`, `test_foo.py`, `__tests__/foo.js`.
4. **Check types and interfaces** referenced by the changed code. Follow imports to understand the shape of data being passed around.
5. **Check git blame on changed lines** if the change is a modification (not new code) to understand the original intent: `git log -1 --format='%s' <commit>` on relevant commits.

Do NOT skip this step. Reviewing a diff without reading the surrounding code is the #1 cause of shallow, useless reviews.

## 3. Review checklist

Evaluate the code against each category below. Only raise an issue if you have a concrete, specific concern. NEVER generate filler observations.

### Correctness
- Logic errors, off-by-one, wrong operator, missed branches
- Race conditions, deadlocks, unsafe concurrent access
- Null/undefined/nil dereference risks
- Resource leaks (file handles, connections, goroutines, subscriptions)
- Error handling: are errors swallowed, logged but not propagated, or missing entirely?
- Edge cases: empty inputs, zero values, maximum sizes, unicode

### Security
- Injection (SQL, command, template, path traversal)
- Authentication/authorization gaps
- Secrets or credentials in code
- Unsafe deserialization, prototype pollution
- TOCTOU and other timing-related vulnerabilities
- Unvalidated user input reaching sensitive operations

### Design & Maintainability
- Does the abstraction level make sense? Is it over-engineered or under-abstracted?
- Coupling: does this change reach into internals it shouldn't?
- Naming: would a reader unfamiliar with this code understand the names?
- Duplication: is this reimplementing something that already exists in the codebase? Use grep/glob to check.
- API surface: are new public functions/types necessary, or should they be private/unexported?

### Performance
- Unnecessary allocations in hot paths
- O(n^2) or worse where O(n) or O(n log n) is possible
- Missing indexes or N+1 query patterns
- Unbounded growth (caches, buffers, queues without limits)
- Blocking operations in async/concurrent contexts

### Testing
- Are the changes covered by existing tests? Check, don't guess.
- If not covered, are they the kind of change that should have tests?
- Do existing tests still make sense after this change, or are they now testing stale behavior?
- Are test assertions actually checking meaningful outcomes, not just "no error"?

### Style & Conventions
- Only flag style issues that are NOT caught by the project's linter/formatter. If a formatter config exists, assume formatting is handled and do not comment on it.
- Consistency with existing patterns in the codebase (naming conventions, file organization, error handling patterns).

## 4. Output format

Structure your review as follows:

### Summary

One short paragraph: what the change does, its scope, and your overall assessment. Use one of these verdicts:

- **Looks good** — no issues or only nits
- **Needs minor changes** — no correctness/security issues, but improvements warranted
- **Has significant issues** — correctness, security, or design problems that should be fixed before merging

### Issues

List each issue as:

- **Severity**: `critical` | `warning` | `nit`
- **Location**: `file:line` reference
- **Problem**: what is wrong — be specific and direct
- **Suggestion**: how to fix it, with a code snippet when helpful

Mark anything you are not fully certain about with `(uncertain)` so the author knows to scrutinize it.

Sort issues by severity (critical first).

If there are zero issues, say so explicitly. Do NOT invent problems to appear thorough.

### Positive observations

If something is notably well-done — good test coverage, clean abstraction, smart use of a language feature — mention it in 1-2 sentences. Do not pad this section. Omit it entirely if nothing stands out.

## 5. Anti-patterns to avoid

These are failure modes to actively guard against:

- Do NOT produce generic advice like "consider adding more tests" without identifying what specifically is untested and why it matters.
- Do NOT comment on things outside the scope of the change unless they are directly broken by it.
- Do NOT suggest refactors that are unrelated to the change being reviewed.
- Do NOT repeat code back in your review. Reference it by `file:line`.
- Do NOT be diplomatic to the point of obscuring the message. Say "This crashes when X is null because line 42 dereferences it without a check" not "This might not work in all cases."
- Do NOT flag issues that a configured linter/formatter would already catch.
- Do NOT assume the author's intent — if something looks intentional but questionable, ask about it rather than prescribing a fix.
- Do NOT review generated code (lockfiles, compiled output, vendored dependencies) unless the user specifically asks.
