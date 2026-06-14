# Stage 2: Task Breakdown

**Purpose:** Transform a spike document and module scope into a detailed, granular task list with dependencies, sub-checkpoints, and clear sequencing.

**Input:** Spike document, module scope, codebase analysis (from Stages 1 and 3)

**Output:** Structured task breakdown with atomic tasks, dependencies, sub-checkpoints, and effort estimates

---

## Stage 1: Intake & Clarification

You are receiving a spike document that describes what needs to be built. Your first task is to ensure you understand the full scope and context.

Read the spike document carefully and extract:
- **What is the main feature/epic?**
- **What are the success criteria?**
- **Which modules are in scope?**
- **Are there any technical constraints or concerns flagged?**
- **What existing code patterns should we follow?**

Check for gaps or ambiguities. If something is unclear, ask clarifying questions:
- "The spike mentions 'payment integration' — should we also build refund handling, or is that Phase 2?"
- "For the cart feature, should abandoned carts be auto-cleared after X days?"
- "Do we need backwards compatibility with the old API, or can we deprecate it?"

Ask 1-3 targeted questions based on complexity. After the user answers, update your understanding internally.

---

## Stage 2: Identify Natural Boundaries

The key to good task breakdown is identifying the natural boundaries — where one logical unit ends and another begins.

Read the spike document and ask yourself:
- **What are the distinct phases or workflows described?**
- **Are there clear entry and exit points?**
- **What depends on what?**
- **Are there independent workstreams that could run in parallel?**

Example (e-commerce cart):
- Phase 1: Cart data model & basic CRUD
- Phase 2: Add/remove items with business logic
- Phase 3: Checkout workflow
- Phase 4: Payment integration
- Phase 5: Order creation & persistence

Ask the user: "Based on the spike document, I'm seeing [X phases/boundaries]. Do you agree, or should we group/split differently?"

Once boundaries are confirmed, each boundary becomes a **major task or epic**. Within each, there are **subtasks**.

---

## Stage 3: Break Down into Atomic Tasks

For each major task/boundary, break it into **atomic, actionable tasks**. A task should:
- Be completable by one developer in 1-3 days
- Have a clear acceptance criterion
- Not depend on too many other tasks
- Be testable in isolation (where possible)

Format each task as:

```text
Task ID: T-[Feature]-[Number]
Title: [Clear, action-oriented title]
Description: [What needs to be done, in 1-2 sentences]
Acceptance Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3
Dependencies: [List of task IDs this depends on, or "None"]
Estimated Effort: [1-3 days, be realistic]
Test Requirements: [What tests must pass]
Sub-tasks: [Any nested tasks, or "None"]
```

If a task can't realistically fit in 1-3 days, split it into sub-tasks (e.g., `T-CART-006-A`, `T-CART-006-B`) under the same parent Task ID.

---

## Stage 4: Map Dependencies & Identify Parallelism

Create a dependency graph to show:
- Which tasks **must run sequentially** (blocking)
- Which tasks **can run in parallel** (independent)

Example visualization:

```text
T-CART-001 (Schema)
    |
    v
T-CART-002 (Endpoints) --> T-CART-003 (Add Logic)  <- can run in parallel
                       \--> T-CART-004 (Remove Logic)
    |
    v
T-CART-005 (Checkout)
    |
    v
T-CART-006 (Payment)
    |
    v
T-CART-007 (Order)
    |
    v
T-CART-008 (Tests & Docs)
```

**Critical path:** The longest sequence determines the overall timeline.

Ask the user: "Based on these dependencies, do you want to parallelize anything? For example, could T-CART-003 and T-CART-004 run in parallel since they both depend on T-CART-002?"

---

## Stage 5: Identify Sub-Checkpoints

A **sub-checkpoint** is a natural gate within the feature where you verify progress before moving forward. Sub-checkpoints are labeled with letters (A, B, C, ...) and assigned to the task after which they occur.

For the cart example:
- **Checkpoint A (after T-CART-002):** Basic CRUD works, can add/remove items
- **Checkpoint B (after T-CART-005):** Cart logic and checkout flow complete
- **Checkpoint C (after T-CART-006):** Payment integration working
- **Checkpoint D (final):** Full workflow tested and documented

Ask the user: "After which tasks should we pause and validate before continuing? Where are the natural quality gates?"

---

## Stage 6: Estimate Effort & Set Timeline

Sum up effort estimates across all tasks:

```text
T-CART-001: 1 day
T-CART-002: 2 days
T-CART-003: 1.5 days (parallel with 002's dependents)
T-CART-004: 1 day   (parallel with 003)
T-CART-005: 2 days
T-CART-006: 2.5 days
T-CART-007: 2 days
T-CART-008: 1.5 days

Sequential timeline: ~13.5 days
With parallelism:    ~10 days (if T-003 & T-004 run together)
```

Ask the user: "Is [X] days realistic given your team size and current bandwidth?"

---

## Stage 7: Task Breakdown Document Assembly

Compile the final task breakdown using [`../../templates/TASK-BREAKDOWN-TEMPLATE.md`](../../templates/TASK-BREAKDOWN-TEMPLATE.md), with these sections:

- **Overview:** Brief summary of what's being built and why, from the spike
- **Task List:** All tasks, each with Task ID, Title, Description, Acceptance Criteria, Dependencies, Estimated Effort, Test Requirements, Sub-tasks, and assigned Sub-Checkpoint letter
- **Dependency Graph:** ASCII visualization showing the critical path and any parallel branches
- **Sub-Checkpoints:** Each lettered checkpoint with its own verification checklist
- **Timeline Estimate:** Sequential total, parallelized total, and the critical path (list of blocking tasks)
- **Testing Strategy (per task):** framework, minimum coverage targets, integration test scope, common edge cases
- **Notes:** Special considerations, risks, assumptions (e.g., highest-risk tasks, deferred scope)

---

## Stage 8: Handoff Checklist

Before finalizing, confirm:

- [ ] All tasks are atomic and clear
- [ ] Dependencies are accurately mapped
- [ ] Sub-checkpoints are identified
- [ ] Effort estimates are realistic
- [ ] Testing requirements are specified for each task
- [ ] Timeline is acceptable
- [ ] User has reviewed and approved

Ask: "Does this task breakdown look complete and actionable? Any changes before we move to Codebase Analysis?"

If the user says "no, let me revise," loop back to Stage 2 or Stage 3.

If the user says "yes," this is **Checkpoint 2** of the workflow. They approve and we move to **Stage 3: Codebase Analyzer**.

---

## Instructions for Use

**As a standalone prompt:**
1. User provides spike document
2. Work through Stages 1-8 sequentially
3. Generate the final Task Breakdown document
4. Ask: "Are you happy with this task breakdown? Any changes before proceeding to Codebase Analysis?"

**As part of the master workflow:**
1. Receive spike document from Stage 1
2. Work through Stages 1-8
3. Output the task breakdown
4. Transition to [`03-CODEBASE-ANALYZER.md`](03-CODEBASE-ANALYZER.md)

---

## Key Principles

1. **Atomic tasks** — each task is a single, testable unit
2. **Clear dependencies** — no ambiguity about ordering
3. **Realistic estimates** — account for testing and review
4. **Sub-checkpoints** — natural quality gates within the feature
5. **Parallel where possible** — reduce timeline without sacrificing quality
6. **Test-first thinking** — each task includes test requirements

## Output

Save as `[feature]-tasks.md` if running standalone. When run as part of the master workflow, this — along with the module scope from Stage 1 — becomes the input to [`03-CODEBASE-ANALYZER.md`](03-CODEBASE-ANALYZER.md). A full worked example is in [`../../examples/ecommerce-cart-example/03-TASK-BREAKDOWN.md`](../../examples/ecommerce-cart-example/03-TASK-BREAKDOWN.md).
