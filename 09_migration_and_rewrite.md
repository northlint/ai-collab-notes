# 09 Migration & Rewrite Governance: Fork, Greenfield Rewrites & Parity Reconciliation

## Core Definitions

Migration and rewrite are the class of engineering work where AI involvement is highest — and where things spiral out of control most easily: source material is abundant and mutually contradictory, the goal is a moving target ("stay consistent with the old system"), and the workload is large enough that batching and parallelism become unavoidable.

"Execution Layer" governs decomposition and orchestration (Phase 0/1/2, batches, parallelism boundaries); this chapter governs what is specific to migration — **source governance and close-out**: what to treat as truth, how to prove "consistency," and when the old source can be declared retired.

## 1. Two Modes: Fork Governance vs Greenfield Rewrite

| Dimension | Fork Governance | Greenfield Rewrite |
|---|---|---|
| Approach | Snapshot-fork the old repo and evolve it in place | Build a new repo from scratch; the old implementation serves only as reference |
| Fit | Old code quality is acceptable, and the surface to modify < the surface to rewrite | Old code is a cautionary example; the architecture needs a generational change |
| Core Risk | Old baggage and new rules coexist long-term with blurred boundaries | The reference source gets "casually copied," letting old bad patterns leak into the new repo |

The judgment criterion is not sentiment ("the old code is annoying") but arithmetic: **the volume of logic that must be preserved × modification cost, versus rewrite cost + reconciliation cost**.

### 1.1 Discipline for Fork Governance

- **Snapshot-fork with an explicit declaration of not tracking upstream**: forking means evolving independently; if upstream still needs to be synced, that is a branch, not a fork, and the discipline is entirely different.
- **Register the fork baseline**: which version, which commit it was forked from — write this into the project documentation. Every future archaeology into "why is this code the way it is" starts here.
- **Make the modification checklist explicit**: global changes such as package names, naming prefixes, and dependency replacements should be listed as a checklist and executed and verified item by item, not scattered across individual commits.
- **Tag the status of carried-over documents**: mark each old document brought over as current / historical — AI tends to treat history as current (a hotspot for source-of-truth misuse).

### 1.2 Discipline for Greenfield Rewrite

- **Carry over the contract, not the structure**: what is worth bringing from the old implementation are **contracts** — interface paths, field semantics, state machines, business rules; directory structure, component boundaries, and implementation patterns should be redone under the new architecture. Copying the structure = moving old debt into the new repo.
- **Freeze the reference source**: during reconciliation, the reference implementation must not change (or its version must be locked), otherwise "consistency" is a moving target.
- **Prohibit casual copy-paste**: "referencing" the reference source and "pasting" from it are two different things; set an explicit "do not copy old code" check item in lint / review.

## 2. Multi-Source, Per-Dimension Authorization

It is common on a migration to have four or five sources present simultaneously: the old production implementation, interface documentation, design mockups / prototypes, product logic specifications, and the new architecture blueprint. The concrete form Source-of-Truth governance (see "Upper-Level Rules" §3) takes in migration is **per-dimension authorization** — each dimension has exactly one authority:

| Dimension | Authoritative Source | Rationale |
|---|---|---|
| Interface path / method / envelope / whether an interface exists | **The production implementation actually running in traffic** | It works under real traffic every day |
| Field type / nullability | **Interface documentation** (generated from backend code) | The production frontend may mask the real type through tolerant handling |
| Visual | Design tokens / prototype | The visuals of the production implementation may already be outdated |
| Behavior / state machine / validation | Product logic specification (PRD); deep logic it simplifies should be checked back against the production implementation | The document governs intent, the implementation governs detail |
| Structure / technology | New architecture blueprint | Where it is silent or cannot resolve the question → **ask a person, do not decide unilaterally** |

When there is a conflict, do not ask "which source is more trustworthy" — first ask "which dimension does the conflict fall in" and route it per the table above; where the table cannot answer, flag it as blocked and ask, rather than guessing.

## 3. Parity Reconciliation: Audit First, Then Fix

The most dangerous version of "migration is done" is "I think everything has been moved over." The reliable approach is to turn "consistency" into a **checkable list**, done in two steps:

### 3.1 Audit: Produce a Discrepancy List

- Compare against the reference source page by page / module by module, and register discrepancies one by one: missing logic, inconsistent behavior, different field handling, intentional simplifications.
- During the audit phase, **only record, do not fix** — fixing while auditing means the audit never finishes, and coverage cannot be proven.
- Tag each discrepancy with: source evidence (location in the reference source), severity level, and disposition (fix this batch / fix across batches / register as debt / intentionally not done).

### 3.2 Fix: Clear the List in Batches

- The discrepancy list is the batch task list; execute it under the batch-decomposition discipline in "Execution Layer."
- After each batch fix, clear the corresponding items off the list; the list reaching zero (or all remaining items explicitly converted to technical debt / intentionally not done) = parity achieved.
- "Intentionally not done" must come with a stated reason — it is a decision, not an omission.

## 4. Close-Out: Retiring the External Source

The marker of migration completion is not "the new system runs," but **retirement of the external source**:

- [ ] References to the reference source and old documents in the new repo's documentation are removed one by one, or tagged historical.
- [ ] The "required-reading document set" set up for the migration period is trimmed down — the source-adjudication rules and reference guidance used for reconciliation can be retired (see the Required-Reading Matrix in "Context Governance").
- [ ] Migration-period-only lint / check items are evaluated for whether to keep or remove.
- [ ] From this point on, the new repo is the sole source of truth; the old source is no longer read by any process.

A migration that is not closed out leaves a permanent dual-source state: AI spends half its time reading the new repo and half reading the old reference, undoing all the work of source-of-truth governance.

## 5. Additional Preconditions for Unattended Migration

Migration is a highly suitable scenario for unattended operation (repetitive, clear boundaries, has a reference), but it must still satisfy the entry conditions in "Long-Running Tasks, Loop, Cron & Unattended Operation" §6, in particular:

- The reference source has been frozen (otherwise you are chasing a moving target);
- There is an oracle that can judge automatically (reference comparison, state matrix, schema validation, screenshot diff — for a counterexample see "Case Library" #10);
- The discrepancy list already exists — unattended clearing of the list is fine, unattended **auditing** is not; judging audit coverage requires human review.

## 6. Migration Governance Checklist

- [ ] Has the mode been chosen (fork / greenfield), based on the cost arithmetic rather than sentiment?
- [ ] Fork: has the fork baseline been registered, has "not tracking upstream" been declared, have old documents been tagged with status?
- [ ] Greenfield: has the reference source been frozen, has "carry over the contract, not the structure" become a check item?
- [ ] Has the multi-source, per-dimension authorization table been established, with clear conflict-routing rules?
- [ ] Does parity follow "audit first to produce a list, then clear it in batches," rather than fixing while reviewing?
- [ ] Does every item on the discrepancy list have evidence, a severity level, and a disposition?
- [ ] Does a close-out plan exist: retiring the external source + trimming the required-reading set?
