# Stage 5: Dataset acquisition

The dataset is the hardest part of most reproductions. Public datasets are usually fine; private datasets require a substitution decision that needs to be documented honestly.

## Public dataset path

### 1. Try HuggingFace datasets first

```
mcp__claude_ai_Hugging_Face__hub_repo_search({
  query: "<dataset name>",
  repo_type: "dataset"
})
```

If the dataset is on HF Hub, loading it is one line:

```python
from datasets import load_dataset
ds = load_dataset("<org>/<name>", split="train")
```

This handles caching, format conversion, and version pinning automatically.

### 2. Fall back to the official source

If not on HF:

- the paper's "data" section usually lists the canonical URL
- check the cloned repo's README for download instructions
- use `wget` / `curl` / `aria2c` for direct download (parallel chunks for large datasets)

### 3. Verify dataset integrity

Always check:

```bash
ls -la data/ < dataset > / | head
du -sh data/ < dataset > /*

# Sample-count sanity check
find data/ -type f -name "*.jpg" < dataset > /train | wc -l
# does this match the paper's reported train size?
```

If the count is off, you likely have a corrupted download or a different version. Resolve before stage 6.

### 4. Match split conventions

Papers sometimes use non-standard splits:

- "train" might mean "trainval" combined
- "val" might be the held-out test set the paper actually reports on
- some papers split the canonical val into val + dev_test

Document the split convention you're using in `repro/<arxiv-id>/dataset.md`:

```markdown
# Dataset

**Source**: HuggingFace `<org>/<name>` v1.2.0 (commit hash <abc>)
**Train**: 1,281,167 samples (matches paper's table 1)
**Val**: 50,000 samples (paper's "test set", note: paper calls val "test")
**Splits used**:

- training: HF "train" split as-is
- evaluation: HF "validation" split, no further subsplit
```

## Private dataset path (substitution)

If the paper used a proprietary, gated, or paper-specific collected dataset that isn't publicly available:

### 1. Try harder for legitimate access

- check if it's gated on HF (sometimes a free agreement gets you in)
- email the corresponding author (this often works)
- check if the academic license is available via institutional access
- check OpenReview reviewer guidance for the venue (sometimes "data on request" was promised)

### 2. Substitute with care

If access is genuinely impossible, pick a _structurally similar_ public dataset:

**Selection criteria:**

- same task type (classification → classification, not classification → detection)
- same modality (images at similar resolution, text at similar length)
- similar scale (don't substitute a 10-class 1k-image dataset for a 1000-class 1M-image one)
- prefer datasets cited in the paper's _related work_ section: those are explicitly comparable in the authors' framing

Use HF search with task tags:

```
mcp__claude_ai_Hugging_Face__hub_repo_search({
  query: "<task type> <modality> <key constraints>",
  repo_type: "dataset"
})
```

### 3. Document the substitution

Substitution is a real scientific compromise. It must be visible:

```markdown
# Dataset substitution

**Original dataset (paper)**: ProprietaryDataset-X (not publicly available)
**Substitute**: HuggingFace `<org>/<public-name>`

**Justification**:

- Task: both are <task type>
- Modality: both are <modality>
- Scale: substitute is <X>k samples vs paper's <Y>k (within an order of magnitude)
- Cited in paper related work as comparable: <yes/no>

**Bias caveats**:

- the substitute has <some property> that the paper's dataset did not
- the substitute's class distribution is <skewed/balanced> differently
- the substitute may favor / disadvantage methods that <some sensitivity>

**Expected impact on reproduction**:

- absolute metric numbers will differ from the paper's
- relative comparisons within our reproduction (method A vs method B) are still meaningful
- claims that depend specifically on the original dataset's properties cannot be validated
```

This document goes into `repro/<arxiv-id>/dataset_substitution.md` and is referenced from `results.md` in stage 7.

## Symlink, don't copy

For large datasets, symlink into the workspace rather than copying:

```bash
ln -s /shared/datasets/imagenet repro/ < arxiv-id > /data/imagenet
```

Saves disk space and avoids stale duplicates.

## Success criteria

- dataset accessible from `train.py` at the configured path
- sample counts validated against the paper's reported numbers (or substitution documented if not)
- splits documented in `dataset.md`
- if substituted, `dataset_substitution.md` is honest about the compromise
