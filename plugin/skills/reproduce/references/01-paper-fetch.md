# Stage 1: Paper acquisition

Fetch the paper into a structured local extract before doing anything else. Working from a polished local copy is much faster than re-scrolling arxiv on every hyperparam question.

## Inputs

- arxiv URL or arxiv ID (e.g. `2508.12345`, `https://arxiv.org/abs/2508.12345`)
- OpenReview URL or proceedings URL (CVPR / NeurIPS / ICLR / ICML / etc.)
- direct PDF URL as fallback

## Steps

### 1. Prefer the HTML version

ArXiv's HTML rendering (`https://arxiv.org/html/<id>`) is far easier to parse than the PDF. Try it first via the Tavily MCP tool:

```
mcp__tavily__tavily_extract({
  urls: ["https://arxiv.org/html/2508.12345v1"],
  extract_depth: "advanced"
})
```

If HTML is missing or broken, fall back to:

- `mcp__tavily__tavily_extract` on the abstract page (`/abs/<id>`) to get bibliographic info
- The `pdf` skill (anthropic-office-skills:pdf) on the PDF URL for full content

### 2. Cross-check with HuggingFace papers

Use the HF papers tool to find paper metadata, related papers, and any community-maintained reproduction notes:

```
mcp__claude_ai_Hugging_Face__paper_search({
  query: "<paper title or arxiv id>"
})
```

This often surfaces:

- official author code repo (when arxiv didn't link it)
- community reproductions (huggingface spaces, gradio demos)
- related papers cited later

### 3. Capture into `repro/<id>/paper.md`

Structured extract with these sections (copy verbatim from paper, do not paraphrase yet):

```markdown
# <Paper Title>

**arxiv**: <id>
**venue**: <conference/journal/year>
**authors**: <full author list>
**code**: <official repo url, "none" if not provided>
**abstract**: <verbatim>

## Method (verbatim from paper sections 3-4)

<copy-paste relevant sections>

## Hyperparameter tables (verbatim)

<every table that lists training hyperparameters, dataset stats, eval setup>

## Algorithm boxes (verbatim)

<every numbered algorithm or pseudocode block>

## Loss formulation (with equation numbers)

<every equation referenced from the method, with its number>

## Results tables (verbatim)

<the main result table + ablations>

## Caveats / negative results / mentioned-but-not-shown

<scan the paper for "we found", "in our experiments", "with X we observed", these often
hide critical implementation details>
```

### 4. Note what's missing

At the bottom of `paper.md`, add an `# Open questions` section listing every gap you noticed during the read:

- "Optimizer betas not specified, only said 'AdamW with default settings'"
- "Augmentation pipeline order ambiguous: does cutout happen before or after normalize?"
- "Eval protocol references appendix B which is not in the arxiv version"

These become inputs to stage 3 (gap analysis).

## Success criteria

- `paper.md` exists with all six sections populated
- the `# Open questions` list has at least 3-5 items (most papers have many; if you found zero, you didn't read carefully enough)
- you can answer "what does this paper actually do" in one paragraph from `paper.md` alone

If the paper has an official code repo, note its URL but do not clone yet, that's stage 2.
