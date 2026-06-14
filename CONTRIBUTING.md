# Contributing

This workflow is meant to be adapted. Most "contributions" for a given team will be local customizations (different stage prompts, different templates, different retry limits) — you don't need to upstream those to get value. This guide covers both: how to customize the workflow for your own use, and how to contribute improvements back.

## How to Extend the Workflow

The workflow is just a directory of Markdown and JSON files read by an AI agent. Extending it means editing or adding files — there's no build step.

### Adding a New Stage

Sometimes a team needs a stage that doesn't exist yet (e.g. a "Security Review" stage between Self-Verifier and Business Logic Reviewer, or a "Documentation Generator" stage after Code Executor).

1. **Decide where it fits** in the pipeline. Stages are numbered `01`–`08`; inserting a stage means renumbering subsequent stages (e.g. inserting after Stage 7 makes the old Stage 8 become Stage 9).
2. **Create the stage file** in `prompts/stages/`, following the structure used by existing stages:
   - Title and purpose
   - Input requirements (what it consumes from prior stages)
   - Process (step-by-step instructions for the agent)
   - Output template (what it produces, and where it's saved)
   - Checkpoint checklist
3. **Add a corresponding entry** to:
   - `prompts/MASTER-WORKFLOW.md` (stage list and ordering)
   - `ARCHITECTURE.md` (state machine diagram and dependency table)
   - `config/checkpoint-definitions.json` (checkpoint checklist for the new stage)
4. **Add a template** to `templates/` if the stage produces a structured document.
5. **Update the example** in `examples/ecommerce-cart-example/` if it would help illustrate the new stage (optional but encouraged).

### Removing or Skipping a Stage

Some teams won't need every stage (e.g. a team with no automated test suite might skip Stage 6). Rather than deleting the stage file:

- Mark it as optional in `prompts/MASTER-WORKFLOW.md` and `config/checkpoint-definitions.json` (`"required": false`).
- Document in your team's fork why it's skipped, so future contributors understand the gap.

## How to Customize Prompts

Every file in `prompts/stages/` is a standalone prompt — edit it directly. Common customizations:

- **Tone/verbosity**: tighten or expand the "Process" section to match how much hand-holding your team's agent needs.
- **Stack-specific guidance**: add a "Stack Notes" section to Stage 3 (Codebase Analyzer) and Stage 4 (Prompt Generator) describing your language/framework conventions (e.g. "this codebase uses repository pattern + dependency injection; generated code must follow the same pattern").
- **Checkpoint strictness**: edit `config/checkpoint-definitions.json` to add/remove checklist items per stage.
- **Retry behavior**: edit `config/retry-limits.json` — see inline `description` field for what each value controls.
- **Supported test frameworks**: add entries to `config/test-frameworks.json` for languages/frameworks not yet listed.

When customizing, keep the **input/output contract** of each stage intact (per the table in `ARCHITECTURE.md`) — that's what lets stages be swapped or re-run independently.

## Code Style Guidelines

This repository contains no executable code — only Markdown prompts, JSON config, and Markdown templates/examples. Guidelines:

- **Markdown**: use ATX headers (`#`, `##`, ...), fenced code blocks with language hints where applicable, and keep line length reasonable for diff readability.
- **JSON config**: valid JSON only (no comments/trailing commas), with a `description` field on top-level config files explaining their purpose.
- **Prompt files**: follow the existing section structure (Purpose / Input / Process / Output / Checkpoint) so the master workflow can reference stages uniformly.
- **Examples**: keep the worked example (`examples/ecommerce-cart-example/`) internally consistent — if you change a stage's output format, update the corresponding example file too.

## Submitting Changes

1. Make your changes on a branch.
2. If you changed a stage's input/output contract, update `ARCHITECTURE.md` and `prompts/MASTER-WORKFLOW.md` to match.
3. If you changed an output format, update the relevant template in `templates/` and the worked example in `examples/`.
4. Open a PR describing what changed and why — include a before/after if you changed prompt wording, since the impact of prompt changes isn't visible in a diff alone.
