# Example: E-Commerce Shopping Cart Feature

This is a complete worked example of the Backend Development Automation Workflow, applied to a realistic feature: **adding shopping cart functionality to an existing e-commerce platform**.

It walks through all 8 stages, showing the actual output produced at each step, so you can see how context flows from one stage to the next and what "good" output looks like.

## The Feature

The platform already has `User`, `Product`, and `Order` modules. It does not yet have a `Cart` — customers can only place an order directly. Product wants customers to be able to add multiple items to a cart over time, then check out, with a payment integration added in a later phase.

## Walkthrough

| Stage | File | What It Shows |
|-------|------|-----------------|
| 0 | [`01-PROBLEM-STATEMENT.md`](01-PROBLEM-STATEMENT.md) | The raw, initial problem statement as given to the workflow |
| 1 | [`02-SPIKE-DOCUMENT.md`](02-SPIKE-DOCUMENT.md) | The resulting spike document — refined problem, module scope, technical concerns |
| 2 | [`03-TASK-BREAKDOWN.md`](03-TASK-BREAKDOWN.md) | The task list derived from the spike document |
| 3 | [`04-CODEBASE-ANALYSIS.md`](04-CODEBASE-ANALYSIS.md) | The codebase analysis for the in-scope modules |
| 4 | [`05-GENERATED-PROMPTS.md`](05-GENERATED-PROMPTS.md) | Execution prompts generated for Task 1 |
| 5 | [`06-CODE-OUTPUT.md`](06-CODE-OUTPUT.md) | The code generated from those prompts |
| 6 | [`07-TEST-RESULTS.md`](07-TEST-RESULTS.md) | Test results for the generated code |
| 7/8 | [`08-FINAL-VERIFICATION.md`](08-FINAL-VERIFICATION.md) | Self-verification report and final business logic approval |

## How to Use This Example

If you're new to the workflow, read through these files in order — they show a realistic (if abbreviated) version of what each stage produces. If you're adapting the workflow for your own codebase, compare your stage outputs against these to gauge the right level of detail.

This example does **not** cover the payment integration mentioned in the problem statement — that's intentional. It's flagged as out-of-scope in the spike document (Stage 1), demonstrating how the workflow handles deferring work rather than scope creep.
