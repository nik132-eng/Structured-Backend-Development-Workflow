#!/bin/bash
# Global safety hook: ask before running destructive shell commands.
# Input: hook JSON on stdin. Output: permission JSON on stdout.

input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')

if [[ -z "$command" ]]; then
  echo '{ "permission": "allow" }'
  exit 0
fi

patterns=(
  'rm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)'
  'git[[:space:]]+push[[:space:]].*(--force([^-]|$)|[[:space:]]-f([[:space:]]|$))'
  'git[[:space:]]+reset[[:space:]].*--hard'
  'git[[:space:]]+clean[[:space:]].*-[a-zA-Z]*f'
  'git[[:space:]]+branch[[:space:]].*-D[[:space:]]'
  'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)'
  'drop[[:space:]]+(table|database|schema)'
  'terraform[[:space:]]+destroy'
  'kubectl[[:space:]]+delete'
  'docker[[:space:]]+(system|volume)[[:space:]]+prune'
  'chmod[[:space:]]+-R[[:space:]]+777'
  'mkfs\.'
  '>[[:space:]]*/dev/(sd|disk|nvme)'
)

for p in "${patterns[@]}"; do
  if [[ "$command" =~ $p ]]; then
    jq -n --arg cmd "$command" '{
      permission: "ask",
      user_message: "Potentially destructive command flagged by safety hook — review before running:\n\($cmd)",
      agent_message: "A safety hook flagged this command as potentially destructive. It requires explicit user approval. Do not attempt to bypass or rephrase the command to avoid the check."
    }'
    exit 0
  fi
done

echo '{ "permission": "allow" }'
exit 0
