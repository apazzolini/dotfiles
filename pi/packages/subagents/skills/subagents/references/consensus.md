# Advisor consensus

Use a bounded council for material decisions with genuine tradeoffs, not routine questions.

## Protocol

1. Define the question, scope, non-goals, evidence targets, roster, and pass cap.
2. Use `council-opus` and `council-sol` by default. Keep the roster at two or three and never exceed four.
3. Launch the first-pass advisors together with fresh context. They are read-only and do not see peer reports.
4. The parent builds a claim matrix: agreements, disputes, missing proof, and owner decisions.
5. Run at most one cross-examination pass by default. Give each advisor only the material peer claims and missing evidence it should challenge. Fork from that advisor's first-pass transcript when preserving its reasoning is useful.
6. Stop at convergence, the pass cap, user interruption, or an owner decision that evidence cannot settle.
7. The parent writes the final memo and remains the only decision-maker.

## Memo

Include the recommendation, rationale, accepted and rejected feedback, unresolved owner decisions, evidence, advisor roster, pass count, confidence, and what would change the recommendation.

Do not turn a council into agent chat, implementation authority, or a writer swarm.
