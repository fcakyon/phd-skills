---
name: launch
description: Pre-flight checklist for long-running ML training jobs covering config diff, run naming, path verification, monitoring setup, and restart-cleanup. Use when the user asks to launch, kick off, start, restart, or kill a training run, or mentions launching a multi-hour or multi-day GPU job (python train, accelerate launch, torchrun, deepspeed, sbatch, tmux training).
---

# Launch: pre-flight checklist for long ML training jobs

Long training jobs are expensive to fail. A 12-hour run that crashes on epoch 3 from a missing dataset path or a default `workers=8` against an NFS mount is a full day lost. This skill walks five quick checks before you commit the GPUs.

The agentic Stop hook in this plugin will route here from `reason` when an assistant tries to launch a run without going through the checklist.

## When to run

The user just asked to:

- launch / kick off / start / fire up a training run
- restart a run that died
- kill a current run (also runs the cleanup half of the checklist)
- review a launch command before submitting

Or the user is about to run any of: `python train.py`, `accelerate launch`, `torchrun`, `deepspeed`, `sbatch train.sh`, `tmux new-session ... python ... train`, `wandb sweep`.

## The checklist

### 1. Config diff against a reference run

The most expensive failure is launching with the wrong knobs. Before starting:

```bash
find configs/ recipes/ experiments/ -maxdepth 3 \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.toml' \) -mtime -30 2> /dev/null | head
```

Pick the most-recently-modified config that resembles the intended run (same model family, same task). Diff against the intended config:

```bash
diff -u configs/baseline_v1.yaml configs/intended.yaml
```

Walk every diff line. For each, ask: _is this difference intentional and motivated, or is it a stale default I forgot to set?_ Common silent regressors:

- `num_workers` / dataloader workers (default in many repos is 8: wrong on NFS)
- `batch_size` (per-device vs global mismatch under DDP)
- `learning_rate` (linearly scaled with batch size; if batch changed, lr should too)
- `optimizer` betas / weight decay (paper-default vs framework-default)
- `mixed_precision` (`fp16` vs `bf16` matters for some models)
- `gradient_accumulation_steps`
- `seed` (still set if you care about reproducibility)

If no reference exists in this project, ask the user to point at one. Do not launch with framework defaults alone.

### 2. Run name discipline

The run name will live in wandb / neptune / checkpoint dirs / status reports for the rest of its life. It must describe the experiment in plain English without internal codes:

- bad: `run-1`, `wave-2`, `cs-ad`, `phase2-internal`
- good: `7src-fastvit-s-featmap-mlp-dinov3`, `coco-baseline-bs256-lr3e-4`, `swin-t-imagenet-distill-from-vit-l`

The pattern: `<dataset/task>-<model>-<key-config>-<distinctive-recipe-piece>`. If you can't describe the experiment from the name in one sentence, the name is wrong. The Stop hook flags any run reference that uses session-local labels.

### 3. Path verification

Before launching, every path the run depends on must be confirmed to exist:

```bash
# Dataset path
ls -la /path/to/dataset | head

# Pretrained checkpoint (if loading)
ls -la /path/to/checkpoint.pt

# Output directory parent (must exist; the run dir will be created)
ls -la /path/to/runs/

# Config file
cat configs/intended.yaml | head
```

Never trust a path that was recalled from memory. The `destructive_path_guard.sh` hook will already block obvious cases for `rm`/`mv`, but the launch path needs the same scrutiny, a run started with a nonexistent dataset path crashes 30 minutes in instead of immediately.

### 4. Monitoring setup

Auto-detect the experiment tracker:

- `WANDB_API_KEY` set or `wandb` import in the launcher → wandb
- `NEPTUNE_API_TOKEN` set → neptune
- `MLFLOW_TRACKING_URI` set or `mlflow` in launcher → mlflow
- presence of `runs/` or `lightning_logs/` → tensorboard
- none of the above → ask the user; "no monitoring" is rarely the right answer for a multi-hour run

Confirm the run will appear under the right project / entity / experiment-name. Confirm any tags / groups for cohort comparison are set.

### 5. ETA in your local timezone

Estimate wall-clock duration: `epochs × seconds-per-epoch / 3600 = hours`. State the ETA in your local TZ (the system's TZ, which the `timezone_scrub.sh` hook validates against). If the run will straddle a meeting / sleep / OOO window, decide whether to defer or split.

## Restart and kill cleanup

If this is a restart of a previously-failed run, or a kill before launching a replacement, purge stale artifacts in this exact order:

1. **Local checkpoint dir** on the launching machine: `rm -rf /local/runs/<run-name>` (verify path first; the `destructive_path_guard.sh` will warn).
2. **Remote artifact dir** on the cluster / NFS / object store: `rm -rf /remote/runs/<run-name>` (or equivalent).
3. **Experiment tracker run**: delete via the tracker's API (`wandb api.run(...).delete()`, neptune `run.stop() + delete via UI`, etc.). Stale tracker runs corrupt later comparisons.
4. **Scheduler reservation**: cancel the SLURM job (`scancel <jobid>`), the lambda labs reservation, the cron entry, etc. Runs that "killed but the GPUs are still allocated" are a recurring waste.

Skipping any of these creates ghost state that will confuse the next launch or the next comparison.

## Output

When the user invokes this skill, walk the five checks (or three checks + cleanup, if killing) and report which passed and which failed. Block the launch on any failure unless the user explicitly waives the check.

For a clean launch, end with the launch command itself in a fenced block, ready to copy.
