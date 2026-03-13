---
description: >
  Multi-dimensional paper audit — spawns 5 parallel sub-agents to check
  numerical accuracy, terminology consistency, code-paper alignment,
  citation accuracy, and evaluation integrity.
allowed-tools: Agent, Read, Glob, Grep, Bash, WebSearch, WebFetch
---

# Paper X-Ray Audit

You are performing a multi-dimensional audit of a research paper against its codebase and experimental results.

## Step 1: Discover Paper Files

Find all .tex files in the project:
- Use Glob to find `**/*.tex` files
- Identify the main .tex file (usually imports other sections)
- Find .bib files for citation checking
- Find result files (JSON, CSV, logs) for numerical verification

## Step 2: Launch Parallel Audits

Spawn **5 sub-agents in parallel**, each handling one audit dimension. Each agent should return a structured list of findings rated HIGH/MEDIUM/LOW.

### Agent 1: Numerical Accuracy
Task: Extract every number from the .tex files (dataset sizes, metric values, percentages, counts). For each number, trace it to its source in the codebase — a result file, code output, config, or tracking system. Report any number that doesn't match its source or cannot be traced.

### Agent 2: Terminology Consistency
Task: Extract all technical terms defined in the methods section. Search for each term across ALL sections of the paper. Flag inconsistent usage: same concept with different names, same name with different meanings, defined but unused terms, or used but undefined terms.

### Agent 3: Code-Paper Alignment
Task: For each method or algorithm described in the paper, find the corresponding code implementation. Compare the paper's description with the actual code. Check that hyperparameters, architecture details, loss functions, and training procedures match between paper and code.

### Agent 4: Citation Accuracy
Task: Read the .bib file. For each entry, verify author names, venue, and year against web search or DBLP. For cited claims in the .tex files that include specific numbers, check whether those numbers appear in the cited paper. Flag unverified metadata and unsupported cited claims.

### Agent 5: Evaluation Integrity
Task: Review the evaluation code and result files. Check for: data leakage between train/val/test splits, off-by-one errors in metric computation, wrong aggregation methods (micro vs macro), mismatched ground-truth and prediction alignment, zero-division edge cases, and results that don't reproduce from the evaluation scripts.

## Step 3: Consolidate Results

After all agents return, merge their findings into a single prioritized list:

### Output Format
```
## X-Ray Audit Results

### HIGH Priority (must fix before submission)
1. [Dimension] Finding description — suggested fix

### MEDIUM Priority (should address)
1. [Dimension] Finding description — suggested fix

### LOW Priority (nice to have)
1. [Dimension] Finding description — suggested fix
```

## Step 4: Auto-Fix Offer

For HIGH priority issues that have clear fixes (wrong numbers, typos, stale values):
- Show the exact .tex location and current text
- Show the verified correct value from the source
- Ask the user for confirmation before applying fixes
