---
name: research-publishing
description: >
  Use when the user wants to prepare code for open-source release,
  create reproducible research artifacts, or structure a repository
  for publication. Triggers on phrases like "publish code",
  "open source release", "reproducibility", "research repository",
  "code release", or "prepare for publication".
---

# Research Publishing Methodology

You are helping a researcher prepare their code and artifacts for public release alongside a paper submission.

## Step 1: Repository Assessment

Before any changes, audit the current state:

1. **Sensitive content scan**:
   - API keys, tokens, credentials (grep for common patterns)
   - Hardcoded paths specific to the researcher's machine
   - Internal URLs or private infrastructure references
   - Personal identifiable information in comments or data

2. **Dependency audit**:
   - List all dependencies with pinned versions
   - Identify any proprietary or restricted-license dependencies
   - Check for abandoned/unmaintained dependencies
   - Verify all dependencies are pip/conda installable

3. **Code organization**:
   - Identify dead code, debugging artifacts, scratch files
   - Find duplicated code that should be unified
   - Check for overly complex code that can be simplified

## Step 2: Repository Structure

A publishable research repository should have:

```
project/
  README.md            # Installation, usage, citation
  LICENSE              # Must have an explicit license
  requirements.txt     # or pyproject.toml with pinned deps
  setup.py / setup.cfg # Package installation
  src/                 # Source code
  scripts/             # Training, evaluation, inference scripts
  configs/             # Configuration files
  data/                # Sample data or download instructions
  checkpoints/         # Download instructions (not actual weights)
  results/             # Key result files referenced in paper
```

## Step 3: Reproducibility Checklist

For each experiment in the paper:

- [ ] Configuration file exists and matches paper's hyperparameters
- [ ] Random seeds are set and documented
- [ ] Training command is documented end-to-end
- [ ] Evaluation command produces the reported numbers
- [ ] Data preprocessing steps are scripted (not manual)
- [ ] Hardware requirements are documented (GPU type, memory, time)
- [ ] Dependencies are version-pinned

## Step 4: README Structure

A research README must include:

1. **Title + one-line description**
2. **Paper link** (arXiv, venue page)
3. **Visual** (architecture diagram, key result figure, or demo GIF)
4. **Installation** (step-by-step, tested on clean environment)
5. **Quick start** (inference on a single example, < 5 commands)
6. **Training** (full reproduction commands)
7. **Evaluation** (reproduce paper numbers)
8. **Model zoo / checkpoints** (download links with expected metrics)
9. **Citation** (BibTeX block)
10. **License**

## Step 5: Code Cleanup

Apply minimal, targeted cleanup:

1. **Remove** debugging prints, commented-out code, scratch experiments
2. **Replace** hardcoded paths with configurable paths (env vars or args)
3. **Add** docstrings to public functions (not internal helpers)
4. **Ensure** the main entry points are clearly documented
5. **Do NOT** refactor working code for style — it adds risk for no benefit

## Step 6: License Selection

Guide the user through license choice:

| License | Allows commercial use | Requires attribution | Copyleft |
|---------|----------------------|---------------------|----------|
| MIT | Yes | Yes | No |
| Apache 2.0 | Yes | Yes | No (patent grant) |
| GPL 3.0 | Yes | Yes | Yes (derivative works) |
| CC BY 4.0 | Yes | Yes | No (for non-code) |
| CC BY-NC 4.0 | No | Yes | No (for non-code) |

Default recommendation: MIT for code, CC BY 4.0 for datasets/models.

## Step 7: Pre-Release Testing

Before publishing:

1. Clone into a fresh directory
2. Follow README installation steps exactly
3. Run quick start commands
4. Run evaluation to verify numbers match paper
5. Check that no sensitive information is in git history

## Output Format

Produce:
1. **Audit report**: sensitive content found, dependency issues, dead code
2. **Action list**: specific files to modify/remove/add
3. **README draft**: following the structure above
4. **Reproducibility checklist**: per-experiment verification status
