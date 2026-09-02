# Review workflows

## One review

Use one fresh-context `reviewer`. Give it the exact repository scope, diff or ref, review criteria, and a review-only boundary. A literal `/review ...` task is useful because the child expands the same packaged review prompt and performs it directly when the parent-facing `subagent` tool is unavailable in the child.

## Parallel review

Launch two or three fresh `reviewer` calls in the same assistant tool block. Give each a distinct angle based on the actual change, such as correctness, tests, simplicity, security, or UI behavior. The parent deduplicates and verifies the reports.

## Review/fix loop

1. If implementation is needed, launch one forked `worker`.
2. Launch fresh reviewers against the resulting repository state.
3. Synthesize findings into blockers, fixes worth doing now, optional notes, and rejected feedback.
4. Pause for any unapproved product, scope, or architecture decision.
5. If fixes are authorized, launch one forked `worker` to apply only the accepted fixes.
6. Review again only after material changes. Stop when no concrete blocker or fix worth doing now remains, or after three review rounds by default.

The parent controls the loop. Do not ask a child to run the loop or spawn more agents.

## Cleanup review

Use fresh reviewers for distinct cleanup angles. Keep them review-only. Shorter is better only when it preserves behavior, useful invariants, error signals, and local style.

## Writer safety

Never create worktrees automatically. Use one writer in the active working tree. Parallel writers are allowed only when the user has explicitly prepared separate worktrees and provided their paths.
