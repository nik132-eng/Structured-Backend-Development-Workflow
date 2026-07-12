---
name: clarify
description: Slash-command wrapper that interrogates the current task for ambiguity before any work starts.
disable-model-invocation: true
---

# Clarify

Before doing anything else, interrogate the current task for ambiguity. List every decision that would change what gets built (outcome, scope, constraints, irreversibles), resolve what you can from the codebase, and ask the user the rest as one structured multiple-choice prompt (AskQuestion). After they answer, restate the task in one paragraph with all assumptions pinned, then wait for their go-ahead.
