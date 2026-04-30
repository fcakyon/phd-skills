#!/usr/bin/env bash
# PreCompact hook: save research state before context is compressed.
# Captures local git state plus signals extracted from the transcript
# (recent hosts, tmux sessions, run paths) so the assistant can recover
# context after compaction.
#
# Saves to ~/.claude/research-state.md.

set -uo pipefail

state_dir="${HOME}/.claude"
state_file="${state_dir}/research-state.md"

mkdir -p "$state_dir"

# Read PreCompact event payload from stdin (may include transcript_path)
input=$(cat 2> /dev/null || echo "")
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty' 2> /dev/null)

# Local state
timestamp=$(date -Iseconds)
git_branch=$(git branch --show-current 2> /dev/null || echo "unknown")
git_status=$(git status --short 2> /dev/null | head -20 || echo "not a git repo")
pwd_dir=$(pwd)

# Transcript-derived signals (only if transcript_path is readable)
recent_hosts=""
recent_tmux=""
recent_runs=""
if [ -n "$transcript_path" ] && [ -r "$transcript_path" ]; then
  recent_hosts=$(grep -oE 'ssh\s+[A-Za-z0-9_.@-]+' "$transcript_path" 2> /dev/null | sort -u | tail -10 | tr '\n' ' ')
  recent_tmux=$(grep -oE 'tmux\s+(new-session|attach-session|attach|kill-session)\s+[^\\"]*\s-s\s\S+' "$transcript_path" 2> /dev/null | grep -oE '\-s\s\S+' | awk '{print $2}' | sort -u | tail -10 | tr '\n' ' ')
  recent_runs=$(grep -oE '/(home|data|runs|tmp|workspace)/[A-Za-z0-9_/.+-]+' "$transcript_path" 2> /dev/null | sort -u | tail -15 | tr '\n' ' ')
fi

cat > "$state_file" << ENDSTATE
# Research State (saved at context compaction)

**Saved**: ${timestamp}
**Directory**: ${pwd_dir}
**Branch**: ${git_branch}

## Recent Git Changes

\`\`\`
${git_status}
\`\`\`

## Recent transcript signals

**Hosts touched**: ${recent_hosts:-none}
**tmux sessions**: ${recent_tmux:-none}
**Recent paths**: ${recent_runs:-none}

## Note

Context was approaching its limit. This state was auto-saved.
Consider starting a fresh session for complex tasks to avoid
rushed conclusions from compressed context.
ENDSTATE

echo '{"decision": "allow", "reason": "CONTEXT LIMIT: research state saved to ~/.claude/research-state.md including recent hosts, tmux sessions, and run paths from the transcript. Long sessions lead to compressed context and potentially rushed conclusions. Consider starting a fresh session if you have complex remaining tasks."}'
