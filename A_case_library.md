# Appendix A: Case Library

## How to Use This

The case library is not a collection of stories — it is material for training judgment.

Each case is written in three parts:

- Anti-Pattern: how AI or the team is prone to get it wrong.
- Correct Approach: how to correct course.
- Abstracted Rule: distilled into a reusable governance principle.

Cases can be used for:

- onboarding
- review checklists
- Spec template examples
- automated workflow design
- subagent task instructions
- technical debt retrospectives

## 1. Mistaking the Visual Source for the Business Source

### Anti-Pattern

AI infers business rules directly from the text, button order, and status labels in a design mockup.

For example:

- The mockup shows "Under Review," so the AI assumes the API status field must be named `pending`.
- The Figma page doesn't show a failure state, so the AI assumes no failure state exists.
- The mockup's list shows only three rows, so the AI omits the pagination logic.

### Correct Approach

The visual source only answers "what it looks like."

Business rules must be determined from the Business Spec, production behavior, API facts, and verified logic.

If the visual source conflicts with the business source:

- Flag the conflict first
- Establish the Source of Truth priority
- Request human adjudication when necessary
- Write the adjudicated result back into the Spec

### Abstracted Rule

> A design mockup is the visual Source of Truth, not the business Source of Truth.

## 2. API Documentation Conflicts with Production Facts

### Anti-Pattern

AI only reads the old API documentation and implements against its field names.

But the production API has actually changed field names, and the old mocks and old tests happen to still support the old fields — so tests pass while production fails.

### Correct Approach

API-related tasks must distinguish between:

- historical documentation
- the current openspec
- real request samples
- observed production behavior
- existing call-site facts in the code

When these sources conflict, do not simply pick whichever document is easiest to read.

Adjudicate according to the project's defined Source of Truth priority, and register the conflict as documentation debt.

### Abstracted Rule

> API implementation follows current fact; old documentation is only a lead.

## 3. AI Claims Tests Pass, But There Are No Assertions

### Anti-Pattern

AI adds a test file, runs it, sees it pass, and declares the task complete.

Review reveals:

- the test only renders the component
- no assertion on key behavior
- no coverage of the exception path
- the mock data is unrelated to the real risk
- the test name literally implies one scenario (e.g. `invokesTracker` / `logsWarn`), but the body actually asserts something else — you must check whether the test name's literal meaning matches what the body actually asserts, not just whether the test exists

### Correct Approach

Tests must prove the task's objective.

At minimum, ask:

- What does the test assert?
- Would the test fail if the implementation were wrong?
- Does it cover the reproduction path of this bug?
- Does it cover boundary states?

### Abstracted Rule

> A passing test does not equal completed verification; a test without assertions is close to a prop.

## 4. Asynchronous Failures Are Silently Swallowed

### Anti-Pattern

A step in a long-running task has an API call fail; the catch block only logs it.

The main flow continues and finally reports "all done."

### Correct Approach

First define error severity levels:

- Blocking error: stop the flow, write a failure status, notify a human.
- Recoverable error: retry, degrade gracefully after the retry cap is exceeded.
- Non-blocking error: log a warning, do not affect the main flow.

Before an automated flow concludes, it must check the failure list.

### Abstracted Rule

> In an unattended flow, a silent failure is false completion.

## 5. Technical Debt Goes Unregistered

### Anti-Pattern

AI discovers stale documentation, a missing test for some state, or a worker with no reset — but since the current task can still be completed, it only mentions this in a single line of the final response.

The next task, with a different context, hits the same problem again.

### Correct Approach

Any issue meeting the following conditions should be registered as technical debt:

- not fixed now
- will affect future judgment
- has a risk of recurrence
- has a clearly defined scope of impact

When registering, write down clearly:

- the symptom
- the risk
- the reason for deferring
- the repayment method
- the acceptance criteria

### Abstracted Rule

> Debt that isn't registered becomes the next AI's blind spot.

## 6. Subagent Runs Empty

### Anti-Pattern

The lead agent assigns a review task to a subagent.

The subagent reports "no issues found," but the report has no file references, no command evidence, no stated scope of review.

### Correct Approach

A subagent's output must be auditable.

The lead agent should require:

- which files were explicitly read
- the explicit dimensions of review
- the scope explicitly not covered
- findings accompanied by paths and evidence

For critical tasks, the lead agent must spot-check.

### Abstracted Rule

> A subagent can share the work, but it cannot share the final responsibility.

## 7. Cron Continuation Causes Duplicate Work

### Anti-Pattern

A `Cron` job starts a new session at midnight; the new session doesn't know the previous stage already completed, so it re-executes the batch task.

Result:

- overwrites the previous changes
- duplicate commits
- state confusion
- humans cannot tell which result is trustworthy

### Correct Approach

`Cron` continuation must have a handoff.

The handoff must state:

- what has been completed
- what has not been completed
- which checkpoint it is currently stopped at
- which states are normal to be paused at
- which actions must not be repeated
- how to determine whether to continue

The `Cron` task itself must be idempotent.

### Abstracted Rule

> A `Cron` job without a handoff is blindly starting a new task.

## 8. Watch and Worker Are Mixed Together

### Anti-Pattern

All that was needed was to listen for chat messages, but instead a background `Worker` is left to directly modify code, commit, and notify.

Because the `Worker` has no context, it mistakes a casual discussion for a formal task.

### Correct Approach

Distinguish `Watch` from `Worker`:

- `Watch` only observes events, exits once one is found, and wakes the current session.
- `Worker` handles a complete task chain and must have locks, a state machine, and human checkpoints.

When the current window is human-attended, prefer `Watch`.

Only use `Worker` when truly unattended and the workflow is mature.

### Abstracted Rule

> When `Watch` can preserve context, don't rush to bring in `Worker`.

## 9. A Headless Worker Gets Stuck on Permissions and Context

### Anti-Pattern

For the sake of automation, the entire fix chain is handed to a headless agent.

The result is that the headless agent:

- has no context from the current session
- has inconsistent tool permissions
- gets stuck waiting for human input
- has incomplete error handling

### Correct Approach

First adopt the current-session mode:

- the background process only listens
- it exits once an event arrives
- the current main session continues processing

Once the workflow is stable, sink the well-defined, low-risk, state-machine-able parts down to a `Worker`.

### Abstracted Rule

> When automation maturity is insufficient, automate the wake-up, not the decision.

## 10. An Unattended Migration Has No Oracle

### Anti-Pattern

AI migrates pages in bulk and considers the task done once the build passes.

But the migration target actually includes:

- visual consistency
- business-state consistency
- API field consistency
- consistency of real-device interaction
- consistency of exception paths

A passing build cannot prove any of these.

### Correct Approach

An unattended migration must define its oracle in advance.

The oracle can include:

- live side-by-side comparison with the source page
- a state matrix
- schema validation
- screenshot diffs
- real-device operation scripts
- console error checks
- network request assertions

A task without an oracle cannot promise unattended completion.

### Abstracted Rule

> Whether a long-running task can be unattended depends on whether there is an automatically checkable completion criterion.

(For oracle design and entry preconditions for migration-type tasks, see [`09_迁移与重写治理.md`](./09_migration_and_rewrite.md) — "Migration & Rewrite Governance: Fork, Greenfield Rewrites & Parity Reconciliation" §5.)

## 11. Mocks Are Treated as Fake Data

### Anti-Pattern

AI treats mocks merely as local debugging data, freely changing them to make a page look good.

As a result, the mocks no longer cover real business states.

### Correct Approach

In migration, refactoring, and state-machine tasks, mocks should serve as a state ledger.

They should cover:

- success
- empty state
- loading
- error
- boundary values
- permission differences
- combinations of multiple states

Mock changes must state which business state they correspond to.

### Abstracted Rule

> A high-quality mock is a state ledger, not fake data.

## 12. "Looks Fine" Does Not Equal Faithful Design Reproduction

### Anti-Pattern

AI opens the page, sees no obvious misalignment at a glance, and declares the UI complete.

But in reality there exist:

- inconsistent font sizes
- spacing deviations
- missing states
- incorrect line wrapping on mobile
- inconsistent scroll regions
- incorrect icon assets

### Correct Approach

Faithful design reproduction requires an explicit acceptance method.

Common methods:

- side-by-side comparison with the mockup or source page
- screenshot diffs
- multi-viewport checks
- screenshots of key component states
- console error checks
- real-device verification

### Abstracted Rule

> A UI that "renders" is not the same as "reproduction complete."

## 13. Improvising Freely When Assets Are Missing

### Anti-Pattern

AI cannot find an icon or image, so it directly substitutes a placeholder, a gradient, or a solid color block, and marks the page complete.

### Correct Approach

When assets are missing, handle it in order:

1. Search the current project's asset directory.
2. Search the upstream project or an old version.
3. Check the mockup's exported assets.
4. Ask, or register asset debt.
5. When using a placeholder, explicitly mark it as not final-acceptance-ready.

### Abstracted Rule

> A missing asset is not a license for free creation — find the source first, then placeholder.

## 14. Contract Changes Without Independent Verification

### Anti-Pattern

AI modifies the schema, API calls, and UI field display, but does not independently verify the source of the change.

In the end, the code, the mocks, and the documentation are all wrong together.

### Correct Approach

A contract change requires at least two kinds of evidence:

- source evidence: where the field comes from
- behavioral evidence: how the implementation is verified

For example:

- an openspec example
- an actual API response
- the old code's call chain
- backend confirmation
- schema tests

### Abstracted Rule

> A contract change cannot self-certify; it must have an independent source.

## 15. A Batch Task Has No Phase 0

### Anti-Pattern

Multiple pages, multiple modules, multiple agents start work at the same time.

Each agent builds its own mocks, defines its own types, and handles caching on its own.

At integration time, it turns out that:

- types are duplicated
- cache-invalidation strategies conflict
- directory structures are inconsistent
- component boundaries are inconsistent

### Correct Approach

A batch task must do Phase 0 first:

- common types
- shared mocks
- data contracts
- base components
- cache/invalidate conventions
- acceptance criteria
- division-of-labor boundaries

Only then proceed to Phase 1 for parallel implementation.

### Abstracted Rule

> Unify the foundation before going parallel.

## 16. A Human Checkpoint Gets Skipped

### Anti-Pattern

An automated fix flow goes straight from diagnosis into modification, commit, and notification.

But the diagnosis stage involves a business judgment call that needs human confirmation.

### Correct Approach

Set any step that cannot be automatically adjudicated as a human checkpoint.

Common checkpoints:

- requirement ambiguity
- conflicting business rules
- deleting data
- changing a public API
- push / merge / release
- large-scale refactoring

The checkpoint message must clearly state:

- the current judgment
- what choice the human needs to make
- what will not be done by default
- what happens on timeout

### Abstracted Rule

> Automation must not override business adjudication authority.

## 17. Park-Don't-Guess

### Anti-Pattern

AI lacks a critical source, but guesses the most likely approach in order to keep moving forward.

After guessing, it keeps writing code, so a large amount of subsequent work is built on an uncertain foundation.

### Correct Approach

When facing critical uncertainty, stop at a recoverable point.

Actions include:

- recording the known facts
- recording the missing information
- explaining why it cannot proceed
- stating what input is needed for the next step
- not making irreversible changes

### Abstracted Rule

> When a critical Source of Truth is missing, stopping is more engineering-sound than guessing right.

## 18. No Check of the Actual Diff Before Commit

### Anti-Pattern

AI commits directly after finishing the changes.

But formatting, generated files, and auto-fix scripts introduce extra changes that the AI never checked.

### Correct Approach

Before commit, at minimum check:

- `git status`
- the actual diff
- whether unrelated files are included
- whether there are generated artifacts or caches
- whether documentation was missed
- whether the necessary verification passed

High-risk tasks should also go through a `change-review`.

### Abstracted Rule

> Commit is a delivery action, not a save action.

## 19. A Review Report Has No Verdict

### Anti-Pattern

The review report is full of suggestions, but does not state clearly whether it can proceed.

The executing agent doesn't know whether to fix, stop, or ship.

### Correct Approach

A review must give a verdict:

- `APPROVE`
- `APPROVE WITH CHANGES`
- `RETHINK`
- `REQUEST CHANGES`

And classify issues as:

- Blocking
- Important
- Minor

### Abstracted Rule

> A review without a verdict cannot drive the process.

## 20. Lessons Are Only Written in the Final Reply

### Anti-Pattern

AI summarizes "things to watch for next time" in its final answer, but never writes it into any persistent location.

The next task cannot inherit it at all.

### Correct Approach

Lessons with reuse value should flow back into:

- the knowledge base
- `AGENTS.md`
- the template library
- the review checklist
- the technical debt ledger
- automation scripts

### Abstracted Rule

> A lesson that isn't committed to disk is not a system capability.

## 21. Governance Mechanisms Can Die Too

### Anti-Pattern

A cross-phase ledger was designed to solve "must-fix items from Plan Review being forgotten during execution": Plan Review writes issues to disk, Change Review checks them off one by one and closes them out. The mechanism was elegant and complete, but once it ran, the ledger was always empty — because the correct workflow was, all along, to fix the must-fix items directly into the plan before execution, then re-review to `APPROVE`. The mechanism became dead code that had to run an empty pass on every review.

### Correct Approach

Retire the ledger, fix at the source: must-fix → revise the plan document directly → incremental re-review → execute only after `APPROVE`. At the same time, record "the death of the ledger" to prevent anyone from rebuilding it. For the definition and criteria of governance debt, see [`06_技术债与经验回流.md`](./06_tech_debt_and_lesson_backflow.md) — "Technical Debt & Lesson Backflow" §4.1.

### Abstracted Rule

> If the problem a governance mechanism guards against can be eliminated at zero cost further upstream, the mechanism itself is governance debt.

## 22. A Verbally Claimed Review Pass

### Anti-Pattern

In an unattended loop, the agent claims "the review has passed" and immediately commits and proceeds. In reality the review either never ran, or ran but the verdict was not a pass — the claim cannot be falsified after the fact, and faulty output keeps entering the main branch.

### Correct Approach

Turn the verdict into physical evidence + layered enforcement:

- The **sole evidence** for automatic progression is the verdict line in the review's file on disk; a verbal claim is not valid.
- At a layer the agent cannot reach (the `pre-commit` interceptor in the runtime environment), add a hard gate: when the unattended marker exists, commit must verify that the on-disk verdict == `APPROVE`, otherwise it is blocked outright.
- Create the marker file on entering unattended mode and delete it on exit, so the gate only takes effect when unattended, without interfering with normal skip behavior when a human is present.

### Abstracted Rule

> A verbal claim is not physical evidence; the closer to unattended, the higher the enforcement layer of the constraint must be.

## 23. A Broken Read/Write Contract Across Tools

### Anti-Pattern

Review tool B is designed to "read the file that tool A writes to disk to close the verification loop," but tool A's definition never included a write-to-disk step from the start. Every run of B hits "file doesn't exist → skip," so this carefully designed closed loop **never actually took effect**, and no error ever exposed it.

### Correct Approach

- A cross-tool read/write contract must be **designed on both ends together**: when the read end is defined, the write end must simultaneously specify "who writes what format, at which step."
- On the read end, note the write end's provenance ("this file is produced by step N of X"), so a broken link can be audited.
- Periodically audit "conditional skip" branches: a mechanism that hits the skip branch for N consecutive times should be treated as governance debt.

### Abstracted Rule

> For a cross-tool closed loop, first prove the write end exists, then design the read end.

## 24. Component Extraction Only Half Done

### Anti-Pattern

Recurring visual styles are sunk into a shared style layer (for example, extracting some interactive component's CSS into a common class), but the accompanying behavior code (such as auto-advancing to the next field, state management) is still separately reimplemented in each calling page. On the surface it "has been DRYed," but in reality the part most prone to error and most costly to maintain — the behavioral logic — was never extracted at all.

### Correct Approach

When extracting a component or logic, treat "visuals + behavior + accompanying elements" as one indivisible whole and sink it down together — don't declare the job done after extracting only the visual layer. It's simple to tell whether the extraction is complete: if the same behavior code still appears separately in ≥2 call sites, the extraction is not yet done.

### Abstracted Rule

> The right granularity for extracting duplicate code is "the whole functional unit," not "whichever layer is easiest to extract."

## 25. A Knowledge Base Entry Point That Is a File List Amounts to Requiring a Full Read

### Anti-Pattern

A project built a fact-base for locating issues, but the entry-point `README` was written as a file list: "This directory contains four documents: architecture / code-map / domain-glossary / user-journeys." When an agent gets a bug, it dutifully reads all four before doing anything — the knowledge base not only fails to lower the cost of locating the issue, it becomes a fixed reading tax on every task, no better than "no knowledge base, just scan the whole repo."

### Correct Approach

Make the entry point a triage router: the first cut asks "would this also happen on a different page" to split cross-cutting from single-point issues; cross-cutting issues go through a symptom → mechanism table straight to the layer involved; single-point issues go, from cheap to expensive, straight to the file using whatever handle the description provides (literal UI text / action / noun / route); and the entry point must explicitly state the counter-instruction — "do not read every document before doing anything." Every locating path written into the entry point must be validated against a real case.

### Abstracted Rule

> The product of a knowledge base entry point is routing, not a directory; an index that cannot triage amounts to requiring a full read.

## 26. A Local Mechanism Written Up as a Global Mechanism

### Anti-Pattern

During investigation, a conversion/normalization logic is found on one page and immediately written up as "this system's amount-conversion mechanism." The next time a bug is located, the agent fixes the shared layer as if it were a "global mechanism," or applies that same convention to other pages — fixing the wrong layer, and dragging in innocent code along the way.

### Correct Approach

Before asserting a mechanism's scope, grep laterally across similar pages first: confirm whether it is "one global instance" or "a pattern each page implements separately." Add a "scope" column to the symptom → mechanism table, and handle the two scopes with different fixes: a global instance is fixed directly; a per-page pattern only tells you "what shape of code to look for" — the specific file still needs the single-point axis to locate it.

### Abstracted Rule

> Where a mechanism holds is just as important as what the mechanism is; a fact whose scope hasn't been verified is only half a fact.

## 27. "Confirmed Not to Exist" Was Never Committed to Disk

### Anti-Pattern

An investigation confirms some feature does not exist in this repository (an exhaustive keyword search turns up zero hits), and this is only mentioned once in conversation before moving on. The next session, or the next person, hits a similar ticket and searches the same keywords all over again; worse, they see leftover artifacts (a dead i18n key, an old config) and mistakenly conclude the feature exists, digging deeper and deeper in the wrong place.

### Correct Approach

The fact-base should have a section for "features confirmed investigated and non-existent": record the conclusion plus the investigation basis (which keywords were searched, which directories were checked), and note the verification date — "does not exist" can also go stale.

### Abstracted Rule

> "Confirmed not to exist" is a fact of the same standing as "confirmed to exist"; an investigation not committed to disk gets repurchased over and over.

## 28. A Guardrail That Can Only Say No Gets Bypassed

### Anti-Pattern

Two symmetric failure modes: first, a human (product/business) asks to "just tweak the color directly," "manually edit the generated file, it's faster," and the AI complies — the invariant gets breached "through" the AI's own change; second, the AI flatly refuses without offering a way forward — the other party, finding the process too slow, bypasses the AI and edits the file by hand, and since the guardrail was never able to do anything about changes made "without going through the AI" in the first place, it becomes a dead letter from then on.

### Correct Approach

Refuse the means, not the end: while refusing the non-compliant way of doing it, proactively offer a way to achieve the same outcome through the proper channel (which source to change, how many steps, and that it can be done right now), guiding the person back to a safe path; pair this with a minimal mechanical gate (such as a `pre-commit` check) to catch changes that bypass the AI — AI-based enforcement handles persuasion, mechanical enforcement handles the backstop.

### Abstracted Rule

> The product of a refusal is an alternative path, not "no"; a guardrail that can only say no ends up bypassed.

## 29. The Text Is All Correct, the Visuals Are All Wrong

### Anti-Pattern

After a UI change, the implementer uses a script to assert the page's text — amounts, copy, checked item by item, all correct — and immediately reports "verified." A human opens the page and spots two problems at a glance: one line of content is squeezed and wraps, and an icon is stretched out of shape. Text assertions cannot touch layout or geometry — the verification dimension is misaligned with the dimension the bug could occur in, which amounts to no verification at all.

### Correct Approach

- The dimensions asserted must cover every dimension the change could break: content (text), layout (coordinates, same-row judgment), geometry (aspect ratio), rendering (an actual screenshot).
- UI verification must end with actually looking at a screenshot; the "verified" line in a checkpoint report may only be written after the rendered result has actually been viewed.
- A common trap: when a vector icon's source file declares "do not preserve aspect ratio when stretching" (e.g. SVG's `preserveAspectRatio="none"`), a container ratio that doesn't match the original ratio will silently deform it — something the text layer is completely oblivious to.

### Abstracted Rule

> The dimensions of verification must cover the dimensions a bug could occur in; passing a text assertion does not mean the page is right.

## 30. Treating an Old Comment's "Can't Be Done" as a Skip-Verification Pass

### Anti-Pattern

A code comment or old ledger states: "this feature is blocked on an external dependency, can't be done in this repo." Every time AI passes by, it copies this conclusion and stands pat. In reality: the dependency's hook point was registered in the contract table long ago, another module in the same repo has already run the same dependency successfully, and the project's conventions already have a default-value pattern — the "can't be done" may have been true the day it was written, but no one has re-checked it since. Within the same session, two separate instances of casually attributing a "todo" to "blocked on an external dependency" were both corrected on the spot by a human.

### Correct Approach

- A blocking conclusion ("can't be done / blocked / waiting on a third party") is the negative knowledge most prone to going stale — falsify it before accepting it: check the contract registry → check precedent within the same repo → check existing patterns; only classify it as blocked if it's still blocked after all three checks.
- Once a hook point is found, just do it — don't stop to ask "can this be done."
- This applies especially to greenfield rewrites against a mature reference system: for any capability that has already run successfully in the reference system's production environment, this repo most likely already has a corresponding hook point — "not wired up" ≠ "can't be done."

### Abstracted Rule

> Use negative knowledge with a date attached; falsify a blocking conclusion before accepting it — it is not a skip-verification pass.

## 31. A Sub-Agent Dispatched to the Background Dies With Its Parent Process

### Anti-Pattern

Inside a single round of a headless loop — a one-shot, non-interactive process that exits the moment the round ends — the implementer dispatches change-review's judgment sub-agents asynchronously in the background and then polls for their results. The round's timeout is a hard ceiling that includes polling time; the two sub-agents never finish before it's hit, the parent process is killed, and the entire round produces zero commits. This happened for real (2026-07-21): an otherwise correctly designed loop burned a full round on nothing.

### Correct Approach

- Inside any execution unit whose process lifetime ends with the round (a headless CLI call, a one-shot cron invocation), all sub-agents must be dispatched **synchronously** — the parent call blocks until they return.
- "Parallel" inside such a unit means firing multiple synchronous calls in one batch so the harness runs them concurrently and returns together — never background-dispatch-then-poll. A backgrounded sub-agent has no independent lifetime: when the parent process exits, it is killed, and there is no cross-round mechanism to wake it up or recover its partial output.
- This rule is easy to get backwards, because "dispatch sub-agents in the background and check on them later" is exactly the right pattern *inside a long-lived interactive session* — it only breaks the moment the parent's own lifetime is scoped to a single round.

### Abstracted Rule

> Inside a process whose lifetime ends with the round, every sub-agent must be dispatched synchronously — a backgrounded one dies with its parent and leaves nothing behind.

## 32. An "Automated" Tool With a Hidden One-Time Human Gesture Buried Inside It

### Anti-Pattern

An unattended pipeline's tool whitelist includes a browser-automation MCP server configured to attach to the operator's real, already-logged-in Chrome via a browser extension. The tool looks fully automated — no code path calls out to a human. But the *first* time the headless process actually touches that extension, the extension itself pops up a one-time permission dialog ("Allow this connection?") that lives entirely inside the browser UI, outside any CLI permission system a skip-permissions-style flag can reach. In a headless environment there is no one to click it. The round hangs until the round-timeout kills it. This repeated for 9 consecutive rounds over 6 hours before a wall-clock watchdog finally caught the "no progress" pattern and stopped the loop.

### Correct Approach

- Before adding any tool/MCP server to an unattended pipeline's whitelist, check specifically for a one-time human gesture hidden inside it: an OAuth popup, a browser-extension permission dialog, an interactive login prompt, a device-pairing confirmation. These don't show up as a "requires human" step in the tool's own definition — they surface only the first time the tool is actually exercised.
- Prefer variants of the same capability that are headless-safe by construction (e.g. a browser-automation tool that launches its own throwaway, unauthenticated browser instance) over ones that attach to a real, human-authorized session.
- Restrict the unattended process to an explicit tool whitelist rather than inheriting the operator's full tool configuration — a tool that's perfectly safe in an interactive session (because a human is there to click through it once) can silently deadlock a headless one.

### Abstracted Rule

> A tool that never explicitly asks for permission in its own definition can still have a human gesture buried inside its first real invocation — audit for that specifically before trusting a tool in an unattended pipeline.
