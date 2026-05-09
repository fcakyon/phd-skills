# phd-skills

Catch AI mistakes before they cost weeks of compute. Reproduce papers from arxiv. Debug runs evidence-first. Compare experiments at the right epoch. Launch with discipline.

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

Claude Code is powerful, but it makes research-specific mistakes that cost weeks of compute:

- It typed "done?" as "dont?" and launched an unwanted upload of thousands of files
- It analyzed my full dataset when I asked for a specific 4k/2k/2k split
- It claimed a test covered a bug it had never actually verified
- It never once looked at a figure it generated, just trusted the numbers
- It restarted a 50-hour training job without diffing the config against the reference run, lost three days
- It claimed an experiment was diverging based on a non-converged proxy metric, killed it before downstream eval would have shown the truth
- It ran `rm -rf` on a path it had hallucinated from memory, lost local checkpoints

Other plugins give you more commands. **This plugin gives you guardrails.**

---

## Install

```
claude plugin marketplace add fcakyon/phd-skills
claude plugin install phd-skills@phd-skills
```

The plugin works correctly the moment it is installed. Optional: run `/phd-skills:setup` for a 30-second tour of what was auto-detected and to opt into extras (notifications, allowlist, LaTeX).

---

## Usage

Open Claude Code in your project directory, then:

- `/phd-skills:reproduce arxiv 2508.12345` reproduce a paper from arxiv URL through replication runs
- `"why is my loss diverging?"` the `debug` skill auto-triggers, runs evidence-first probes
- `"compare run alpha to baseline"` the `compare` skill auto-triggers, aligns at the same epoch
- `"launch the new training run"` the `launch` skill auto-triggers, runs the pre-flight checklist
- `/loop 30m check experiment logs, notify me if metrics beat the baseline or if loss starts to diverge`

Notifications (task completion, background agents) forward to ntfy / Slack / email after `/phd-skills:setup`.

---

## What You Get

### Commands

| Command                                                     | What it does                                               |
| ----------------------------------------------------------- | ---------------------------------------------------------- |
| [`/phd-skills:xray`](plugin/commands/xray.md)               | Audit paper against code and data (5 parallel dimensions)  |
| [`/phd-skills:factcheck`](plugin/commands/factcheck.md)     | Verify BibTeX entries and cited claims against DBLP        |
| [`/phd-skills:gaps <topic>`](plugin/commands/gaps.md)       | Literature gap analysis with web confirmation              |
| [`/phd-skills:fortify [venue]`](plugin/commands/fortify.md) | Select strongest ablations + anticipate reviewer questions |
| [`/phd-skills:setup`](plugin/commands/setup.md)             | Auto-detection tour + optional extras                      |
| [`/phd-skills:help`](plugin/commands/help.md)               | Show all features at a glance                              |

### Skills (auto-trigger, just describe what you need)

| When you say...                                   | Skill activates                                                   |
| ------------------------------------------------- | ----------------------------------------------------------------- |
| "reproduce this arxiv paper"                      | [Reproduce](plugin/skills/reproduce/SKILL.md)                     |
| "why is X failing / diverging / OOMing"           | [Debug](plugin/skills/debug/SKILL.md)                             |
| "compare run A to baseline"                       | [Compare](plugin/skills/compare/SKILL.md)                         |
| "launch a new training run" / "kick off training" | [Launch](plugin/skills/launch/SKILL.md)                           |
| "design an ablation study"                        | [Experiment Design](plugin/skills/experiment-design/SKILL.md)     |
| "find related papers on X"                        | [Literature Research](plugin/skills/literature-research/SKILL.md) |
| "check if my numbers match the code"              | [Paper Verification](plugin/skills/paper-verification/SKILL.md)   |
| "review my methods section for consistency"       | [Paper Writing](plugin/skills/paper-writing/SKILL.md)             |
| "analyze dataset bias"                            | [Dataset Curation](plugin/skills/dataset-curation/SKILL.md)       |
| "prepare code for open-source release"            | [Research Publishing](plugin/skills/research-publishing/SKILL.md) |
| "what will reviewers ask about this?"             | [Reviewer Defense](plugin/skills/reviewer-defense/SKILL.md)       |
| "setup latex for CVPR"                            | [LaTeX Setup](plugin/skills/latex-setup/SKILL.md)                 |

### Agents (Claude delegates automatically)

| Agent                                                         | What it does                                                         | Special                                                       |
| ------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------- |
| [`paper-auditor`](plugin/agents/paper-auditor.md)             | Cross-checks paper claims vs code and data                           | Runs in isolated worktree, remembers patterns across sessions |
| [`experiment-analyzer`](plugin/agents/experiment-analyzer.md) | Analyzes results from wandb / neptune / tensorboard / mlflow / local | Hands off to `compare` and `debug` skills for discipline      |

### Research Guardrails (run silently, you never invoke these)

| What it catches                                                                                                              |
| ---------------------------------------------------------------------------------------------------------------------------- |
| [Conclusions reviewed against actual artifacts by a fresh-context research peer](plugin/hooks/prompts/stop_research_peer.md) |
| [In-place edits to git-tracked source over SSH](plugin/scripts/remote_inplace_edit_guard.sh)                                 |
| [Unverified commands or paths in outbound teammate messages](plugin/scripts/outbound_artifact_reminder.sh)                   |
| [Project-internal jargon shapes in commits and docs](plugin/scripts/jargon_scrub.sh)                                         |
| [Timezone tokens that do not match the system clock](plugin/scripts/timezone_scrub.sh)                                       |
| [Pre-flight checklist on long ML training launches](plugin/scripts/long_job_launch_inject.sh)                                |
| [Fabricated paths in destructive commands (rm / mv / dd / force-push)](plugin/scripts/destructive_path_guard.sh)             |
| [Missing citation verification when editing .tex/.bib](plugin/scripts/citation_guard.sh)                                     |
| [LaTeX compilation errors after .tex edits](plugin/scripts/latex_check.sh)                                                   |
| [Unreviewed generated images/figures](plugin/scripts/visual_check.sh)                                                        |
| [Research state loss before context overflow](plugin/scripts/save_state.sh)                                                  |

---

## How It Compares

|                                           | phd-skills                  | flonat/claude-research       | Others       |
| ----------------------------------------- | --------------------------- | ---------------------------- | ------------ |
| Commands to learn                         | 6                           | 39                           | 13-20        |
| Research integrity hooks                  | 11 (agent + 10 auto-detect) | 1                            | 0            |
| Paper reproduction (arxiv to runs)        | **Yes** (7-stage skill)     | No                           | No           |
| Paper-code consistency audit              | 5-dimension parallel        | Read-only, no code cross-ref | None         |
| Experiment monitoring + SSH notifications | Yes (ntfy / slack / email)  | No                           | No           |
| External dependencies                     | **None**                    | npm + pip + MCP servers      | MCP required |
| Install time                              | 30 seconds                  | 10+ minutes                  | Varies       |

---

## Design Principles

1. **Methodology over scripts**. Skills teach the approach, Claude generates code for your specific setup (wandb, neptune, local files, whatever)
2. **Human oversight first**. Claude makes premature claims and jumps to conclusions. Every skill builds in verification checkpoints
3. **Actionable output**. Ranked suggestions with specific fixes, never just a list of findings

---

## License

MIT. Use it, fork it, adapt it to your research.

## Thank you for the support!

[![Star History Chart](https://api.star-history.com/svg?repos=fcakyon/phd-skills&type=Date)](https://www.star-history.com/#fcakyon/phd-skills&Date)

## Contributors

<p align="center">
    <a href="https://github.com/fcakyon/phd-skills/graphs/contributors">
      <img src="https://contrib.rocks/image?repo=fcakyon/phd-skills" />
    </a>
</p>
