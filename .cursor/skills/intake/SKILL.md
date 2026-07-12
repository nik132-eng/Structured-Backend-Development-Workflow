---
name: intake
description: Slash-command wrapper that runs problem intake and stops for review.
disable-model-invocation: true
---

# Intake

Run the `problem-intake` skill on whatever follows this command (ticket text, issue link, bug report, or a rough idea). Produce the problem brief with acceptance criteria and stated assumptions. Ask blocking questions in one batched prompt if any exist. Do NOT start implementing — stop after the brief so the user can review it.
