#!/usr/bin/env bash
# PreToolUse hook: warn before sending content to a teammate-facing channel.
# Reminds the assistant that any commands, paths, version strings, or numbers
# inside the body should have been produced by a tool output earlier in the
# session, not recalled from memory.

set -uo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2> /dev/null)

if [ -z "$command" ]; then
  exit 0
fi

# Detect outbound channels
outbound_pattern='(slack|gh\s+(issue|pr|release)|hooks\.slack\.com|teams\.microsoft\.com|discord(app)?\.com|sendgrid|mailgun|\bmail\s|/notify|/draft)'

if echo "$command" | grep -qiE "$outbound_pattern"; then
  cat << 'EOF'
{"decision": "allow", "reason": "OUTBOUND ARTIFACT: this command sends content to a teammate-facing channel. Before submitting, scan the body for any commands, file paths, version strings, or numeric claims. For each, confirm it was produced by a tool output earlier in this session (ls, find, git, Read, etc.). Anything recalled from memory should be labeled 'unverified template' or probed first. Teammates act on what you send."}
EOF
  exit 0
fi

exit 0
