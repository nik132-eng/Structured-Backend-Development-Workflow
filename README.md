# Backend Development Automation Workflow

A tool-agnostic, modular system for automating backend feature development using structured prompts and AI agents. The workflow takes a feature idea from a rough problem statement all the way through to reviewed, tested, working code — moving through eight well-defined stages with human checkpoints in between.

It is designed to work with any AI coding agent (Claude Code, Cursor, Copilot Workspace, etc.) and any backend stack (Node, Python, Ruby, Java, ...). The prompts are plain Markdown — read them, paste them, or wire them into your own automation.

## Quick Start

### Option A: Run the Master Workflow (recommended for new features)

1. Open [`prompts/MASTER-WORKFLOW.md`](prompts/MASTER-WORKFLOW.md)
2. Give your AI agent the master workflow prompt plus your problem statement
3. Work through Stages 1–8 sequentially, approving each checkpoint as you go

### Option B: Run an Individual Stage

If you already have output from a previous stage (e.g. you have a spike document and just need a task breakdown), jump straight to the relevant stage prompt in [`prompts/stages/`](prompts/stages/) and provide its required inputs.

```text
prompts/stages/01-SPIKE-DOCUMENT-GENERATOR.md   # Problem statement -> Spike document
prompts/stages/02-TASK-BREAKDOWN.md             # Spike document -> Task list
prompts/stages/03-CODEBASE-ANALYZER.md          # Task list -> Codebase analysis
prompts/stages/04-PROMPT-GENERATOR.md           # Analysis -> Execution prompts
prompts/stages/05-CODE-EXECUTOR.md              # Execution prompts -> Code
prompts/stages/06-TEST-RUNNER.md                # Code -> Test results
prompts/stages/07-SELF-VERIFIER.md              # Code + tests -> Verification report
prompts/stages/08-BUSINESS-LOGIC-REVIEWER.md    # Everything -> Final approval
```

## Features

- **8-stage pipeline** covering spike, planning, analysis, prompt generation, execution, testing, self-verification, and human review
- **Human checkpoints** at every stage with explicit approve / revise / go-back / pause controls
- **Retry & escalation logic** for test failures, configurable via [`config/retry-limits.json`](config/retry-limits.json)
- **Reusable templates** for every document the workflow produces
- **Worked example** ([`examples/ecommerce-cart-example/`](examples/ecommerce-cart-example/)) showing the full pipeline end-to-end on a shopping cart feature
- **Framework-aware test generation**, configurable via [`config/test-frameworks.json`](config/test-frameworks.json)
- **Fully customizable** — every prompt, template, and config value can be adapted to your team's stack and conventions

## Architecture

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the full state machine, stage dependency table, retry logic, and design rationale.

## Examples

See [`examples/ecommerce-cart-example/`](examples/ecommerce-cart-example/) for a complete, realistic walkthrough of the workflow applied to building a shopping cart feature — from problem statement to final verification.

## Documentation

- [`docs/WORKFLOW-OVERVIEW.md`](docs/WORKFLOW-OVERVIEW.md) — detailed stage-by-stage explanation
- [`docs/WORKFLOW-DIAGRAM.md`](docs/WORKFLOW-DIAGRAM.md) — full state machine diagram
- [`docs/CHECKPOINT-GUIDE.md`](docs/CHECKPOINT-GUIDE.md) — what to check at each checkpoint
- [`docs/MODULE-IDENTIFICATION.md`](docs/MODULE-IDENTIFICATION.md) — how to scope modules in large codebases
- [`docs/CUSTOMIZATION-GUIDE.md`](docs/CUSTOMIZATION-GUIDE.md) — adapting the workflow to your team

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to add stages, customize prompts, and contribute changes.

## License

Released under the [MIT License](LICENSE).
