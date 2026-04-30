# Stage 4: Implementation

Now write the code that fills the gaps. The goal: minimum new code, maximum reuse of the cloned repo.

## Bootstrap the environment

Use `uv` for fast, reproducible Python envs:

```bash
cd repro/ < arxiv-id > /code/
uv venv
source .venv/bin/activate
uv pip install torch numpy transformers wandb pyyaml
```

Add any paper-specific deps (`timm`, `einops`, `datasets`, `accelerate`, etc.) one at a time as you hit imports.

## Reuse before you write

Before writing any new file:

1. Check the cloned repo for an existing scaffold. Many repos have `scripts/` or `tools/` with starter training code, even if incomplete, it gives you the right import/config conventions.
2. Match the existing repo's idioms:
   - if the repo uses `argparse`, don't introduce `hydra`
   - if configs are YAML, don't introduce TOML
   - if the repo uses PyTorch Lightning, don't write a raw loop
3. Vendor missing pieces from `timm` / `transformers` / `accelerate` rather than rolling your own.

## Write the missing pieces

For each "missing" component in `inventory.md`, create _one file per concern_:

- `train.py`: the training loop (most commonly missing)
- `configs/<paper-name>-default.yaml`: the hyperparam config matching `gaps_filled.md`
- `optim_factory.py`: optimizer + schedule construction (if not already in repo)
- `losses.py`: loss functions matching the paper's equations (if not already)
- `eval.py`: eval protocol (if not already, or if existing doesn't match the paper)

Keep files small. A 200-line training loop is suspicious.

## Config-first

Write the config file first, before the training loop. The config is the contract between `gaps_filled.md` and the training code. Every value in the config should appear in `gaps_filled.md` with provenance.

```yaml
# configs/repro-default.yaml
optimizer:
  name: AdamW
  lr: 3e-4
  weight_decay: 0.05
  betas: [0.9, 0.999]
  eps: 1e-8

schedule:
  epochs: 100
  warmup_epochs: 5
  warmup_type: linear
  decay: cosine

batch:
  per_device: 64
  global: 512 # validated at runtime

# ... rest matching gaps_filled.md
```

## Commit per gap

This is the discipline that pays off later. Each commit fills one gap and references its provenance:

```
git add configs/repro-default.yaml
git commit -m "config: optimizer block from paper §4.1 + hyperparam table

Optimizer is AdamW (lr=3e-4, wd=0.05, betas=default).
betas tag is [framework default] since paper says 'default AdamW settings'.
"

git add losses.py
git commit -m "losses: cross-entropy + KL-divergence-with-teacher from paper eq 3-4

Implements L = CE(student, label) + 0.5 * KL(student || teacher) at T=4.
Coefficients from paper §4.1.
"
```

Three benefits:

1. when the run fails or the result diverges, you can `git log` the implementation to see which gap might be wrong
2. when the paper authors release more code later, you can diff per-commit
3. when someone reviews the reproduction, each commit is self-explanatory

## Imports

Match the cloned repo's import style. If it uses absolute imports from a top-level package, do the same. If it uses relative imports inside subpackages, do the same. Import-style mismatches break the run silently when the cloned modules try to find each other.

## What NOT to do

- Don't refactor the cloned code "to make it cleaner" before reproducing the result. Reproduce first, refactor never (or in a separate branch after the result lands).
- Don't add type hints, docstrings, or tests to the cloned code unless they were missing in a way that broke imports. Reproduction is not a code review.
- Don't fix the cloned code's bugs unless they prevent the run. The paper's result was produced by the code-as-written, including its bugs. "Fixing" a bug may explain a non-replication.
- Don't skip writing `train.py` because "the user can write it." The reproduction is incomplete without an executable launch.

## Output

A working training launch:

```bash
python train.py --config configs/repro-default.yaml --debug-mode
```

`--debug-mode` should run for 10 iterations and exit cleanly. If it doesn't, stage 6 will be a mess. Fix it now.

## Success criteria

- `train.py` exists and accepts `--config`
- the config in `configs/repro-default.yaml` matches `gaps_filled.md` 1:1
- `--debug-mode` runs end-to-end (10 iters) without error
- every commit references the gap it filled and the paper section that justified the value
