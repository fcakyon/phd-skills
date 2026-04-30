#!/usr/bin/env bash
# PreToolUse hook: block in-place edits to source files over SSH.
# Forces git pull/edit/commit/push instead of remote heredoc/tee/sed-i edits
# that silently diverge from the tracked-source-of-truth.

set -uo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2> /dev/null)

if [ -z "$command" ]; then
  exit 0
fi

# Only fire on ssh-prefixed commands
if ! echo "$command" | grep -qE 'ssh\s+[A-Za-z0-9_.-]+'; then
  exit 0
fi

# Detect in-place edit shapes inside the SSH payload
inplace_pattern='(<<\s*['"'"'"]?EOF|tee\s+[^|&;]*\.(py|yaml|yml|toml|json|md|sh|rs|go|ts|tsx|js|jsx|c|cpp|h|hpp|java|rb|R)|sed\s+-i[a-zA-Z]*\s+[^|&;]*\.(py|yaml|yml|toml|json|md|sh|rs|go|ts|tsx|js|jsx|c|cpp|h|hpp|java|rb|R)|>\s+[^|&;]*\.(py|yaml|yml|toml|json|md|sh|rs|go|ts|tsx|js|jsx|c|cpp|h|hpp|java|rb|R))'

if echo "$command" | grep -qE "$inplace_pattern"; then
  cat << 'EOF' >&2
REMOTE EDIT GUARD: this command edits a tracked source file in-place over SSH.
That bypasses git and creates remote-vs-origin divergence. Instead:
  1. Edit the file locally
  2. git add / commit / push
  3. ssh <host> 'cd <repo> && git pull'
If you really need an emergency in-place edit, do it without going through this assistant.
EOF
  exit 2
fi

exit 0
