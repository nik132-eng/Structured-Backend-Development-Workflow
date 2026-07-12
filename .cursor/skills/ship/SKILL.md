---
name: ship
description: Slash-command wrapper that finishes the current task with verification, security audit, and PR prep.
disable-model-invocation: true
---

# Ship

Finish the current task properly: run the `regression-check` skill on all touched areas, run the `verifier` subagent for an independent verdict, run the `security-auditor` subagent if auth/input/storage/network/privacy code was touched, then run the `pr-prep` skill. Report the verdict and STOP before committing, pushing, or opening a PR.
