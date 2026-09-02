---
description: Run fresh parallel reviewers with distinct angles, then synthesize their findings
argument-hint: "[target or focus]"
---

Run an adversarial parallel review of the current work.

Read the `subagents` skill's review workflow reference. Choose two or three distinct, high-value angles from the actual target, such as correctness/regressions, tests/validation, simplicity, security, type safety, or UI behavior.

Launch one fresh-context `reviewer` call per angle in the same tool block so they run in parallel. Give each reviewer a self-contained task naming:

- the exact target, cwd, diff, ref, or file scope;
- its distinct review angle;
- the review-only boundary;
- the requirement for concrete evidence, file/line references, severity, and the smallest fix;
- `No issues found.` when nothing qualifies.

Reviewers must inspect the repository directly and must not rely on the parent conversation. They must not edit files.

After all calls return, deduplicate and verify their feedback. Report fixes worth doing now, optional notes, and findings rejected or deferred with a reason. Do not apply fixes unless the user already authorized implementation or the invocation contains the exact word `autofix`.

Additional target or focus:

$@
