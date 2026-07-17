# 01 Upper-Level Rules: Architectural Invariants, Business Specs & Source-of-Truth Governance

## Core Definition

Upper-Level Rules establish the "source of law" and "adjudication authority" for AI collaboration.

They are not responsible for hard-coding every project detail. Instead, they answer:

- What are the project's stable rules?
- What must not be casually altered by a task?
- Where does the current state of business capabilities live?
- When materials conflict, who has the final say?
- When AI is uncertain, should it stop or is inference allowed?
- Which layer should new experience be consolidated into?

The key to Upper-Level Rules is:

> The upper layer does not manage every detail, but it must hold adjudication authority.

## 1. Architectural Invariants: The Project's Constitution

### 1.1 What Is an Architectural Invariant

An architectural invariant is an engineering rule that holds true for the project over the long term.

It is not a plan for a single requirement, nor a historical record — it is a constraint currently in force.

It defines:

- How many layers the system has
- The direction of dependencies
- Where the unified entry points are
- How data and state flow
- Who manages foundational capabilities such as errors, permissions, logging, analytics, networking, and UI
- Which practices are permanently forbidden

### 1.2 Why AI Needs Architectural Invariants

AI is very good at local completion, but locally reasonable does not mean globally correct.

Without architectural invariants, AI will, in order to complete the task at hand:

- Call APIs directly from within pages
- Bypass unified error handling
- Stuff server-side state into a UI store
- Invent a new component system
- Copy an existing piece of logic
- Modify a shared contract to fix a single bug

Each of these changes may individually "work," but they steadily erode the project's structure.

### 1.3 Typical Types of Invariants

| Type | Purpose | Example |
|---|---|---|
| Layering invariant | Specifies module dependency direction | Pages may only depend on business models; they may not call APIs directly, bypassing the model |
| Data-flow invariant | Specifies data ownership | Server-side data belongs to Query / Repository; local UI state belongs to the Store |
| Entry-point invariant | Specifies unified encapsulation | Networking, bridging, permissions, logging, and amount formatting must go through a unified entry point |
| Contract invariant | Specifies cross-platform or cross-module protocols | Bridge handler names, response envelopes, and error-code semantics are unified |
| Design invariant | Specifies the visual system | Business code must not hard-code raw colors; it must consume tokens |
| Quality invariant | Specifies the validation baseline | Pure logic must be tested; test names and assertions must be consistent |
| Security invariant | Specifies high-risk actions | `git push`, deletion, merging, and releases require human confirmation or approval workflows; certain engineering file formats can only be reliably written by official GUI tools (e.g., specific versions of native project configuration files) — AI should be excluded from writing to these, with its role downgraded to generating operational steps plus post-hoc read-only verification |

### 1.4 Governance Principles for Invariants

Architectural invariants must satisfy:

- **Current state**: reading it tells you what the rules are right now.
- **Stability**: it does not change casually for a single task.
- **Referenceability**: plans and reviews can cite it explicitly.
- **Checkability**: automate where possible; where not possible, add it to the review checklist.
- **Non-self-modifiability**: AI must not simultaneously violate a rule and rewrite the rule to permit its own violation.

### 1.5 Rules for Modifying Invariants

Invariants are not permanently unchangeable — but they must not be changed "in passing."

If a modification is genuinely needed, it should go through a separate rule-change process:

1. Explain where the existing invariant no longer applies.
2. Explain what problem the new rule solves.
3. Explain which modules and legacy implementations are affected.
4. Explain the migration approach and compatibility strategy.
5. Only change it after a plan review.

### 1.6 When a Human Demands a Violation of an Invariant: Refuse the Means, Not the End

The adversary of invariants is not only AI drift, but also people impatient with process: "just tweak this color directly," "hand-edit the generated output to save time." In this situation, AI's correct behavior is neither compliance nor a flat "no":

- **Refuse the means**: do not execute the change that violates the invariant; state which rule it violates.
- **Proactively offer an equivalent path through the proper channel**: explain how to achieve the same effect through the proper channel, and whether to do it now.

The product of a refusal is an "alternative path," not a "no." A guardrail that only says no ends with the human bypassing AI and editing by hand — and every guardrail fails together. So this rule requires dual-layer enforcement: AI handles it as described above (governing "changes that go through AI"), while a mechanical layer adds a minimal gate (e.g., a pre-commit check, governing "changes that bypass AI"; see Toolchain Governance §2 for the enforcement hierarchy).

Example phrasing:

> "Changing the style directly violates the project's hard rule (no literal colors / generated output must not be hand-edited), so I won't do that. But you can achieve the effect you want this way: modify the corresponding token in the design source → regenerate → it takes effect site-wide in one pass. Want me to do that now?"

## 2. Business Specs: The Current State of User Capabilities

### 2.1 The Difference Between Plans and Specs

A plan is a change stream; a spec is the current state.

| Document | Question it answers | Lifecycle |
|---|---|---|
| Plan | What to change this time, how to change it, how to accept it | One task |
| Business Spec | What users can currently do, how the system should behave | Long-lived |
| Review record | What issue was found this time, how it was handled | Historical evidence |
| Technical debt | What known issues are deferred, when they'll be paid down | Open ledger |
| Fact base | What the implementation actually looks like (business language → code location) | Long-lived, verified against code as it evolves (see [`10_事实库治理.md`](./10_fact_base_governance.md)) |

If a project has only plans and no spec, AI can only guess the current state from historical plans next time.

This leads to:

- Completed plans continuing to be treated as pending work
- Deprecated approaches continuing to be referenced
- Multiple plans conflicting with each other
- Current behavior only inferable by reverse-engineering the code

### 2.2 What a Business Spec Should Contain

A Business Spec governs "user capabilities," not underlying architectural implementation.

It should describe:

- What the user sees in which state
- What actions can be performed
- What happens after an action succeeds
- How failure, cancellation, empty states, and exceptions are handled
- What the permissions, gating, and state machines are
- What contracts exist with external interfaces or systems
- Which behaviors are intentional simplifications, and which are technical debt to be addressed

WHEN / THEN format works well:

```text
WHEN the user is under review
THEN the home page shows a pending-review state
AND the primary button cannot initiate a new application
AND the countdown ending triggers a status refresh
```

### 2.3 When to Consolidate into a Business Spec

After a task is complete, judge whether the result should be merged into the spec.

Should be merged in:

- Changes to user-visible capabilities
- State machine changes
- Gating rule changes
- Interface contract changes
- Error-handling strategy changes
- Cross-page flow changes

May not need to be merged in:

- One-off implementation details
- Temporary debugging approaches
- Local refactoring process
- Archived historical debates

## 3. Source-of-Truth Governance: Who Manages What

### 3.1 Why Source-of-Truth Governance Is Needed

The most dangerous thing when AI faces multiple materials is not "failing to read them" — it's "reading them but applying them wrong."

Common mistakes:

- Using a visual mockup to judge whether a feature exists.
- Using API documentation to override actual live requests.
- Using mock data to infer a backend contract.
- Using old code to override a new architecture.
- Using a temporary decision from some conversation to override a stable rule.
- Applying Project A's experience directly to Project B.

Hence the rule:

> Each source of truth only has authority within its own dimension.

### 3.2 Common Types of Sources of Truth

| Source type | What it governs | What it does not govern |
|---|---|---|
| Architecture source | Layering, dependencies, technical boundaries, infrastructure | Does not determine whether a business feature exists |
| Business source | User behavior, flows, state machines, validation | Does not determine visual pixel details |
| Visual source | Layout, dimensions, colors, icons, interaction appearance | Does not determine feature existence |
| Contract source | API fields, status codes, data shapes | Does not override runtime facts |
| Runtime-fact source | Actual live requests, actual responses, actual client-side behavior | Does not automatically overturn architectural rules |
| Historical-decision source | Why something was done this way, what pitfalls were previously hit | Does not override the latest explicit decision |
| Immediate user instruction | This task's goal, priority, and boundaries | Should not silently rewrite long-term rules |

### 3.3 Steps for Adjudicating Conflicts

When sources conflict, do not directly ask "which one is more credible" — instead, adjudicate step by step:

1. First determine which dimension the conflict occurs in.
2. Find the authoritative source for that dimension.
3. Determine whether a higher-level rule exists.
4. Determine whether there is measured runtime fact.
5. If it still cannot be adjudicated, flag it as blocked and ask — do not fill in the gap by guessing.

Examples:

- The mockup does not draw a certain button, but the business source shows the feature exists: keep the feature, log the visual gap.
- The API documentation says a field is a string, but the actual response is a number: fix the contract per the actual response, log the documentation discrepancy.
- Old code calls the API directly, but the architectural invariant requires a unified API layer: rewrite per the architectural invariant, do not copy the old bad pattern.

### 3.4 Source-of-Truth Declaration Template

Every complex plan should declare:

```md
## Sources of Truth

- Architectural constraints:
- Business behavior:
- Visual experience:
- API contract:
- Runtime facts:
- Historical decisions:

## Conflict Adjudication

- Structural/technical conflicts:
- Product behavior conflicts:
- Visual conflicts:
- API path/method conflicts:
- Field type/nullability conflicts:
- Live-environment fact conflicts:
```

### 3.5 Sources of Truth Flip: Phase Transitions Require Explicit Re-Declaration

The source-of-truth hierarchy is not a project constant — it is a **phase variable**. In the same repository, "who has the final say" can flip wholesale at different phases.

A real-world specimen: during the prototype-replication phase, logic truth = legacy implementation (copy its behavior), visual reference = design mockup; after the project is handed off to the product team for iteration per PRD, logic truth flips to the PRD, and the legacy implementation and design mockup both drop to historical reference simultaneously.

Typical phase transitions that trigger a flip: replication/migration completion, handoff to another role, fork governance splits (see Migration & Rewrite Governance), and the accumulation of live-environment facts after launch.

Rules:

- **A flip must be explicitly declared**: rewrite the source-of-truth declaration in the project constitution (the §3.4 template), noting the effective date and where the old tier goes (demoted to historical reference / archived) — do not let the new tier "emerge naturally."
- **The cost of not declaring it**: AI keeps working off the old tier — using a retired legacy implementation to overrule behavior from the new source of truth, or vice versa.
- **Derivative documents must convert accordingly**: records written against the old truth (e.g., page-by-page logic records) must, at the flip, either be updated to record the new truth or be explicitly marked read-only — otherwise they rot into stale comments and become the next round's source of misdirection.
- **A flip is a wholesale event**: when one category of truth changes hands, check every line of the source-of-truth declaration — usually more than one line is affected.

## 4. Separating Constraint Sources from Change Streams

### 4.1 Why They Must Be Separated

Constraint sources and change streams have different lifecycles.

| Type | Nature | Goal |
|---|---|---|
| Constraint source | Current state, stable, long-lived | Lets AI know what the rules are now |
| Change stream | One-off, procedural, task-related | Lets AI know what to change this time |

If mixed together:

- Architectural rules get drowned out by a requirements log.
- Historical plans get mistaken for current rules.
- AI looks for justification in stale documents.
- The upper-level law gets polluted in reverse by lower-level tasks.

### 4.2 What Belongs in Constraint Sources

Suitable for constraint sources:

- Architectural layering
- Directory conventions
- Dependency direction
- Technology choices
- Data-flow rules
- Testing strategy
- Security boundaries
- Cross-platform contracts
- Review process

### 4.3 What Belongs in Change Streams

Suitable for change streams:

- This task's requirement goal
- This task's scope
- This task's risk analysis
- This task's batch decomposition plan
- This task's acceptance checklist
- This task's open questions

### 4.4 Handling Gray Areas

Some tasks change both business behavior and underlying constraints.

Handling approach:

1. Enter through the business change.
2. Explicitly state in the plan which constraint sources will be affected.
3. List risks and acceptance criteria separately for the constraint-source change.
4. Review both the business change and the constraint change together.
5. Once complete, merge the stable result into the current-state document.

A supporting write discipline: **writing to a constraint source requires an explicit authorization gate** — temporary consensus reached during solution discussion is not written directly into the constitution / architecture docs; it is merged in one pass only once a human explicitly says "write it in / land it." This does not contradict "record conversation conclusions promptly" (see Context Governance §7): plans and decisions should be recorded frequently, **but writing to the constitution requires a gate** — the former guards against forgetting, the latter guards against the discussion process polluting the constraint source.

### 4.5 Rule Tiers: Global Rules, Project Rules, Engineering Constitution, Business Change Stream

Upper-Level Rules cannot be solved by a single file.

A mature project has at least four types of rule sources:

| Tier | Governs | Typical carrier | Stability |
|---|---|---|---|
| Global working rules | How AI collaborates, plans, reviews, and delivers | Global AGENTS / CLAUDE / skill | High |
| Project working rules | This project's directories, naming, commands, forbidden patterns | Project AGENTS / CLAUDE | Medium-high |
| Engineering constitution | How the system is built, architectural invariants, technical boundaries | specs / architecture docs | High |
| Business change stream | What users can do, what this iteration changes | openspec / proposal / tasks | Medium-low |

These four tiers must not be blended into one.

For the **loading cost** and slimming discipline of each tier — what belongs in always-loaded context versus what gets consolidated into a dedicated document with a pointer, and how required-reading documents are routed by task — see [`02_上下文治理.md`](./02_context_governance.md).

Global rules solve "how AI and humans collaborate."

Project rules solve "how this project runs."

The engineering constitution solves "what structure the code should exist in."

The business change stream solves "how user capability changes this time."

### 4.6 The Division of Labor Between specs and openspec

A portable mnemonic:

> `specs` governs how the system is built; `openspec` governs what users can do.

`specs/` is suited to carrying:

- Layered architecture
- Module boundaries
- Naming rules
- Forbidden APIs
- Design tokens
- Routing rules
- Data-flow constraints
- Testing strategy

`openspec/` is suited to carrying:

- A single business change
- proposal
- design
- spec delta
- tasks
- archive

If business iterations are all stuffed into the engineering constitution, the constitution turns into a running log.

If long-term architectural rules are stuffed into one business change after another, the currently valid rules end up scattered across historical archives.

So the two must be kept separate.

### 4.7 The Order of Precedence for Adjudicating Rule Conflicts

When multiple rule sources conflict, adjudication must be explicit.

Recommended order:

```text
The user's explicit instruction for this task
  > Decisions already confirmed for the current task
  > Project-level AGENTS / CLAUDE
  > The project's engineering constitution (specs)
  > The current business spec / openspec
  > The default workflow in global AGENTS / CLAUDE
  > Historical plans / stale documents / guesswork based on experience
```

This does not mean global rules do not matter.

Global rules define the default mode of collaboration; project rules define the specific boundaries of the current project; the user's instruction for this task can temporarily override them, but this should be explicitly recorded in the plan or review.

### 4.8 Business-Driven Infrastructure Changes

A common gray area in practice:

> A business requirement necessitates upgrading engineering infrastructure along the way.

For example:

- A new feature requires extending the networking layer.
- A new page requires a new navigation pattern.
- A new state requires changing the caching strategy.

Handling approach:

1. Still enter through the business change.
2. List the accompanying infrastructure change in the design or plan.
3. Explain risk and acceptance criteria separately for the infrastructure change.
4. `change-review` reviews both business completeness and architectural consistency at once.
5. Once stable, merge the infrastructure rule into the engineering constitution.

This way, business needs can drive infrastructure evolution, but cannot quietly pollute the constraint source.

## 5. The Knowledge Hub: Naming the Hub, Governing Bottom-Up from the Top

### 5.1 What the Hub Is Not

The hub is not:

- A dumping ground for all documents
- An encyclopedia of project details
- A complete historical record
- A substitute for a code index
- A junk drawer for temporary plans

### 5.2 What the Hub Is

The hub is a router and an adjudication index.

It tells AI:

- Where the architectural invariants are
- Where the business specs are
- Where the current active plan is
- Where technical debt is
- Where review history is
- How sources of truth are adjudicated
- Which layer new experience should be consolidated into

### 5.3 The Minimal Structure of a Hub

A project's hub should at minimum contain:

```text
README / INDEX
  - Current project positioning
  - Document tiers
  - Source-of-truth table
  - active plan
  - durable spec
  - fact kb (fact base)
  - technical debt
  - review history
  - workflow
```

### 5.4 What "Governing Bottom-Up from the Top" Actually Means

"Governing bottom-up from the top" does not mean the upper layer hard-codes every practice for the lower layer. Rather:

- The upper layer defines adjudication authority.
- The lower layer executes according to that adjudication authority.
- The lower layer can escalate newly discovered facts.
- The lower layer cannot unilaterally overturn the upper layer.
- If it needs to be overturned, it must go through a rule change.

In one sentence:

> The upper layer sets the boundaries, the lower layer implements; the upper layer sets the source of law, the lower layer finds the facts; the upper layer sets the process, the lower layer runs the tasks.

## 6. How Upper-Level Rules Become Executable Capability

If upper-level rules only ever remain in documents, they ultimately still depend on AI's self-discipline.

A more reliable path is:

```text
Rule text
  → checklist
  → skill / workflow
  → script / lint / CI
  → execution gate
```

For example:

- "Plans must be reviewed" should become the `plan-review` skill.
- "Changes must be reviewed after the fact" should become the `change-review` skill.
- "No raw/literal values" should become a lint or grep check.
- "Comment references must actually exist" should become a pre-commit self-check.
- "Recurring issues found in review should be escalated into a rule" should become history analysis.

In one sentence:

> Documents set the law, workflows enforce the law, gates verify the law, history amends the law.

For the complete hierarchy table of "who enforces each tier, and whether the agent can bypass it," as well as the engineering discipline of the tracks themselves (skill / workflow / gate), see [`07_工具链治理.md`](./07_toolchain_governance.md).

## 7. Checklist for Upper-Level Rules

When starting a new project or restructuring project governance, ask first:

- Are there architectural invariants?
- Is there a business spec?
- Are global rules, project rules, the engineering constitution, and the business change stream distinguished from each other?
- Are the current state and historical plans distinguished from each other?
- Have the types of sources of truth been defined?
- Has conflict adjudication been defined?
- Has the order of precedence for rule-conflict adjudication been defined?
- Is there a technical-debt ledger?
- Is there review history?
- Is there a lesson-backflow path?
- Is it clear which upper-level rules AI must not modify on its own?
- Is there a hub index that lets AI quickly locate these materials?

If these questions cannot be answered, the deeper AI's involvement, the higher the risk.
