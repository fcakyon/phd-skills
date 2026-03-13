---
description: >
  Interactive onboarding wizard — configure notifications, CLI allowlist,
  research-specific CLAUDE.md rules, and LaTeX environment.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# PHD-Skills Setup Wizard

Guide the user through interactive setup. Use AskUserQuestion for each step.

## Step 1: Feature Selection

Ask the user which features to configure:

```
Which features would you like to set up?

1. Notifications — get alerts when long tasks complete (ntfy/slack/email)
2. CLI Allowlist — auto-approve safe commands used in research workflows
3. Research CLAUDE.md — add research integrity rules to your project
4. LaTeX Environment — detect and configure LaTeX/BibTeX toolchain

Enter numbers separated by commas (e.g., 1,3,4), or "all":
```

## Step 2: Notifications (if selected)

Ask which notification method:

```
How would you like to receive notifications?

1. ntfy.sh — free, works over SSH, no account needed
2. Slack — webhook to a channel
3. Email — via sendmail/msmtp

Enter number:
```

Based on selection:
- **ntfy.sh**: Ask for topic name, write to `.env` as `NTFY_TOPIC=<topic>`. Test with `curl -d "phd-skills test" ntfy.sh/<topic>`
- **Slack**: Ask for webhook URL, write to `.env` as `SLACK_WEBHOOK_URL=<url>`. Test with curl POST
- **Email**: Ask for recipient, write to `.env` as `NOTIFICATION_EMAIL=<email>`. Test with sendmail

## Step 3: CLI Allowlist (if selected)

Show the user a list of safe, non-destructive commands commonly used in research:

```json
{
  "allowedTools": [
    "Read", "Glob", "Grep",
    "Bash(pdflatex *)", "Bash(biber *)", "Bash(bibtex *)",
    "Bash(python -c *)", "Bash(uv run *)",
    "Bash(git status)", "Bash(git diff *)", "Bash(git log *)",
    "Bash(nvidia-smi)", "Bash(htop)", "Bash(df -h)",
    "Bash(wc -l *)", "Bash(du -sh *)"
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
