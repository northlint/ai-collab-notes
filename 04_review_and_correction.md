# 04 Review & Correction

## Core Definition

Review & Correction is the brake mechanism within the AI collaboration engineering governance system.

It is not a courtesy check, nor a cursory "looks fine at a glance." Its responsibility is to:

- Detect goal drift
- Detect misuse of the source of truth
- Detect architectural violations
- Detect implementation gaps
- Detect fabricated verification
- Detect documentation drifting apart from code
- Halt the process before risk enters the mainline

In a word:

> Review is not a rubber stamp — it is what forces AI output to withstand counter-evidence.

## 1. Why AI Collaboration Requires Adversarial Review

The common problem with AI is not "it doesn't work" but "it looks done."

Typical manifestations:

- The plan is written completely, but a critical dependency is missing.
- Lots of code changed, but the real problem was never touched.
- Claims the tests pass, but the tests contain no assertions.
- Claims to have referenced the documentation, but the documentation contains no such conclusion.
- The UI looks close, but state, spacing, and interaction do not match the source of truth.
- The subagent produces a lot of output, but never actually read the core files.
- Fixing one bug while introducing a more hidden architectural debt.

So review must be adversarial.

Adversarial does not mean rejecting AI — it means actively asking:

- Where did this conclusion come from?
- Is there any counter-evidence?
- Did it cross the task boundary?
- Does it comply with the upper-level invariants?
- Is there real verification, not just a verbal claim of verification?
- If this merges today, who is affected tomorrow?

## 2. Where Review Sits in the Governance System

Review sits at the critical checkpoints of the execution flow.

```text
Goal input
  → Plan decomposition
  → Plan Review
  → Execution & implementation
  → Self-verification
  → Change Review
  → Delivery / commit / release
  → Lesson backflow
```

Plan Review reviews "how it's planned to be done."

Change Review reviews "what was actually delivered."

Neither can substitute for the other.

A plan being approved does not mean the implementation is necessarily correct.

An implementation that appears to work does not retroactively prove the plan was sound.

## 3. Plan Review: Pre-Execution Review

The goal of Plan Review is to prevent a task from going off track from the outset.

It focuses on checking:

- Whether the goal is clear
- Whether the scope is bounded
- Whether the source of truth is clear
- Whether dependencies are identified
- Whether risks are surfaced
- Whether acceptance criteria are verifiable
- Whether the execution order is reasonable
- Whether a human checkpoint is needed

### 3.1 Plan Review Required Checks

| Check | Question to Ask |
|---|---|
| Goal | What user problem is this plan meant to solve? |
| Scope | What is in scope, and what is explicitly out of scope? |
| Source of Truth | Who/what is authoritative for business logic, visuals, architecture, and interfaces respectively? |
| Invariants | Does this touch the architectural constitution? |
| Dependencies | Does it depend on external accounts, devices, environments, permissions, or data? |
| Decomposition | Can it be executed in batches with independent acceptance? |
| Risk | Where is it most likely to fail? |
| Acceptance | How will completion be proven, rather than merely claimed? |
| Checkpoint | Which actions must wait for human confirmation? |
| Rollback | How do you stop or recover after an error? |

### 3.2 Common Plan Review Verdicts

Plan Review should produce a clear conclusion, not a vague opinion.

Available verdicts:

- `APPROVE`: The plan is complete and ready to proceed to execution.
- `APPROVE WITH CHANGES`: The overall direction is workable, but must-fix items must be addressed first.
- `RETHINK`: The plan's underlying assumptions are wrong and it needs to be rewritten.

Example:

```text
Verdict: APPROVE WITH CHANGES

Must-fix:
- Add source-of-truth priority: production interface > verified behavior > legacy documentation.
- Split the batch migration into Phase 0 infrastructure, Phase 1 parallel pages, Phase 2 integration acceptance.
- Add a human checkpoint: change scope and verification evidence must be output before commit.
```

### 3.3 Plan Review Issue Categories

Plan Review does not merely check "whether the plan was written."

It is recommended to review by these categories:

| Category | Focus |
|---|---|
| DESIGN | Whether the solution is over-engineered, whether the abstraction level is correct, whether it bypasses established practices |
| EDGE CASE | Real-world edges such as network conditions, empty states, concurrency, background switching, migration, compatibility |
| INCOMPLETE | Whether goal, scope, files, steps, dependencies, or ordering are missing |
| CONVENTION | Whether it violates AGENTS, CLAUDE, project conventions, or architectural boundaries |
| RISK | Whether APIs, classes, paths, and external dependencies actually exist, and whether there are hidden side effects |
| IMPACT | Whether it affects public APIs, shared models, serialization, or cross-module calls |
| MAINTENANCE | Whether it introduces implicit contracts, magic values, order dependencies, or long-term comprehension cost |

The value of Plan Review lies in interrupting a wrong direction early.

Catching a problem at the planning stage means fixing text and ordering.

Catching it only after implementation may mean fixing dozens of files.

## 4. Change Review: Pre-Delivery Review

The goal of Change Review is to prevent a flawed deliverable from entering the next stage.

It is not concerned with "whether effort was made," but with:

- Whether the change solves the target problem
- Whether it introduces new problems
- Whether it complies with architectural and business constraints
- Whether there is evidence to prove it
- Whether it leaves behind unregistered risk

### 4.1 Change Review Required Checks

| Check | Question to Ask |
|---|---|
| Scope Consistency | Does the change cover only this task's scope? |
| Source-of-Truth Consistency | Does the implementation come from the correct source? |
| Architectural Consistency | Does it break module boundaries, data flow, or state management? |
| Behavioral Correctness | Are the normal path, error paths, and empty states correct? |
| Verification Evidence | Do tests, screenshots, logs, real-device checks, and pixel checks actually exist? |
| Documentation Sync | Have affected specs, README, technical debt records, and handoffs been updated? |
| Debt Registration | Are leftover issues explicitly recorded? |
| Regression Risk | Are legacy features, legacy entry points, and legacy data affected? |

Certain business categories (such as financial write operations or permission determination) should be pinned at the highest review intensity: investment should not naturally degrade just because this code has been changed and passed review many times before — the floor on review intensity set by the risk category does not shift with historical track record.

### 4.2 Common Change Review Verdicts

Available verdicts:

- `APPROVE`: Ready to deliver.
- `APPROVE WITH CHANGES`: must-fix items exist (blocking / important); deliverable once fixed; the re-review follows an incremental re-review (see "Long-Running Tasks, Loop, Cron & Unattended Operation" §8.3).
- `REQUEST CHANGES`: A fundamental problem exists that requires rethinking the approach; a local patch cannot save it. No incremental path — after redoing the work, a full re-review is required.

The line between tiers is not "how severe the problem is" but the **repair path**: if it can be fixed item by item (even if severe), it is APPROVE WITH CHANGES; only when the approach's direction itself is wrong, and fixing items cannot save it, is it REQUEST CHANGES.

Example:

```text
Verdict: APPROVE WITH CHANGES

Blocking:
- The commit claims the interface switch is complete, but two call sites still use the old path.
- Tests only cover the mock success path and do not cover the server returning an empty array.

Important:
- The startup command in the README is no longer valid; the documentation was not synced.
```

```text
Verdict: REQUEST CHANGES

Problem:
- This change builds a custom client-side polling mechanism for state sync, but the project
  already has a server push channel, and the architectural invariants mandate that state sync
  go through push. The approach's direction conflicts with the existing architecture;
  continuing to fix items on top of this polling implementation would only deepen the divergence.

Alternative:
- Use the existing push channel to carry state updates, and remove the polling state machine.
```

### 4.3 Change Review Issue Categories

Change Review must prove that "the actual change is deliverable."

It is recommended to review by these categories:

| Category | Focus |
|---|---|
| PLAN GAP | Whether the implementation misses plan items, whether unexplained deviations occur |
| DESIGN | Abstraction, coupling, state management, lifecycle, silent failure |
| ROBUSTNESS | Async failures, null values, timeouts, retries, cleanup, crash risk |
| PERFORMANCE | Redundant computation, listener leaks, N+1, main-thread blocking |
| CONVENTION | Project rules, naming, disallowed patterns, architectural boundaries |
| QUALITY | Obvious logic errors, dead code, TODOs, unused variables, resource leaks |
| LINTER | Issues introduced by this change in lint/analyze/test |
| RECURRING | Problems that have recurred across historical reviews |

Change Review must read the actual changed files and their context.

Looking only at the diff can easily miss:

- Impact on callers
- File-level conventions
- Lifecycle relationships
- Legacy logic guard conditions
- Documentation sync gaps

### 4.4 Plan Review's Must-Fix Items Close Out at the Planning Stage

Once Plan Review raises must-fix items, the correct handling is not to log them into a ledger and carry them into the execution period, but rather:

> Directly revise the plan document itself → incremental re-review → until APPROVE, and only then proceed to execution.

Rationale: at this point work has not yet begun, so revising the plan's text is a **zero-cost fix at the source**. Once the plan is fixed, the problem no longer exists — no cross-stage tracking mechanism is needed; a fixed plan is itself the closure.

Therefore Change Review does not carry the responsibility of "closing out items left over from Plan Review": a plan that enters execution must already be in the APPROVE state; and if the user explicitly skips `plan-review` and proceeds directly to execution, there is no debt to settle either.

> Historical note: an earlier version of this knowledge base designed a cross-stage closure mechanism where "plan-review writes pending to disk → change-review closes items one by one (PR-RESOLVED / PR-UNRESOLVED)," which was later abolished entirely — the problem it guarded against could be eliminated at zero cost further upstream. This is a textbook sample of governance debt; for its definition and criteria, see [`06_技术债与经验回流.md`](./06_tech_debt_and_lesson_backflow.md) §4.1 "governance debt."

## 5. Multi-Dimensional Review Framework

A complex task cannot be reviewed from the single angle of "does it run."

It is recommended to review along these dimensions:

| Dimension | Focus |
|---|---|
| DESIGN | Visuals, interaction, information hierarchy, state completeness |
| ROBUSTNESS | Exceptions, retries, timeouts, idempotency, empty states |
| PERFORMANCE | Rendering, caching, batch jobs, polling frequency, resource consumption |
| CONVENTION | Directory structure, naming, architecture, project conventions |
| QUALITY | Readability, tests, abstraction boundaries, duplicated code |
| SECURITY | Permissions, secrets, data leakage, dangerous operations |

Not every review needs to expand all dimensions.

But a high-risk task must at least explicitly state:

- Which dimensions have been reviewed
- Which dimensions do not apply
- Which dimensions are still pending

## 6. Review Must Be Able to Halt the Process

If review has no authority to halt, it is mere decoration.

Delivery must stop in the following cases:

- The source of truth is unclear
- An architectural invariant is broken
- Test or verification evidence does not exist
- A critical error path is not covered
- It involves data destruction, permission escalation, or automated release without a human checkpoint
- The AI plainly cannot prove where its conclusion came from
- "Done" is found to be inconsistent with the actual file state

Stopping is not failure.

Stopping avoids disguising uncertainty as completion.

## 7. Blocking, Important, Minor

Review findings must be graded.

| Level | Meaning | Handling |
|---|---|---|
| Blocking | Cannot proceed to the next stage without fixing | Must fix |
| Important | Not necessarily blocking, but noticeably raises risk | Fix with priority or register as debt |
| Minor | Naming, formatting, minor consistency issues | Fix opportunistically or handle later |

Do not write every finding as Blocking.

Nor downgrade a genuinely blocking problem into a mere suggestion.

### 7.1 Preventing Review from Becoming an Infinite Debt

The goal of review is not to "nitpick until there's nothing left to say."

The goal of review is to render an actionable verdict against a fixed target.

Therefore:

- Only blocking / important items halt the process.
- Minor items should not drive repeated loops.
- Acceptable gaps must be explicitly `accept`ed or registered as debt.
- Suggestions that will not be acted on must be explicitly marked `wontfix`, with a stated reason.
- Style preferences must not be disguised as correctness issues.

Otherwise `change-review` becomes a bottomless pit, and the loop can never converge.

For the state semantics of `accept` / `wontfix` and adjudication authority (which must rest with a human, not be self-exempted by the executing agent), see §10.2.

### 7.2 Strictness Is Not Unlimited Escalation

Strict review does not mean blocking on every issue.

Strictness means:

- The source is clear
- The standard is clear
- The evidence is clear
- The fix is clear
- The verdict is clear

If an issue has no evidence, no impact, and no concrete fix, it should not be written up as a blocking item.

## 8. Review Evidence

Review conclusions must be backed by evidence wherever possible.

Common forms of evidence include:

- File paths and line numbers
- Command output
- Test results
- Screenshots
- Real-device logs
- Network request records
- API response samples
- Design-file nodes
- Comparison against prior-version behavior
- Code reference chains

Example:

```text
Problem:
The implementation claims to use the production interface field status, but the field name
in the interface sample is approval_status.

Evidence:
- The openspec sample response field is approval_status.
- The current code reads status at the point of state determination.
- The test fixture does not cover approval_status, so the error was never exposed.
```

## 9. Typical Correction Scenarios

### 9.1 Contract Changes Following the Wrong Source of Truth

Anti-pattern:

The AI modifies the field mapping based on outdated interface documentation, but the production interface has already changed.

Correction:

- First confirm the source-of-truth priority.
- Observed production facts outrank legacy documentation.
- Documentation serves as a reference, not the final adjudication.
- After the change, update the spec in reverse or register a documentation debt.

Abstract rule:

> Interface-related changes must verify current facts, not merely cite historical documentation.

### 9.2 Async Failures Silently Swallowed

Anti-pattern:

A step in the task queue fails, but after being caught it is only logged, while the overall result still shows success.

Correction:

- Clarify whether the failure is blocking.
- A blocking failure must be thrown upward or written into state.
- Automated processes must have failure notification and reset actions.

Abstract rule:

> In an unattended process, a silent failure is equivalent to false completion.

### 9.3 KDoc or Comments Fabricating References

Anti-pattern:

A code comment says "refer to such-and-such spec," but the spec contains no corresponding provision.

Correction:

- Remove references that cannot be substantiated.
- If it is genuinely an empirical rule, label it as a project rule.
- Important rules should be codified into the spec or `AGENTS`, not hidden in comments.

Abstract rule:

> Comments may explain intent, but must not fabricate provenance.

### 9.4 Subagent Running Empty

Anti-pattern:

The subagent reports "review complete," but never read the target files and has no evidence.

Correction:

- The lead agent must spot-check the subagent's inputs and evidence.
- The review report must include file references or an explicit reason why they do not apply.
- For critical tasks, the lead agent retains final adjudication authority.

Abstract rule:

> Subagents can run in parallel, but responsibility cannot be outsourced.

## 10. How Review Records Get Put Into Practice

Review records are not kept for the sake of leaving a trace.

Their value is:

- Making decisions traceable
- Making risk reviewable in retrospect
- Enabling lesson backflow
- Preventing the same mistake from recurring

Recommended structure:

```markdown
# Review: Task Name

## Verdict
APPROVE / APPROVE WITH CHANGES / REQUEST CHANGES / RETHINK

## Scope
- Scope of this review

## Findings
- Blocking
- Important
- Minor

## Evidence
- Files, commands, screenshots, logs

## Required Changes
- Items that must be fixed

## Follow-up Debt
- Issues that can be deferred but must be registered
```

### 10.1 Pending and History

Review records are recommended to be split into two categories:

| Type | Purpose |
|---|---|
| pending | Current unarchived review results, driving the next fix |
| history | Archived review summaries, used for pattern analysis |

Typical structure:

```text
plan/reviews/
  change_review_pending.md
  change_review_history.md
```

The `pending` file stores the current verdict, issue IDs, status, and must-fix items.

The `history` file stores historical summaries, used to spot recurring problems.

Note: **only Change Review needs to be written to disk**. Plan Review is not written to disk — its must-fix items are fixed directly into the plan document (see §4.4), with the plan document itself being the sole carrier.

### 10.2 Review Issue States

Every review issue should have a state.

Recommended states:

- `OPEN`: Still pending.
- `ACCEPTED`: Risk accepted, no longer blocking. **Requires adjudication by a human** (not the executing agent itself), with a stated reason.
- `WONTFIX`: Explicitly will not be fixed, with a stated reason. Likewise requires human adjudication.

Once an issue is fixed and archived into history, it is recorded as `resolved`; `ACCEPTED` / `WONTFIX` items are archived as-is, preserving the judgment made at the time.

A state is more reliable than simply deleting the issue.

Deletion loses the decision; a state preserves the judgment.

### 10.3 Review Records Must Be Able to Drive the Process

A valid review record must be able to answer at least:

- Can it proceed right now?
- If not, which issues are blocking it?
- Who fixes each issue, and how?
- How will it be proven once fixed?
- Which issues become debt and no longer block the current process?

If a review record cannot drive the next action, it is not an engineering asset — it is merely commentary.

## 11. Review and Lesson Backflow

Every review should ask one question:

> Is this issue worth escalating into a rule?

If it is a one-off issue, recording it is sufficient.

If it is a recurring issue, it should become a candidate for technical debt or rule escalation.

If it is a high-frequency, high-risk issue, it should be escalated into:

- AGENTS.md
- spec templates
- review checklist
- automated tests
- lint / script / CI
- skill or workflow

The end goal of review is not to point out errors.

The end goal of review is to make the system commit fewer similar errors next time.

---

Review guards against errors **entering**; once an error has already occurred (a production bug, a defect ticket), follow the evidence-based localization process instead — see [`05_诊断方法论.md`](./05_diagnostics.md).
