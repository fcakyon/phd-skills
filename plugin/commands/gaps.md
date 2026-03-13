---
description: >
  Literature gap analysis with web confirmation. Takes a research
  topic or question and maps existing work to find what's missing.
argument-hint: "<research topic or question>"
allowed-tools: Read, Glob, Grep, Bash, WebSearch, WebFetch
---

# Literature Gap Analysis

You are performing a systematic gap analysis for the following research topic:

**Topic**: $ARGUMENTS

## Step 1: Landscape Mapping

Search for existing work on this topic using multiple queries:
- Direct topic search via web search
- Search with alternative phrasings and synonyms
- Check Google Scholar, Semantic Scholar, and arXiv
- Look for survey papers that map the area

## Step 2: Categorize Existing Work

Organize found papers into a coverage table:

```
| Approach Category | Papers | What They Cover | What's Missing |
|-------------------|--------|----------------|---------------|
```

## Step 3: Identify Gaps

For each empty cell or "What's Missing" entry:

1. Search specifically for work that might fill this gap
2. Check very recent papers (last 6 months) on arXiv
3. Look for workshop papers and preprints
4. Assess whether the gap is meaningful

## Step 4: Validate Gaps

For each candidate gap, rate confidence:
- **HIGH**: Searched with 3+ phrasings, checked top venues, clearly missing
- **MEDIUM**: Searched but might have missed niche venues
- **LOW**: Limited search, gap may exist under different terminology

## Step 5: Output

```
## Gap Analysis: [Topic]

### Research Landscape
[2-3 sentence overview]

### Coverage Table
| Approach | Representative Papers | Coverage | Gap? |
|----------|----------------------|----------|------|

### Identified Gaps
| Gap | Confidence | Evidence of Absence | Why It Matters |
|-----|-----------|---------------------|---------------|

### Candidate Papers to Cite
[BibTeX entries for relevant papers — VERIFIED against DBLP]
```
