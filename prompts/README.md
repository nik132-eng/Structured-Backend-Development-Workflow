# Prompts

This directory contains every prompt used by the Backend Development Automation Workflow: the master orchestrator and the 8 individual stage prompts.

## The 8 Stages

| Stage | File | Purpose |
|-------|------|---------|
| 1 | [`stages/01-SPIKE-DOCUMENT-GENERATOR.md`](stages/01-SPIKE-DOCUMENT-GENERATOR.md) | Turn a problem statement into a structured spike document — clarified problem, module scope, technical concerns. |
| 2 | [`stages/02-TASK-BREAKDOWN.md`](stages/02-TASK-BREAKDOWN.md) | Decompose the spike document into a granular, dependency-ordered task list. |
| 3 | [`stages/03-CODEBASE-ANALYZER.md`](stages/03-CODEBASE-ANALYZER.md) | Analyze the relevant modules for existing patterns, conventions, and technical debt. |
| 4 | [`stages/04-PROMPT-GENERATOR.md`](stages/04-PROMPT-GENERATOR.md) | Generate execution-ready, context-rich prompts for each task. |
| 5 | [`stages/05-CODE-EXECUTOR.md`](stages/05-CODE-EXECUTOR.md) | Execute the generated prompts to produce code. |
| 6 | [`stages/06-TEST-RUNNER.md`](stages/06-TEST-RUNNER.md) | Generate and run tests against the new code, following existing test patterns. |
| 7 | [`stages/07-SELF-VERIFIER.md`](stages/07-SELF-VERIFIER.md) | Verify architecture, performance, and trade-offs; auto-fix safe issues. |
| 8 | [`stages/08-BUSINESS-LOGIC-REVIEWER.md`](stages/08-BUSINESS-LOGIC-REVIEWER.md) | Final human checkpoint — does the code actually solve the original problem? |

## Master Workflow vs. Individual Stages

- **[`MASTER-WORKFLOW.md`](MASTER-WORKFLOW.md)** is the entry point for a new feature. It walks an AI agent through all 8 stages in order, handling checkpoints, context-passing, and retries as described in [`../ARCHITECTURE.md`](../ARCHITECTURE.md).
- **Individual stage files** are useful when you already have output from earlier stages (e.g. you wrote your own spike document and want to jump straight to Stage 2), or when you want to re-run a single stage in isolation (e.g. re-running Stage 3 after the codebase has changed).

## How to Invoke a Prompt

### Master workflow

Give your AI agent:
1. The contents of `MASTER-WORKFLOW.md`
2. Your problem statement (and codebase context, if available)

The agent will guide you through Stage 1 onward.

### A single stage

Give your AI agent:
1. The contents of the relevant `stages/0N-*.md` file
2. The required inputs for that stage, as listed in its "Input" section (typically the output of the previous stage)

The agent will produce that stage's output and checkpoint checklist.

## Customization

Every prompt here is plain Markdown — edit directly to fit your team's stack, tone, or process. See [`../CONTRIBUTING.md`](../CONTRIBUTING.md) for guidance on adding, removing, or modifying stages without breaking the pipeline's input/output contracts.
