#!/usr/bin/env bash
# PostToolUse hook: block project-internal jargon shapes in commits and docs.
# These shapes are virtually never legitimate prose: they're session-local
# labels (sprint codes, phase markers, internal-only flags) that become
# embarrassing when they leak into shared artifacts.

set -uo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2> /dev/null)
new_string=$(echo "$input" | jq -r '.tool_input.new_string // .tool_input.content // empty' 2> /dev/null)

if [ -z "$file_path" ] || [ -z "$new_string" ]; then
  exit 0
fi

# Only scan documentation and commit messages
case "$file_path" in
  *.md | *.txt | *.tex | *.rst | *COMMIT_EDITMSG*) ;;
  *)
    exit 0
    ;;
esac

# Curated jargon-shape regex: only patterns that are almost never legitimate prose
jargon_pattern='\bwave-[0-9]+\b|\bphase-internal\b|\bstage-internal\b|\binternal-only\b|\b(M|stage)[0-9]+-(only|gated)\b'

hits=$(echo "$new_string" | grep -nE "$jargon_pattern" || true)

if [ -n "$hits" ]; then
  {
    echo "JARGON SCRUB: project-internal jargon shapes detected in $file_path"
    echo "These shapes (sprint/phase/stage codes, internal flags) leak session-local labels"
    echo "into shared artifacts. Rewrite using descriptive prose."
    echo ""
    echo "Offending lines:"
    echo "$hits"
  } >&2
  exit 2
fi

exit 0
