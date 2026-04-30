#!/usr/bin/env bash
# PreToolUse hook: warn before destructive operations on absolute paths.
# Catches the "rm on a path the assistant invented from memory" failure
# mode by reminding to verify path existence first.

set -uo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2> /dev/null)

if [ -z "$command" ]; then
  exit 0
fi

# Destructive verbs that take a path argument
destructive_pattern='(\brm\s+(-[rRfF]+\s+)?/|\bmv\s+[^|&;]+\s+/|\bdd\s+[^|&;]*of=/|\btruncate\s+[^|&;]*\s+/|\bgit\s+push\s+--force|\bgit\s+push\s+-f\b|\bgit\s+reset\s+--hard|\bgit\s+clean\s+-[a-z]*f|\bshred\s+/|>\s*/[A-Za-z])'

if ! echo "$command" | grep -qE "$destructive_pattern"; then
  exit 0
fi

cat << 'EOF'
{"decision": "allow", "reason": "DESTRUCTIVE PATH GUARD: this command is destructive (rm/mv/dd/truncate/force-push/reset-hard/clean) and references an absolute path. Before running, verify each path actually exists and is what you think it is, `ls -la <path>` or `git status` first. The most common failure mode is acting on a path recalled from memory that doesn't exist or contains different content than expected."}
EOF
exit 0
