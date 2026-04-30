---
description: >
  30-second auto-detection tour, then optional configuration of notifications,
  CLI allowlist, research CLAUDE.md rules, and LaTeX environment.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# PHD-Skills Setup

The plugin works correctly the moment it is installed. Most users never need to run setup. This command exists to (1) show what was auto-detected on the user's system, and (2) let users opt into a few extras (notifications, allowlist, project CLAUDE.md, LaTeX).

## Step 0: Auto-detection tour (always run first)

Before asking any questions, print what the plugin already knows. No prompts, no decisions, just visibility.

Run these probes silently and present the results:

```bash
# System timezone
sys_tz=$(date +%Z)
sys_tz_long=$(readlink /etc/localtime 2> /dev/null | sed 's|.*zoneinfo/||')

# Last few long-job launches the plugin would have flagged
recent_launches=$(history 200 2> /dev/null | grep -E '(python.*train|accelerate launch|torchrun|deepspeed|sbatch|tmux.*python)' | tail -5)

# Sample jargon-shape hits in user's recent commits (if in a git repo)
jargon_hits=$(git log -50 --pretty=format:%s 2> /dev/null | grep -E '\bwave-[0-9]+\b|\bphase-internal\b|\binternal-only\b' | head -3)

# What the agentic Stop hook would orient on for this project
project_orientation=""
[ -f README.md ] && project_orientation+="README.md found  "
[ -f CLAUDE.md ] && project_orientation+="CLAUDE.md found  "
[ -f .claude/CLAUDE.md ] && project_orientation+=".claude/CLAUDE.md found  "
[ -f AGENTS.md ] && project_orientation+="AGENTS.md found  "
```

Then present:

```
phd-skills auto-detected the following:

Timezone:           ${sys_tz} (${sys_tz_long})
Recent launches:    <count> training-job patterns in shell history
Jargon hits:        <count> commits with internal-jargon shapes
Project orientation: ${project_orientation:-no README / CLAUDE.md / AGENTS.md found at project root}

This is what the hooks and agentic Stop hook will use. No configuration needed.
The plugin works on the first command. Hooks fire silently when there is nothing to flag.

Want to configure any extras? (notifications, allowlist, CLAUDE.md, LaTeX) [y/N]
```

If the user says no, you are done. If yes, walk them through the optional steps below.

## Step 1: Feature Selection (optional, only if user opted in)

Use AskUserQuestion:

```
Which extras would you like to set up?

1. Notifications: get alerts when long tasks complete (ntfy / slack / email)
2. CLI Allowlist: auto-approve safe commands used in research workflows
3. Research CLAUDE.md: add research integrity rules to your project
4. LaTeX Environment: detect and configure LaTeX / BibTeX toolchain

Enter numbers separated by commas (e.g., 1,3,4), or "all":
```

## Step 2: Notifications (if selected)

Ask which notification method:

```
How would you like to receive notifications?

1. ntfy.sh: free, works over SSH, no account needed
2. Slack: webhook to a channel
3. Email: via sendmail / msmtp

Enter number:
```

Based on selection:

- **ntfy.sh**: ask for topic name, write to `.env` as `NTFY_TOPIC=<topic>`. Test with `curl -d "phd-skills test" ntfy.sh/<topic>`
- **Slack**: ask for webhook URL, write to `.env` as `SLACK_WEBHOOK_URL=<url>`. Test with curl POST
- **Email**: ask for recipient, write to `.env` as `NOTIFICATION_EMAIL=<email>`. Test with sendmail

## Step 3: CLI Allowlist (if selected)

Show the user a list of safe, non-destructive commands commonly used in research:

```json
{
  "allowedTools": [
    "Read",
    "Glob",
    "Grep",
    "Bash(pdflatex *)",
    "Bash(biber *)",
    "Bash(bibtex *)",
    "Bash(python -c *)",
    "Bash(uv run *)",
    "Bash(git status)",
    "Bash(git diff *)",
    "Bash(git log *)",
    "Bash(nvidia-smi)",
    "Bash(htop)",
    "Bash(df -h)",
    "Bash(wc -l *)",
    "Bash(du -sh *)"
  ]
}
```

Ask for confirmation, then merge into `.claude/settings.json`.

## Step 4: Research CLAUDE.md (if selected)

Present the following research integrity rules to add to the project's CLAUDE.md:

```markdown
## Research Integrity Rules

- Code is the source of truth. When paper text and code disagree, the code is correct
  unless the user explicitly states otherwise.
- Never state a numerical result without tracing it to a specific file, log, or code output.
  If you cannot find the source, say so explicitly.
- Never assume domain-specific technical behavior. Verify against code before making claims
  about how methods, losses, architectures, or training procedures work.
- When editing paper text, change ONLY what was requested. Do not remove existing content,
  add unrequested sections, or "improve" surrounding text unless asked.
- Citation integrity: verify author names, venue, and year against DBLP before adding or
  modifying any BibTeX entry. Flag any citation detail you cannot verify.
```

Ask the user to confirm, then:

- Read existing CLAUDE.md (if any)
- Append the research rules section (avoiding duplicates)

## Step 5: LaTeX Environment (if selected)

Trigger the `latex-setup` skill by telling the user:

```
I'll now analyze your LaTeX setup and install any missing components.
```

Then follow the latex-setup skill methodology:

1. Check installed TeX distribution
2. Analyze .tex files for requirements
3. Install missing packages
4. Verify compilation works

## Escape hatches (mention only if asked)

The plugin avoids configuration on purpose. If a user really wants to override:

- **Suppress a hook**: edit `~/.claude/settings.json` and set `"hooks.<event>.<matcher>.disabled": true` (Claude Code's standard mechanism)
- **Override timezone**: set `TZ=Region/City` env var (system standard)
- **Stop the jargon scrubber from flagging a token**: add the token to your project's `README.md` or any `docs/*.md`. The scrubber treats documented tokens as legitimate.
