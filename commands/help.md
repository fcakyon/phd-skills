---
name: help
description: >
  Show all phd-skills features, commands, skills, agents, and hooks
  at a glance. Use for in-session discoverability.
allowed-tools: Read, Glob
---

# PHD-Skills Help

Display a formatted overview of all plugin features. Read the plugin structure to generate this dynamically.

## Output the following overview:

```
PHD-SKILLS — Research Integrity Plugin for Claude Code

COMMANDS (invoke directly)
  /phd-skills:xray      Audit paper against code and data (5 parallel dimensions)
  /phd-skills:factcheck  Verify BibTeX entries and cited claims against DBLP
  /phd-skills:gaps       Literature gap analysis with web confirmation
  /phd-skills:fortify    Select strongest ablations + anticipate reviewer questions
  /phd-skills:setup      Interactive onboarding (notifications, allowlist, LaTeX)
  /phd-skills:help       This help message

SKILLS (auto-trigger — just describe what you need)
  "design an ablation study"             → Experiment Design
  "find related papers on X"             → Literature Research
  "write the methods section"            → Paper Writing
  "check if my numbers match the code"   → Paper Verification
  "analyze dataset bias"                 → Dataset Curation
  "prepare code for open-source release" → Research Publishing
  "what will reviewers ask about this?"  → Reviewer Defense
  "setup latex for CVPR"                 → LaTeX Setup

AGENTS (Claude delegates automatically)
  paper-auditor          Cross-checks paper vs code/data (isolated worktree)
  experiment-analyzer    Analyzes results from any tracking system + scheduling

ACTIVE GUARDRAILS (run silently)
  Stop hook              Checks for unverified claims, wrong targets, scope creep,
                         dropped requests, assumptions stated as facts
  Ambiguity guard        Confirms interpretation of short/ambiguous messages
  Citation guard         Reminds to verify citations when editing .tex/.bib files
  LaTeX auto-compile     Compiles .tex after edits, catches errors early
  Visual inspection      Reminds to inspect generated images/plots
  State preservation     Saves research context before context overflow

COMPLEMENTARY BUILT-IN FEATURES
  /loop 10m <task>       Recurring monitoring (e.g., GPU training checks)
  /simplify              Review code for quality after publishing prep
  /fork                  Branch conversation to explore alternatives
  /btw                   Quick side questions without polluting context
```

Read the actual plugin files via `${CLAUDE_PLUGIN_ROOT}` if available to verify the list is current, then display the formatted overview above.
