# 02 Context Governance: Treating Attention as a Scarce Resource

## Core Definition

Upper-Level Rules answers "what the rules are"; Context Governance answers "how the rules reach the AI."

A common misconception is: the more rules you write, and the more fully the AI reads them each time, the more controllable its behavior becomes. The reverse is true — **context is a scarce resource**, and the marginal effect of a rule diminishes as the total volume grows. The goal of Context Governance is:

> With the smallest possible always-loaded context, let the AI see exactly the rules and facts it needs for each task — no more, no less.

## 1. Why Context Is a Scarce Resource

Three real mechanisms of degradation:

| Degradation | Mechanism | Consequence |
|---|---|---|
| Attention dilution | The more rules there are, the lower the compliance rate for each one | An agent that has read five constitutions discounts its execution of every single one |
| Critical information drowned out | Hard constraints mixed into background narrative | Genuine red lines get treated as ordinary suggestions |
| Cost and latency | Every session pays the full reading cost | Under high-frequency collaboration, the waste is amplified by repetition |

So the first principle of Context Governance is not "write it clearly" but **"few and precise"**: every additional always-loaded rule levies an attention tax on all the rules that already exist.

## 2. Always-Loaded vs. On-Demand: Two Ways to Load a Rule

There is only one threshold for deciding whether a rule should be always-loaded (i.e., placed in a global or project-level file such as AGENTS or CLAUDE that must be read every session):

> **It is needed in every session, and it exists nowhere else.**

Both conditions must hold:

- If "needed every time" fails → sink it into a dedicated document, loaded on demand.
- If "exists nowhere else" fails → do not restate content that already has an authoritative source (code, lint configuration, architecture documents); restating it will inevitably drift.

| Content | Destination | Loading Method |
|---|---|---|
| Hard red lines (prohibitions/conventions that must be followed every time) | Always-loaded rules file | Automatically, every session |
| Full rules + historical violation records | Dedicated conventions / lessons documents | The always-loaded file keeps a one-line pointer |
| Architectural blueprints, contract details | Engineering charter / contract documents | Read on demand when task-relevant |
| One-off task context | Plan / handoff documents | For the current task only |

## 3. Thin-Constitution Mode

The always-loaded rules file should be a **thin constitution**: it keeps only the essentials plus a one-line pointer, while the full text and the ledger sink into dedicated documents.

```text
❌ Thick constitution: full rules + examples + historical violation records, all piled into the always-loaded file
✅ Thin constitution: a one-line essential + a pointer to the dedicated document
```

Example (one line in the always-loaded file):

```markdown
## Engineering Quality Hard Lines (full rules + violation records: see specs/code_quality_lessons.md)
1. Pure logic must have unit tests — see §2 of that document for details
```

### 3.1 Bloat Signals

The following signs indicate that the always-loaded file needs to go on a diet:

- A single rule exceeds 5 lines (the details should be sunk elsewhere).
- "Background" or "historical reasons" paragraphs appear (this is document content, not a rule).
- A fresh-session AI starts violating the rules in the first half of the file (content added later dilutes what came before).
- Rules on the same topic are scattered across multiple places (they should be merged into one essential plus one dedicated document).

### 3.2 Sinking Discipline

New rules produced by a rule upgrade (see Technical Debt & Lesson Backflow) default to sinking into a **dedicated document**; the always-loaded file only gets a pointer line added. Make "which layer it sinks to" a required field of the rule-upgrade proposal, to prevent every new rule from flooding into the always-loaded file.

### 3.3 Re-Evaluation Trigger Points: Give Strong Constraints a Concession Condition

Architectural/convention decisions that get repeatedly overturned tend to accumulate in the body text into a mess where "old and new arguments coexist and it's unclear which one is current." The approach:

- The body text (constitution/architecture document) keeps only the **current conclusion**; the full rationale and reversal history of past decisions move into a separate decision log, with the body text keeping a one-line pointer (e.g., "(reversed 2026-06-22, see decision log)").
- **Every strong constraint comes with a re-evaluation trigger point**: the condition under which the rule should be reconsidered. A strong constraint with no trigger point either gets treated as dogma and never challenged, or gets casually broken without a trace.

Example: a project set "UI primitives must not wrap thin components" as a strong constraint, while also writing down the re-evaluation trigger point — "if a composite component with genuine reuse behavior (state/focus management) appears and is needed in ≥2 places, extract a component with real props at that point." This makes the rule non-static: before the condition appears, no one has grounds for an exception; once the condition does appear, there is no need for a "reversal"-style overhaul — you simply follow the pre-written trigger condition.

The re-evaluation trigger point and the technical debt "trigger condition" field (see Technical Debt & Lesson Backflow §3) apply the same idea to different objects: that one governs "when a to-do item should be done," while this one governs "when an already-in-effect strong constraint should be challenged."

Status tables / checklist-type documents are another instance of the same anti-pattern: new progress must **backfill the overturned old lines**, not merely be appended at the end — a status table that only appends without backfilling will contradict itself old-versus-new and misreport progress. A status change without backfilling = not actually done.

## 4. Required-Reading Matrix: Routing by Task Type

Once a project has accumulated enough documents, the second bloat point is the "required reading list": every important document gets marked as required, and every session pays the full reading cost.

The governance approach is to turn the "required reading list" into a **Required-Reading Matrix** — routed by task type:

```markdown
| Document | Build a Page | Modify the Base | Modify Instrumentation | Parity Reconciliation for Migration |
|---|:-:|:-:|:-:|:-:|
| Architecture blueprint | ⭐ | ⭐ | | |
| Page-building playbook | ⭐ | | | ⭐ |
| Instrumentation contract | | | ⭐ | |
| Source adjudication rules | ⭐ | | | ⭐ |
```

The benefit is twofold: what is saved is not just tokens but attention — an agent that reads only the three relevant documents complies with each of them better than one that reads seven.

## 5. Subagent Context Contract

Subagents are **stateless**: they cannot see the lead conversation's history, cannot see the output of other agents that ran before them, and cannot see any verbal consensus reached between the user and the lead agent. From this follows a set of hard contracts:

### 5.1 Input: The Prompt Must Be Self-Contained

- The full plan text, the list of changed files, the project root path, the checklist for judgment — whatever the subagent needs, the lead agent must **explicitly inject** it into the prompt or point to it clearly ("Read such-and-such file yourself").
- Never write "as we discussed earlier" — a subagent has no "earlier."
- For decisions reached in conversation but never committed to disk, the lead agent is the sole carrier; either write it into the prompt, or commit it to disk first and then point to it.

### 5.2 Output: Return Data Only

- A subagent's return value is data for the lead agent to consume, not a report for a human to read — require "a list of findings, an empty list if there are no problems, no pleasantries."
- The return format must be explicitly defined in the prompt (fields, structure); otherwise each agent improvises freely, and the lead agent's aggregation cost skyrockets.

### 5.3 Responsibility: The Lead Agent Is the Carrier of Context

When a subagent runs in circles, compares the wrong files, or misunderstands boundaries, the root cause is most often that the context the lead agent injected was incomplete or ambiguous. **The ceiling on a subagent's output quality is set by the input the lead agent gives it.**

## 6. Token Economy: Don't Dispatch an Agent for Mechanical Work

The cost of dispatching a subagent = context injection + model invocation + result digestion. This calculation determines the division of labor:

- **Mechanical / grep-able work is done by the lead agent itself**: running a few commands to check output, grepping to verify existence — dispatching an agent for this is pure waste, and it also introduces distortion through retelling.
- **Only work requiring judgment is dispatched to an agent**, and it scales with difficulty: 0 agents for trivial work, 2 for routine work, and only high-risk work gets split finer with adversarial re-review added.
- Model tier is layered by role; see Execution Layer §5.4 Subagent Model Economics.

## 7. Context Governance Within Long Conversations

Within a single session, context dilutes in the same way:

- **Commit important conclusions to disk promptly**: key decisions reached mid-conversation should be written into a plan / decision document, not relied upon to be "remembered by the conversation." During compaction, continuation, or handoff, only what has been committed to disk actually exists (the handoff mechanism is covered in Long-Running Tasks, Loop, Cron & Unattended Operation).
- **Turn verification artifacts into physical evidence**: what was verified and what paths were covered should be written as a one-line "verified / not covered," not left scattered across process output.
- **Change the water instead of gritting it out**: the discussion noise of the plan phase (rejected proposals, trial and error, back-and-forth) keeps diluting attention during the implementation phase; automatic summarization is lossy compression and cannot recover it. The countermeasure is not to keep stretching the conversation longer, but to move implementation into a subagent with clean context, with the lead session fixed as the control track — see Execution Layer §5.11 for the mechanism and dispatch discipline.

## 8. Context Governance Checklist

When designing governance for a project, check:

- [ ] Does the always-loaded rules file contain only content that is "needed every time + exists nowhere else"?
- [ ] Is there a dedicated lessons / conventions document to carry the full rules and the ledger?
- [ ] Does the always-loaded file show bloat signals (a single rule >5 lines / background paragraphs / scattered duplication)?
- [ ] Are required-reading documents routed by task type, rather than all marked ⭐?
- [ ] Is the prompt for dispatching a subagent self-contained (full plan text / file list / return format)?
- [ ] Is it specified that subagents return data only?
- [ ] Does mechanical verification stay with the lead agent, without being wasted on subagents?
- [ ] Is there a discipline for committing key mid-conversation decisions to disk?
- [ ] Do long-running tasks use water-changing to isolate plan-phase noise, rather than relying on automatic summarization to grit it out?
