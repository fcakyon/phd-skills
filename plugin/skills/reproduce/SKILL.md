---
name: reproduce
description: End-to-end paper reproduction from arxiv URL through smoke runs to replication experiments. Handles missing or partial official code, missing training scripts, missing hyperparameters, and private datasets via similar-public-dataset substitution. Use when the user asks to reproduce, implement, replicate, or re-run a paper from scratch, or pastes an arxiv URL with reproduction intent.
---

# Reproduce: paper reproduction from scratch

Reproducing an ML paper often means filling gaps the authors didn't ship, training scripts, hyperparameter tables, augmentation specifics, exact dataset splits. This skill walks seven stages from "I have an arxiv link" to "I have a replication run with measurable delta vs the paper's number."

Each stage has a separate reference file under `references/` so this overview stays scannable.

## When to run

The user just said any of:

- "reproduce / implement / replicate / re-run paper X"
- pasted an arxiv URL with reproduction intent ("can you redo this", "let's try this approach")
- pointed at an OpenReview / proceedings link with the same intent
- said "the paper has no code, can we build it"

## Workflow

| Stage | What                                                           | Reference                                                      |
| ----- | -------------------------------------------------------------- | -------------------------------------------------------------- |
| 1     | Paper acquisition (arxiv HTML → structured extract)            | [references/01-paper-fetch.md](references/01-paper-fetch.md)   |
| 2     | Existing code discovery + inventory                            | [references/02-code-clone.md](references/02-code-clone.md)     |
| 3     | Gap analysis (extract every missing hyperparam from the prose) | [references/03-gap-analysis.md](references/03-gap-analysis.md) |
| 4     | Implementation (uv venv, fill gaps, commit per gap)            | [references/04-implement.md](references/04-implement.md)       |
| 5     | Dataset acquisition (HF datasets first; substitute if private) | [references/05-dataset.md](references/05-dataset.md)           |
| 6     | Smoke runs (forward pass → 1 step → 20 iters)                  | [references/06-smoke.md](references/06-smoke.md)               |
| 7     | Replication runs + comparison at paper's reported epochs       | [references/07-replicate.md](references/07-replicate.md)       |

Walk them in order. Each stage has its own success criteria; do not advance to the next until the current one passes.

## Working directory layout

For each paper reproduction, set up a dedicated workspace:

```
repro/<paper-arxiv-id>/
├── paper.md              # structured extract from stage 1
├── inventory.md          # what exists / missing from stage 2
├── gaps_filled.md        # hyperparam table with provenance from stage 3
├── code/                 # implementation from stage 4 (or cloned + extended)
├── data/                 # dataset symlinks or actual data from stage 5
├── dataset_substitution.md  # if a public dataset stood in for a private one
├── smoke_logs/           # outputs from stage 6
└── results.md            # replication outcomes from stage 7
```

This keeps reproductions self-contained and easy to revisit later.

## Cross-references

- After stage 3, hand the gap analysis off to the `paper-verification` skill for a round-trip check ("did I really capture every hyperparam the paper mentions").
- Stage 4 implementation should be committed in small, reviewable pieces: each commit references the paper section that justified the filled value.
- Stage 6 smoke failures route to the `/phd-skills:debug` skill, not to ad-hoc fixes.
- Stage 7 launches go through the `/phd-skills:launch` checklist before any multi-hour run.
- Stage 7 comparisons go through the `/phd-skills:compare` skill at the paper's reported epochs (never current-vs-final).

## Output

For each reproduction, the final artifact is `results.md` with absolute deltas (not just %) and one of three labels per metric:

- `[matched within 0.X pp]`: within the paper's reported variance
- `[gap, hypothesis: ...]`: measurable underperformance, with a stated hypothesis for the cause
- `[fundamental disagreement, see X]`: the result and the paper's claim are inconsistent in a way that needs investigation, not just more compute

If the workspace is on a public repo, link the workspace README from the project's main reproduction-tracking doc.
