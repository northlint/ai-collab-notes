# 05 Diagnostic Methodology: Evidence-Based Root Cause Analysis

## Core Definition

Review & Correction guards against **defects entering**; Diagnostic Methodology investigates **defects that have already occurred**. The two are sister stages: one intercepts before delivery, the other locates the root cause after a defect has surfaced.

The biggest failure mode in diagnosis is not "failing to find it" — it is "looking only at the small patch of code where the bug surfaced, prescribing a fix without gathering evidence from the surrounding area." This fixes the victim, lets the real culprit escape, and collaterally damages innocent code along the way.

So the core discipline of diagnosis is:

> Gather evidence first, conclude second; the one who diagnoses does not operate.

## 1. Three Disciplines

### 1.1 Evidence Before Conclusion

Do not guess the root cause before finishing a review of the evidence. It is fine to start with a "root cause hypothesis," but it must be explicitly marked **unconfirmed**, and must remain open to being overturned at any time.

### 1.2 Symptom ≠ Root Cause

The "symptom the user sees" and "the layer where the actual problem lies" must be explicitly distinguished. The point where a symptom surfaces is often only the **victim** — bad data or bad state flows down from upstream and simply happens to become visible here. Patching the victim only treats the symptom.

### 1.3 Every Conclusion Points Back to Evidence

Every claim in a diagnostic report must be traceable back to an actual tool action (a file read, a grep run, a git history check). If a claim cannot be traced back, mark it as **[hypothesis, unconfirmed]** — it must not be disguised as fact.

### 1.4 Beware "Confident Fabrication": More Dangerous Under Context Contamination

The three disciplines above guard against "the agent knows it is uncertain but did not stop to confirm." There is a more insidious failure mode: **the agent does not know it has already gone wrong**.

When the current session's context has already been contaminated (an earlier read pulled in wrong information, a stale cache, leftover state from an old branch), the agent will "coherently" derive a conclusion from this contaminated context that looks plausible but is actually fabricated — especially when external contracts are involved (API paths, field names, enum values for states), the fabricated details tend to resemble the real values rather than being obviously absurd, making them hard to catch by "this feels off."

Countermeasure: for key judgments involving external contracts, do not rely on "synthesizing from accumulated context" to confirm them — a fresh, independent, clean re-verification from the source must be performed. Do not trust accumulated context state, even when it appears logically consistent.

## 2. Six-Dimensional Reconnaissance

For every bug, quickly pass through six dimensions first. Each dimension requires an **actual tool action** with a landed artifact — never work from impression alone:

| Dimension | Action | Artifact |
|---|---|---|
| ① Symptom Confirmation | Restate the bug in your own words, separating symptom from expectation | A one-sentence root cause hypothesis (marked "unconfirmed") |
| ② Locating the Anchor | Search/read the code to confirm the exact location where the symptom surfaces | A file:line anchor (only counts once read) |
| ③ Tracing the Root Cause Upstream | Read upward along the call chain from the anchor | Which layer the bad data/bad state originates from |
| ④ Blast Radius | Grep all callers/consumers of the symbol to be changed | Who the change will affect |
| ⑤ Lateral Siblings | Search for other instances of the same pattern (similar pages/components/functions) | Whether siblings share the same defect / whether a correct reference exists |
| ⑥ Historical Intent | git blame / log on the relevant lines | Why this code ended up looking this way in the first place |

Dimensions ④⑤ are broad-net searches and can be delegated to retrieval-type subagents running in parallel; ②③⑥ stay in the lead context — diagnosis relies on **connecting dots across dimensions into a line**, which cannot be handed off to subagents that cannot see each other.

If a project has already built a **Fact-Base** (see [`10_fact_base_governance.md`](./10_fact_base_governance.md)), go through its triage entry point first, and use it to narrow the search surface for **② Locating the Anchor, ③ Tracing the Root Cause Upstream, and ⑤ Lateral Siblings**: for cross-cutting symptoms, look up the "symptom → mechanism table" to go straight to the root cause layer; for single-point issues, go straight to the component via its handle; for similar instances, find siblings via the reference template — usually one or two greps yields the anchor. What the Fact-Base gives is a lead, not a verdict — it must still be confirmed by reading the code per §1.3; dimensions it does not cover are reconnoitered as usual.

## 3. Adaptive Deep-Dive: Four Trigger Conditions

After reconnaissance, deep-dive into the corresponding dimension whenever any trigger condition is met; if none is met, a light bug stops here — this is the key to being "adaptive": do not pay heavy process cost for simple problems.

| Trigger | Condition | Deep-dive action |
|---|---|---|
| A. Root Cause Not at the Anchor | The symptom point is only the victim; bad data comes from upstream | Trace upward along the call chain layer by layer until finding the layer that **introduced** the bad state; any "fix" before that layer only treats the symptom |
| B. Siblings Exist | Discovered to be one instance of a shared pattern | Read each sibling individually: if they share the defect, the fix must cover all of them; if a correct reference template exists, copy it |
| C. Large Blast Radius | Many callers, widely depended upon | Assess each caller individually for whether it depends on the old behavior; list the call sites that will break |
| D. History Shows It Was Intentional | git history shows this code was added to fix another problem | Clarify the original intent, and assess whether reverting it would **regress** the old bug |

The root cause hypothesis from the reconnaissance stage can be overturned at any point during the deep-dive. Keep deep-diving repeatedly until the **root cause is unique and the evidence loop is closed**.

## 4. Output: Root Cause Analysis + Candidate Solutions

### 4.1 Root Cause Analysis

```text
Symptom: <what the user sees>
Expectation: <what should happen>
Root cause: <the layer where the actual problem lies, down to file:line>
  ↑ Evidence: <which dimension / which read supports it>
Symptom → root cause chain: <one or two sentences explaining the causal chain>
Related surface: blast radius / lateral siblings / historical regression risk (or "none")
```

### 4.2 Candidate Solutions: Multiple Only When a Real Fork Exists

Give 1–3 candidate solutions. **Only give multiple when a real fork actually exists** (a quick fix that treats the symptom vs. a proper refactor that treats the root cause, changing shared logic vs. changing each sibling individually); when there is only one rational path, give just one — do not manufacture false options to pad the list.

For each solution, spell out: the approach, the scope of the change (each item pointing back to a piece of evidence), the trade-off (symptom-level vs. root-cause-level, size of the change), and the risk (new problems that might be introduced, regression points). When there are multiple solutions, give one recommendation with a reason.

### 4.3 Stop and Hand Back the Choice

**The one who diagnoses does not operate.** After presenting the analysis and the solutions, stop, and let the human choose: adopt a solution and proceed into the planning workflow (followed by Plan Review), supply more information and re-diagnose, or continue deep-diving into a particular dimension. Never start work automatically — separating diagnosis from remediation is a structural safeguard against "swinging the hammer you're already holding at whatever looks like a nail."

## 5. Where Diagnostic Artifacts Go

- Diagnostic reports are persisted to the project's plan directory (e.g., `plan/diagnoses/`), serving as **input evidence** for the subsequent planning stage — the plan directly cites the diagnostic evidence, avoiding drift when execution restarts the investigation.
- Sibling defects and historical debt discovered during diagnosis that are not fixed this time are registered as technical debt.
- Root causes of the same kind that recur repeatedly go through rule escalation (see Technical Debt & Lesson Backflow).
- **Escape Recheck ([REVIEW ESCAPE])**: after locating the root cause, follow dimension ⑥ to find **the commit that introduced the root cause**, and check back against the review record from that time — if that commit passed review and this problem was not flagged, append a `[REVIEW ESCAPE]` entry to the review history (one sentence on the root cause + which review it escaped). The learning ratchet must not learn only from "findings that were caught" — escaped samples must be fed into the same recurrence-escalation pipeline (see Technical Debt & Lesson Backflow §7.1); if the corresponding review record cannot be found, skip it — do not force a match.
- The path taken to locate the issue is itself experience: if the Fact-Base does not cover this symptom/term, add a line to the corresponding index (symptom table / journey / negative knowledge, see Fact-Base Governance).

## 6. Diagnostic Checklist

- [ ] Has the bug been restated, with symptom and expectation separated? When the description is vague, was the human asked first, rather than proceeding with ambiguity?
- [ ] Does each of the six dimensions have an actual tool action and artifact?
- [ ] Has the root cause hypothesis been challenged by evidence at least once?
- [ ] Does every conclusion point back to evidence? Are unconfirmed ones marked [hypothesis]?
- [ ] Have the trigger conditions been checked, and were the ones requiring deep-diving actually deep-dived?
- [ ] Are the candidate solutions a real fork, not padding for the sake of numbers?
- [ ] Did it stop at handing back the choice, without going ahead and fixing it?
