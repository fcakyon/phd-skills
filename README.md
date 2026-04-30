# phd-skills

Research integrity plugin for Claude Code — paper auditing, citation
verification, experiment analysis, and methodology-first skills for
academic workflows.

Built by [Fatih Cagatay Akyon](https://scholar.google.com/citations?user=RHGyDE0AAAAJ)
(1500+ citations, 7 patents) after 300+ Claude Code sessions, tens of
critical AI mistakes caught the hard way, and thousands of hours of
PhD research. Every guardrail in this plugin traces to a real mistake.

![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blue)
![MIT License](https://img.shields.io/badge/License-MIT-green)
![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero-brightgreen)
![No MCP Required](https://img.shields.io/badge/MCP-Not_Required-lightgrey)

---

## Why This Plugin Exists

I use Claude Code daily for my PhD. It's powerful, but it
makes research-specific mistakes that cost hours:

- It typed "done?" as "dont?" and launched an unwanted upload of thousands of files
- It analyzed my full dataset when I asked for a specific 4k/2k/2k split
- It claimed a test covered a bug it had never actually verified
- It never once looked at a figure it generated — just trusted the numbers

Other plugins give you more commands. **This plugin gives you guardrails.**

---

## Install

```
claude plugin marketplace add fcakyon/phd-skills
claude plugin install phd-skills@phd-skills
```

Then run `/phd-skills:setup` inside Claude Code to configure notifications, LaTeX, and allowlist.

---

## Usage

Open Claude Code in your paper directory, then:

- `/phd-skills:xray` — audit paper against code and data across 5 dimensions, get prioritized fixes
- `/phd-skills:factcheck` — verify all BibTeX entries and cited claims against DBLP
- `/phd-skills:fortify CVPR` — anticipate reviewer questions, rank ablations, and suggest paper improvements
- `/phd-skills:gaps neural architecture search` — find what's missing in the literature
- `/loop 30m check experiment logs, notify me if metrics beat the baseline or if loss starts to diverge`
- `"check if my numbers match the code"` — skills auto-trigger, no slash command needed
- `"make code publish ready"` — prepares code for open-source release with license, docs, and reproducibility checks

After running `/phd-skills:setup`, all Claude Code notifications (task completion,
background agents) are forwarded to your configured service (ntfy/Slack/email).

---

## What You Get

### Commands

| Command                                                     | What it does                                               |
| ----------------------------------------------------------- | ---------------------------------------------------------- |
| [`/phd-skills:xray`](plugin/commands/xray.md)               | Audit paper against code and data (5 parallel dimensions)  |
| [`/phd-skills:factcheck`](plugin/commands/factcheck.md)     | Verify BibTeX entries and cited claims against DBLP        |
| [`/phd-skills:gaps <topic>`](plugin/commands/gaps.md)       | Literature gap analysis with web confirmation              |
| [`/phd-skills:fortify [venue]`](plugin/commands/fortify.md) | Select strongest ablations + anticipate reviewer questions |
| [`/phd-skills:setup`](plugin/commands/setup.md)             | Interactive onboarding (notifications, allowlist, LaTeX)   |
| [`/phd-skills:help`](plugin/commands/help.md)               | Show all features at a glance                              |

### Skills (auto-trigger — just describe what you need)

| When you say...                             | Skill activates                                                   |
| ------------------------------------------- | ----------------------------------------------------------------- |
| "design an ablation study"                  | [Experiment Design](plugin/skills/experiment-design/SKILL.md)     |
| "find related papers on X"                  | [Literature Research](plugin/skills/literature-research/SKILL.md) |
| "review my methods section for consistency" | [Paper Verification](plugin/skills/paper-writing/SKILL.md)        |
| "check if my numbers match the code"        | [Paper Verification](plugin/skills/paper-verification/SKILL.md)   |
| "analyze dataset bias"                      | [Dataset Curation](plugin/skills/dataset-curation/SKILL.md)       |
| "prepare code for open-source release"      | [Research Publishing](plugin/skills/research-publishing/SKILL.md) |
| "what will reviewers ask about this?"       | [Reviewer Defense](plugin/skills/reviewer-defense/SKILL.md)       |
| "setup latex for CVPR"                      | [LaTeX Setup](plugin/skills/latex-setup/SKILL.md)                 |

### Agents (Claude delegates automatically)

| Agent                                                         | What it does                                         | Special                                                       |
| ------------------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------- |
| [`paper-auditor`](plugin/agents/paper-auditor.md)             | Cross-checks paper claims vs code and data           | Runs in isolated worktree, remembers patterns across sessions |
| [`experiment-analyzer`](plugin/agents/experiment-analyzer.md) | Analyzes results from wandb/neptune/local/any format | Can schedule monitoring via cron, sends SSH notifications     |

### Research Guardrails (run silently — you never invoke these)

| What it catches                                                                                                                                                     | Real incident that inspired it                                                                                    |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| [Conclusions and recommended actions reviewed against actual artifacts (configs, run dirs, metric files) by a fresh-context research peer](plugin/hooks/hooks.json) | Claude removed introduction novelty claims, analyzed wrong data split, dropped a verification question mid-commit |
| [Missing citation verification when editing .tex/.bib](plugin/scripts/citation_guard.sh)                                                                            | Claude propagated unverified author names and venue info                                                          |
| [LaTeX compilation errors after .tex edits](plugin/scripts/latex_check.sh)                                                                                          | Errors compounded across multiple edits before being caught                                                       |
| [Unreviewed generated images/figures](plugin/scripts/visual_check.sh)                                                                                               | Claude analyzed metrics but never looked at the actual plots                                                      |
| [Research state loss before context overflow](plugin/scripts/save_state.sh)                                                                                         | Long research sessions lost context, leading to rushed conclusions                                                |

---

## How It Compares

|                                           | phd-skills             | flonat/claude-research       | Others       |
| ----------------------------------------- | ---------------------- | ---------------------------- | ------------ |
| Commands to learn                         | 6                      | 39                           | 13-20        |
| Research integrity hooks                  | 5 (agent + command)    | 1                            | 0            |
| Paper-code consistency audit              | 5-dimension parallel   | Read-only, no code cross-ref | None         |
| Experiment monitoring + SSH notifications | Yes (ntfy/slack/email) | No                           | No           |
| External dependencies                     | **None**               | npm + pip + MCP servers      | MCP required |
| Install time                              | 30 seconds             | 10+ minutes                  | Varies       |

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

## Thank you for the support!

[![Star History Chart](https://api.star-history.com/svg?repos=fcakyon/phd-skills&type=Date)](https://www.star-history.com/#fcakyon/phd-skills&Date)
