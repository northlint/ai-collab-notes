# AI Collaboration Engineering Governance

**English** | [中文](zh/README.md)

> Theme: Establish an engineering governance system of "Upper-Level Rules, Execution Layer, Review & Correction, and Lesson Backflow" for AI collaboration, complemented by context governance, diagnostics, fact-base governance, and toolchain governance, plus execution orchestration methods for long-running tasks, loops, cron jobs, batch tasks, and unattended operation.

## What This Knowledge Base Is

This is not a set of "AI coding tricks," nor is it a manual dedicated to any single project.

What it distills is a general engineering methodology: when AI participates in long-term software engineering, how to upgrade a project from a "code repository" into a governance system that AI can operate correctly within — one that is reviewable, revertible, and sustainably evolvable.

Core judgment:

- AI's problem isn't just "can it write code" — it's that AI oversteps boundaries, drifts, confabulates, self-certifies completion, and forgets across sessions.
- These problems can't be solved by relying on AI's self-discipline; they require upper-level constraints, process rails, adversarial review, mechanical verification, and lesson backflow.
- Scenarios such as long-running tasks, unattended operation, bulk migration, and automated bug fixing also need a dedicated execution orchestration system: loop, cron, watch, worker, queues, human checkpoints, oracles, self-verification, and handoff.

## Positioning Statement

- This knowledge base is a **methodology source**: it explains principles, design rationale, and boundaries of applicability (the "why"); it is self-contained, portable, and does not depend on any proprietary tooling.
- Once each mechanism is implemented in your environment as a skill / command / script, **the implementation is authoritative at runtime**; this knowledge base and the implementation maintain **mechanism-level consistency** (verdict enumerations, state semantics, on-disk contracts, closed-loop flow) — differences in wording or checklist-item granularity do not count as drift.
- When an implemented mechanism changes, the corresponding chapter owes one round of synchronization — this synchronization discipline should itself carry a mechanical trigger (such as hash-baseline comparison); see "07 Toolchain Governance." This repo has already implemented this (2026-07-16): the pre-commit gate automatically runs `plan/check_sync.sh` (skill hash baseline) and `plan/check_refs.sh` (cross-reference integrity), and rejects commits on failure.

## Overall Framework

The whole system is organized into two main tracks.

### Governance Track

The Governance Track answers: under what rules should AI work, how do rules efficiently reach AI, who has adjudication authority, how are mistakes discovered, how are errors localized, how are lessons distilled, and who enforces the constraints.

```text
Upper-Level Rules
  → Context Governance (how rules reach AI)
  → Execution Layer
  → Review & Correction (keep errors from entering)
  → Diagnostic Methodology (investigate errors that occurred)
  → Technical Debt & Lesson Backflow
  → Toolchain Governance (upgrade rules into machine enforcement)
  → back to Upper-Level Rules
```

### Execution Track

The Execution Track answers: how AI completes long-running tasks, batch tasks, automatic continuation, and unattended work, and how high-risk bulk engineering such as migration/rewrite is governed.

```text
Task Entry
  → Queue / Trigger
  → Plan / Batch / Phase
  → Executor
  → Self-Verification (verify as you go)
  → Checkpoint / Human Checkpoint
  → Delivery / Archive / Continuation
```

## Core Concept Index

| Concept | Description |
|---|---|
| Architectural Invariant | The project's "constitution" — defines how the system is built and which red lines must not be crossed |
| Business Spec | The current state of user-facing capability, as distinct from a one-off plan document |
| Source-of-Truth Governance | Specifies who owns business, visual, contract, architecture, and runtime-fact truth respectively |
| Source-of-Truth Flip | The source-of-truth hierarchy is a phase variable; handover / launch / fork requires explicit re-declaration, and derived documents change allegiance accordingly |
| specs / openspec | specs governs the engineering constitution; openspec governs the business change flow |
| Token Economy | Attention is a scarce resource; the bar for an always-loaded rule is "needed every time + not available elsewhere" |
| Thin-Constitution | Always-loaded rule files retain only the essentials + pointers; full text and ledgers sink into dedicated documents |
| Required-Reading Matrix | Required reading is routed by task type, not loaded in full ⭐ |
| Change of Water (换水) | The lead session stays fixed as the control line; implementation/exploration is dispatched to subagents with clean context, so plan-phase noise doesn't carry into construction |
| Workflow | Puts AI operations onto rails, reducing free discretion |
| Plan Review | Reviews the plan before execution, to prevent wrong direction, wrong source, wrong scope |
| Change Review | Reviews the implementation after the change, to prevent false completion, missing verification, and broken constraints |
| Checkpoint Protocol | Must pause after output; flow is verdict-driven; when unattended, the only automatic branch = APPROVE |
| Six Diagnostic Dimensions | Symptom confirmation / anchor / root-cause tracing / blast radius / lateral siblings / historical intent |
| Review History | Accumulated review history, used to identify recurring patterns and upgrade rules |
| Technical Debt | An explicit ledger of known incomplete items — deferrable, but never forgettable |
| Debt Origination Belongs to People | AI only has proposal rights; "to be safe / wait for confirmation" is not a reason to defer — debt is entered only when genuinely blocked externally |
| Governance Debt | Dead code within the governance mechanism itself; a mechanism should be retired if the problem it guards against can be eliminated at zero cost further upstream |
| Time-Bound Wager | Every hard-constraint mechanism registers which model flaw it is betting against and what signal should trigger re-evaluation; mechanisms betting against a model flaw have a lifespan, while those governing verification and enforcement do not |
| Lesson Backflow | From a single incident to a recurring pattern, then upgraded into a rule or gate |
| Enforcement Hierarchy | Model self-discipline < documentation < review < machine gate < harness hard-block; upgrading a rule = moving up a level |
| Asymmetric Collaboration | When the user cannot verify AI, gatekeeping strength is inversely proportional to verification ability; minimize the operating surface, isolate language, and make review independence mechanical |
| Verdict Evidencing | Automatic progression only recognizes evidence committed to disk; verbal claims are invalid |
| Model Tiering | Save money on retrieval, preserve quality on verification; output that directly determines a blocking verdict is never downgraded |
| Loop Workflow | A convergent closed loop composed of oracle, gate, self-check, review, and ratchet |
| Cron | A scheduled-trigger mechanism, suited to fallback, continuation, and patrol — not suited to every real-time task |
| Watch | A lightweight watcher process that exits and wakes the lead session upon detecting an event |
| Worker | An executor capable of serially processing a complete task chain |
| Oracle | The arbiter of right and wrong in unattended tasks, e.g. a live implementation, a mock matrix, or screenshot comparison |
| False-Green | A gate or self-check appears to pass but did not actually verify the target; gates must prove their own execution |
| Sensor Calibration | Confirm that verification tools such as screenshots, devices, caches, tests, and APIs are observing current facts |
| Parity Reconciliation | Migration consistency = first audit out a list of discrepancies, then clear them batch by batch, and finally retire the external source |
| Park-Don't-Guess | When uncertain, stop and queue it — don't patch over it with a guess |
| Fact Base (kb) | Distills facts about "what the system actually looks like"; the README serves as the triage entry point |
| Two-Axis Triage | The first cut at localization: cross-cutting issues go through a symptom-to-mechanism table, single-point issues go straight to the page by handle |
| Negative Knowledge | "Confirmed, after investigation, not to exist" is also a fact — register the basis to prevent redundant searching; falsify blocking conclusions before adopting them |

## Chapter Index

1. [00_charter.md](./00_charter.md) — 00 Charter: AI Collaboration Engineering Governance System — system definition, overview of the Governance Track and Execution Track, Time-Bound Wager registry, maturity model, applicability boundaries
2. [01_upper_level_rules.md](./01_upper_level_rules.md) — 01 Upper-Level Rules: Architectural Invariants, Business Specs & Source-of-Truth Governance — Architectural Invariant, Business Spec, Source-of-Truth Governance and flip re-declaration, separation of constraint source and change flow, rule layering and adjudication order, knowledge hub
3. [02_context_governance.md](./02_context_governance.md) — 02 Context Governance: Treating Attention as a Scarce Resource — attention scarcity, always-loaded vs. on-demand, Thin-Constitution and bloat signals, Required-Reading Matrix, subagent context contract, Token Economy
4. [03_execution.md](./03_execution.md) — 03 Execution Layer: Plans, Batch Decomposition & Lead/Subagent Orchestration — task entry, planning, batch-task decomposition, Phase 0/1/2 orchestration, scope-runaway signals, subagent division of labor and model economics, parallelism caps, hidden shared-file checks, tiered model-selection rules, when to go concurrent and automatic-concurrency design, change of water and implementation dispatch
5. [04_review_and_correction.md](./04_review_and_correction.md) — 04 Review & Correction — adversarial review, Plan/Change Review, verdict tiers, plan-phase closed-loop principle, review write-to-disk and archiving
6. [05_diagnostics.md](./05_diagnostics.md) — 05 Diagnostic Methodology: Evidence-Based Root Cause Analysis — three evidence-gathering disciplines, six-dimensional reconnaissance, adaptive deep-diving, root-cause analysis and candidate solutions, separating diagnosis from fix
7. [06_tech_debt_and_lesson_backflow.md](./06_tech_debt_and_lesson_backflow.md) — 06 Technical Debt & Lesson Backflow — technical debt registration and tiering, Governance Debt, four-tier backflow path, three-recurrence escalation rule, convention proposal
8. [07_toolchain_governance.md](./07_toolchain_governance.md) — 07 Toolchain Governance: The Rails You Build for AI Decay Too — skills are code too, cross-tool read/write contracts, Enforcement Hierarchy, Verdict Evidencing, the three-state relationship among methodology/template/skill, Asymmetric Collaboration harness design
9. [08_long_running_tasks.md](./08_long_running_tasks.md) — 08 Long-Running Tasks, Loop, Cron & Unattended Operation — loop/cron/watch/worker, five elements of closed-loop convergence, false-green defense, Checkpoint Protocol, unattended admission criteria
10. [09_migration_and_rewrite.md](./09_migration_and_rewrite.md) — 09 Migration & Rewrite Governance: Fork, Greenfield Rewrites & Parity Reconciliation — fork governance vs. greenfield rewrite, multi-source dimension-based authorization, parity reconciliation, external-source retirement close-out
11. [10_fact_base_governance.md](./10_fact_base_governance.md) — 10 Fact-Base Governance: Current-State Facts & Triage Entry Points — fact-type knowledge base, ownership rules, two-axis triage entry point, evidence discipline, negative knowledge, population and verification
12. [A_case_library.md](./A_case_library.md) — Appendix A: Case Library — anti-patterns and correct solutions: source-of-truth misuse, false completion, subagents running idle, death of governance mechanisms, verbally-claimed review approval, and more
13. [B_template_library.md](./B_template_library.md) — Appendix B: Template Library — templates for plan / review / technical debt / rule escalation / handoff / cron / watch / worker / Checkpoint Protocol / diagnostic report / parity reconciliation, and more

## How to Use This

### Reading It as a Methodology

Read in chapter order to build a complete mental model:

```text
00 → 01 → 02 → 03 → 04 → 05 → 06 → 07 (one loop of the Governance Track)
→ 08 → 09 (execution orchestration and special topics)
→ 10 (knowledge-asset special topic: fact base)
A / B consulted on demand (appendices)
```

### Entering by Problem Type

| What you're doing | Read |
|---|---|
| Designing project governance | 01 Upper-Level Rules |
| Controlling the loading cost of rules/documents | 02 Context Governance |
| Arranging a complex task | 03 Execution Layer |
| Doing quality control | 04 Review & Correction |
| Investigating a bug | 05 Diagnostic Methodology |
| Distilling lessons / cleaning up mechanisms | 06 Technical Debt & Lesson Backflow |
| Building skills / gates / hooks | 07 Toolchain Governance |
| Designing automation or long-running tasks | 08 Long-Running Tasks & Unattended Operation |
| Doing migration / rewrite | 09 Migration & Rewrite Governance |
| Distilling localization knowledge / building a fact base for a project | 10 Fact-Base Governance |
| Explaining to someone else | A Case Library |
| Executing directly | B Template Library |

### As a Project Governance Initialization Checklist

When onboarding a new or existing project to AI collaboration, check first:

- Whether an Architectural Invariant exists
- Whether a Business Spec or current-state capability document exists
- Whether the source of truth and conflict adjudication are defined
- Whether there is a triage entry point (fact base) for incoming bugs
- Whether plan, review, technical debt, and lesson backflow processes exist
- Whether always-loaded rules satisfy "needed every time + not available elsewhere" (Thin-Constitution)
- Whether boundaries exist for long-running tasks and unattended operation

## Maintenance Principles

- This knowledge base distills general methods; it does not hard-code any project's paths, commands, or tech stack.
- Specific projects can reference the methods here, then implement the concrete details in their own project documentation.
- Cases can come from real projects, but must be abstracted into general rules.
- Recurring problems should move from case to rule candidate, then into a template or automated gate.
- This knowledge base itself should also be subject to lesson backflow: if a type of problem keeps recurring, update the corresponding chapter.
- **Concept Home Chapter**: Each core concept designates a single "home" chapter to carry its full exposition; when mentioned in other chapters, it gets only a one-line reference + pointer, without restating mechanism details. Appendices are exempt from this rule — the Case Library tells stories of failure and the Template Library provides reusable skeletons; these are two other states of the same mechanism (see "Toolchain Governance" §5) and do not count as duplication.
- **Synchronization Discipline**: When a workflow rule's or an implemented skill's mechanism changes, revise the corresponding chapter in sync; if there is a conflict, the implementation is authoritative, and this counts as this knowledge base owing one round of synchronization (mechanism-level consistency is sufficient — see "Positioning Statement").
- This README's index is the authority for chapter order. **Dual Namespace**: Main-line chapters (`00`–`10`) have numeric prefixes that mirror the README order; inserting a new main-line chapter requires one mechanical renumbering of the affected range. The Case Library / Template Library are pure appendices, using letter prefixes (`A_`/`B_`) as an **independent namespace** that does not shift with main-line chapter insertions and never needs renumbering.
