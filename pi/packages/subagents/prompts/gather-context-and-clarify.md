---
description: Use focused scouts to gather local context before asking clarification questions
argument-hint: "[task or target]"
---

Based on the discussion and user intent, launch one or more focused `scout` subagents before planning or implementing.

Use fresh context. Give each scout a distinct, self-contained local evidence target: relevant files, existing patterns, constraints, tests, data flow, or likely integration points. Launch independent scouts together. Ask for concise findings plus the remaining clarification questions that materially affect implementation confidence.

After they return, synthesize what is known and ask the user only the unresolved questions needed to reach a shared understanding. Do not implement yet.

Task or target:

$@
