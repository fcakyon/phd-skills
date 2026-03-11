# phd-skills

Research integrity plugin for Claude Code — paper auditing, citation
verification, experiment analysis, and methodology-first skills for
academic workflows.

Built by [Fatih Cagatay Akyon](https://scholar.google.com/citations?user=RHGyDE0AAAAJ)
(1300+ citations, 7 patents) after 200+ Claude Code sessions, tens of
critical AI mistakes caught the hard way, and thousands of hours of
PhD research. Every guardrail in this plugin traces to a real mistake.

![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blue)
![MIT License](https://img.shields.io/badge/License-MIT-green)
![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero-brightgreen)
![No MCP Required](https://img.shields.io/badge/MCP-Not_Required-lightgrey)

---

## Why This Plugin Exists

I use Claude Code daily for my PhD — writing papers, running experiments,
verifying results, managing citations. It's incredibly powerful, but it
makes research-specific mistakes that cost hours:

- It stated my "detached tag head" worked differently than it actually did
- It typed "done?" as "dont?" and launched an unwanted upload of thousands of files
- It silently removed novelty claims from my introduction during a "small edit"
- It analyzed my full dataset when I asked for a specific 4k/2k/2k split
- It claimed a test covered a bug it had never actually verified
- It never once looked at a figure it generated — just trusted the numbers

Other plugins give you more commands. **This plugin gives you guardrails.**

6 silent hooks catch these exact failure patterns before they cost you time.
8 skills encode research methodology — not scripts. 2 agents build
project knowledge across sessions.

---

## Install

```
claude plugin install fcakyon/phd-skills
```

---

## What You Get

### Commands

| Command | What it does |
|---------|-------------|
| `/phd-skills:xray` | Audit paper against code and data (5 parallel dimensions) |
| `/phd-skills:factcheck` | Verify BibTeX entries and cited claims against DBLP |
| `/phd-skills:gaps <topic>` | Literature gap analysis with web confirmation |
| `/phd-skills:fortify [venue]` | Select strongest ablations + anticipate reviewer questions |
| `/phd-skills:setup` | Interactive onboarding (notifications, allowlist, LaTeX) |
| `/phd-skills:help` | Show all features at a glance |

### Skills (auto-trigger — just describe what you need)

| When you say... | Skill activates |
|-----------------|----------------|
| "design an ablation study" | Experiment Design |
| "find related papers on X" | Literature Research |
| "write the methods section" | Paper Writing |
| "check if my numbers match the code" | Paper Verification |
| "analyze dataset bias" | Dataset Curation |
| "prepare code for open-source release" | Research Publishing |
| "what will reviewers ask about this?" | Reviewer Defense |
| "setup latex for CVPR" | LaTeX Setup |

### Agents (Claude delegates automatically)

| Agent | What it does | Special |
|-------|-------------|---------|
| `paper-auditor` | Cross-checks paper claims vs code and data | Runs in isolated worktree, remembers patterns across sessions |
| `experiment-analyzer` | Analyzes results from wandb/neptune/local/any format | Can schedule monitoring via cron, sends SSH notifications |

### Research Guardrails (run silently — you never invoke these)

| What it catches | Real incident that inspired it |
|-----------------|-------------------------------|
| Unverified claims, wrong targets, scope creep, dropped requests, assumptions stated as facts | Claude removed introduction novelty claims, analyzed wrong data split, dropped a verification question mid-commit |
| Ambiguous short messages before costly actions | "done?" misread as "dont?", launched unwanted upload |
| Missing citation verification when editing .tex/.bib | Claude propagated unverified author names and venue info |
| LaTeX compilation errors after .tex edits | Errors compounded across multiple edits before being caught |
| Unreviewed generated images/figures | Claude analyzed metrics but never looked at the actual plots |
| Research state loss before context overflow | Long research sessions lost context, leading to rushed conclusions |

---

## Quick Start

```
/phd-skills:setup                    # Configure once
/phd-skills:xray                     # Audit your paper
"design an ablation study"           # Skills auto-trigger
"audit my paper against the code"    # Spawns paper-auditor agent
```

---

## How It Compares

| | phd-skills | flonat/claude-research | Others |
|---|---|---|---|
| Commands to learn | 6 | 39 | 13-20 |
| Research integrity hooks | 6 (prompt + command) | 1 | 0 |
| Paper-code consistency audit | 5-dimension parallel | Read-only, no code cross-ref | None |
| Experiment monitoring + SSH notifications | Yes (ntfy/slack/email) | No | No |
| External dependencies | **None** | npm + pip + MCP servers | MCP required |
| Install time | 30 seconds | 10+ minutes | Varies |

---

## Design Principles

1. **No MCP dependency** — works on any machine, including SSH
2. **Methodology over scripts** — skills teach the approach, Claude generates code for your specific setup (wandb, neptune, local files, whatever)
3. **Human oversight first** — Claude makes premature claims and jumps to conclusions. Every skill builds in verification checkpoints
4. **Actionable output** — ranked suggestions with specific fixes, never just a list of findings

---

## License

MIT — use it, fork it, adapt it to your research.

Built with frustration and care during a PhD at METU.
