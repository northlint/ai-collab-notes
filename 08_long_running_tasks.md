# 08 Long-Running Tasks, Loop, Cron & Unattended Operation

## Core Definition

When an AI task spans long durations, multiple steps, multiple external systems, or even requires automatic continuation, an ordinary "complete within a single conversation" workflow is not enough.

At this point a dedicated execution orchestration system is needed:

- cron: scheduled trigger
- watch: lightweight watcher
- worker: serial executor
- loop: long-running autonomous cycle
- headless: an external, non-interactive loop that survives usage-limit windows
- queue: task queue
- handoff: cross-session handover
- checkpoint: manual checkpoint
- oracle: self-verifying oracle

What this section addresses is:

> How AI can, during long-running tasks, avoid losing power, avoid running wild, avoid guessing to fill gaps, and avoid overstepping authority.

## 1. Why Long-Running Tasks Are Different

Long-running tasks have several characteristics:

- The task may exceed the duration of a single session.
- The task needs to wait for external input.
- The task needs to continue across points in time.
- The task may depend on devices, browsers, Figma, real hardware, or test environments.
- Blocking may occur mid-task.
- The completion criteria cannot be judged by a single command.

Without execution orchestration, AI is prone to:

- Being unable to pick up work after an interruption
- Redoing parts that are already complete
- Stalling when a tool is missing
- Losing context while waiting for human input
- Guessing its way forward when unattended
- Multiple tasks running simultaneously causing branch and state conflicts

## 2. Cron: Scheduled Triggers and Fallback

### 2.1 What Cron Is Suited For

cron is suited for:

- Starting the next phase on a schedule
- Fallback re-checks
- Periodic inspection
- Pulling tasks at a fixed frequency
- Continuation when the session may have dropped

Typical scenario:

```text
21:10 start B2
If the prior phase is not complete, close it out first
02:10 run another fallback check to see if everything is complete
If already stopped at a checkpoint, do not re-execute
```

### 2.2 What Cron Is Not Suited For

cron is not suited for:

- High-frequency real-time message response
- Interactions requiring immediate handling
- Tasks strongly dependent on the current session's context
- Multiple tasks concurrently writing to the same repository

Problems with cron:

- Coarse granularity
- Prone to duplicate triggering
- Weak context
- Must have idempotency and locking
- Must know whether "the current state is already complete"

### 2.3 Cron Continuation Must Have a Handoff

Scheduled continuation must be accompanied by a handoff document.

A handoff must include at minimum:

- The user's goal, in their own words
- Current phase
- Checklist of completed items
- Checklist of incomplete items
- Source of Truth
- Workflow
- Decisions already made, which must not be reversed
- Normal stopping point
- How to degrade if a tool is missing
- Which states are "as expected, do not redo"

A cron without a handoff is just letting a new session open the task blind.

### 2.4 When the Number of Rounds Is Unknown: A Self-Bootstrapping One-Shot Trigger Chain

For tasks that continue across windows, it is often impossible to say in advance "how many rounds it will take." Hardcoding N triggers in advance is an anti-pattern: if N is too small, the task doesn't finish and no one notices (a silent failure); if N is too large, it idles and wastes resources.

The convergent design is to make the trigger chain **self-bootstrapping**:

```text
1st trigger (manually created, one-shot)
  ↓ at execution time, first make a completion determination against the durable spec
  ├─ Complete → close out with a summary, end, do not attach a new trigger
  └─ Incomplete → run one increment of work → determine again
       ├─ Complete → close out, end
       └─ Still incomplete → create the next one-shot trigger (same prompt as this one, self-replicating)
```

Run as many rounds as needed, and stop automatically once done. Two preconditions apply:

- The completion determination must be **concrete enough to be scripted** (N non-empty files exist / a given command outputs 0 / all tests are green); a trigger chain with a vague goal will drift off course when unattended;
- If the trigger chain is **in-session memory state** (it vanishes silently, without error, the moment the process exits), this fragility assumption must be repeated back to the user for confirmation before starting — do not "assume it will work."

## 3. Watch: A Lightweight Watcher for the Current-Window Mode

### 3.1 What Watch Is

watch is a lightweight background process.

It does not execute the full task; it only observes external events.

Upon detecting an event:

```text
Print an event summary
Exit the process
Wake the main session
The main session continues handling it
```

### 3.2 What Watch Is Suited For

watch is suited for:

- Someone is watching the current window
- The main session's context needs to be preserved
- External events are infrequent
- Execution requires normal permissions and context
- Not suited for nesting a headless agent

Typical scenario:

```text
Check every 10 seconds:
  - Is there a new pending bug
  - Has anyone in the group @-mentioned the designated bot
If either is found:
  - Output reason / bug / message
  - process.exit(0)
  - The main session takes over
```

### 3.3 Watch Design Points

- Only observe, do not modify code.
- Only send signals, do not make complex decisions.
- Use a marker to de-duplicate.
- On occasional external API failure, retry next round.
- Exit upon detecting an event, rather than handling it itself.
- watch stops while the main session is processing, to avoid concurrency.

### 3.4 Watch vs Cron

| Dimension | Watch | Cron |
|---|---|---|
| Trigger mode | Continuous observation, exits on detection | Scheduled start |
| Context | Preserves the current session | New session or new process with weak context |
| Suited for | Current-window mode, waiting for a reply, lightweight queue | Scheduled fallback, periodic tasks |
| Risk | Becomes ineffective once the session closes | Requires idempotency and locking |

### 3.5 Headless: When Neither Cron Nor Watch Can Escape a Modal Deadlock

There is a failure mode that neither cron nor watch can solve, because it is structural rather than a scheduling problem: when an interactive session hits its usage-limit window mid-task, it does not go idle — it gets stuck behind a **modal confirmation** (a tool-permission prompt, a login/limit dialog). A cron trigger fired against that session does not resume it; nothing is listening. And once the usage window resets, the session does not self-heal — it is still sitting behind the same modal, waiting for a human who is not there.

This means an in-session cron/watch wrapped around a task that might run long enough to cross a usage-limit window isn't "cron done wrong" — it's the wrong tool for this failure mode. The fix is structural, not tunable: move the loop entirely out of the interactive session into an **external, non-interactive process** — an OS-level shell loop repeatedly invoking a headless CLI call — where there is simply no UI layer for a modal to occupy. On hitting the limit, a headless call exits with an error; the shell loop sleeps and retries; once the window resets, the next call succeeds and picks up from the last commit.

Call this mode **headless**. It differs from cron/watch by axis, not by degree:

| | Cron / Watch (in-session) | Headless (external loop) |
|---|---|---|
| Where it runs | Inside an interactive session | An external process with no interactive UI |
| Behavior on hitting a usage limit | Stuck behind a modal, non-idle, unrecoverable without a human | Exits with an error; the external loop sleeps and retries |
| What it takes to resume | A human clears the modal | Nothing — it self-heals once the window resets |
| Suited for | Tasks that stay within one usage window, or where a human is present | Tasks that may cross one or more usage-limit windows, fully unattended |

If a task might run long enough to cross a usage-limit window and no human will be present to clear a stuck modal, that alone is the deciding factor for choosing headless over cron/watch — not task complexity, not duration by itself. (On tools that carry their own hidden human gesture and can deadlock a headless process the same way, see Case Library #32.)

## 4. Worker: A Serial, Complete Executor

### 4.1 What Worker Is

worker is an executor capable of handling one complete task chain.

For example, auto-fixing a bug:

```text
Pull a pending bug
  → claim the task
  → diagnose
  → post to the group
  → wait for human input
  → pull the fix branch
  → fix
  → change-review
  → commit
  → notify
  → reset
```

### 4.2 Key Design Points for Worker

worker must have:

- A serial lock
- Task claiming
- State write-back
- Timeout handling
- Error notification
- Branch isolation
- A safety boundary of not pushing / not merging
- A manual checkpoint
- Reset after failure
- Synchronous sub-task dispatch whenever the worker itself runs as a single throwaway process: a sub-agent dispatched to the background is killed the moment that process exits, and there is no cross-round mechanism to wake it or recover its partial output (Case Library #31)

### 4.3 Worker's Risks

worker carries higher risk than watch, because it actually executes the task.

Risks include:

- The nested agent having excessive permissions
- Erroneous edits due to lack of context
- Holding the lock too long while waiting for human input
- Unreviewed changes from formatting hooks before commit
- External API timeouts causing a half-finished process
- The branch not being reset

So worker, in its early stage, should:

- Handle only one task
- Not push
- Not merge into the trunk
- Get human review after commit
- Record state throughout

## 5. Loop: A Long-Running Autonomous Cycle

The object of Loop is not a bare task, but a workflow.

If AI is simply told to:

```text
do the task → review → fix → review → fix again
```

it easily falls into an endless debt of review.

Because review is a gradient with no natural zero point: style, boundaries, abstraction, naming, and maintainability can always be picked at further.

For a loop to actually converge, "done" must be changed from "the reviewer has nothing left to say" to:

> aligned to a fixed target + passes the mechanical gate + passes the dynamic self-check + review renders a verdict only against the fixed target.

### 5.1 The Difference Between Loop and Worker

worker handles one well-defined task.

loop is a long-running autonomous system.

loop needs to handle:

- Long-running heartbeat
- Blockage detection
- Task reordering
- Device watchdog
- Consecutive-empty-run counting
- Review queue
- Partial auto-ship
- Parking ambiguous items

### 5.2 Loop's Typical Structure

```text
loop
  → read the task queue / state
  → select the next executable task
  → execute one minimal pipeline
  → run the mechanical gate
  → run oracle verification
  → ship if confident
  → park to the review queue if uncertain
  → update state
  → next round
```

### 5.3 Loop's Termination Conditions

loop must not run indefinitely.

Explicit termination conditions are needed, for example:

- N consecutive rounds with no new tasks
- All tasks are complete or parked
- A critical dependency is unavailable
- The device is unrecoverable
- The manual review queue exceeds a threshold
- A high-risk operation is encountered

Example:

```text
3 consecutive rounds detect no new logic requiring handling
  → treat as converged
  → stop the loop
  → send a notification reporting the result
```

### 5.4 Loop's Safety Valves

loop must have safety valves:

- park-don't-guess: when uncertain, park, don't guess.
- Manual review queue: ambiguous items enter the queue.
- Device watchdog: restart or reschedule when a device hangs.
- Stop on gate failure: do not keep piling on changes when build/test fails.
- Small task granularity: each round advances only one minimal closed loop.

### 5.5 The Five Requirements for Closed-Loop Convergence

For a loop to converge, at least five things are required.

| Requirement | Purpose | Example |
|---|---|---|
| Fixed-target oracle | Gives "done" an external definition | spec, openspec, ux, a live implementation, a state matrix |
| Two independent metrics | Simultaneously captures static shape and dynamic behavior | lint / grep / schema + Playwright / adb / real device |
| Learning ratchet | Each round either fixes a defect or locks down a class of recurring problem | lessons, AGENTS, skill, CI |
| Conservative action when unattended | Do not take irreversible or highly ambiguous action when no one is watching | park, log technical debt, wait for a human |
| Trusted sensing + independent verification | Prevents self-confirmation and false verification | calibrated browser/device + adversarial review |

Without a fixed target, loop chases a moving goalpost.

Without two metrics, loop only proves that "the code shape is correct" or "it appears to run."

Without a learning ratchet, loop repeats the same mistakes every round.

Without conservative action, loop oversteps its authority when unattended.

Without trusted sensing, loop stamps its own approval using the wrong screenshot, a stale cache, or an empty-run gate.

### 5.6 Static Gates and Dynamic Self-Checks Must Be Paired

Static gates answer:

- Whether the code shape is compliant
- Whether architectural boundaries have been violated
- Whether disallowed patterns have appeared
- Whether types, lint, and tests pass

Dynamic self-checks answer:

- Whether runtime behavior is correct
- Whether the page actually renders
- Whether real-device interaction works
- Whether async and error states meet expectations

Neither can substitute for the other.

Static checks all-green does not mean it runs correctly.

Dynamic screenshots looking normal does not mean architectural boundaries weren't broken.

The timing of the dynamic self-check matters equally: **verify as you go, don't leave it for after the fact**. For changes with a runnable interface, the real page should be opened and the key path walked immediately during implementation — verifying all at once afterward doubles the cost of fixing any problem found. And every checkpoint must report one line:

```text
Verified: <path actually run>
Not covered: <path not run>
```

This line turns "verification coverage" into evidence visible to reviewers: reviewers need not re-doubt paths already verified, and can spot blind spots at a glance. When verification cannot be run, honestly mark it "not run," and do not default to treating it as passed.

### 5.7 False-Green Defense

In an unattended loop, false-green is more dangerous than a red light.

False-green refers to the system showing a pass, while the target was not actually verified.

Typical false-greens:

- The gate script's path is wrong, the scanned directory doesn't exist, yet it still reports SUCCESS.
- A grep filter was missed in an update, and the rule runs empty.
- The test command executed, but the test count was 0.
- The browser opened a `file://` page or a stale cached page.
- The Playwright viewport was not the target width, yet it was accepted as the target width.
- The device ran an old build, and the screenshot came from old code.
- UI verification asserted only on the DOM text: copy and amounts were all correct item by item, but the layout was broken (content squeezed and wrapped, icons stretched out of shape) — the text assertions all passed regardless (Case Library #29).

Defense methods:

- The execution count must be checked to be greater than 0.
- Deliberately introduce a known violation to confirm the gate can catch it.
- Prohibit using `file://` as the final dynamic acceptance check.
- Use cache-busting or clear the cache.
- Record the real viewport, device, package version, and build number.
- Perform independent review of critical oracles.
- **The assertion dimensions must cover the dimensions in which the bug could appear**: text assertions only cover the content dimension; visual changes must be closed out by actually looking at a screenshot, adding geometric assertions where necessary (element coordinates to judge same-row alignment, aspect ratio to judge deformation).

### 5.8 Sensor Calibration

A sensor refers to any tool used to judge the result:

- Browser screenshot
- Real-device screenshot
- Console log
- Network request record
- Test report
- lint output
- Build artifact
- API fixture

A sensor must be calibrated before use.

Calibration must ask:

- Is what it sees the current code?
- Is what it sees the target environment?
- Does it have a cache?
- Are its resolution, device, account, and data correct?
- Will its failures get swallowed?
- Will it still report success when run against nothing?

In one sentence:

> An uncalibrated verification is more dangerous than no verification at all.

### 5.9 Retry, Stall, and Fatal Are Three Different Things — and Misclassifying Between Them Must Not Be Safety-Critical

An unattended loop needs to tell apart three situations that can all look like "this round produced nothing":

- **Retry-worthy** (rate limit, transient overload, a timeout/hang): wait and try again; the task is still healthy.
- **Stalled** (the model completed the round, exited cleanly, but produced zero commits): something is wrong with the task or the model's understanding of it; escalate.
- **Fatal** (auth expired, billing/credit exhausted, a misconfigured model): retrying is pointless no matter how long you wait.

Conflating these produces two distinct failure modes:

1. **Counting a retry-worthy round as a stall.** If "no commit this round" alone drives the stall counter, a genuine rate-limit stretch — which can run for the length of the entire usage window — will trip the stall threshold and shut the loop down *before the window resets*, defeating the whole point of running unattended. The fix: the fast, round-based stall counter must count **only confirmed NOOPs** (clean exit, zero commits, not blocked); retries, timeouts, and errors are excluded from it entirely.
2. **Trusting retry-classification to be safety-critical.** Rate-limit detection is inherently probabilistic — error text and exit codes vary across versions and are never fully reliable. If the stall counter's correctness depended on always classifying rate-limit rounds correctly, a single misclassification would become a safety failure. The fix is a second, independent detector: a **wall-clock watchdog** — time-since-last-commit, with its threshold deliberately set *above* the length of one usage window (e.g. 6h against a 5h window). It doesn't care why nothing landed; it only asks how long it's actually been. A genuine rate-limit stretch always resolves within one window and resets the clock; only a truly stuck loop (a misclassified retry looping forever, an unsplittable giant unit, a broken environment) burns through the watchdog's longer threshold. This makes the *accuracy* of retry classification a quality-of-logging concern rather than a safety one.

When classifying "is this retry-worthy," prefer signals in this reliability order: a structured error field (e.g. an explicit rate-limit status code) over text matching over the process exit code (exit codes for the same failure can differ across versions and even across runs). And give fatal errors — the kind no amount of waiting fixes — their own fast-stop lane: detect them and stop immediately with a notification, rather than let them idle silently until the wall-clock watchdog finally catches them hours later.

## 6. Unattended Operation

### 6.1 Unattended Does Not Mean No One Is Responsible

Unattended does not mean "letting AI run freely."

It is:

> Under strong constraints, strong verification, rollback capability, and a human review queue, letting AI autonomously advance deterministic tasks.

### 6.2 Conditions for Unattended Operation to Hold

Unattended operation must have three categories of things in place.

#### 1. A Frozen Source of Truth

The task goal must not be a moving target.

For example:

- Business capability is already frozen
- The H5 is already feature-complete
- The Spec is already stable
- The state matrix is already clear

If the Source of Truth is still changing, unattended operation will chase a moving target.

#### 2. A Right/Wrong Oracle

AI cannot be the sole judge of its own completion.

An external oracle is needed:

- A live reference implementation
- A real backend
- A mock state matrix
- Screenshot comparison
- Real-device behavior
- A test environment
- An end-to-end acceptance script

Without an oracle, unattended output can only be fully reviewed by a human.

#### 3. Mechanical Gates

Automatic blocking must be in place:

- build
- lint
- test
- typecheck
- invariant check
- grep
- screenshot
- console
- API fixture

Mechanical gates must also prove they actually executed — the complete checklist for self-proving execution (execution count > 0, recording the real environment, non-zero exit on failure, treating empty runs as failure) is in §5.7 False-Green Defense; enforcement ownership is in "Toolchain Governance" §4.

#### 4. Manual Checkpoints and Conservative Action

Unattended operation is not a way to bypass human judgment.

The following matters must be handled conservatively:

- Business rule conflicts
- Source-of-Truth conflicts
- Deleting or overwriting data
- Modifying a public contract
- push / merge / release
- Visual differences that cannot be judged automatically
- Divergent proposals requiring a product or architecture decision

Default actions when unattended:

- Do not take irreversible action.
- Do not reverse an already-recorded decision.
- Do not expand the task's scope.
- Park ambiguous items to the review queue.
- Log gaps as technical debt.
- List a post-wake re-verification checklist in the handoff.

### 6.3 What Tasks Unattended Operation Is Suited For

Suited for:

- Large volumes of repetitive migration
- Cross-platform rewrites of already-frozen capabilities
- UI completion where the state matrix is clear
- DTO / schema / contract mirroring
- Low-risk portions of a well-defined bug-fix chain

Not suited for:

- Product decisions
- Architectural direction choices
- Unclear contracts
- Visuals without a source
- High-risk write operations
- Interactions requiring substantial subjective judgment

### 6.4 Readiness Gate: Every Pre-Launch Risk Needs One of Three Destinations

Unattended does not mean "no one resolves ambiguity" — it means ambiguity has to be resolved *before* launch, because there is no one to ask once it's running. So every task queued for unattended execution must pass a readiness gate distinct from a plan review: a plan review asks "is this plan good, is it feasible"; a readiness gate asks only "is this unambiguous enough to run with no one watching."

The gate works by walking every task and checking that every source of pre-launch risk (an unclear requirement, a vague description, insufficient data, fuzzy acceptance criteria, an open decision, wrong-sized granularity) has landed in exactly one of three legitimate destinations:

1. **Resolved into the plan** — turned into something concrete, traceable, and checkable. Default choice.
2. **Converted into a machine-checkable BLOCKED trigger** — what can't be resolved ahead of time becomes a condition the loop can detect and stop on (e.g. "visual-diff hotspot exceeds X% → BLOCKED", "contract has no basis → log the gap and mock forward, or BLOCKED").
3. **Escalated to a pre-launch human decision** — a genuinely open call, made by a human before launch, never left for the unattended agent to guess.

**Any task with a risk that hasn't landed in one of these three = gate fail, do not launch.** The report must be precise about which task, which risk category, and which destination is missing — e.g. "T-3's acceptance criterion stops at the action 'reconcile side by side,' with no item-by-item judgment and no BLOCKED threshold — both ① and ② are missing." Loosening the bar just to get moving defeats the point; this is exactly where unattended scenarios bury their landmines.

Even after the gate passes in full, run one round manually (a `--max-rounds 1`-style dry run) to confirm the loop actually advances the first task and notifications actually arrive, before releasing it to run overnight unsupervised.

Two mechanical corollaries are worth calling out explicitly, because both guard against a destructive step that an unattended loop typically runs every round:

- **A dirty working tree must refuse to launch.** If each round opens by discarding the previous round's draft (a hard reset plus removing untracked files) to guarantee a known starting state, launching against an already-dirty tree means that first reset permanently destroys whatever uncommitted work was sitting there. Refuse to start unless the tree is clean, or the operator explicitly overrides it having acknowledged the loss.
- **Volatile cross-round state must live outside that reset's blast radius.** A per-round reset is scoped to the repository; state that has to survive across rounds anyway — a blocked flag, a stall counter, the last-seen commit — must live somewhere the reset can't reach. Keeping it inside the repo means the very safety mechanism that protects durable state (reset-and-redo) silently wipes the volatile state too, and the loop redoes the same blocked batch forever.

## 7. Event Subscription, Polling, and Scheduling

### 7.1 Three Trigger Modes

| Mode | Suited for | Caveats |
|---|---|---|
| Event subscription | Real-time messages, webhooks, system events | Requires permissions and stable services |
| Polling | CLI is readable but has no subscription, rapid MVP validation | Must handle timeouts, de-duplication, frequency |
| Scheduled cron | Periodic inspection, continuation, fallback | Must handle idempotency, locking, state determination |

### 7.2 Selection Principles

- For real-time events that can be reliably subscribed to, use event subscription.
- When permission cost is high or in the MVP stage, use polling.
- For a clear point in time or a fallback check, use cron.
- When someone is watching the current session, use watch.
- To execute fully automatically end-to-end, use worker.
- To operate continuously and autonomously, use loop.

## 8. Manual Checkpoints

### 8.1 What Must Have a Checkpoint

Must have a manual checkpoint:

- Merging into a production branch
- Pushing to a shared remote
- Deleting a resource
- Changing an architectural invariant
- Accepting high-risk technical debt
- Adjudicating a contract conflict
- Product experience trade-offs
- Conclusions that cannot be verified by an oracle

### 8.2 How Checkpoints Should Be Designed

A checkpoint cannot be a verbal "go take a look."

It must provide:

- diff
- Branch
- commit
- Verification results
- Screenshot
- Risk explanation
- Available actions
- An explicit approval method

For example:

```text
The fix has been committed to a local branch, not pushed.
Please have a human review it and decide:
1. Proceed to push
2. Revert the change
3. Abandon this branch
```

### 8.3 Checkpoint Protocol: Turning the Checkpoint from a Habit into a Protocol

Even with a human present, checkpoints still need to be turned into a protocol, or they get eroded by "just going ahead and continuing." A field-tested checkpoint protocol:

- **Must stop after producing output**: after producing a plan / completing a change, it must pause and explicitly offer options (review (recommended) / skip and proceed / discuss) — it must not auto-advance.
- **verdict-driven flow**: review passes → wait for confirmation before the next step; if there are must-fix items → after fixing, offer an incremental re-review; if there is a fundamental problem → after fixing, a full re-review is required, with no skipping.
- **Incremental re-review**: only re-check whether the prior round's issues were fixed, do not rerun the full review — otherwise the cost of re-review will make people prone to skipping it. The precondition for going incremental is that the prior round's must-fix list is **still in hand** (evidenced on disk, or still present in the current context); once the list has been lost to the session / compacted away, a full review is required — doing an incremental review from memory will inevitably miss things.

When unattended, the checkpoint protocol **degrades to a verdict confirmation**, and the rule must be written unambiguously:

- **The only automatic branch**: a verdict on disk == APPROVE → proceed automatically; **any other verdict must stop and wait for a human**.
- No wording should leave room for "it's not a big issue, can proceed" gray areas — an agent's self-exemption always happens in the gray areas of a rule; if the rule has no gray area, it cannot be exempted.
- A verdict is only recognized as **evidence on disk** — a verbal claim is invalid. The full requirements for evidencing and auditing are in "Toolchain Governance" §3 (its home turf).

## 9. Three-Tier Model for Git Write Operations

An automation system must support graceful degradation.

| Mode | push | Merge | Applicable stage |
|---|---|---|---|
| C: Fully manual | The machine only provides the branch, diff, and command | Human merges | MVP / high risk |
| B: Semi-automatic | The machine pushes the feature branch | Human MR / merge | After it has run stably |
| A: Fully automatic with approval | The machine pushes | The machine merges after human approval | High maturity |

Default to starting from C.

Do not pursue full automation from the outset.

## 10. Handoff: Cross-Session Handover

A long-running task must be able to be picked up by a new session.

A handoff document should include:

- Task goal
- Current state
- Completed items
- Incomplete items
- Decisions that must not be reversed
- Source of Truth
- Workflow
- Acceptance method
- Normal stopping point
- Exception handling method
- How to degrade if a tool is unavailable

One important rule:

> Stopping at a checkpoint also counts as fulfilling the responsibility of that phase — do not make the continuation session rebuild it.

## 11. Park-Don't-Guess

The most important safety principle in unattended operation and long-running tasks is:

> When uncertain, park; do not fill the gap by guessing.

Parking means:

- Recording the problem
- Writing down what needs a human judgment
- Preserving the current output
- Not further expanding the change
- Placing it into the review queue or technical debt

Common parking scenarios:

- Source conflict
- Visuals without a source
- Unclear contract
- Unable to produce the state with a real account
- Device abnormality
- The oracle cannot make a determination
- A high-risk operation needs approval

## 12. Long-Running Task Design Checklist

Before designing a long-running task, check:

- Does the task need to span sessions?
- Is there a handoff?
- Is there state recording?
- Is watch, cron, worker, or loop needed?
- Is there a lock to prevent concurrency?
- Is there a de-duplication marker?
- Is there a manual checkpoint?
- Is there failure recovery?
- Is there an oracle?
- Is there a park queue?
- Is there a termination condition?
- Is there a notification mechanism?

If none of these exist, do not call it unattended operation.
