---
name: paper-writing
description: >
  Use when the user wants to write, structure, or revise academic paper
  sections, improve notation consistency, or refine figures and tables.
  Triggers on phrases like "write the abstract", "structure the methods",
  "improve this section", "notation consistency", "figure refinement",
  or "paper structure".
---

# Academic Paper Writing Methodology

You are helping a researcher write or revise an academic paper. Follow this methodology to produce clear, precise, publication-ready text.

## Core Principles

1. **Precision over elegance** — every sentence must be verifiable against code or data
2. **Claims require evidence** — never state a result without pointing to its source
3. **Notation consistency** — define once, use identically everywhere
4. **Conciseness** — remove words that don't add information

## Section-Specific Guidance

### Abstract
- Structure: problem → approach → key result → significance
- Include 1-2 concrete numbers (dataset size, main metric improvement)
- Every number must be traceable to a specific experiment
- No citations in abstract unless venue requires it

### Introduction
- Paragraph 1: Problem and why it matters (societal/practical motivation)
- Paragraph 2: Why existing approaches are insufficient (gap)
- Paragraph 3: Your approach and why it addresses the gap
- Paragraph 4: Contributions list (concrete, falsifiable claims)
- Each contribution must map to a section that provides evidence

### Related Work
- Organize by theme/approach, not chronologically
- For each group: what they do, what's missing, how your work differs
- Be fair: acknowledge strengths of prior work, don't strawman
- End each paragraph with how your work addresses the limitation

### Methods
- Define all notation in a single place (notation table or first-use definitions)
- Each method component should be independently understandable
- Include enough detail that someone could reimplement from the paper
- Cross-reference equations with corresponding code

### Experiments
- Dataset: size, splits, preprocessing (cite or describe collection)
- Metrics: define formally, explain why these metrics
- Baselines: justify selection, ensure fair comparison
- Results table: highlight best results, include std dev or CI if available
- Ablations: one factor at a time, clearly show contribution of each component

### Conclusion
- Summarize contributions (not the entire paper)
- State limitations honestly
- Future work: specific and feasible, not vague

## Notation Consistency Protocol

When writing or editing any section:
1. Read existing notation definitions in the paper
2. Use EXACTLY the same symbols — do not introduce synonyms
3. If a new symbol is needed, check it doesn't clash with existing ones
4. Maintain a notation table if the paper has one

Common pitfalls:
- Using both $x$ and $\mathbf{x}$ for the same concept
- Defining $N$ as dataset size in methods but using $n$ in experiments
- Inconsistent subscript conventions (e.g., $f_i$ vs $f(i)$)

## Figure Refinement Methodology

Figures are the most iterated component. Follow this process:

### 1. Specification Capture
Before generating or modifying any figure:
- What data does it show? (exact source file/variable)
- What message should the reader take away?
- What are the hard constraints? (font size ≥ 8pt, column width, color scheme)
- What aspects of the current version are correct and must be preserved?

### 2. Constraint Preservation
Across multiple rounds of revision, track constraints explicitly:
```
Constraints for Figure N:
- [KEEP] Y-axis range 0-100
- [KEEP] Color scheme: blue=ours, gray=baselines
- [CHANGE] Legend position: inside → outside
- [ADD] Error bars from std_results.json
```

### 3. Variant Generation
When exploring design alternatives:
- Generate 2-3 variants side by side when feasible
- Each variant changes ONE visual aspect
- Let the user compare and choose, don't pick for them

### 4. Visual Verification
After generating any figure:
- ALWAYS read/inspect the generated image file
- Check that data values match the source
- Verify labels, legends, and annotations are correct
- Confirm the takeaway message is clear from a glance

## Writing Process

1. **Read first** — always read the existing section before writing
2. **Identify the claim** — what is this paragraph trying to say?
3. **Find the evidence** — where in code/results does this come from?
4. **Write the text** — state claim, present evidence, interpret
5. **Verify** — re-read against source to catch any drift

## Output Format

When writing paper text:
- Provide LaTeX-ready output that matches the paper's existing style
- Include comments for any claim that needs verification: `% TODO: verify this number`
- Flag any notation inconsistencies found during writing
- Suggest specific improvements with before/after comparisons
