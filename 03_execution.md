# 03 Execution Layer: Plans, Batch Decomposition & Lead/Subagent Orchestration

## Core Definition

The Execution Layer turns Upper-Level Rules into a sequence of controlled task executions.

It is not concerned with whether AI *can* do something, but with:

- How does a task enter the system?
- How is scope determined?
- How is it decomposed into batches?
- Which parts run serially first, and which can run in parallel?
- Where are a subagent's boundaries?
- How does the lead agent integrate and verify the result?
- At what point must work stop for review?

The goal of the Execution Layer is:

> To reduce open-ended tasks into small, plannable, verifiable, reversible closed loops.

## 1. Task Entry: Identify the Task Type First

Different tasks follow different execution strategies once they enter the system.

| Task Type | Characteristics | Recommended Handling |
|---|---|---|
| Small fix | Clear scope, low risk | Execute directly + brief verification |
| Complex feature | Multiple modules, states, dependencies | Plan first, then `plan-review`, then execute |
| Architecture/contract change | Affects Upper-Level Rules or cross-module protocols | Form a separate batch; must be reviewed |
| Bulk migration | Repetitive work across many pages/platforms/files | Build a manifest, batch it, use a unified recipe |
| Automated bug fixing | External task input, requires diagnosis and human confirmation | Queue + diagnosis + human checkpoint |
| Long-task continuation | Session may be interrupted or span time | Handoff document + cron/watch/loop |
| Unattended operation | AI runs autonomously for a period | Requires an oracle, gates, and a review queue |

Do not run every task through the same process.

## 2. Plans: Turning Tasks into Controllable Units of Change

Complex tasks must have a plan written first.

A plan is not a formality — it exists to make the AI clear on:

- What to do
- What not to do
- Whose authority to follow
- How to decompose it
- How to accept/verify it
- When to stop

### 2.1 What a Plan Must Contain

```md
## Goal
What outcome this effort is meant to achieve.

## Non-Goals
What this effort explicitly will not do.

## Source of Truth
Where architecture, business, visual, contract, and runtime facts each come from.

## Scope
Which modules, pages, interfaces, documentation, and tests will be affected.

## Execution Steps
Decomposed in dependency order.

## Risks
Where things are most likely to go wrong.

## Acceptance
How to prove completion.

## Stop Conditions
Under what circumstances work must stop for review or clarification.
```

### 2.2 Non-Goals in a Plan Matter

AI tends to expand scope opportunistically.

The purpose of non-goals is to tell the AI:

- Do not fix related issues just because you happened to notice them.
- Log new requirements first; do not act on them directly.
- Do not let this batch turn into an "opportunistic refactor."
- Do not disguise a temporary simplification as completion.

## 3. Batch Decomposition

The core of batch decomposition is not "dividing work evenly" — it is decomposing by risk, dependency, and verification method.

### 3.1 Do Not Decompose by Time

Incorrect decomposition:

```text
Do half the pages today, the other half tomorrow.
```

A better decomposition:

```text
Build shared infrastructure first
Then build mutually independent pages
Finally perform unified integration verification
```

AI execution is not well suited to using time as its primary boundary, because time is not controllable.

Better boundaries are:

- File scope
- Module boundaries
- Shared dependencies
- Risk level
- Verification method
- Rollback granularity

### 3.2 Common Decomposition Dimensions

| Dimension | Decomposition Approach |
|---|---|
| Shared dependencies | Build infrastructure, components, contracts, and mocks first, then fan out into business work |
| Risk level | High-risk write operations form their own batch |
| Verification method | Verification requiring real devices/real accounts/screenshots is grouped together |
| Business boundary | One page, one domain, one capability, one state machine |
| Nature of change | Keep infrastructure, features, fixes, tests, and documentation separate |
| Rollback granularity | A group that can be rolled back independently forms one batch |

### 3.3 Batch Size Principles

A batch should satisfy:

- Reviewable at a glance
- Independently verifiable
- Independently reversible
- A single objective
- Does not cross too many boundaries

If a batch simultaneously contains:

- New architecture
- New pages
- New interfaces
- A new styling system
- A new testing framework
- Documentation migration

then it is too large.

## 4. Phase Orchestration: Phase 0 / Phase 1 / Phase 2

The most stable orchestration pattern for batch tasks is a three-stage model.

```text
Phase 0: Shared infrastructure goes first, serially
Phase 1: Independent tasks fan out in parallel
Phase 2: Lead agent integration verification
```

### 4.1 Phase 0: Shared Infrastructure Goes First, Serially

Phase 0 builds everything that multiple subtasks will depend on.

Including:

- Directory structure
- Query / API / Repository foundations
- Key factories
- Mocks / fixtures
- i18n placeholder blocks
- Shared UI classes or components
- Shared types
- Test utilities
- lint / grep / dependency rules

Principle:

> If shared components are not ready, parallel fan-out is not permitted.

Otherwise each subagent will patch together its own version of shared components, causing conflicts and divergence.

### 4.2 Phase 1: Independent Tasks Fan Out in Parallel

Phase 1 can run in parallel, but boundaries must be constrained.

Typical rules:

- One agent is responsible for only one page, one module, or one capability.
- It may only modify its own files.
- It must not modify shared components.
- When a shared component needs to change, stop and report to the lead agent.
- Each agent performs logic-level self-testing.
- No agent is required to perform final pixel-level/real-device/full verification.

Only this way is parallelism safe.

### 4.3 Phase 2: Lead Agent Integration Verification

Phase 2 must be completed serially by the lead agent.

Reasons:

- Subagents cannot see the full context.
- Subagents easily act on their own, independent of one another.
- Visual, real-device, real-account, console, and end-to-end verification must follow a unified standard.
- Integration issues often span files and cannot be handled in a distributed way.

Phase 2 performs:

- Full static checks
- Build
- grep gates
- Browser/real-device verification
- Screenshot reconciliation
- Console checks
- Documentation sync
- `change-review`
- Fixing integration issues

Even if unit tests in the infrastructure stage are already all passing, that is no reason to skip manual/end-to-end smoke verification — integration-layer bugs produced by combining multiple phases often only surface once real callers appear, and the objects unit tests construct frequently have no real downstream consumer.

### 4.4 Phase Discipline

A phase is not a timebox — it is a reviewable, reversible unit of change.

Recommended discipline:

- Keep a single phase's file count in check, to avoid a batch growing too large to review.
- A single-platform task should not mix changes across platforms.
- Do not mix task types — keep infrastructure, configuration, tests, features, and documentation separate.
- Do not merge execution across phases.
- Run `change-review` at the end of every phase.
- After a high-risk phase concludes, commit / tag / archive the review record.
- The termination condition is not "time is up" — it is scope going out of control, a high rework rate, an unclear source of truth, or verification that cannot be completed.

The goal of a phase is not to keep the AI busy for a stretch of time.

The goal of a phase is to let a human understand it, finish reviewing it, and roll it back.

### 4.5 Signals of Scope Going Out of Control

When these situations arise, the current phase should stop and be re-decomposed:

- The file count significantly exceeds the plan.
- The task simultaneously touches multiple boundaries — UI, interface, architecture, tests, documentation.
- New shared abstractions keep being added in order to finish the current task.
- A subagent needs to modify a shared component to continue.
- The verification method escalates from simple self-testing to real devices, real accounts, and a multi-state matrix.
- The change starts depending on unconfirmed business rules.
- Old documentation is found to conflict with current facts.

Stopping is not failure.

Stopping turns an out-of-control change back into a governable one.

## 5. Division of Labor Between Lead Agent and Subagent

### 5.1 What Subagents Are Suited For

Subagents are suited for:

- Independent pages
- Independent modules
- Single-domain DTO porting
- A single review dimension
- A single documentation section
- Repetitive work with clear boundaries

### 5.2 What Subagents Are Not Suited For

Subagents are not suited for:

- Modifying shared infrastructure
- Modifying global architecture
- Making the final integration judgment
- Making cross-task adjudications
- Handling ad hoc user decisions
- Performing high-risk git operations

### 5.3 Lead Agent Responsibilities

The lead agent is not a simple scheduler — it is the integration owner.

It must be responsible for:

- Defining Phase 0 shared components
- Giving subagents clear boundaries
- Checking whether a subagent ran without doing real work
- Spot-checking key files
- Unified integration verification
- Consolidating documentation and technical debt
- Initiating `change-review`
- Handling must-fix items

Lesson learned:

> Subagents occasionally run without doing real work, or misunderstand their boundaries — the lead agent must verify deliverables, not just read the reports.

### 5.4 Subagent Model Economics

Beyond dividing labor, **model tiers** must also be divided. A one-size-fits-all approach — all large models (burns money) or all small models (burns quality) — is wrong either way. Divide into three tiers by role:

| Tier | Role | Model |
|---|---|---|
| Retrieval / broad search | Finding callers, scanning similar implementations, pulling reference material | Small model |
| Routine judgment | Convention checks, checklist-style pre-checks | A small model suffices (backed by a checklist) |
| Core judgment / adversarial review | Primary correctness judgment, falsifying blocking findings | **The primary model, not downgraded** |

The judgment standard in one line:

> An agent whose output **directly determines the blocking verdict** is not downgraded; one whose output still needs to be digested and verified by the lead agent may be downgraded.

A counterintuitive hidden cost: the false-positive-prevention patches added to a weak model's review ("must cite file:line," "the lead agent must verify independently before adopting") are, in essence, **the lead agent paying on the weak model's behalf** — the money the weak model saves comes back in the form of the lead agent's review cost. General rule: **save money on retrieval, preserve quality on verification**.

### 5.5 Physical Isolation for Parallel Write Operations: worktree

When subagents execute in parallel, if the task decomposition cannot fully guarantee zero overlap between each agent's modification area (for instance, all of them might touch the same shared file), relying on "task boundary agreements" alone is not reliable enough — a git worktree should be used to give each parallel-writing agent a physically isolated working copy, rather than relying on after-the-fact merge conflict resolution. This is not limited to unattended long-running tasks: it applies equally to routine multi-agent parallel development. Once a risk of area overlap exists, isolation should be the default option, not a remedy applied only after problems occur.

### 5.6 Upper Bound on Parallelism: Who Decides

More parallel subagents is not always better — the ceiling should be set by **what the lead agent can actually finish reviewing**, not by whatever concurrency limit the tool happens to allow.

A tool-level concurrency number is a physical hard cap, not a governance target. For instance, some orchestration tools cap concurrency at "a value tied to core count," with the total capped at some large number — this guarantees "the machine won't be overloaded," not "running at that number is safe." A physical hard cap prevents the system from crashing; a governance ceiling prevents review from degrading into reading a subagent's self-report without verifying the actual deliverable (Case Library #6: subagent running without doing real work).

If no global or project rule specifies a number otherwise, here is a default that can be applied directly:

> **For a single batch of subagents with write access that might touch shared resources, the default parallelism cap is no more than 4.**

Rationale: §5.3 requires the lead agent to "spot-check key files" of subagent deliverables one by one. Beyond this number, a human (or the lead agent itself) will unconsciously degrade into skimming report conclusions rather than genuinely reviewing the code.

This default has one exception where it can be relaxed: **purely read-only retrieval subagents** (Explore, scanning similar implementations, pulling reference material — writing no files at all) carry no risk of conflicting with one another, and their deliverables do not need to be individually checked for "was this merged correctly" — the ceiling can follow directly from "how many independent retrieval units the task can be broken into," with no need to be capped at 4.

A directly applicable formula:

```text
Parallelism for this batch = min(
  the tool's concurrency hard cap,
  the number of independent units the task can be split into,
  the number of deliverables the lead agent is willing/able to individually verify   ← usually the bottleneck once write access is involved, default 4
)
```

### 5.7 Check Before Opening Subagent Threads: Implicit Shared Files

The place where §4.1's "shared infrastructure first" is most easily shortchanged in execution is not the shared components or shared types that everyone readily recognizes, but the **single-file shared resources** that look like you can "just add a line" — the routing table is a typical example.

Using the routing table to expand this into an actionable rule:

- If this batch has multiple page-level subagents, and each one must add an entry to the same routing table (`routes.ts`, the `<Route>` list in `App.tsx`, a navigation registry) once its page is done — that routing table is already a shared conflict point before Phase 1 even starts, and cannot be left for "merge once everyone is done writing."
- There are two ways to handle it, and the choice must be settled in Phase 0 — it cannot be discovered only once Phase 1 is under way:
  - **(a) Skeleton placeholders**: In Phase 0, pre-build a placeholder for each route entry a subagent will eventually mount (a placeholder component + a fixed path). A subagent only needs to "replace" its own placeholder block, not "insert" at an arbitrary position in a shared file — an uncertain insertion position is the main source of merge conflicts, whereas replacing a fixed placeholder block has no such problem.
  - **(b) Reserve the modification right for the lead agent**: Once a subagent finishes its page, it only reports "needs to be mounted at path `/xxx`"; the routing table itself is appended to only by the lead agent, uniformly, in Phase 2.

The routing table is only one example. Other similar "implicit shared single files" include:

| Type | Example |
|---|---|
| Registry | Routing table, DI container registration, Redux/Store slice registration |
| Index / export manifest | Barrel file (`index.ts` unified export), component manifest |
| Key-value table | i18n key table, tracking event table, feature flag table |
| Directory index | Documentation README table of contents, test fixture index |

The judgment standard in one line:

> If two subagents, once each finishes its task, will both end up appending content to **the same file**, that file cannot be in a "starting from scratch" state before Phase 1 begins.

This is not an either/or choice with the worktree approach in §5.5 — they address two different layers of the problem: worktree solves "no physical conflict" (independent copies each, merged at the end); this section solves "no logical conflict" (by design, the shared file never needs to be modified by multiple agents at once). Even with worktrees in place, doing the skeleton-placeholder work first is still recommended — it reduces the amount of conflict that requires manual intervention at final merge time; the two can be layered together.

### 5.8 Which Layer of CLAUDE.md Should Define Automatic Model Selection

§5.4 answers "which tier should be assigned to which task." Here we answer a governance-level question: which file should this rule be written into, so that it takes effect globally without needing a major rewrite every time the project or the model vendor changes.

Following the rule-layering approach in [Upper-Level Rules](./01_upper_level_rules.md) §4.5, this splits into two layers:

- **The three-tier division principle** (the boundaries between retrieval/broad search, routine judgment, and core judgment/adversarial review, and the judgment standard of "whether the output directly determines the blocking verdict") — this is a global working rule about "how AI collaborates," unrelated to any specific project or model vendor, and should be written into the **global CLAUDE.md**.
- **The mapping from tier → specific model name** — this is, in essence, a project/team cost decision (which vendor to use, how tight the budget is), and in principle falls under the jurisdiction of the **project CLAUDE.md**; it should not be hardcoded into the global rule.

A concrete demonstration (the author's own current global CLAUDE.md, verbatim):

```md
## Subagent Models (Three Tiers by Role)
- Retrieval / broad search (Explore, finding callers, scanning similar implementations, pulling reference material) → sonnet
- Routine judgment (convention checks, checklist-style pre-checks) → sonnet
- Core judgment and adversarial review (primary judgment, falsifying blocking findings) → no model specified, inherits the lead model
- Judgment standard: an agent whose output directly determines the blocking verdict is not downgraded; one whose output still needs to be digested and verified by the lead agent may be downgraded
```

Strictly following the layering above, this rule actually puts "the principle" and "the current mapping" on the same layer (global). That is not an error — it is an acceptable state of affairs: **layering itself has a maintenance cost, and it is only worth pushing the "tier → model" line down into the project CLAUDE.md — leaving only the principle at the global level — once a genuine need arises for "the same principle, different mappings per project."** With only one mapping in use, and no second project yet demanding a different one, forcibly splitting into two layers of files only adds the cost of jumping between them to find the rule, without any real payoff.

Trigger signal for splitting: a second project appears that needs a different tier mapping (for example, a cost-sensitive project that wants to downgrade the retrieval tier to a cheaper model; or a change of model vendor under which the tier names no longer apply) — only then should the mapping line be moved into the project CLAUDE.md, with the global CLAUDE.md reverted to holding only the principle.

The implementation can be pushed one layer further into mechanism (echoing the enforcement hierarchy "documentation-as-rule → mechanism-as-enforcement" in [Toolchain Governance](./07_toolchain_governance.md) §2): if the orchestration tool supports passing parameters by "role name" rather than "specific model name" (for example, passing `role: 'core judgment'` by role instead of hardcoding a specific model name), the role-to-model mapping can be changed in one central place and take effect everywhere, without needing to manually decide which model name to use every time an agent is opened.

### 5.9 When Concurrency Is Warranted

The preceding sections all assumed that "parallelism has already been decided on." Here we step back: concurrency is not the default option — it is not "if it can be split, it should be."

Concurrency is worth opening only when three conditions hold at once:

- **No decision dependency**: subtasks do not need to see each other's results first in order to determine scope.
- **Independently verifiable**: echoing the batch size principles in §3.3.
- **Coordination cost < time saved**: this condition is the one most easily overlooked. Opening concurrency has real overhead — defining boundaries, spelling out each subtask's inputs and outputs, reviewing deliverables one by one (§5.3 / §5.6). When the number of tasks is small, or a single task is itself quick, this overhead can flip the equation, and serial execution ends up faster.

Here is a directly applicable anchor:

> **When the number of independent units that can be split out is ≤ 2-3, default to doing it serially — it is not worth splitting just to "look more parallel."**

Signals that parallelism is not appropriate:

- Tasks have a sequential dependency, where the later one needs the earlier one's output to determine scope
- A shared resource cannot be turned into skeleton placeholders (§5.7 cannot handle it, and only the lead agent can modify it serially)
- The verification method requires viewing everything together — for instance, a certain kind of consistency check where splitting it apart to look separately actually hides the problem
- The task is too trivial — the cost of spelling out clear boundaries exceeds just doing it directly

The one-line judgment standard:

> The benefit of concurrency comes from the savings in "number of tasks × time per task"; the cost comes from coordination and review. It is only worth opening when the former is significantly greater than the latter.

### 5.10 Designing for Automatic Concurrency: Default to Parallel or Default to Sync Points

§5.9 answers "whether to parallelize." Here we answer a further question: how to turn that judgment into a default mechanism, rather than rethinking it for every batch of tasks.

A common misconception is equating "staging" with "every stage must wait for everyone to arrive before moving to the next stage." The cost of this default synchronization point (hereafter, "barrier") is that the single slowest task drags down the time it takes for every task to enter the next step — whereas in most cases, the next step does not need to see "everyone's" result at all; it only needs to see "its own" result from the previous step.

A more time-efficient default design is the reverse: **by default, let each independent unit flow through its own stages without waiting for others** (one subtask may already be in stage two while another is still in stage one — each proceeds on its own). Only add an explicit barrier when one of the following conditions holds:

| Trigger Condition | Example |
|---|---|
| The next step needs to deduplicate/merge everyone's results | Consolidating findings from multiple sources before handling them uniformly, to avoid the same issue being processed twice |
| The next step needs to make a judgment based on the "total count" | If this batch found zero issues, skip all subsequent steps directly |
| The next step depends on "comparison with other results" | Picking the best option out of multiple candidates |

Outside these three categories, every other scenario should default to "each flows on its own, without waiting for others" — do not synchronize out of habit just because it "looks tidier."

This is not an abstract proposal — it is the default the author uses in its own orchestration mechanism: unless a synchronization point is explicitly declared, each item flows independently without waiting for others; only an explicit requirement to "wait until everyone is done" constitutes a barrier. This default helps avoid the hidden slowdown of "synchronizing out of habit for convenience."

Relationship to §5.6 (the upper bound on parallelism): the two knobs are orthogonal — do not conflate them. The parallelism cap determines "how many units are running at once"; the barrier determines "whether to wait for everyone to arrive between stages." Limiting the count does not mean barriers no longer need to be considered — the two must be judged separately.

### 5.11 Changing the Water: Context Isolation Between Plan Discussion and Implementation

The preceding sections covered how to dispatch subagents to share the execution load. This section covers another, independent reason for dispatching: **context hygiene**.

In a long-running task, the plan discussion accumulated in the lead session — rejected alternatives, trial and error, back-and-forth — becomes noise during the implementation stage. This noise does not go inert just because "the plan is finalized": it keeps diluting attention and can lure implementation back toward directions that were already rejected. Automatic summarization cannot rescue this — summarization is lossy compression, and compressed noise is still noise; it does not count as changing the water.

The countermeasure is to put "rule-setting" and "construction" into different contexts:

- **The lead session is fixed as the control track**: reviewing plans, dispatching, receiving reports, walking through checkpoints, merge coordination, committing. All context-heavy work is externalized.
- **Implementation changes the water**: once the plan review passes, subagents are dispatched to implement by task package — a subagent starts with a naturally clean context, fed only the spec (the plan document path + this task package's scope), with no discussion history attached.
- **Exploration also changes the water**: work such as research, reading large numbers of files, or "understanding how some module is implemented" is likewise dispatched to subagents, and the lead session receives only structured conclusions; the lead session reads a file itself only when it needs to make precise, line-by-line edits to it.

Dispatch discipline (each rule corresponds to a failure mode):

- **Dispatch by task package; never hand the whole plan to a single agent** — the rework radius is one task package, not the entire plan.
- **Decision-point protocol**: when a subagent hits a decision point the spec does not cover, it writes the question into its return report and ends that round, rather than guessing (the subagent version of park-don't-guess); the lead session resumes with the answer once it has obtained a human ruling.
- **Explicitly write the division of responsibility into the dispatch prompt**: subagents handle filling in tests, runtime verification, and documentation sync; checkpoints, review, and commit belong to the lead session — **a subagent never commits**. Global rules get doubly inherited by a subagent (such as the checkpoint protocol); without an explicit split, a subagent will pause in place at a checkpoint, waiting for a person who will never arrive.
- **Return a structured report on completion**: what was changed / what verification was run / the results / a point-by-point check against acceptance criteria / uncovered items / counter-evidence / where to start troubleshooting if something goes wrong. The report is written to disk for audit — the evidence discipline shares its origin with the review record (see Review & Correction §8).
- **The model is not downgraded**: implementation is the lead track's own work, done in a clean room — it inherits the primary model (the judgment standard in §5.4 applies equally here).

Cadence for changing the water: the next task package defaults to starting a new agent; must-fix iterations continue with the original agent (it already has the implementation context); when the original agent has been dragged through many rounds and its context has visibly decayed, change the water a second time — a new agent + the latest spec + the current diff state.

Known cost (accepted): a subagent has to re-read code the lead session already read during the plan stage. In long-running tasks, the cost of plan-stage noise far outweighs the cost of re-reading — the trade is worthwhile.

Scenarios where implementation dispatch does not apply: trivial changes that never went through the plan process (do not spin up an agent for a one-line change); debugging-type tasks (a spec cannot be written up front, so the lead session watches it run directly — though the retrieval steps within it can still be dispatched to a subagent); cron / unattended continuations (each trigger is itself already a new session — it is already changing the water, so it should not be nested further).

## 6. Page-by-Page / Module-by-Module Recipes

For repetitive tasks, a recipe should be distilled and retained.

A typical recipe:

1. Read the input sources: architecture, business, visual, contract, existing implementation.
2. Make scope determinations: what to do, what not to do, what to log as debt.
3. Wire up data: only through the prescribed layer, never bypassing the unified entry point.
4. Render or implement: follow styling, tracking, state, and error-handling rules.
5. Self-test: run through this module's logic paths.
6. Backfill documentation: status, debt, decisions, navigation relationships.
7. Hand off to the lead agent for integration verification.

The value of a recipe is:

- Reducing the cost of re-negotiating every time
- Preventing the AI from skipping steps
- Letting a new agent take over
- Making batch tasks parallelizable

For how a recipe's input sources are determined in migration/rewrite scenarios (multi-source authority split by dimension), and how "consistency" is proven (parity reconciliation), see [Migration & Rewrite Governance](./09_migration_and_rewrite.md).

## 7. State Classification and Wiring

In bulk restoration or page construction, states must be classified first.

A general classification:

| Type | Meaning | Handling |
|---|---|---|
| Persistent business state | A state a page displays over the long term, such as empty, under-review, or failed | May go into a state switcher or a test matrix |
| Triggered popup | A transient state that appears on a button click | Triggered through the real button, not treated as a primary state |
| Process step | Form steps, confirmation steps, progression steps | Reached via Next / Confirm |
| Shared overlay | A sheet/dialog/card reused across multiple pages | Extract as a shared component, wire it up uniformly |

Classify first, implement second.

Otherwise it is easy to:

- Turn a popup into a fake page state
- Hide a real process inside a debug switcher
- Reimplement a shared overlay redundantly
- Miss backfilling a state

## 8. Acceptance Design

Acceptance must be layered.

| Layer | Who Does It | What Is Verified |
|---|---|---|
| Subtask self-test | Subagent | Logic within its own scope, basic rendering, local tests |
| Integration verification | Lead agent | Full build, cross-module, visual, console, real device |
| Adversarial review | Review agent / lead agent | Scope, architecture, correctness, sufficiency of verification |
| Human checkpoint | User/owner | Product judgment, risk acceptance, merge/release |

Acceptance should not rely on a single stage alone.

## 9. Stop Conditions

During execution, work should stop or be escalated when the following occur:

- A Source of Truth conflict cannot be resolved under the rules
- An Architectural Invariant needs to be modified
- A new requirement is found to exceed this batch's scope
- A high-risk write operation is required
- A critical verification environment is unavailable
- The visual source is missing and cannot be reasonably degraded
- The contract is unclear and affects real requests
- A subagent needs to modify a shared component
- Automated verification fails for an unclear reason

Stopping is not failure.

For an AI, knowing when to stop matters more than blindly continuing.

## 10. Execution Layer Checklist

Confirm before starting execution:

- What type is this task?
- Does a plan need to be written first?
- Have non-goals been declared?
- Has the source of truth been declared?
- Is there a clear acceptance criterion?
- Has it been decomposed into reviewable small batches?
- Has Phase 0 shared infrastructure gone first?
- Are the Phase 1 parallel boundaries clear?
- Who is responsible for Phase 2 integration verification?
- Under what circumstances must work stop?

Confirm after execution completes:

- Have the in-plan goals been achieved?
- Are there any out-of-bounds changes?
- Has new technical debt been created?
- Does the Spec need updating?
- Does the workflow or checklist need updating?
- Has it already entered `change-review`?
