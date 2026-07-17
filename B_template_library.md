# Appendix B: Template Library

## Usage

The template library translates governance thinking into concrete artifacts.

Principles of use:

- Templates are not a fill-in-the-blank exercise; they must be tailored to the task at hand.
- "Not applicable" in a template must still be explained.
- For high-risk tasks, err on the side of keeping more checklist items.
- Templates can be copied into a project's `plan/`, review records, handoff documents, or `AGENTS.md`.

## 1. Plan Template

```markdown
# Plan: Task Name

## Objective
- Problem the user wants solved:
- Target state upon completion:

## Background
- Current state:
- Known constraints:
- Relevant historical decisions:

## Source of Truth
- Business source of truth:
- Architecture source of truth:
- Visual source of truth:
- Interface source of truth:
- Runtime fact source:
- Conflict adjudication order:

## Scope
### In scope this round
- 

### Out of scope this round
- 

## Approach
- Core idea:
- Modules involved:
- Data flow / state flow:
- Compatibility strategy:

## Execution Breakdown
### Phase 0: Infrastructure / Contracts
- 

### Phase 1: Core Implementation
- 

### Phase 2: Integration & Acceptance
- 

## Risks
- Risk:
- Trigger condition:
- Mitigation:

## Acceptance Criteria
- Functionality:
- Visual:
- Data:
- Exceptions:
- Performance:
- Documentation:

## Human Checkpoints
- Checkpoint:
- Questions requiring user confirmation:
- Actions not executed by default:

## Rollback / Stop Conditions
- When to stop:
- How to recover:
```

## 2. Plan Review Template

> Implementation approach: recommended to be packaged as a skill / command. Once landed, the skill serves as the runtime standard; this template retains the rationale and skeleton (mechanism-level consistency suffices — the wording may evolve as it lands).

```markdown
# Plan Review: Task Name

## Verdict
APPROVE / APPROVE WITH CHANGES / RETHINK

## Review Scope
- Documents read:
- Code / resources checked:
- Uncovered scope:

## Summary
- 

## Blocking / Must-fix
- Issue:
- Evidence:
- Required change:

## Important
- Issue:
- Impact:
- Suggestion:

## Minor
- 

## Checklist
- [ ] Objective is clear
- [ ] Scope is converged
- [ ] Source of truth is explicit
- [ ] Architectural invariants are not violated
- [ ] Dependencies and permissions are explicit
- [ ] Batch task decomposition is reasonable
- [ ] Risks are visible
- [ ] Acceptance criteria are verifiable
- [ ] Human checkpoints are explicit
- [ ] Stop conditions are explicit

## Follow-up Actions
- 
```

## 3. Change Review Template

> Implementation approach: same as Template 2 — once packaged as a skill, the skill becomes the runtime standard.

```markdown
# Change Review: Task Name

## Verdict
APPROVE / APPROVE WITH CHANGES / REQUEST CHANGES

## Review Scope
- Changed files:
- Commands run:
- Evidence reviewed:
- Uncovered scope:

## Findings
### Blocking
- 

### Important
- 

### Minor
- 

## Dimension Checklist
- [ ] Scope consistency
- [ ] Source-of-truth consistency
- [ ] Architectural consistency
- [ ] Behavioral correctness
- [ ] Exception paths
- [ ] Verification evidence
- [ ] Documentation sync
- [ ] Technical debt logged
- [ ] Regression risk

## Verification Evidence
- Tests:
- Build:
- Screenshots:
- Logs:
- Real device / browser:
- Other:

## Must-fix
- 

## Deferrable Debt
- 
```

## 4. Technical Debt Template

```markdown
# Technical Debt: Debt Title

- Type:
- Level: P0 / P1 / P2 / P3
- Reason deferred: business not yet triggered / deliberately declined (with "if this changes" conditions) / temporary oversight
- Status: open / in progress / paid / obsolete
- Date found:
- Source of discovery:
- Scope of impact:

## Symptom
- 

## Risk
- 

## Trigger Condition
- 

## Reason for Deferral
- 

## Current Workaround
- 

## Repayment Plan
- 

## Acceptance Criteria
- 

## Related Records
- Plan:
- Review:
- Commit:
- Issue:
```

## 5. Rule Upgrade Candidate Template

```markdown
# Rule Upgrade Candidate: Rule Name

## Source
- From task / review / production issue / retrospective:

## Recurrence
- First time:
- Second time:
- Third time:

## Risk
- 

## Proposed Rule
> 

## Applicable Scope
- 

## Non-Applicable Scope
- 

## Landing Location
- [ ] AGENTS.md
- [ ] README.md
- [ ] spec template
- [ ] review checklist
- [ ] automation script
- [ ] CI
- [ ] skill / workflow

## Automatable Portion
- 
```

## 6. Batch Task Decomposition Template

```markdown
# Batch Task Decomposition: Task Name

## Batch Objective
- 

## Shared Premises
- Source of truth:
- Common types:
- Common components:
- Common mocks:
- Cache / state rules:
- Acceptance method:

## Phase 0: Common Foundation
- [ ] Contract / schema
- [ ] Mock state matrix
- [ ] Base components
- [ ] Common utilities
- [ ] Review standard

## Phase 1: Parallel Subtasks
| Subtask | Scope | Input | Output | Acceptance |
|---|---|---|---|---|
| A | | | | |
| B | | | | |

## Phase 2: Integration
- [ ] Merge types
- [ ] Merge state flow
- [ ] Merge cache strategy
- [ ] Run full verification
- [ ] Perform change-review

## Parallelization Boundaries
- What subagents can do independently:
- What must be decided by the lead agent:
- What must not be modified in parallel:

## Stop Conditions
- 
```

## 7. Phase 0 / 1 / 2 Playbook

```markdown
# Phase Playbook

## Phase 0: Lay the Foundation
Goal: make the shared constraints clear before parallelization.

Outputs:
- Source-of-truth list
- Architectural invariants
- Data contracts
- State matrix
- Common components / utilities
- Acceptance criteria
- Subtask boundaries

Pass criteria:
- Subsequent subtasks do not need to each invent their own rules.

## Phase 1: Execute in Batches
Goal: advance the implementation within clear boundaries.

Requirements:
- Each subtask has an input, an output, and an acceptance criterion.
- Subagents cannot modify shared contracts without returning to the lead agent.
- Status is recorded after each batch completes.

Pass criteria:
- Subtasks can be verified independently.

## Phase 2: Integration & Acceptance
Goal: prove the whole is consistent.

Requirements:
- Verify shared contracts after merging.
- Check cross-module state flow.
- Check visuals, interfaces, exceptions, cache.
- Perform change-review.

Pass criteria:
- Not every piece is complete, but the whole is deliverable.
```

## 8. Handoff Template

```markdown
# Handoff: Task Name

## User Objective
- Original request:
- Current interpretation:

## Current Status
- Current phase:
- Completed:
- Not completed:
- Normal stopping point:

## Decisions Made
- 

## Source of Truth
- 

## Important Context
- 

## To-Do
- 

## Do Not Repeat
- 

## Risks and Checkpoints
- 

## If Continuing
1. 
2. 
3. 

## If Tools Are Unavailable
- Fallback approach:
- What cannot be done:
```

## 9. Cron Job Design Template

```markdown
# Cron Job Design: Task Name

## Trigger Strategy
- Time:
- Frequency:
- Timezone:
- One-off / recurring:

## Task Objective
- 

## Idempotency Design
- How to determine completion:
- How to avoid duplicate execution:
- What to do on repeated triggers:

## Lock
- Lock file / status field:
- Release on timeout:
- Release on exception:

## Input
- Config:
- Queue:
- Handoff:
- External API:

## Output
- Status write-back:
- Logs:
- Notifications:
- Documentation:

## Stop Conditions
- 

## Human Checkpoints
- 

## Failure Handling
- Retry:
- Degrade:
- Notify:
- Reset:

## Safety Boundaries
- Push prohibited:
- Merge prohibited:
- Deletion prohibited:
- Other:
```

## 10. Watch Design Template

~~~markdown
# Watch Design: Task Name

## Monitoring Target
- Source:
- Condition:
- Frequency:

## Watch Responsibilities
- Observe only:
- Output only:
- Exit after detecting an event:

## Deduplication
- Marker:
- Processed record:
- Handling of duplicate messages:

## Output Format
```text
reason:
event:
source:
next_step:
```

## What It Does Not Do
- Does not change code
- Does not commit
- Does not make business decisions
- Does not hold a lock long-term

## Exception Handling
- API failure:
- Timeout:
- Permission error:
~~~

## 11. Worker Design Template

~~~markdown
# Worker Design: Task Name

## Worker Boundaries
- Tasks it can handle:
- Tasks it cannot handle:

## State Machine
```text
idle
  → claimed
  → diagnosing
  → waiting_human
  → fixing
  → reviewing
  → committed
  → notified
  → idle
```

## Lock
- Acquire:
- Release:
- Timeout:

## Task Occupancy
- How to claim:
- How to prevent duplication:
- How to write status back:

## Human Checkpoints
- Trigger condition:
- Message format:
- Timeout policy:

## Git Write Mode
- Mode A: change only, no commit
- Mode B: commit locally, no push
- Mode C: push / PR / merge, requires human authorization

## Verification
- Self-test:
- change-review:
- Diff before commit:

## Failure Handling
- Failure state:
- Notification:
- Reset:
- Trace left behind:
~~~

## 12. Loop / Unattended Admission Checklist

```markdown
# Loop Admission Checklist

## Is the Task Fit for Unattended Operation
- [ ] Objective is machine-judgeable
- [ ] Input source is stable
- [ ] State can be persisted
- [ ] Recoverable after interruption
- [ ] Repeated execution is idempotent
- [ ] Failures can be notified
- [ ] Dangerous actions have checkpoints
- [ ] Does not depend on transient verbal context

## Oracle
- [ ] Schema validation
- [ ] Tests
- [ ] Screenshot diff
- [ ] Real request samples
- [ ] State matrix
- [ ] Log assertions
- [ ] Device / browser check

## Reason for Non-Admission
- 

## Restrictions After Admission
- 
```

## 13. Human Checkpoint Message Template

```markdown
# Human Checkpoint

## Current Task
- 

## Current Assessment
- 

## Needs Your Confirmation
Please choose:
1. 
2. 
3. 

## Default Behavior
- If not confirmed, I will stop at the current state and not proceed with irreversible actions.

## Risk
- 

## Evidence of Completion
- 
```

## 14. Git Write Mode Template

```markdown
# Git Write Mode

## Current Mode
Mode A / Mode B / Mode C

## Mode A: Change Only, No Commit
Suitable for:
- Exploration
- User wants to see the diff first
- Higher risk

Restrictions:
- No commit
- No push

## Mode B: Commit Locally, No Push
Suitable for:
- Automated fix-and-close loops
- Need for stable persistence
- Still requires human merge

Restrictions:
- Must review the diff before committing
- No push
- No merge

## Mode C: push / PR / merge
Suitable for:
- Explicit user authorization
- CI and review rules fully in place

Restrictions:
- Must have human authorization
- Must pass required verification
```

## 15. Oracle / Self-Verification Checklist

```markdown
# Oracle Checklist: Task Name

## Functional Oracle
- [ ] Normal path
- [ ] Empty state
- [ ] Error state
- [ ] Loading state
- [ ] Permission variance
- [ ] Boundary values

## Interface Oracle
- [ ] Schema
- [ ] Current response sample
- [ ] Field mapping
- [ ] Error codes
- [ ] Timeout / retry

## UI Oracle
- [ ] Comparison against design mockup
- [ ] Comparison against source page
- [ ] Multiple viewports
- [ ] Screenshot diff
- [ ] Font / spacing / icons

## Runtime Oracle
- [ ] Build
- [ ] Unit tests
- [ ] E2E
- [ ] Console errors
- [ ] Real device / browser

## Automation Oracle
- [ ] Lock
- [ ] Idempotency
- [ ] Status write-back
- [ ] Failure notification
- [ ] Reset
```

## 16. Lesson Backflow Template

```markdown
# Lesson Backflow: Lesson Title

## Source
- 

## What Happened
- 

## Wrong Approach
- 

## Correct Approach
- 

## Abstracted Rule
> 

## Applicable Boundary
- 

## Non-Applicable Boundary
- 

## Where It Should Flow Back To
- [ ] Case Library
- [ ] Template Library
- [ ] AGENTS.md
- [ ] review checklist
- [ ] Technical Debt Ledger
- [ ] Automation script

## Follow-up Actions
- 
```

## 17. Review History Template

```markdown
# Review History

## {date} | {commit subject or uncommitted}
- [{CATEGORY}] {description} — severity: {blocking|important|minor} — status: {resolved|accepted|wontfix}

## Pattern Notes
- recurring pattern:
- first seen:
- repeated count:
- suggested upgrade:
```

## 18. Plan Review Full Category Template

> Implementation approach: same as Template 2 — once packaged as a skill, the skill becomes the runtime standard.

```markdown
# Plan Review — {date}

## Reviewed Source
- plan file / conversation:
- version / date:

## Verdict
APPROVE / APPROVE WITH CHANGES / RETHINK

## Summary Table
| Category | Count |
|---|---:|
| DESIGN | 0 |
| EDGE CASE | 0 |
| INCOMPLETE | 0 |
| CONVENTION | 0 |
| RISK | 0 |
| IMPACT | 0 |
| MAINTENANCE | 0 |

## Issues
- **[PR-01]** [CATEGORY] {description}
  - Section:
  - Evidence:
  - Concrete suggestion:
  - Severity: blocking / important / minor

## Must-fix Before Execution
- 

> Handling must-fix items = **revise the plan document directly** + incremental re-review until APPROVE. This report is not persisted and is not tracked across phases — a fixed plan is itself the closure.
```

## 19. Change Review Full Category Template

> Implementation approach: same as Template 2 — once packaged as a skill, the skill becomes the runtime standard.

```markdown
# Change Review — {date}

## Changed Files
- 

## Verdict
APPROVE / APPROVE WITH CHANGES / REQUEST CHANGES

## Summary Table
| Category | Count |
|---|---:|
| PLAN GAP | 0 |
| DESIGN | 0 |
| ROBUSTNESS | 0 |
| PERFORMANCE | 0 |
| CONVENTION | 0 |
| QUALITY | 0 |
| LINTER | 0 |
| RECURRING | 0 |

## Issues
- **[CR-01]** [CATEGORY] {description}
  - Location: {file:line}
  - Evidence:
  - Concrete fix:
  - Severity: blocking / important / minor
  - Status: OPEN / ACCEPTED / WONTFIX (the latter two require human adjudication, with a stated reason)

## Verification
- Commands:
- Tests:
- Lint:
- Screenshots:
- Device / browser:
- Not covered:

## Follow-up Debt
- 

## Convention Proposals
- 
```

## 20. Convention Proposal Template

```markdown
# Convention Proposal: {rule name}

## Source
- Review issue:
- Dates observed:
- Repeated count:

## Recurring Pattern
- 

## Risk
- 

## Proposed Rule
> 

## Scope
- Applies to:
- Does not apply to:

## Landing Location
- [ ] Global AGENTS / CLAUDE
- [ ] Project AGENTS / CLAUDE
- [ ] specs / architecture docs
- [ ] openspec / business spec
- [ ] plan-review checklist
- [ ] change-review checklist
- [ ] skill / workflow
- [ ] script / lint / CI

## Automation Potential
- Fully automatable:
- Partially automatable:
- Must remain human review:

## Migration
- Existing violations:
- Cleanup plan:
- Backward compatibility:
```

## 21. False Green / Sensor Calibration Checklist

```markdown
# False Green / Sensor Calibration

## Gate Execution
- [ ] Scan path exists
- [ ] Number of objects checked > 0
- [ ] Number of tests > 0
- [ ] Assertion count or key assertions confirmed
- [ ] Non-zero exit on failure
- [ ] Fails or warns on an empty run
- [ ] Deliberately introduced violations get caught

## Browser / UI Sensor
- [ ] Final acceptance is not via file://
- [ ] Cache-busted or cache cleared
- [ ] Real target viewport
- [ ] Screenshots are from the current build
- [ ] Console errors checked
- [ ] Key interactions tested live

## Device Sensor
- [ ] Device is online
- [ ] Package version / build number is correct
- [ ] Account and data state are correct
- [ ] Screenshots are from the current package
- [ ] Logs are from the current session

## API / Data Sensor
- [ ] Requests hit the target environment
- [ ] Fixtures are aligned with the current schema
- [ ] Error codes and exception paths are covered
- [ ] Mocks are a state matrix, not just for making the page look good

## Independent Verification
- [ ] There is independent review beyond self-check
- [ ] Key conclusions have a second source
- [ ] Uncertain items are parked or logged as technical debt
```

## 22. Loop Workflow Convergence Checklist Template

```markdown
# Loop Workflow Convergence Checklist

## Fixed Target
- [ ] spec / openspec / ux / live implementation is explicit
- [ ] "Done" does not depend on the reviewer having no objections
- [ ] Source-of-truth conflict adjudication order is explicit

## Two Metrics
- [ ] Static gate: lint / grep / schema / invariant
- [ ] Dynamic self-check: browser / device / screenshot / interaction

## Learning Ratchet
- [ ] Review findings are recorded
- [ ] Recurring patterns are identified
- [ ] Three recurrences escalate to a convention proposal
- [ ] Automatable items go into script / CI

## Conservative Unattended Mode
- [ ] No irreversible actions when unattended
- [ ] Ambiguous items are parked
- [ ] Gaps are logged as technical debt
- [ ] Handoff states the wake-up re-verification checklist

## Trusted Sensors
- [ ] Sensors are calibrated
- [ ] False-green defense has been executed
- [ ] Independent verification is paired
```

## 23. Checkpoint Protocol Template

```markdown
# Checkpoint Protocol: {Project / Workflow Name}

## Trigger Points
- After producing a plan (mandatory stop)
- After completing a code / content change (mandatory stop)

## Options (explicitly offered every time, never auto-advance)
1. review (recommended)
2. Skip, go straight to the next step
3. Discuss

## Verdict Flow
- APPROVE → wait for confirmation before the next step
- Has must-fix → fix → incremental re-review (checking only the prior round's issues)
- Fundamental problem (RETHINK / REQUEST CHANGES) → must go through a full re-review after fixing, no skipping

## Unattended Branch
- The only automatic branch: persisted verdict == APPROVE → continue automatically
- Any other verdict always stops and waits for a human (no "the issue is minor, can continue")
- The verdict is honored only as persisted physical evidence; oral claims do not count — each automatic pass leaves one line of audit record
- Create the unattended marker before entering, delete it on exit (the hard gate uses this to determine its scope of effect)
```

## 24. Diagnosis Report Template

```markdown
# Diagnosis: {bug ID or short title}

## Symptom / Expectation
- Symptom:
- Expectation:

## Six-Dimension Reconnaissance Output
- Anchor point (file:line):
- Root-cause layer:
- Blast radius:
- Lateral siblings:
- Historical intent (blame/log):

## Root Cause
- Conclusion (precise to file:line):
- Evidence back-references:
- Symptom → root-cause chain:
- Unconfirmed link: [Hypothesis] …

## Candidate Solutions (multiple only if there is a genuine fork)
### Option 1: {one-line name} [Recommended?]
- Approach:
- Change scope (each item backed by evidence):
- Trade-offs:
- Risk:

## Handing Back the Decision
1. Adopt Option N → proceed to the plan process
2. Provide more information and re-diagnose
3. Continue digging into dimension X
```

## 25. Parity Reconciliation Checklist Template

```markdown
# Parity Audit: {page / module name}

## Reference Source
- Reference implementation (frozen version / commit):
- Authoritative source per dimension (contract / types / visual / behavior):

## Discrepancy List (audit phase only records, does not fix)
| # | Discrepancy Description | Reference Source Evidence | Severity | Handling | Status |
|---|---|---|---|---|---|
| 1 | | file:line / screenshot | blocking/important/minor | fix this batch / fix in batches / log as debt / deliberately not done (with reason) | open/done |

## Close-out Progress
- Total discrepancies:
- Resolved:
- Converted to technical debt:
- Deliberately not done (all with stated reasons):

## Close-out Check (perform once the list reaches zero)
- [ ] Every reference-source citation has been removed or marked historical
- [ ] The migration-period required-reading document set has been trimmed
- [ ] Migration-period-specific checklist items have been evaluated for retention or removal
- [ ] The new implementation has become the sole source of truth
```

## 26. Fact-Base Triage Entry Point (README) Template

```markdown
# {System Name} Fact-Base Entry Point

> Applies to: {repository / branch scope} · Last verified: YYYY-MM-DD

## Given a Bug, How to Locate It (read this first — don't read everything before acting)

First triage cut: does the issue also occur on a different page / module?
- Yes → Cross-cutting: the root cause is in some shared mechanism layer → follow Axis 1's symptom table
- Only here → Single-point: first localize to the component → follow Axis 2's anchor-based localization

### Axis 1 · Cross-Cutting → Symptom → Mechanism Table
| Symptom | Root-cause layer | Specific location (file:line, must be verified with grep) | Scope (single global spot / per-page pattern) |
|---|---|---|---|
| | | | |

### Axis 2 · Single-Point → By Anchor, Cheapest First
1. On-screen text (button label / prompt text) → two-hop grep (get the key from the language pack → locate the component by key; without i18n, go one hop directly) — attach one real, verified-working example
2. One operation / one flow / cross-page interaction → user-journeys
3. Only a business term → domain-glossary
4. Known route / page path → code-map
5. None of the above hit → fall back to a repo-wide grep / trace along the journey dependency chain

> ⚠ Mark unverified paths as "unconfirmed" and provide a credible alternative anchor (e.g., a component file path).

## What Each File Is For (consult as needed, no need to read everything upfront)
- architecture — expanded mechanism details (the backing detail for Axis 1's symptom table)
- code-map — master index of route ↔ component ↔ API + naming pitfalls
- domain-glossary — business terms → fields / enums / modules
- user-journeys — named business closed loops + per-step operation → method name

## Features Confirmed Not to Exist After Investigation
- {conclusion + investigation basis (keywords searched / directories reviewed) + verification date}
```
