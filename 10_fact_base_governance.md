# 10 Fact-Base Governance: Current-State Facts & Triage Entry Points

## Core Definition

The other chapters in the Governance Track govern "rules" and "process": Architectural Invariants define how the system **should** be built, Business Specs define what users **should** be able to do, and plans define what this change is meant to change. There is one type of knowledge asset that is easily overlooked: **what the system's implementation is actually like** — which business term maps to which field, which page maps to which component, and at which layer the root cause of a given symptom lives.

The fact base (`kb`) is where this type of knowledge lives:

> Capture factual knowledge about "what the system actually looks like," so that when AI or a human picks up a bug or a requirement, one or two greps are enough to locate the code — instead of a full scan every time.

Its division of labor with its three neighbors must be drawn clearly first (see also [`01_上层定法.md`](./01_upper_level_rules.md) ("Upper-Level Rules") §2 on the distinction between plans and Specs):

| Asset | Question It Answers | Nature |
|-|-|-|
| Plan / openspec | What to change this time | Change stream |
| Business Spec | What users should be able to do, how the system should behave | Prescribed current state |
| Working conventions / skill | How code should be written, how process should run | Operational convention |
| **Fact base** | What the implementation actually looks like, how a symptom traces to code | **Descriptive current state** |

The fact base holds only facts: plans and conventions do not belong here, nor do unverified guesses — guesses belong in plan-track discussion, and only enter the fact base once confirmed.

## 1. Why It Deserves Dedicated Governance

In Diagnostic Methodology (see [`05_诊断方法论.md`](./05_diagnostics.md)), Dimension ②, "locating the anchor," is a cost every bug has to pay. Without a fact base:

- AI greps from zero every time, reading an entire directory just to find one button;
- The same class of bug is relocated from scratch every time, the same path is repurchased over and over;
- New sessions, new hires, and new agents each grope through the same mechanism again;
- Worse still, "not found" gets mistaken for "does not exist," or a leftover resource gets mistaken for a live feature.

What the fact base does is turn this kind of **repeated reconnaissance** into an asset: diagnosis looks something up once, and the fact base fixes the lookup path in place. It is the flip side of the same ledger as Context Governance (see [`02_上下文治理.md`](./02_context_governance.md)) — Chapter 02 governs "how rules reach AI at low cost," this chapter governs "how facts reach AI at low cost."

## 2. Ownership Rules: Knowledge Follows What It Describes

- **Facts belonging to a single repository go into that repository's own `kb/` directory**: committed alongside the code, available on clone, naturally version-matched with the code — "update it in passing while changing code" is zero-friction only within the same repository.
- Only knowledge for which "placing it in any single repository would be wrong" gets externalized:
  - **Cross-branch**: one repository whose multiple branches carry multiple distinct systems — facts are divided by branch, and placing them in any one branch would mislead the others;
  - **Cross-repository sharing**: product-line terminology and cross-repository protocols shared across multiple repositories.
- The test, in one sentence:

> Externalization is allowed only when writing this knowledge into any single repository would put it "in the wrong place."

- New projects copy their skeleton from a unified template; category file names are **never renamed** across projects (see §4), so switching projects costs zero learning.

## 3. Entry-Point Design: The README Is a Triage Router, Not a File List

The most common failure of a fact base is not incorrect content but a broken entry point: a README written as a file list ("This directory contains the following documents...") is equivalent to demanding the reader read everything — turning the knowledge base into a fixed reading tax on every task (Case Library #25).

The correct form of an entry point is **triage**.

### 3.1 The First Triage Cut

When a bug comes in, ask first: **would this also happen on a different page / module?**

- **Yes → cross-cutting class**: the root cause is in a shared mechanism at some layer; one fix covers every page, and looking for a specific page first is actually a detour → go to Axis One.
- **Only here → single-point class**: a specific feature behaves unexpectedly; you need to locate the component first → go to Axis Two.

### 3.2 Axis One: Symptom → Mechanism Table

| Column | Purpose |
|-|-|
| Symptom | Described in the user's own language (garbled export / frequent forced logout / wrong copy) |
| Root-cause layer | Request layer / auth / i18n / permissions ... straight to the layer |
| Specific location | file:line, **must be grep-verified** |
| Scope | **Single global spot** (go fix it directly) / **per-page pattern** (still needs Axis Two to locate the page) |

The "Scope" column is the governance-critical part of this table: writing up a rule that only holds in one place as if it were a global mechanism sends the fix to the wrong layer and drags in innocent bystanders (Case Library #26).

### 3.3 Axis Two: Ordering by "Handle," Cheapest First

Order the locating techniques by the clue given in the bug description; the earlier ones are cheaper:

1. **UI copy** (button label / prompt text) → a two-hop grep: get the key from the language pack → locate the component from the key; with no i18n, the literal string is a one-hop grep.
2. **An action / a flow / cross-page interaction** → user journeys (`user-journeys`).
3. **Only a business term** → domain glossary (`domain-glossary`).
4. **A known route / page path** → code map (`code-map`).
5. None of the above hit → fall back to a repository-wide grep, or follow the journey dependency chain.

Two hard rules:

- Every grep path written into the entry point must be **verified against a real case** before it is written down, with an example attached — an unverified locating path is a false fact.
- The entry point must explicitly state a counter-instruction: "**do not read the entire document before acting**" — that is exactly the full-scan behavior the fact base exists to eliminate.

This entry-point design is, in essence, an application of the Required-Reading Matrix idea (see [`02_上下文治理.md`](./02_context_governance.md) §4) at the fact layer: routing by task characteristics rather than loading everything.

## 4. Document Structure: A Fixed Set of Four + Fixed File Names

| File | Covers | Guards Against |
|-|-|-|
| `architecture` | Tech stack / module breakdown / key mechanism details (the Axis One symptom table is expanded here) | Mechanisms scattered everywhere |
| `code-map` | Master index of route ↔ component ↔ API + naming pitfalls | "Can't guess the location from the term" |
| `domain-glossary` | Business terms → fields / enums / modules | Terms disconnected from code |
| `user-journeys` | Named business closed loops + per-step action → method name | Action locating and cross-page dependencies having nowhere to be looked up |

- **File names are kept identical across projects, never renamed**: the governance value lies in mental-model consistency — every project's fact base looks the same, so neither humans nor AI need to relearn the structure when switching projects.
- The reason `user-journeys` is its own file: **action locating** (describing an action → method name) and **cross-page data dependency** (configuring A but B doesn't take effect) are two classes of clue that no other index structurally covers.
- `user-journeys` must guard against bloat, with four boundaries:
  1. Only include "named business closed loops" (test: would a PM give this flow a name?);
  2. Cap the count (roughly 5–15 entries);
  3. Record only step order + key branches; function-level detail belongs in `code-map` / `domain-glossary`;
  4. Exclude exceptions / edge cases / A-B branches; keep only the happy path plus at most 1–2 key decision branches.

## 5. Evidence Discipline and Trustworthiness

The fact base's trustworthiness is maintained by three layers of mechanism:

- **Entry threshold**: write only verified facts. file:line must be grep-verified; method names must be individually confirmed to actually exist; anything derived only by structural inference without being individually expanded must be honestly labeled as such, not passed off as fully verified.
- **Make uncertainty explicit**: anything that cannot be verified (e.g., a route dynamically issued by the backend) is marked "to be confirmed," together with a trustworthy alternative anchor (if the component file path is reliable, use that instead) — do not let one unconfirmed field drag down the usability of the whole index.
- **Freshness mechanism**: every document's header states `applicable scope + last-verified date`; when citing it, judge trustworthiness by the last-verified date, and re-check before trusting anything stale. **When changing code, if the fact base is found stale or missing → update it in passing; changing code without updating the fact base = the change is not done** (the same discipline as documentation sync, see [`07_工具链治理.md`](./07_toolchain_governance.md) §1.1).

## 6. Negative Knowledge: Confirming Non-Existence Is Also an Asset

The fact base should include a section titled "**Features confirmed, upon investigation, not to exist**":

- Record the conclusion + **the investigation basis** (which keywords were searched, which directories were examined);
- Value one: prevents repeated searching — an investigation that isn't recorded gets repurchased at full price by the next session (Case Library #27);
- Value two: prevents mistaking existence — leftover resources (dead i18n keys, stale config) make AI believe a feature exists; negative knowledge is the antidote (see also Case Library #11 on mocks, and Technical Debt & Lesson Backflow §8.2 on dead keys);
- Negative knowledge also needs a last-verified date: "does not exist" can also go stale (it may have been added later).
- **Falsify blocking conclusions before trusting them**: the mirror-image risk of negative knowledge — conclusions in code comments or old ledgers such as "cannot be done / blocked on an external dependency / pending a third party" are the facts most prone to going stale (the hook may have since been wired up, a precedent may have since appeared). Before acting, check current status in a fixed order: the contract registry → precedent within the same repository (has another module already gotten this working against the same dependency?) → existing patterns (does the project's conventions provide a default value / fallback path?); only after all three checks still show a block should it be classified as blocked — if a hook is found, proceed directly. Copying an old conclusion and standing pat is equivalent to treating negative knowledge as a free pass (Case Library #30).

## 7. Population and Verification: Save Money on Retrieval, Preserve Quality in Verification

Building or filling in the fact base is a typical batch task, applying the model economics of the Execution Layer (see [`03_下层执行.md`](./03_execution.md) §5.4):

- **Cast a wide net on retrieval**: multiple downgraded-model, retrieval-type subagents scout in parallel (scanning routes, mechanisms, terminology, journeys), producing candidate facts;
- **Never downgrade the verifier**: the verifier's job is to **falsify** — grep-verify file:line entry by entry, actually run the entry-point examples end to end, check the Scope column (single global spot or per-page pattern) — anything unverified does not get finalized;
- With multiple targets (multiple repos / branches / brands), split verifiers per target and run them in parallel; retrieval results are never mixed across targets.

Every finalized fact should be able to answer "which tool action backs it up" — the same discipline as the evidence back-reference in diagnosis (see Diagnostic Methodology §1.3).

## 8. Closing the Loop with Diagnosis

The fact base and Diagnostic Methodology are mutual supply and demand:

- **Diagnosis consumes the fact base**: Dimensions ① and ② of the six-dimension reconnaissance go through the triage entry point first; a hit yields the anchor in one or two greps;
- **Diagnosis feeds back into the fact base**: at the close of every diagnosis, ask one question — did the fact base cover this locating path? If not, add the symptom row / journey / negative knowledge. This is the concrete channel through which Lesson Backflow (see [`06_技术债与经验回流.md`](./06_tech_debt_and_lesson_backflow.md)) operates on "locating-type facts."

## 9. Fact-Base Governance Checklist

- [ ] Only verified facts? Do plans, conventions, and guesses each go back to their own home?

- [ ] Does every document's header have an applicable scope + last-verified date?

- [ ] Is ownership correct: single-repository knowledge in that repository's `kb/`, and anything externalized genuinely cross-branch / cross-repository?

- [ ] Is the entry point a triage router rather than a file list? Does it carry an explicit counter-instruction against reading everything?

- [ ] Does the symptom table have a "Scope" column distinguishing single global spot / per-page pattern?

- [ ] Have all locating paths written into the entry point been verified against real cases?

- [ ] Are to-be-confirmed items marked, with an alternative anchor given?

- [ ] Is there a negative-knowledge section (conclusion + investigation basis)?

- [ ] Do file names match the template, with no ad hoc naming?

- [ ] Does "update the fact base in passing while changing code" have an enforcement point (review checklist)?
