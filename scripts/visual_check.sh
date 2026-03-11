#!/usr/bin/env bash
# PostToolUse hook: remind to visually inspect generated images/plots
# Reads tool result from stdin JSON for Bash commands.
# If the command produced image files (.png, .jpg, .pdf, .svg),
# reminds the assistant to actually look at the generated output.

set -euo pipefail

# Read the hook input from stdin
input=$(cat)

# Extract the command that was run
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
stdout=$(echo "$input" | jq -r '.tool_result.stdout // empty' 2>/dev/null)

if [ -z "$command" ]; then
    exit 0
fi

# Check if the command or its output mentions image generation
image_pattern='\.(png|jpg|jpeg|svg|pdf|eps|tiff)\b'

# Check command for savefig, plt.save, output paths, etc.
if echo "$command" | grep -qiE "(savefig|save_fig|imwrite|imsave|\.save\(|convert|>.*${image_pattern})" 2>/dev/null; then
    echo '{"decision": "allow", "reason": "VISUAL CHECK: An image/plot was likely generated. Use the Read tool to inspect the output file and verify it looks correct. Do not trust metrics alone — check that labels, legends, colors, axis ranges, and the overall visual message match expectations."}'
    exit 0
fi

# Check stdout for image file paths
if echo "$stdout" | grep -qiE "(saved|written|created|generated).*${image_pattern}" 2>/dev/null; then
    echo '{"decision": "allow", "reason": "VISUAL CHECK: An image/plot was generated. Use the Read tool to inspect the output file and verify it looks correct. Do not trust metrics alone — check that labels, legends, colors, axis ranges, and the overall visual message match expectations."}'
    exit 0
fi

exit 0
