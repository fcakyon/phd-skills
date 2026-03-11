---
name: fortify
description: >
  Select strongest ablations and anticipate reviewer questions.
  Reads paper and experiment results to prepare for peer review.
argument-hint: "<venue name (optional)>"
allowed-tools: Agent, Read, Glob, Grep, Bash, WebSearch, WebFetch
---

# Paper Fortification

You are helping strengthen a paper before submission by selecting the best ablations and preparing for reviewer questions.

## Step 1: Read the Paper

- Find and read all .tex files
- Identify the claims made in the paper (especially in contributions and experiments)
- Note the evaluation metrics and baselines used

## Step 2: Find Experiment Results

- Search for result files: JSON, CSV, wandb logs, checkpoint directories
- Look for training configs that define ablation variants
- Identify all available experimental runs and their outcomes

## Step 3: Rank Ablations

For each available ablation or experiment:

| Run | Factor Changed | Primary Metric Delta | Narrative Strength | Include? |
|-----|---------------|--------------------|--------------------|----------|

Ranking criteria:
1. **Impact magnitude**: largest metric improvement = most convincing
2. **Narrative strength**: directly supports a specific paper claim
3. **Uniqueness**: shows something no other ablation shows
4. **Anticipated questions**: preemptively answers likely reviewer concerns

Recommend: main paper (top 3-5) vs supplementary (rest).

## Step 4: Generate Reviewer Questions

Consider the venue: $ARGUMENTS (if provided, adjust expectations accordingly).

Generate the **top 10 most likely reviewer questions**:

```
1. [Question]
   Why they'd ask: [motivation]
   Answerable now: [Yes — point to data / No — needs new experiment]
   Draft response: [2-3 sentences if answerable]
```

## Step 5: Identify Weaknesses

List specific weaknesses a reviewer might flag:
- Missing baselines
- Claims not fully supported by evidence
- Scalability or generalization concerns
- Missing statistical significance

## Step 6: Output

```
## Fortification Report

### Recommended Ablation Subset
[Table with justification for each]

### Top 10 Anticipated Questions
[Numbered list with draft responses]

### Weaknesses to Address
[Prioritized list with suggested text edits]

### Suggested Edits
[Specific paragraph-level improvements]
```
