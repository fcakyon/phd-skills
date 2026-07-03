#!/usr/bin/env bash
# PreToolUse hook: block in-place edits to TRACKED source files over SSH.
# Forces git pull/edit/commit/push instead of remote tee/sed-i/redirect edits
# that silently diverge from the tracked-source-of-truth. Temp/scratch
# destinations (/tmp, /var/tmp, /dev/shm, $TMPDIR, scratch dirs) are throwaway
# test transfers, not tracked source, so they are exempt.

set -uo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2> /dev/null)
[ -z "$command" ] && exit 0

# Only fire on ssh-prefixed commands
echo "$command" | grep -qE 'ssh\s+[A-Za-z0-9_.-]+' || exit 0

ext='py|yaml|yml|toml|json|md|sh|rs|go|ts|tsx|js|jsx|c|cpp|h|hpp|java|rb|R'
# A source-file path ending: one of the extensions then a word boundary, so
# .py does not match inside .python. Defined once, shared by every shape below.
extm="\.($ext)([^A-Za-z0-9]|\$)"
# Throwaway destinations: never tracked source, safe to write over SSH
temp='(^|/)(tmp|var/tmp|dev/shm)/|\$\{?TMPDIR|scratch(pad)?/'

block() {
  cat << 'EOF' >&2
REMOTE EDIT GUARD: this command edits a tracked source file in-place over SSH.
That bypasses git and creates remote-vs-origin divergence. Instead:
  1. Edit the file locally
  2. git add / commit / push
  3. ssh <host> 'cd <repo> && git pull'
Writing to a temp/scratch path (/tmp, /var/tmp, /dev/shm, $TMPDIR, scratch/) is exempt.
If you really need an emergency in-place edit, do it without going through this assistant.
EOF
  exit 2
}

# sed -i mutates an existing file in place: always divergent, block regardless of path
echo "$command" | grep -qE "sed\s+-i[a-zA-Z]*\s+[^|&;]*$extm" && block

# Create/overwrite/append shapes (redirect, tee): collect only their target paths
targets=$(echo "$command" | grep -oE "(>>?\s*|tee\s+(-a\s+)?)[^ |&;<>]*$extm" 2> /dev/null)
[ -z "$targets" ] && exit 0

# Block only if at least one target is NOT a temp/scratch path
echo "$targets" | grep -qvE "$temp" && block

exit 0
