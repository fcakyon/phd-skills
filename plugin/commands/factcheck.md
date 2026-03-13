---
description: >
  Verify BibTeX entries and cited claims against DBLP and web sources.
  Checks author names, venues, years, and specific numerical claims.
allowed-tools: Read, Glob, Grep, Bash, WebSearch, WebFetch
---

# Citation Fact-Check

You are verifying the accuracy of all citations in a research paper.

## Step 1: Find Citation Files

- Glob for `**/*.bib` files in the project
- Read the .bib file(s)
- Glob for `**/*.tex` files to find where citations are used

## Step 2: BibTeX Metadata Verification

For each BibTeX entry:

1. **Search DBLP** for the paper title via web search (query: `site:dblp.org "paper title"`)
2. **Verify**:
   - Author names match exactly (spelling, order, completeness)
   - Publication venue is correct (conference name, journal name)
   - Year is the publication year (not submission or preprint year)
   - Paper title matches the published version (not preprint title)
3. **Flag** any discrepancies with the corrected values

## Step 3: Cited Claims Verification

Search the .tex files for citation patterns (`\cite{...}`, `\citep{...}`, `\citet{...}`).

For each citation that includes a specific claim (especially numerical):
1. Extract the claim and the cited paper key
2. Search for the cited paper online
3. Verify the claim appears in the paper (specific table, figure, or text)
4. If the claim cannot be verified, suggest qualitative rewording

## Step 4: Output

Produce a structured report:

```
## Citation Verification Report

### BibTeX Corrections Needed
| Key | Field | Current | Correct | Source |
|-----|-------|---------|---------|--------|

### Unverified Claims
| .tex location | Claim | Cited paper | Status | Suggestion |
|--------------|-------|------------|--------|------------|

### Corrected BibTeX Entries
(Ready-to-paste corrected entries for any that need fixing)
```
