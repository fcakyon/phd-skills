---
name: paper-verification
description: >
  Use when the user wants to verify paper claims against code or data,
  audit numerical accuracy, check formula-code alignment, or validate
  citation accuracy. Triggers on phrases like "verify claims",
  "check numbers", "do the numbers match", "formula vs code",
  "audit the paper", or "cross-check results".
---

# Paper Verification Methodology

You are helping a researcher verify that their paper accurately reflects their code and experimental results. This is the most critical quality control step in academic writing.

## Verification Dimensions

### 1. Numerical Accuracy Audit

For every number in the paper (dataset sizes, metric values, percentages, counts):

1. **Extract** the number and its context from the .tex file
2. **Trace** it to its source: code output, result file, log, or tracking system
3. **Verify** the value matches exactly (watch for rounding, percentage vs decimal)
4. **Flag** any number that cannot be traced to a source

Template:
```
| Paper claim | Location (.tex) | Source file/code | Source value | Match? |
|-------------|-----------------|-----------------|-------------|--------|
| "13,999 frames" | abstract L3 | len(glob(labels/*.json)) | ? | ? |
| "4.2% improvement" | Table 2 | eval_results.json | ? | ? |
```

Common numerical errors:
- Rounding inconsistencies (3.14 in text, 3.1415 in table)
- Stale numbers from earlier experiments not updated after re-runs
- Percentage vs absolute confusion
- Off-by-one in dataset counts (headers counted, or not)

### 2. Terminology Consistency Audit

1. **Extract** all defined terms from the methods section
2. **Search** for each term across ALL sections
3. **Flag** any inconsistent usage:
   - Same concept, different names (e.g., "tag head" vs "classification head")
   - Same name, different meanings across sections
   - Defined but never used, or used but never defined

### 3. Code-Paper Alignment

For each method described in the paper:

1. **Find** the corresponding code (function, class, module)
2. **Compare** the paper's description with the actual implementation
3. **Check** specifically:
   - Algorithm steps match code flow
   - Hyperparameters in text match config/code defaults
   - Architecture descriptions match model code
   - Loss functions in equations match loss code
   - Training procedures match training scripts

Common mismatches:
- Paper describes an idealized version, code has edge cases not mentioned
- Hyperparameters changed during development but paper not updated
- Paper describes a method that was later modified or removed from code

### 4. Formula-Code Verification

For each equation in the paper:

1. **Identify** the equation and its variables
2. **Find** the code that implements it
3. **Map** each mathematical operation to its code equivalent
4. **Verify**:
   - Summation bounds match loop bounds
   - Division operations handle edge cases
   - Normalization factors match
   - Gradient flow matches (detach, no_grad)
   - Reduction operations (mean vs sum) match

### 5. Citation Fact-Checking Protocol

For each citation in the paper:

**Step 1**: Extract the claim and the cited paper
**Step 2**: Verify BibTeX metadata against DBLP:
- Author names (exact spelling, correct order)
- Paper title (exact, from published version not preprint)
- Venue and year (confirmed against actual publication)

**Step 3**: For cited claims with specific numbers:
- Locate the exact table/figure in the cited paper
- Verify the number matches what the citing paper states
- If the number cannot be confirmed, suggest qualitative language instead

**Step 4**: Check for common citation errors:
- Citing preprint when published version exists
- Wrong year (submission vs publication)
- Author name misspellings
- Citing for a claim the paper doesn't actually make

## Verification Process

1. Read the full paper (or specified sections)
2. Build the verification table for each dimension
3. For each entry, read the source and verify
4. Produce a prioritized issue list:
   - **HIGH**: Incorrect numbers, wrong claims, missing citations
   - **MEDIUM**: Terminology inconsistencies, stale but close numbers
   - **LOW**: Minor formatting, optional improvements

## Output Format

Produce a structured verification report:

1. **Summary**: X issues found (Y high, Z medium, W low)
2. **Numerical audit table**: each number with source and match status
3. **Terminology issues**: inconsistent terms with locations
4. **Code-paper mismatches**: description vs implementation gaps
5. **Citation issues**: metadata errors and unverified claims
6. **Suggested fixes**: specific text replacements for each issue
