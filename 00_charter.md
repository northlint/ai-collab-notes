# 00 Charter: AI Collaboration Engineering Governance System

## One-Sentence Definition

The AI Collaboration Engineering Governance System is a set of engineering practices that make AI controllable, reviewable, verifiable, and evolvable in long-term software engineering.

Its core is:

> Upper-Level Rules set the law, the Execution Layer carries it out, Review & Correction catches deviation, lessons flow back.

Expanded, this becomes two tracks:

- **Governance Track**: defines rules, constraints, the Source of Truth, review, technical debt, and lesson accumulation.
- **Execution Track**: defines how tasks enter the system, get decomposed, scheduled, continued, run unattended, and delivered.

The goal of this system is not to let AI "work more freely," but to let AI work efficiently within the correct boundaries.

## Why This Is Not "Prompting Tricks"

The problems with AI-written code are often not a matter of capability, but that the engineering collaboration model itself lacks a governance structure.

Without a governance structure, AI is prone to five categories of failure.

| Failure | Manifestation | Consequence |
|---|---|---|
| Overreach | Refactoring in passing, altering architecture in passing, introducing new dependencies in passing | Change surface goes out of control, hard to review or roll back |
| Drift | Docs say A, code does B; the next session forgets this session's agreements | The project becomes unmaintainable over the long run |
| Confabulation | Guessing when sources conflict, inventing content when materials are missing | Produces implementations that look plausible but are actually wrong |
| False completion | Claims to be done while tests lack assertions and failure paths are unhandled | Trust is depleted, manual review cost skyrockets |
| Forgetting | The same class of error recurs | Humans keep correcting the same mistakes; the system never gets stronger |

So the real question is not "how to prompt AI to write better code," but:

> How to build the project itself into an engineering system that AI can operate correctly.

## From Code Repository to Governance System

A traditional code repository mainly contains:

- Code
- Tests
- Configuration
- A minimal README

Once AI is deeply involved, the repository also needs to contain:

- Architectural Invariants
- Business Specs
- A fact base (implementation facts used for locating issues)
- Source-of-Truth adjudication rules
- Workflows
- Plan Review / Change Review
- A technical debt ledger
- Lesson backflow records
- Automated checks
- Long-running task and unattended execution protocols
- Human checkpoints and permission boundaries

These are not "extra documentation burden" — they are the infrastructure that makes AI governable.

## The Four-Stage Loop

```text
Upper-Level Rules
  Define principles, Architectural Invariants, Business Specs, Source of Truth, adjudication authority
      ↓
Execution Layer
  Break tasks into controllable batches, execute per plan, boundary, and acceptance criteria
      ↓
Review & Correction
  Use adversarial review to catch wrong direction, wrong implementation, insufficient verification
      ↓
Lesson Backflow
  Write issues into review / technical debt / recurring pattern / rules
      ↓
Back to Upper-Level Rules
  Narrow the next round of AI's degrees of freedom, surface errors earlier
```

These four stages are not a one-off process but a flywheel.

A truly mature system should make problems surface earlier and earlier:

- The first time, caught by human review.
- The second time, caught by a checklist reminder.
- The third time, blocked by a rule.
- Once stable, blocked by an automated gate.

## Governance Track and Execution Track

### Governance Track

The Governance Track is concerned with "the law."

It answers:

- What are the project's current rules?
- Who is the architectural authority?
- Who is the business authority?
- Who is the contract authority?
- What is the difference between a plan and a Spec?
- How is technical debt registered?
- How does review block errors?
- How do lessons get upgraded into rules?

Keywords of the Governance Track:

- Architectural Invariant
- Business Spec
- Source-of-Truth governance
- Fact base
- Token Economy / Thin-Constitution Mode
- Review
- Diagnosis
- Technical debt / governance debt
- Lesson backflow
- Enforcement hierarchy / automated gates

### Execution Track

The Execution Track is concerned with "the craft."

It answers:

- How does a task enter the system?
- How does a long-running task avoid interruption?
- How is a batch task decomposed?
- How do subagents run in parallel?
- How do you choose between cron and watch?
- When is unattended operation justified?
- Where must humans be forced to stop and check?
- How does the executor recover after failure?

Keywords of the Execution Track:

- Batch task
- Phase 0 / Phase 1 / Phase 2
- loop
- cron
- watch
- worker
- queue
- checkpoint protocol / human checkpoint
- oracle
- parity reconciliation
- park-don't-guess

## Scope of Applicability

This system is not meant to be applied in full to every project.

| Scenario | Applicable | Notes |
|---|---|---|
| One-off demo | Not suitable for the full system | The goal is fast validation; governance cost may exceed the benefit |
| PoC / prototype | Partially applicable | Needs a Source of Truth and boundaries, but not necessarily a full review/debt system |
| Long-term internal tool | Applicable incrementally | Start with plans, review, and technical debt, then add invariants and automation |
| Production project | Strongly applicable | Needs the full governance loop |
| Cross-platform / multi-repo collaboration | Strongly applicable | Source-of-Truth and contract adjudication are especially critical |
| Automated bug fixing / unattended operation | Strongly applicable | Must have a queue, checkpoints, self-verification, and permission boundaries |
| Large-scale migration | Strongly applicable | Must have a frozen Source of Truth, a state matrix, batch task decomposition, and an oracle; see the dedicated chapter [`09_migration_and_rewrite.md`](./09_migration_and_rewrite.md) |

The criterion is not project size, but:

> Whether this code and knowledge will be relied upon over the long term.

If so, it needs governance.

## Several Fundamental Judgments in This System

### 1. Rely on system constraints, not AI self-discipline

AI is unstable not because it "isn't careful," but because it has no innate sense of engineering responsibility boundaries.

So do not expect it to automatically:

- Control scope
- Find authoritative sources
- Avoid confabulating
- Fill in documentation
- Remember historical lessons
- Proactively stop and ask a human

All of these must be systematized.

### 2. The upper level does not manage details, but it must hold adjudication authority

"Governing from above" does not mean the upper level dictates every detail.

The upper level should not write:

- A specific project's concrete API paths
- A specific page's concrete components
- A specific repository's concrete commands

The upper level should specify:

- Which category of source API paths come from
- Who adjudicates page behavior
- Where Architectural Invariants live
- How to handle conflicts
- Whether guessing is allowed when uncertain

The lower level is responsible for execution; the upper level is responsible for adjudication.

### 3. A plan is a change stream; a Spec is the current state

A plan answers:

> What is being changed this time?

A Spec answers:

> What is the system now?

AI most easily guesses the current state from historical plans. Long-term projects must consolidate the stable results after completion into the current-state Spec, rather than letting plan documents pile up indefinitely.

### 4. Technical debt is not an excuse — it is an explicit ledger

It is fine to defer something, but not to silently omit it.

Any simplification, placeholder, unverified, unintegrated, or uncovered path that is not addressed this round must be registered with:

- Symptom
- Risk
- Trigger condition
- Reason for deferral
- Repayment method

### 5. Unattended operation does not mean "no one is watching"

The essence of unattended operation is not letting AI act with complete freedom, but letting it self-govern within strong constraints.

Preconditions for unattended operation to hold:

- Source of Truth is frozen
- A runnable oracle exists
- A state matrix or fixture exists
- Mechanical gates exist
- Failure recovery exists
- A human review queue exists
- When uncertain, it can park rather than guess

Without these conditions, so-called unattended operation is merely an accumulation of unsupervised risk.

## The Time-Bound Bet of This System

This system bets on the premise that "the failure modes of the current generation of agents will persist." As model capability climbs a rung, a batch of mechanisms may go from necessary safeguard to governance debt (see "Technical Debt & Lesson Backflow" §4.1 for the criteria on when a mechanism should be retired). Rather than waiting for them to silently decay, it is better to register explicitly: what each strong-constraint mechanism is betting on, and what signal should trigger a re-evaluation (see "Context Governance" §3.3 for the re-evaluation trigger mechanism).

| Mechanism | Model deficiency it bets on | Re-evaluation trigger signal |
|---|---|---|
| Water-changing / control-plane continuity ("Execution Layer" §5.11) | Long-context rot, lossy auto-summarization | In ultra-long sessions, previously rejected approaches no longer resurface; summary fidelity becomes verifiable |
| Adversarial review / review independence ("Review & Correction", "Toolchain Governance" §6) | Self-certified completion, implementer's self-report contaminating judgment | The implementing agent's self-reported verification results consistently match independent re-review over the long term |
| Decision-point protocol / park-don't-guess ("Long-Running Tasks, Loop, Cron & Unattended Operation" §11) | Confabulating when materials are missing, not proactively stopping to ask a human | The agent stably exhibits "stop when uncertain" with an acceptable false-stop rate |
| Thin-Constitution / Token Economy ("Context Governance") | Attention dilution, always-loaded rules getting drowned out | Context cost drops substantially, or retrieval-style rule loading matures → relax the "required every time" threshold |
| Fact base ("Fact-Base Governance") | Cross-session forgetting, expensive repeated retrieval | The agent's native long-term memory becomes reliable and auditable |
| False-green defense / sensor calibration ("Long-Running Tasks, Loop, Cron & Unattended Operation" §5.7–5.8) | —— (a verification-theory issue, not a model deficiency) | Expected to remain long-term |
| Verdict evidencing / enforcement hierarchy ("Toolchain Governance" §2–§3) | —— (a governance requirement, not a model deficiency) | Expected to remain long-term |

Registration discipline: when a new strong-constraint mechanism is added, add a row to this table stating what it bets on; when a row's trigger signal appears, go through the re-evaluation process, and handle the mechanism's downgrade or retirement as technical debt. Note the contrast in the last two rows: **not all mechanisms will become obsolete** — mechanisms betting on model deficiencies have a lifespan, while mechanisms governing verification and enforcement do not.

## Maturity Model

Five levels can be used to judge a project's AI-collaboration maturity.

| Level | State | Characteristics |
|---|---|---|
| L0 Ad hoc use | AI only writes code per conversation | No long-term rules; relies on manual line-by-line review |
| L1 Has plans | Complex tasks are planned first | Has goals, scope, and acceptance criteria, but no current-state has formed |
| L2 Has review | Both Plan and Change are reviewed | Can block obvious errors |
| L3 Has governance | Architectural Invariants, Specs, and technical debt are all in place | AI has explicit Upper-Level Rules |
| L4 Has backflow | Recurring issues can be upgraded into rules or gates | The system tightens with use; rule upgrades move the enforcement hierarchy upward (docs → machine gates, see `07_toolchain_governance.md`) |
| L5 Capable of autonomy | loop / worker / oracle / human review queue all in place | Can take on long-running tasks and some unattended work; key constraints on the unattended path reach machine-gate level or above, and automatic progression recognizes only evidence committed to disk |

Many projects do not need to go straight to L5.

But as soon as AI starts taking on long-term production tasks, the project should at least reach L3.

## How to Use This Knowledge Base

We recommend entering by problem type.

If you are designing project governance:

- Read `01_upper_level_rules.md`
- Focus on establishing Architectural Invariants, Business Specs, and Source-of-Truth governance

If you are controlling the loading cost of rules and documentation:

- Read `02_context_governance.md`
- Focus on establishing Thin-Constitution Mode, the Required-Reading Matrix, and subagent context contracts

If you are organizing a complex task:

- Read `03_execution_layer.md`
- Focus on using plans, batch decomposition, and Phase orchestration

If you are designing automation or long-running tasks:

- Read `08_long_running_tasks_loop_cron_unattended.md`
- Focus on judging the applicability boundaries of watch / worker / cron / loop

If you are doing quality control:

- Read `04_review_and_correction.md`
- Focus on establishing Plan Review / Change Review

If you are investigating a bug that has already occurred:

- Read `05_diagnostic_methodology.md`
- Focus on evidence-based six-dimensional reconnaissance, with diagnosis separated from fixing

If you want locating issues to stop starting from zero every time:

- Read `10_fact_base_governance.md`
- Focus on establishing triage entry points, the fixed four-piece set, and calibration discipline

If you are accumulating lessons:

- Read `06_technical_debt_and_lesson_backflow.md`
- Focus on pushing issues from review into debt / recurring pattern / rule

If you are building skills / gates / automation tracks:

- Read `07_toolchain_governance.md`
- Focus on checking the enforcement hierarchy and cross-tool read/write contracts

If you are doing a migration or rewrite:

- Read `09_migration_and_rewrite_governance.md`
- Focus on establishing multi-source, dimension-specific authorization and parity reconciliation

If you need to explain this to someone else:

- Read `A_case_library.md`

If you need to execute directly:

- Read `B_template_library.md`
