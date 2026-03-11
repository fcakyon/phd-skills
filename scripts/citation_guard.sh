#!/usr/bin/env bash
# PreToolUse hook: remind to verify citations when editing .tex or .bib files
# Reads tool input from stdin JSON, checks if the target file is LaTeX-related.
# If yes, emits a system message reminding to verify citation accuracy.

set -euo pipefail

# Read the hook input from stdin
input=$(cat)

# Extract the file path from the tool input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null)

if [ -z "$file_path" ]; then
    exit 0
fi

# Check if the file is a .tex or .bib file
case "$file_path" in
    *.tex|*.bib)
        cat <<'EOF'
{"decision": "allow", "reason": "CITATION GUARD: You are editing a LaTeX/BibTeX file. Before adding or modifying any citation: (1) Verify author names against DBLP, (2) Confirm venue and year match the published version, (3) Check that any cited numerical claims exist in the source paper. If uncertain about any citation detail, flag it for manual verification rather than guessing."}
EOF
        ;;
    *)
        exit 0
        ;;
esac
