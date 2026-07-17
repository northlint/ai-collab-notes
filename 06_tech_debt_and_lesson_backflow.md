# 06 Technical Debt & Lesson Backflow

## Core Definitions

Technical debt is not "code that isn't written perfectly."

In AI collaboration engineering, technical debt refers to:

> A known problem, deliberately not addressed now, that will increase understanding cost, modification cost, operational risk, or governance risk in the future.

Lesson backflow refers to:

> Feeding the failures, review findings, workarounds, and stable practices from a task back into rules, templates, scripts, tests, and the knowledge base.

Together, these two form the learning capability of an engineering system.

Without a technical debt ledger, AI will repeatedly fall into the same traps.

Without lesson backflow, a team can only maintain quality by relying on human memory.

## 1. Why AI Collaboration Needs a Technical Debt Ledger Even More

Human engineers remember a lot of context:

- Which module carries heavy historical baggage
- Which interface's documentation is out of date
- Which page has a visual exception
- Which automation script is unstable
- Which class of problem has already been discussed

AI does not naturally possess this long-term memory.

If debt is not explicitly recorded, the next time AI runs, it is likely to:

- Treat a historical stopgap solution as the standard solution
- Delete code that looks useless but actually serves compatibility purposes
- Re-propose solutions that have already been rejected
- Pick the wrong source when old documentation conflicts with new facts
- Have no defense at all against known risks

So in AI collaboration, technical debt is not a supplementary document — it is an input to the execution system.

## 2. What Should Be Recorded as Technical Debt

Not every problem needs to be recorded.

A technical debt entry is warranted in these situations:

- A problem is clearly identified this time, but will not be fixed for now.
- The problem carries a risk of recurrence.
- The problem will affect judgment on subsequent tasks.
- The problem will change architecture, business logic, interfaces, tests, or release risk.
- The problem cannot be adequately explained with a simple comment.
- The problem requires memory that spans tasks, people, or agents.

Common types:

| Type | Example |
|---|---|
| Architectural debt | Module boundaries temporarily breached, inconsistent state flow |
| Business debt | Spec missing fields, exception rules unspecified |
| Interface debt | Documentation inconsistent with production fields |
| Test debt | Only the happy path is covered, no exception paths |
| Data debt | Mock data cannot cover the real state matrix |
| Visual debt | Key pages have not passed pixel-level acceptance |
| Automation debt | Cron has no idempotency, worker has no reset path |
| Documentation debt | README commands no longer work, old decisions not marked deprecated |
| Rule debt | A recurring problem still lives only as verbal reminders |

## 3. Technical Debt Record Fields

A technical debt entry contains at least:

```markdown
## Debt Title

- Type:
- Discovered on:
- Discovered via:
- Scope of impact:
- Symptom:
- Risk:
- Trigger condition:
- Reason for deferral:
- Current workaround:
- Repayment plan:
- Acceptance criteria:
- Status:
```

Field descriptions:

| Field | Meaning |
|---|---|
| Type | Architectural, business, interface, test, documentation, automation, etc. |
| Discovered via | Task, review, production incident, migration, retrospective |
| Scope of impact | Module, page, workflow, repository, pipeline |
| Symptom | The problem as currently observed |
| Risk | What happens if it is not addressed |
| Trigger condition | When it will erupt |
| Reason for deferral | Why it is not being fixed now |
| Workaround | The current temporary handling |
| Repayment plan | How it will be eliminated in the future |
| Acceptance criteria | How to determine the debt has been repaid |
| Status | open / in progress / paid / obsolete |

The most important part of technical debt is clearly stating "why it is deferred" — otherwise it degenerates into a vague to-do.

### 3.1 Deferral-Reason Classification: A Dimension Orthogonal to Severity

Severity tiering (P0-P3, see §5) answers "how important"; deferral-reason classification answers "why not now" — the two dimensions are orthogonal, and both should be filled in when recording an entry.

| Type | Meaning | Handling |
|---|---|---|
| Business-not-yet-triggered | A business phase or precondition has not yet begun; once conditions mature, it naturally enters the backlog | Record the trigger condition; do not chase it before the condition holds |
| Actively rejected | Already evaluated, explicitly decided not to do | Fixed fields: "reason" + "what if circumstances change" |
| Temporarily missed | A small loose end that ran out of time this development round | Clear it as soon as possible in the next batch or during opportunistic repayment |

The actively-rejected type is the easiest to miss recording: if "already discussed, decision was not to do it" is not explicitly archived, the same proposal will be re-raised in a later task — possibly by a different agent — and the team will have to spend the same analysis cost discussing it all over again. The value of recording it is not to remind people "not done yet," but to **archive an already-adjudicated decision, preventing it from being repeatedly re-litigated**.

## 4. Technical Debt Is Not a Dumping Ground

The technical debt ledger must not become a dumping ground for every problem.

The following should not be recorded as technical debt:

- A small typo that can be fixed immediately
- A subjective preference with no scope of impact
- A speculative problem that cannot be reproduced
- A complaint about a problem with no repayment path
- A Blocking problem that must be fixed within the scope of the current task

A Blocking problem cannot dodge a fix by being recorded as technical debt.

Technical debt applies to problems that "can be deferred, but must be made visible."

The other half of the admission bar is "genuinely cannot be done now." Three typical **false deferrals**:

- **"Playing it safe" is not a reason to defer.** A refactoring-type finding caught in review (e.g., duplicated code that has crossed the Rule-of-Three threshold), deferred on the grounds that "it touches already-shipped code, refactoring on the spot would widen the change boundary" — in practice this kind of extraction rarely causes rework. As long as it can be written and tested (mechanical gate + runtime verification as a backstop), do it on the spot; "it affects already-shipped code" by itself is not a valid reason for deferral.
- **"Waiting for confirmation" must first exhaust authoritative sources.** Before shelving something on the grounds of "waiting on backend / waiting on a third party to confirm," first check whether existing authoritative sources (production package, existing implementation, contract documentation) can already settle the answer. If it can be found, it isn't debt — it's unfinished work.
- **Work that has already been adjudicated and is only waiting on scheduling** should go straight into an execution batch; recording it and scheduling it later is a process tax.

Rule of thumb: **technical debt admission = genuinely blocked externally (missing backend / missing physical device / missing design resources), or the fix itself requires an independent initiative.** Everything else that "should be done" gets done directly.

**The authority to create debt belongs to humans; AI only has proposal rights.** AI must not unilaterally mark something "deferred" and declare the task complete. A proposal must let the decision-maker understand the cost in terms they can grasp: what happens if not done (written as a phenomenon the other party can personally verify) / the cost of doing it now / the recommendation and its rationale — and "defer" must not be the only option offered. A newly added debt entry with no record of a decision-maker's sign-off is invalid; review enforces this (for the enforcement form aimed at non-technical users, see "Toolchain Governance" §6).

### 4.1 Governance Debt: Dead Code Within the Governance Mechanism Itself

Technical debt is about code; **governance debt** is about the governance system itself — the processes, ledgers, closed loops, and review steps built for AI collaboration are equally prone to over-design, and equally capable of turning into dead code.

Typical forms of governance debt:

- An elaborately designed tracking mechanism that, in practice, always takes the "doesn't exist, so skip" branch.
- A checklist item that has never once caught a problem.
- An artifact committed to disk that no downstream consumer ever reads.
- A review dimension whose conclusion is "not applicable" every single time.

There is only one test:

> Can the problem this mechanism guards against be eliminated at zero cost **further upstream**? If yes, don't build the mechanism.

A real specimen: a cross-phase ledger was designed to guard against "plan-review must-fix items being forgotten during execution" — plan review commits pending items to disk, change review closes them one by one. It later turned out that, before execution even begins, the must-fix items can simply be fixed directly into the plan document, followed by an incremental re-review until it passes — at which point the ledger stays permanently empty. The mechanism was scrapped entirely, and the process became shorter and more reliable as a result.

Every governance step added carries an **enforcement cost** (it must run every cycle, and every participant must understand it). Periodically ask: which steps have run empty for the last three consecutive times? A step that runs empty is not "stable" — it is debt.

## 5. Debt Tiering

Tiering by risk is recommended.

| Tier | Meaning | Handling |
|---|---|---|
| P0 | Has already caused incorrect results, data risk, or release risk | Address immediately |
| P1 | High probability of affecting subsequent tasks or core workflows | Include in near-term plans |
| P2 | Moderate risk, affects maintenance efficiency | Schedule repayment |
| P3 | Low risk, mainly cleanup and consistency | Batch cleanup |

Three factors to consider when tiering:

- Frequency: how often will it be encountered?
- Severity: how much loss if it occurs?
- Repair cost: how much difference between fixing it now versus later?

A high-frequency, low-cost problem should not be recorded long-term — it should be automated as soon as possible.

A low-frequency, high-risk problem should enter the review checklist and a manual checkpoint.

## 6. The Four-Level Path of Lesson Backflow

A lesson should not stop at "now I know."

A four-level backflow is recommended:

```text
One-off finding
  → checklist
  → stable rule
  → automated constraint
```

### 6.1 One-Off Finding

Suited to sporadic problems.

Handling:

- Write it into the review record
- Write it into the handoff if necessary
- Do not rush to escalate it into a rule

### 6.2 Checklist

Suited to a problem that is beginning to recur.

Examples:

- UI tasks must check empty, loading, and error states.
- Interface tasks must confirm fields come from the current source of truth.
- Cron tasks must have locking and idempotency.

### 6.3 Stable Rule

Suited to high-frequency or high-risk problems.

Rules should be written into:

- `AGENTS.md`
- Spec templates
- Review templates
- Project `README`
- The knowledge base

Example:

```text
Rule:
When changing a production interface field, do not rely solely on historical documentation.
Current interface samples, production observation, or reproducible requests must be used as evidence.
```

### 6.4 Automated Constraint

Suited to problems a machine can check.

Methods include:

- Unit tests
- e2e
- Lint
- Schema validation
- Dead-key detection
- Screenshot diff
- Lock files
- Queue state machines
- CI gates

The value of automation is that the same class of error no longer relies on human memory.

## 7. The Closed Loop From Review to Debt

After a review finds a problem, the options are not just "fix" or "don't fix."

The correct closed loop is:

```text
Problem found
  → Determine whether it is Blocking
  → Blocking: fix immediately
  → Non-blocking: determine whether there is a recurrence risk
  → Recurrence risk exists: record as technical debt
  → Recurs multiple times: escalate to a rule
  → Machine-checkable: automate
```

Example:

```text
Finding:
Multiple occurrences of an async task failing while the main flow still shows success.

First occurrence:
Noted in the review record.

Second occurrence:
Added to the change-review checklist.

Third occurrence:
Codified as a rule: blocking failures in a long-running task must not be silently swallowed.

After that:
Added a worker state-machine test and a failure notification check.
```

### 7.1 Review History Is Raw Material for Pattern Analysis

Review history is not archival waste paper.

It is a data source for identifying recurring patterns.

After each change-review, a key summary should be archived to history, including:

- Date
- Verdict
- Issue category
- Severity
- Brief description
- Whether resolved
- Whether escalation to a rule is recommended

When a current problem resembles a historical one, it should be flagged as recurring.

The raw material for history is not limited to findings caught by review: missed-detection samples recovered during diagnosis ([REVIEW ESCAPE], see "Diagnostic Methodology" §5) should also be archived — recurrence statistics must cover both "what was caught" and "what slipped through," or the escalation judgment will be distorted.

The value of recurring is not "reminding you that you erred again," but triggering a system upgrade.

### 7.2 Escalating a Rule After Three Recurrences

Using "three recurrences" as the threshold for rule escalation is recommended.

```text
First time: review finding
Second time: checklist item
Third time: convention proposal
After that: AGENTS / skill / script / CI
```

This is not mechanical numerology.

Its purpose is to prevent two extremes:

- Every sporadic problem being escalated into a rule, causing rule bloat.
- A high-frequency problem staying stuck at manual reminders, causing repeated rework.

After three recurrences, at least ask:

- Should this be written into `AGENTS` / `CLAUDE`?
- Should this enter the plan-review or change-review checklist?
- Can this be automatically checked with a script, lint, test, or CI?
- Should this be made into a skill or workflow?
- Should a case be added to the knowledge base?

### 7.3 Convention Proposal

When a problem exhibits stable recurrence, a rule-escalation candidate should be formed.

A convention proposal at minimum states:

- Rule origin
- Recurring phenomenon
- Risk
- Proposed rule to escalate to
- Applicable scope
- Non-applicable scope
- Where it lands
- What part can be automated

Example:

```text
Recurring phenomenon:
Multiple occurrences of a test name claiming to cover a call chain, while the test body only checks initialization.

Proposed rule:
The test name and test body must be contractually consistent. When the name says invokes / logs / persists / retries, the test body must genuinely assert the corresponding behavior.

Where it lands:
AGENTS + change-review checklist.

Can be automated:
Partially, through test-name-pattern scanning as a prompt; ultimate judgment still requires review.
```

The "what can be automated" part is not an optional annotation — it is a **key field** of the proposal, with these requirements for how it is written:

- Where mechanization is possible, give a form that is **directly usable**: a lint rule name plus configuration, a grep regex, a dependency-check rule — not "consider adding a check."
- Where mechanization is not possible, state why (requires cross-file semantic judgment / depends on runtime facts, etc.).
- Principle: **a machine gate is a one-time cost; a documentation rule pays a review cost on every enforcement.** A rule that can be turned into a gate should not stay parked at the documentation layer indefinitely; once gated, the documentation should keep only a one-line pointer.

### 7.4 Landing Tiers for Rule Escalation

Lesson backflow does not all get written into the same place.

Recommended landing order:

| Problem type | Preferred landing location |
|---|---|
| Collaboration process | Global `AGENTS` / skill |
| Project convention | Project `AGENTS` / `CLAUDE` |
| Architectural invariant | `specs` / architecture docs |
| Current business state | `openspec` / business spec |
| Review lessons | Review checklist |
| Machine-checkable | Script / lint / test / CI |
| Deferral risk | `technical_debt` |
| Locational facts (symptom → mechanism, terminology → code) | Fact base (see [`10_事实库治理.md`](./10_fact_base_governance.md)) |
| Teaching cases | Case Library |

A stable rule should land at the position closest to execution.

Anything that can be automated should not rely on documentation reminders alone for the long term.

## 8. Typical Debt Scenarios

### 8.1 Async Failure Silently Swallowed

Symptom:

A step in the task execution chain fails, but only logs it without changing the final state.

Risk:

- The automated flow shows completion
- Subsequent steps proceed based on an incorrect state
- Humans mistakenly believe the task has been handled

Repayment plan:

- Define error severity levels
- Block error propagation upward
- Write non-blocking errors into state
- Have the worker check that the failure list is empty before completion

Lesson backflow:

> Every unattended workflow must have a failure state, notification, and reset path.

### 8.2 Dead i18n Keys

Symptom:

A translation key is no longer used, but remains in the resource file.

Risk:

- AI mistakenly believes the feature still exists
- Search results interfere with judgment
- Subsequent cleanup cost increases

Repayment plan:

- Build dead-key scanning
- Confirm there is no dynamic string concatenation before deleting
- Record the scope of this cleanup

Lesson backflow:

> A resource file is not a business source of truth; it must be judged in conjunction with its reference chain.

### 8.3 Stale Documentation Misleading

Symptom:

The interface documentation has not been updated, but the code or production behavior has already changed.

Risk:

- AI implements against the stale field
- The test fixture also follows the stale field, so it cannot expose the problem

Repayment plan:

- Annotate the documentation's status
- Supplement current facts
- Update `openspec`
- Add a "documentation freshness" check to the review template

Lesson backflow:

> Documentation needs a status: current / stale / deprecated / unknown.

### 8.4 Fabricated Citations

Symptom:

A comment, KDoc, or review report claims to reference some specification, but the original cannot be located.

Risk:

- The authority of the rule is fabricated
- Subsequent AI runs continue copying an erroneous source

Repayment plan:

- Delete citations that cannot be verified
- Experiential judgment may be retained, but must be marked as a local rule
- High-value rules should be written into the knowledge base

Lesson backflow:

> A rule with an unverifiable source must not be packaged as an upper-level specification.

### 8.5 Missing Visual Assets

Symptom:

A page is missing an image; AI substitutes a placeholder or temporary image.

Risk:

- Visual acceptance becomes distorted
- Design fidelity is incorrectly deemed complete

Repayment plan:

- First search upstream projects, design files, and asset directories
- Only record it as asset debt if it cannot be found
- Clearly state the scope of the placeholder and the conditions for replacement

Lesson backflow:

> A missing asset is not a license for free improvisation — find the source first, placeholder second.

## 9. Repaying Technical Debt

Technical debt must be cleared on a regular basis.

Three approaches can be used:

### 9.1 Opportunistic Repayment

When a task happens to touch the relevant area, and the risk is controllable, repay it opportunistically.

Requirements:

- Do not expand the task boundary too much
- There must be verification
- State it clearly in the delivery notes

### 9.2 Batch Repayment

Suited to debts of the same kind.

Examples:

- Cleaning up a batch of dead keys
- Unifying a batch of interface fields
- Fixing a batch of stale README commands
- Adding failure-state checks for multiple workers

Requirements:

- Do a batch task decomposition first
- Have a unified acceptance standard
- Submit in batches

### 9.3 Dedicated Repayment

Suited to architectural debt, state-machine debt, and automation debt.

Requirements:

- A standalone plan
- Plan Review
- A clear migration path
- A clear rollback method
- Change Review

For source governance and reconciliation methods for large-scale migration-type repayment, see [`09_迁移与重写治理.md`](./09_migration_and_rewrite.md).

## 10. Principles for Maintaining the Technical Debt Ledger

The technical debt ledger should stay readable and actionable.

Maintenance principles:

- A newly added debt entry must have a trigger condition and a repayment path.
- A repaid debt should be marked `paid`, not simply deleted.
- An invalidated debt should be marked `obsolete`.
- Duplicate debts should be merged.
- Long-unaddressed P1/P0 items must be re-evaluated.
- If a debt turns into a rule, link to where the rule lands.
- If a rule turns into automation, link to the script or test.

The technical debt ledger is not a pile of historical junk.

It should be a risk map that AI reads before execution.

## 11. How a Lesson Enters the Knowledge Base

At the end of each task, five questions can be asked:

- Where did drift occur this time?
- Which judgment relied on tacit experience?
- Which problem could have been avoided if a template had existed earlier?
- Which check can be automated?
- Which rule should be elevated to Upper-Level Rules?

When a lesson enters the knowledge base, do not just write a story.

Recommended structure:

```text
Source of the lesson:
What happened:
The wrong approach:
The correct approach:
The abstracted rule:
Applicable boundary:
What can be automated:
```

The value of the knowledge base is not recording "what was done at the time."

Its value is letting future AI and humans get it right faster in similar situations.

## 12. From Lesson to Skill

When a certain kind of process recurs repeatedly, a template alone is not enough.

It should be packaged into a skill, script, or workflow.

Signals that something is suited for packaging:

- The steps are stable
- The inputs and outputs are stable
- A strict order is required
- AI frequently misses a step
- A fixed-format artifact needs to be produced
- A fixed rule source needs to be read
- It needs to be written to a fixed archival location

For example:

- plan-review: fixed to read the plan, challenge the design, and output a verdict; must-fix items are fixed directly into the plan document and go through an incremental re-review.
- change-review: fixed to read the diff, run mechanical gates and **self-certify execution** (false-green defense: a count of 0 is treated as a failure), dispatch judgment review scaled to difficulty, and write pending.
- commit-flow: fixed to archive the review, check the diff, and commit.
- cron-handoff: fixed to generate a continuation handoff.

A template lets a person know how to do it.

A skill lets AI do it on the same track every time.

CI and scripts keep the system from failing even when AI forgets.

For the engineering discipline of the track itself (a skill is also code, cross-tool read/write contracts, enforcement tiers, verdict evidencing), see [`07_工具链治理.md`](./07_toolchain_governance.md).
