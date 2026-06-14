# Customization Guide

The workflow is designed to be adapted per-team. This guide covers the most common customizations: tailoring prompts, adjusting retry limits, adding checkpoints, and extending the pipeline with new stages.

## Customizing Prompts for Your Team

Every file in `prompts/stages/` is plain Markdown — edit directly. The highest-value customizations are usually:

### Add stack-specific context to Stage 3 and Stage 4

The biggest lever for generated code "fitting" your codebase is Stage 3's analysis. Consider adding a permanent "Stack Notes" section to `prompts/stages/03-CODEBASE-ANALYZER.md` describing things that won't change between features:

```markdown
## Stack Notes (this codebase)

- Language/Framework: TypeScript, NestJS
- Pattern: modules with controllers, providers (services), and DTOs (class-validator)
- Error handling: NestJS exception filters; throw HttpException subclasses
- Testing: Jest, with `@nestjs/testing` module for integration tests
- ORM: Prisma — migrations via `prisma migrate dev`
```

This means Stage 3 doesn't have to re-discover your stack from scratch every time, and Stage 4's prompts will consistently reference the right idioms.

### Adjust the tone/verbosity of clarifying questions (Stage 1)

If your team already has detailed PRDs before reaching this workflow, Stage 1's clarification step may be mostly redundant. Edit `prompts/stages/01-SPIKE-DOCUMENT-GENERATOR.md`'s "Stage 1: Intake & Clarification" section to skip straight to module identification when the input already looks like a PRD (e.g., add a note: "if the problem statement already includes success criteria and constraints, skip to Stage 2: Module Identification").

### Add a "definition of done" reference to Stage 8

If your team has a standard Definition of Done checklist beyond what's in `config/checkpoint-definitions.json`, link it from `prompts/stages/08-BUSINESS-LOGIC-REVIEWER.md`'s Step 2 checklist.

## Modifying Retry Limits

Edit `config/retry-limits.json`:

```json
{
  "test_failure_retries": 5,
  "test_failure_max_retries": 5,
  "self_verification_retries": 3,
  "escalation_threshold_test_failures": 5,
  "escalation_strategy": "human",
  "description": "Retry logic configuration. After max retries, escalate to human."
}
```

- **`test_failure_max_retries`**: how many times Stage 5/6 (State 9 / RETRY_LOOP) retries before escalating. Lower this (e.g., to 2-3) for teams who want faster escalation and prefer human debugging over many AI retry attempts; raise it for teams comfortable with more autonomous iteration.
- **`self_verification_retries`**: cap on Stage 7's auto-fix attempts before downgrading an issue to "flag for Stage 8" instead. Keep this low (2-3) — auto-fixes should be quick or not attempted.
- **`escalation_strategy`**: currently only `"human"` is defined (Stage 8/operator). If your setup has a tiered escalation (e.g., escalate to a senior-engineer-reviewing-agent before a human), document the new strategy here and update `prompts/stages/06-TEST-RUNNER.md`'s Step 4 accordingly.

## Adding Custom Checkpoints

Edit `config/checkpoint-definitions.json` to add checklist items to an existing stage's checkpoint:

```json
{
  "id": 3,
  "name": "Codebase Analysis",
  "required": true,
  "checklist": [
    "Relevant modules analyzed",
    "Patterns documented",
    "Technical concerns identified",
    "Refactoring needs noted",
    "Security review patterns documented (e.g., authz middleware conventions)"
  ]
}
```

To add an entirely new checkpoint (e.g., a dedicated security checkpoint), see "Extending with New Stages" below — a new checkpoint generally implies a new stage, so the master workflow knows when to run it.

## Extending with New Stages

To add a new stage (e.g., a "Security Review" stage between Stage 7 and Stage 8):

1. **Renumber**: the new stage becomes Stage 8, and the old Stage 8 (Business Logic Reviewer) becomes Stage 9. Rename files in `prompts/stages/` accordingly (`08-BUSINESS-LOGIC-REVIEWER.md` -> `09-BUSINESS-LOGIC-REVIEWER.md`).
2. **Write the new stage file** (`08-SECURITY-REVIEW.md`) following the existing structure: Purpose, Input, Output, Process steps, Checkpoint Checklist, Output/handoff.
3. **Update `prompts/MASTER-WORKFLOW.md`**: add the new stage to "The 8 Stages" (now 9), and update the "State Transitions & Checkpoints" section if the new stage introduces any automatic transitions.
4. **Update `ARCHITECTURE.md`**: add a row to the state machine table and diagram, and update the dependency table.
5. **Update `config/checkpoint-definitions.json`**: add a new checkpoint entry with the new `id`, and renumber subsequent ids if you want them to stay sequential (not strictly required — ids just need to be unique).
6. **Add a template** to `templates/` if the new stage produces a structured document, following the pattern of `templates/CODEBASE-ANALYSIS-TEMPLATE.md`.
7. **Update the example** (`examples/ecommerce-cart-example/`) if it would help illustrate the new stage — not required, but recommended if the new stage is a significant addition.

See `CONTRIBUTING.md` for the full checklist when submitting stage additions.

## Skipping Stages

Stages 5 and 6 are marked `"required": false` in `config/checkpoint-definitions.json` — useful if you're using this workflow purely for planning (Stages 1-4) and will hand off implementation to a different process. To skip a stage:

- In `prompts/MASTER-WORKFLOW.md`, note in "The 8 Stages" that the stage is optional and under what conditions to skip it.
- Ensure the stage *after* the skipped one can still receive the inputs it needs — e.g., if skipping Stage 6 (Test Runner), Stage 7 (Self-Verifier) won't have test results to reference; adjust its "Trade-offs & Threats" step to rely on code review alone.

Stage 8 (Business Logic Reviewer) cannot be skipped — see `prompts/stages/08-BUSINESS-LOGIC-REVIEWER.md`'s final note.
