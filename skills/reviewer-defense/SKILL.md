---
name: reviewer-defense
description: >
  Use when the user wants to anticipate reviewer questions, select the
  strongest ablations to present, prepare rebuttals, or identify paper
  weaknesses before submission. Triggers on phrases like "reviewer
  questions", "anticipate reviewers", "rebuttal", "paper weaknesses",
  "defend the paper", or "strengthen the paper".
---

# Reviewer Defense Methodology

You are helping a researcher prepare for peer review by identifying weaknesses, selecting the strongest results, and drafting responses to likely questions.

## Step 1: Vulnerability Analysis

Read the paper and identify weaknesses from a reviewer's perspective:

### Technical Weaknesses
- Missing baselines that reviewers would expect
- Evaluation metrics that don't fully capture the contribution
- Assumptions stated without justification
- Scalability concerns not addressed
- Missing error analysis or failure case discussion

### Presentation Weaknesses
- Claims stronger than evidence supports
- Missing related work that a reviewer in the area would know
- Unclear methodology (could someone reimplement from the paper alone?)
- Figures that don't clearly convey the intended message
- Inconsistencies between sections

### Experimental Weaknesses
- Small dataset size without justification
- Missing statistical significance tests
- No comparison with state-of-the-art on standard benchmarks
- Hyperparameter sensitivity not explored
- No computational cost comparison

## Step 2: Venue-Specific Anticipation

Different venues have different review cultures:

**Top-tier ML/CV conferences (CVPR, NeurIPS, ICLR, ECCV)**:
- Expect extensive ablation studies
- Strong baseline comparisons required
- Novelty must be clearly articulated
- Reproducibility is valued

**Workshops**:
- More tolerant of work-in-progress
- Interesting ideas valued over exhaustive evaluation
- Novel applications of existing methods are acceptable

**Journals**:
- Expect thorough related work discussion
- Deeper analysis and more experiments than conferences
- Writing quality and organization matter more

## Step 3: Question Generation

Generate likely reviewer questions, ranked by probability:

For each question:
1. **The question** — phrased as a reviewer would write it
2. **Why they'd ask** — what triggers this concern
3. **Can existing data answer it?** — yes (point to specific data) or no (new experiment needed)
4. **Draft response** — if answerable, write a concise response

Template:
```
Q: [Reviewer question]
Motivation: [Why this would be asked]
Answerable: [Yes — cite Table X / No — would need experiment Y]
Draft response: [If answerable, 2-3 sentences]
```

Generate at least 10 questions, prioritized by likelihood.

## Step 4: Ablation Selection

From all available experiments, select the subset that:

1. **Proves the core contribution** — the single most important ablation
2. **Shows each component's value** — incremental additions showing improvement
3. **Addresses anticipated weaknesses** — preemptively answers likely questions
4. **Tells a coherent story** — the progression makes narrative sense

Ranking criteria for each ablation:
- **Impact magnitude**: how much does it change the primary metric?
- **Narrative strength**: does it clearly support a specific claim?
- **Uniqueness**: does it show something no other ablation shows?
- **Cost**: main paper vs appendix (based on space constraints)

## Step 5: Negative Results

Negative results are valuable when properly framed:

- "We explored X but found it did not improve over Y because Z"
- This shows thoroughness and provides insight
- Frame as "analysis" not "failure"
- Include in supplementary if not in main paper

## Step 6: Rebuttal Preparation

If responding to actual reviews:

1. **Read ALL reviews** before responding to any
2. **Identify common concerns** across reviewers
3. **Prioritize**: address factual errors first, then major concerns, then minor ones
4. **Be respectful**: thank reviewers, acknowledge valid points
5. **Be specific**: point to exact sections, tables, figures
6. **New experiments**: only promise what you can deliver in the rebuttal period

Rebuttal structure per reviewer:
```
We thank Reviewer X for their thoughtful feedback.

**[Major concern]**: [Direct response with evidence]

**[Specific question]**: [Concrete answer]

**[Suggestion]**: [How we will incorporate it]
```

## Output Format

Produce:
1. **Weakness table**: categorized weaknesses with severity
2. **Top 10 anticipated questions**: with answerability and draft responses
3. **Recommended ablation subset**: with justification for each
4. **Suggested text edits**: specific paragraphs to strengthen before submission
