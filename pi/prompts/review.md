---
description: Review current changes for correctness issues
argument-hint: "[scope or instructions]"
---

Review the code changes in this repo.

Scope:
- If arguments are provided, use them as the review scope/instructions: $ARGUMENTS
- Otherwise review current git changes, including staged and unstaged changes.

Rules:
- Do not edit files.
- Do not run lint, typecheck, or tests unless I explicitly ask.
- Inspect the diff first, then read surrounding code as needed.
- Focus on bugs, logic errors, security issues, data-loss risks, race conditions, API contract issues, and regressions.
- Avoid style nits unless they affect correctness or maintainability materially.
- If something looks suspicious but you cannot prove it, call it out as a question, not a finding.

Process:
1. Check repo status and diff.
2. Identify changed files and relevant call sites.
3. Read enough surrounding code to validate behavior.
4. Report only actionable findings.

Output format:
- Findings first, sorted by severity.
- For each finding:
  - Severity: blocker, high, medium, low
  - File/line
  - Problem
  - Why it matters
  - Suggested fix
- Then list assumptions or open questions.
- If there are no issues, say that clearly and mention what you reviewed.
