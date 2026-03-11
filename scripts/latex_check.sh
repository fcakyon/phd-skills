#!/usr/bin/env bash
# PostToolUse hook: auto-compile .tex after edits to catch errors early
# Reads tool result from stdin JSON, checks if the edited file is .tex.
# If yes, runs pdflatex in nonstopmode and reports any errors.
# Non-blocking: exit 0 always so the edit goes through regardless.

set -uo pipefail

# Read the hook input from stdin
input=$(cat)

# Extract the file path from the tool input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null)

if [ -z "$file_path" ]; then
    exit 0
fi

# Only process .tex files
case "$file_path" in
    *.tex) ;;
    *) exit 0 ;;
esac

# Get the directory and filename
tex_dir=$(dirname "$file_path")
tex_file=$(basename "$file_path")

# Find the main .tex file (the one with \documentclass)
main_tex=""
for f in "$tex_dir"/*.tex; do
    if grep -q '\\documentclass' "$f" 2>/dev/null; then
        main_tex="$f"
        break
    fi
done

# If no main tex found, try the edited file itself
if [ -z "$main_tex" ]; then
    main_tex="$file_path"
fi

main_basename=$(basename "$main_tex" .tex)

# Run pdflatex in nonstopmode with a short timeout
output=$(cd "$tex_dir" && timeout 30 pdflatex -interaction=nonstopmode -halt-on-error "$main_basename.tex" 2>&1) || true
exit_code=$?

# Check for errors in the output
if echo "$output" | grep -q "^!" 2>/dev/null; then
    # Extract error lines
    errors=$(echo "$output" | grep -A 2 "^!" | head -20)
    echo "{\"decision\": \"allow\", \"reason\": \"LATEX COMPILATION ERROR after editing $tex_file:\\n$errors\\n\\nFix the LaTeX error before it compounds with further edits.\"}"
else
    exit 0
fi
