# 07 Toolchain Governance: The Rails You Build for AI Decay Too

## Core Definition

Workflows, skills, review commands, hook scripts — the "rails" built for AI collaboration are themselves code: they accumulate dead code, develop broken contracts, drift out of sync with documentation, and can be bypassed by agents.

Toolchain governance answers four questions:

- What engineering standard governs the maintenance of the rails themselves?
- Who should enforce a given constraint — documentation, review, or machinery?
- During unattended operation, how do you guarantee an agent cannot bypass the rails?
- When the user cannot verify the AI, how does governance escalate as a whole?

## 1. Skills Are Code Too

### 1.1 The Same Engineering Discipline Applies

| Discipline for code | Its form for skills |
|---|---|
| Single responsibility | One skill owns one segment of the process; a diagnostic skill does not perform surgery, a review skill does not slip in a fix |
| Dead-code cleanup | A step that always falls through the "skip if absent" branch is handled as governance debt (see "Technical Debt & Lesson Backflow" §4.1) |
| Changes require review | Modifying a skill's mechanism = modifying a process contract, and deserves the same treatment as modifying code |
| Documentation synchronization | After a skill mechanism changes, the methodology documents that reference it owe a synchronization pass — changed without synchronizing = not actually done |

### 1.2 Cross-Tool Read/Write Contracts: Design Both Ends Together

The most concealed break in a toolchain: Tool B is designed to read a file that Tool A writes to disk, but Tool A's definition never actually includes a write step. B always falls through the "file does not exist → skip" branch — the mechanism never takes effect, and it never errors either (for the full case, see Case Library #23).

Rules:

- When defining the read side, the write side must simultaneously specify: who writes, at which step, and in what format.
- The read side should cite the write side's source, so a broken link is auditable.
- A mechanism that falls through the skip branch N times in a row is cleaned up as governance debt.

## 2. Enforcement Levels: Who Backstops a Constraint

The same constraint can be enforced at any of five levels. The higher the level, the lower the chance an agent can bypass it — and the higher the cost to build:

| Level | Enforcer | Can an agent bypass it | Typical form |
|---|---|---|---|
| L1 Model self-discipline | The agent itself | Anytime (unintentional drift is enough to bypass it) | Verbal agreements, conversational reminders |
| L2 Documented rules | Always-loaded rule files | Yes (when attention dilutes or rules conflict) | `AGENTS` / `CLAUDE` entries |
| L3 Review enforcement | The review step | Harder (but the review itself can be skipped) | Plan Review / Change Review checklists |
| L4 Machine gates | Scripts / lint / CI | Very hard (short of modifying the gate itself) | Lint rules, grep gates, tests |
| L5 Harness hard block | Runtime environment hooks | **Cannot** (at a level the agent cannot reach) | `pre-commit` interception, permission hooks |

Two corollaries:

- **The end point of upgrading a rule is escalating its level, not writing the documentation more sternly.** When the same problem recurs, the question is not "should we emphasize this again," but "can this be escalated to L4/L5."
- **The closer the operation is to unattended, the higher the required enforcement level.** With a human watching, L2/L3 suffices; when unattended, critical constraints must sit at L4 or above — L1/L2 rely on the agent's self-discipline, and the entire premise of unattended operation is precisely that self-discipline cannot be relied upon.

A common misconception: equating "escalate to a machine gate" with "CI must be built first." A local `pre-commit` hook is itself an L4 gate that does not depend on CI — when a recurrence count triggers an escalation, first check whether a minimal-cost local gate can block it immediately, rather than betting the escalation indefinitely on "waiting for CI to be set up."

## 3. Turning Verdicts into Physical Evidence

The automatic advancement of an unattended process must be backed by physical evidence, not by a claim:

- Whether a review passes is determined solely by the verdict line in a file written to disk; an agent verbally stating "the review passed" is invalid — a claim cannot be falsified after the fact, but physical evidence can.
- The hard gate sits at L5: whenever the unattended marker is present, the commit action is intercepted by a runtime environment hook, and it is released only after verifying that the verdict recorded on disk == APPROVE. Even if the agent drifts, it cannot get the commit through.
- A marker file delimits the scope of effect: created on entering unattended operation, deleted on exit — the gate does not interfere with normal discretion during attended operation (such as explicitly skipping a review).
- Every automatic pass-through leaves one line of audit record — trust, but spot-check.

By the same logic, "verification was done" must also be turned into physical evidence: the checkpoint report carries one line of "Verified / Not covered" (see "Long-Running Tasks, Loop, Cron & Unattended Operation" §5.6), rather than being scattered through the narrative of the process.

## 4. False-Green Defense Is a Gate's Duty to Prove Itself

An L4 gate can itself decay into a false green: the scan path breaks, the rule runs against nothing, the test count is 0 — yet it still reports SUCCESS. So a gate must prove its own execution:

- Output the count of objects checked (files scanned / tests run / assertions made); a count of 0 is treated as a failure.
- Periodically inject a known violation on purpose, to confirm the gate can actually catch it.
- For the full checklist, see "Long-Running Tasks, Loop, Cron & Unattended Operation" §5.7, False-Green Defense.

A more concealed source of false green: warnings suppressed by deliberate configuration. A build tool's warnings do not cause a non-zero exit code, and a team, wanting the output to "look clean," may disable an entire class of warnings through a configuration setting — but warnings mix together two things of entirely different nature: noise that conflicts with other explicit decisions already made in the project (safe to disable), and signals that represent real unfinished work (once these too are disabled, the warning list looks clean, but the real technical debt becomes invisible). Before suppressing a warning, ask first: is this warning noise, or is it unfinished work reminding you? Suppress only the noise, never the signal.

## 5. The Three-Form Relationship Between Methodology, Templates & Tools

The same mechanism often exists in three forms, and it is essential to be clear which one is authoritative:

| Form | Role | Scope of authority |
|---|---|---|
| Methodology document (this kind of knowledge base) | Explains the principle and design rationale, self-contained and portable | why |
| Template | A copyable skeleton | starting point |
| Skill / script (the implementation) | The runtime standard | final adjudication of how |

Rules:

- Once a mechanism is implemented as a skill, the runtime defers to the skill; the methodology document records the why, and stays consistent with the skill at the mechanism level (verdict enumeration, state semantics, on-disk contracts, closed-loop flow) — differences at the wording level do not count as drift.
- Skill mechanism changes → the methodology document owes a synchronization pass. The synchronization discipline itself must also obey the enforcement levels: merely writing "remember to synchronize" is L2; pairing it with a hash-baseline comparison script is L4.

## 6. Asymmetric Collaboration: Designing a Harness for People Who Cannot Verify You

The enforcement levels in the preceding sections assume the user is an engineer — someone who can read a diff and recognize an AI's mistakes. When the user is instead someone who cannot verify technical correctness (a product manager or operations person driving AI to modify code directly from a requirements document), the same governance must be escalated across the board. The core judgment:

> **Gatekeeping strength is inversely proportional to the user's ability to verify.** When engineers use it themselves, L2/L3 plus human judgment suffices; when the user cannot recognize errors, all five failure modes (overreach, drift, confabulation, self-certified completion, cross-session forgetting) must be blocked entirely by mechanism, rather than counting on the AI's self-discipline or the other party's technical judgment.

Design principles:

**Diagnose which level is missing before doing anything.** A real specimen: a project's documentation-level governance was complete, while the enforcement level was empty (no hooks, no gates) — the root cause of "self-certified completion" and "reviews that miss defects" was a missing enforcement level, not insufficient rules. Piling more rules onto an already-full level does nothing; fill in the missing level instead (level definitions in §2).

**Minimize the operating surface.** All of the user's actions are collapsed to a small handful (paste the requirement, answer domain questions, look at the report and say pass/fail), with all complexity hidden inside the mechanism. Requiring the user to run commands, edit documents, or understand the design of verdict text all shift the cost of governance onto someone who should not bear it.

**Language isolation + decision routing.** Every output aimed at the user uses the user's own language, with zero engineering jargon. Questions are routed by role: only the questions the user is equipped to judge (process, copy, priority, whether to tolerate some phenomenon) are handed to them for a choice; technical questions are decided on their own against the project's constitution, and whatever the constitution does not cover is explicitly labeled "escalate to engineer" — pushing decisions upward to manufacture decision fatigue is forbidden. The failure exit is unified and mindless ("send the screenshot to so-and-so"); environmental failures are made an explicit, separate state — never swallowed, never muscled through.

**Review independence rests on freezing, not on self-discipline.** The implementer and the reviewer must be separated, and that independence cannot depend on the lead agent giving an "objective account" when it dispatches the work:

- The reviewer's stance is hard-coded into a version-controlled role definition (falsification-oriented: the implementation is assumed wrong by default, and only passes if no evidence of a problem can be found), which the lead agent cannot rewrite at dispatch time;
- **Input isolation**: the reviewer is given only the requirement ID and the acceptance anchors frozen before implementation (acceptance steps the user has already signed off on form a naturally independent baseline) — no implementation description, diff summary, or "I have completed X"-style statement may be attached; the implementer's self-report is a contamination source;
- **Judge only, never fix**: when the reviewer finds a problem, it is only recorded; the fix goes back to the implementer — enforced by permissions (no write access granted), not by discipline. The referee does not step onto the field to play.

**The evidence chain only guarantees that something "happened," not that the "conclusion is correct."** The machine layer can guarantee two things: that the review genuinely happened (provenance verification — using a run record written by the harness, which the agent cannot tamper with, as evidence); and that what was reviewed is what was delivered (the physical evidence is bound to a content hash, not paired by timestamp, to prevent "what was reviewed was A, what was delivered was B"). The correctness of the review's conclusion itself has, as its ultimate anchor, real evidence a human can understand (such as an actual test screenshot in the acceptance report) — a good anti-forgery design makes the cost of faking evidence approximately equal to the cost of actually doing the work correctly.

**Escape hatches must expire automatically.** Any bypass (a "still being edited, don't block it" WIP marker, a relief valve against infinite loops) must carry automatic expiration (such as session-scoped clearing), a bounded count, and an audit record — an escape hatch without expiration inevitably evolves into a permanent backdoor. When both roles share one repository, the engineer-side bypass should use a machine-decidable local switch (not committed to the repo, existing only on the engineer's own machine), rather than teaching the gate to recognize a person.

**The harness itself must pass acceptance.** Before going live, run an end-to-end self-check on the governance mechanism itself: first run the gate against the existing baseline (so it does not unfairly flag pre-existing state); the end-to-end rehearsal includes adversarial testing — manually forge a piece of passing evidence and confirm it gets blocked; and simulate the other party's environment for a first run from zero. This is the closing piece of §1, "Skills Are Code Too": code needs testing, and gates need adversarial testing.

**Fast gates handle every turn, slow patrols handle drift.** Mandatory checks on every turn carry only the high-frequency failure modes; full regression and drift checks between mechanism and documentation go into a low-frequency manual patrol — do not cram every line of defense into the per-turn hook, since the failure surface itself is also a cost.

Relationship to existing chapters: "reject the means, not the end" ("Upper-Level Rules" §1.6, Case Library #28) is a hard requirement in this kind of scenario — a user who is bluntly refused will bypass the AI and edit the file by hand, and every guardrail goes dark; "debt logging rests with a person" ("Technical Debt & Lesson Backflow" §4) is escalated here into machine enforcement — new debt with no sign-off record causes the review to fail outright.

## 7. Toolchain Governance Checklist

- [ ] Does each skill have a single responsibility, with no step that overreaches in passing?
- [ ] Are cross-tool read/write contracts complete on both ends, with the read side citing the write side's source?
- [ ] Are there any process steps that keep running empty in a row (governance-debt candidates)?
- [ ] Is every critical constraint labeled with an enforcement level? Are constraints on the unattended path ≥ L4?
- [ ] Is the evidence for automatic advancement physical evidence written to disk, not a verbal claim?
- [ ] Does the machine gate prove its own execution (count > 0)?
- [ ] Has the authority relationship among the methodology / template / skill forms been declared? Does the synchronization discipline have a mechanical trigger?
- [ ] When the user cannot verify the output, have all critical constraints been escalated to L4/L5? Is review independence mechanized (role freezing / input isolation / judge-only-never-fix)?
- [ ] Do escape hatches have automatic expiration and an audit trail? Has the harness undergone an adversarial self-check before going live (forged evidence gets blocked)?
- [ ] Has every tool/MCP server on an unattended pipeline's whitelist been audited for a one-time human gesture hidden inside its first real invocation (OAuth popup, browser-extension permission dialog, interactive login) — not just for whether its own definition calls out to a human (Case Library #32)?
