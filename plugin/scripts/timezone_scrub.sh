#!/usr/bin/env bash
# PostToolUse hook: warn on timezone tokens that don't match the system's
# local timezone family. Most researchers publish status updates in their
# local time; cross-TZ collaboration is rare in personal docs and gets
# mishandled silently.

set -uo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2> /dev/null)
new_string=$(echo "$input" | jq -r '.tool_input.new_string // .tool_input.content // empty' 2> /dev/null)

if [ -z "$file_path" ] || [ -z "$new_string" ]; then
  exit 0
fi

case "$file_path" in
  *.md | *.txt | *.tex | *.rst) ;;
  *)
    exit 0
    ;;
esac

# Detect system timezone family
sys_tz=$(date +%Z 2> /dev/null || echo "")
sys_tz_long=""
if [ -L /etc/localtime ]; then
  sys_tz_long=$(readlink /etc/localtime 2> /dev/null | sed 's|.*zoneinfo/||')
fi

if [ -z "$sys_tz" ] && [ -z "$sys_tz_long" ]; then
  exit 0
fi

# Strip fenced code blocks (```...```) and inline code (`...`) before matching
stripped=$(echo "$new_string" | awk '
    /^```/ { in_fence = !in_fence; next }
    !in_fence { print }
' | sed -E 's/`[^`]+`//g')

# TZ tokens to check
tz_pattern='\b(EST|EDT|CST|CDT|MST|MDT|PST|PDT|UTC|GMT|BST|CET|CEST|JST|IST|AEST|AEDT|NZST|NZDT)\b'

hits=$(echo "$stripped" | grep -oE "$tz_pattern" | sort -u || true)

if [ -z "$hits" ]; then
  exit 0
fi

# Filter out hits that match the system TZ
mismatched=""
while read -r tz; do
  if [ "$tz" = "$sys_tz" ]; then
    continue
  fi
  if [ -n "$mismatched" ]; then
    mismatched="$mismatched, $tz"
  else
    mismatched="$tz"
  fi
done <<< "$hits"

if [ -z "$mismatched" ]; then
  exit 0
fi

cat << EOF
{"decision": "allow", "reason": "TIMEZONE SCRUB: ${file_path} contains TZ tokens (${mismatched}) that don't match your system timezone (${sys_tz}). Status updates and ETAs in personal docs should normally use one canonical TZ. If the TZ token is correct (e.g. quoting a remote log), wrap the timestamp in backticks or a fenced code block to mark it as verbatim."}
EOF

exit 0
