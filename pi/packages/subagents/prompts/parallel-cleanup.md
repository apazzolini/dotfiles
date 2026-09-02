---
description: Run fresh parallel reviewers for concrete cleanup opportunities
argument-hint: "[scope] [autofix]"
---

Run a fresh-context parallel cleanup review of the current work.

Launch two `reviewer` calls together. Both are review-only and inspect the current diff directly.

- Reviewer 1: find concrete AI-slop, stale comments, defensive defaults that hide errors, type escapes, style drift, dead wrappers, duplicate helpers, debug leftovers, and generated-sounding prose.
- Reviewer 2: find needless verbosity, single-use paraphrase helpers, obvious temporary variables, avoidable branching, repeated boilerplate, redundant tests, and prose that says the same thing twice.

Shorter is better only when it is clearer and preserves behavior, useful invariants, error signals, cleanup semantics, and local style. Treat cleanup heuristics as leads, not verdicts. Require evidence, file/line references, severity, and the smallest safe fix.

After both return, synthesize fixes worth doing now, optional improvements, and feedback to ignore or defer. Do not apply anything unless already authorized or the invocation contains the exact word `autofix`. Never create a worktree automatically.

Additional scope:

$@
