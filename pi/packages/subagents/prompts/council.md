---
description: Run a bounded council of independent advisors and write a decision memo
argument-hint: "<question> [--max-passes 2|3] [--scope ...] [--non-goals ...]"
---

Run a bounded advisor council on this material decision. Read the `subagents` skill's consensus reference first. The parent is the only supervisor, synthesizer, and decision-maker.

Parse the invocation into a brief containing the question, scope, non-goals, evidence targets, roster, and pass cap. Default to `council-opus` and `council-sol` with at most two passes. Clamp an explicit pass cap to two or three. If the question is trivial or already settled, answer directly instead.

For Pass 1, launch the advisors together with fresh context. Give each the same self-contained brief and report contract. Advisors are read-only, inspect evidence independently, do not see peer reports, and do not edit or communicate with each other.

The parent then builds a claim matrix of agreements, disputes, missing proof, and owner decisions. Run one cross-examination pass only when a material dispute could be settled by evidence. Give each advisor a curated packet containing the relevant peer claims and missing evidence. Use that advisor's Pass 1 transcript as `fork` when preserving its reasoning is useful.

Stop at convergence, the pass cap, user interruption, or an owner decision evidence cannot settle. Write a final memo with the recommendation, rationale, accepted and rejected feedback, unresolved decisions, evidence, roster, pass count, confidence, and what would change the recommendation.

Do not turn the council into free-form agent chat, implementation authority, or a writer swarm.

Question and options:

$@
