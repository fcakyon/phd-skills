#!/usr/bin/env bash
# PreCompact hook: save research state before context is compressed
# Captures current working context so long research sessions don't lose
# important state when the conversation approaches context limits.
#
# Saves to .claude/research-state.md — the assistant can read this
# to recover context after compaction.

set -uo pipefail

state_dir="${HOME}/.claude"
state_file="${state_dir}/research-state.md"

mkdir -p "$state_dir"

# Gather current state information
timestamp=$(date -Iseconds)
git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
git_status=$(git status --short 2>/dev/null | head -20 || echo "not a git repo")
pwd_dir=$(pwd)

cat > "$state_file" << ENDSTATE
# Research State (saved at context compaction)
**Saved**: ${timestamp}
**Directory**: ${pwd_dir}
**Branch**: ${git_branch}

## Recent Git Changes
\`\`\`
${git_status}
\`\`\`

## Note
Context was approaching its limit. This state was auto-saved.
Consider starting a fresh session for complex tasks to avoid
rushed conclusions from compressed context.
ENDSTATE

# Emit advisory message
echo '{"decision": "allow", "reason": "CONTEXT LIMIT: Research state saved to ~/.claude/research-state.md. Long sessions lead to compressed context and potentially rushed conclusions. Consider starting a fresh session if you have complex remaining tasks."}'
