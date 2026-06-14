# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-06-13

### Added

- Initial release of the Backend Development Automation Workflow.
- 8-stage pipeline: Spike Document Generator, Task Breakdown, Codebase Analyzer, Prompt Generator, Code Executor, Test Runner, Self-Verifier, Business Logic Reviewer.
- Master workflow orchestrator prompt (`prompts/MASTER-WORKFLOW.md`).
- Individual stage prompts in `prompts/stages/`.
- Output templates for spike documents, task breakdowns, codebase analyses, execution prompts, and checkpoint checklists.
- Configurable retry/escalation logic (`config/retry-limits.json`).
- Configurable test framework support (`config/test-frameworks.json`).
- Checkpoint definitions for all 8 stages (`config/checkpoint-definitions.json`).
- Full worked example: e-commerce shopping cart feature walked through all 8 stages (`examples/ecommerce-cart-example/`).
- Architecture documentation including 12-state state machine diagram (`ARCHITECTURE.md`).
- Supporting docs: workflow overview, state diagram, checkpoint guide, module identification guide, customization guide (`docs/`).

### Known Limitations

- Stage 6 (Test Runner) assumes a test framework from `config/test-frameworks.json` is already set up in the target project; it does not scaffold a test runner from scratch.
- Retry logic (Stage 9) is described procedurally for an AI agent to follow — there is no automated harness enforcing retry counts; an agent or operator must track attempts.
- The workflow assumes a single feature/task stream at a time. Running multiple features through the pipeline concurrently is not addressed.
- Module identification (Stage 1/3) relies on the operator describing the codebase structure when an agent does not have direct repository access.
- No tooling is provided for automatically renumbering stages if one is inserted/removed — this is a manual documentation update (see `CONTRIBUTING.md`).
