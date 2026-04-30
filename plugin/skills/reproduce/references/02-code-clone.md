# Stage 2: Existing code discovery + inventory

Most papers ship some code. Almost none ship complete training pipelines. The goal of this stage is to know exactly what you have and exactly what you need to build.

## Discover code repos

### 1. From the paper's claimed link

If `paper.md` lists an official repo URL, use it. Verify the URL actually works:

```bash
gh repo view <owner>/<repo>
```

### 2. Search if no official link

```bash
gh search repos "<paper title fragment>" --language python --sort stars --limit 10
gh search repos "<arxiv id>" --limit 10
```

Sometimes authors release code under a different name. Check the README of high-star matches for an arxiv reference back to your paper.

### 3. Papers With Code

Manually visit `https://paperswithcode.com/paper/<paper-slug>`. PWC often lists multiple implementations including community reproductions that may be more complete than the official one.

## Clone and inventory

### 1. Shallow clone

```bash
cd repro/ < arxiv-id > /
git clone --depth 1 < repo-url > code/
```

Shallow clone is fine, you don't need history, you need current state.

### 2. Inventory what's there

Walk the repo and answer each:

| Component                  | Present? | Path       | Notes                                                               |
| -------------------------- | -------- | ---------- | ------------------------------------------------------------------- |
| Model definition           | y/n      | `<path>`   | Is it complete or does it import from a private vendored module?    |
| Data loaders               | y/n      | `<path>`   | Does it match the dataset format the paper used?                    |
| Augmentation pipeline      | y/n      | `<path>`   | Often missing or simplified vs paper                                |
| Loss function(s)           | y/n      | `<path>`   | Compare to equations in `paper.md`                                  |
| Training loop              | y/n      | `<path>`   | The most commonly-missing piece                                     |
| Optimizer + schedule setup | y/n      | `<path>`   | Often present but with different defaults than paper                |
| Eval scripts               | y/n      | `<path>`   | Present in inference repos but rarely matches paper's eval protocol |
| Pretrained checkpoints     | y/n      | `<url>`    | Often released even when training code is not                       |
| Configs                    | y/n      | `<path>`   | YAML / JSON / py, note structure                                   |
| Reproduction instructions  | y/n      | `<README>` | Trust but verify; READMEs often lag                                 |

Save this table to `repro/<arxiv-id>/inventory.md`.

### 3. Compare against gaps from paper.md

Look at the `# Open questions` from stage 1. Cross-reference each with the inventory:

- some open questions get resolved by reading the code (the paper said "default settings" but the code shows the defaults)
- some open questions remain (no code, or code-vs-paper mismatch)

The remaining open questions are the inputs to stage 3.

### 4. Sanity-check the model definition

Even if the model code is present, do a quick read-through:

- does the architecture in code match figure 2 / figure 3 of the paper?
- are the layer dimensions consistent with table 1?
- are there any flags / features in the code that aren't mentioned in the paper?

Note any mismatches in `inventory.md`. The code is usually the source of truth, but if the paper's claim depends on a feature absent from the code, that's important.

## Success criteria

- `inventory.md` exists with the full table
- every "missing" component has a path in the planned implementation (i.e. you know where you'll create it in stage 4)
- the open-questions list from `paper.md` has been triaged: each item is now either "resolved by code at <path>" or carried forward to gap analysis

If the inventory shows the paper has a complete training repo, you may be able to skip directly to stage 5 (dataset). But verify completeness with one smoke before assuming.
