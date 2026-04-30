---
name: compare
description: Same-epoch comparison of training runs across wandb, neptune, tensorboard, or mlflow. Aligns runs at the student's current step (never current-vs-final-of-baseline) and separates proxy metrics from downstream targets. Use when the user asks to compare runs, check if a run is improving, track lag against a baseline, rank experiments, or evaluate run-vs-run performance.
---

# Compare: same-epoch run comparison across trackers

The most common comparison error is reporting "run A is 4 percentage points behind baseline" when run A is at epoch 11 of 100 and the baseline number is from epoch 100. The student is _still training_; the comparison is meaningless. This skill enforces same-epoch alignment.

The agentic Stop hook routes here from `reason` when an assistant reports a delta without aligning the runs.

## When to run

The user just said any of:

- "compare run A to baseline / to run B"
- "is my run improving / catching up / falling behind"
- "rank these experiments"
- "X vs Y wandb / neptune"
- "track lag against baseline"

## Auto-detect the tracker

Check in this order:

1. `WANDB_API_KEY` env var set, or `wandb` imports in the project → **wandb**
2. `NEPTUNE_API_TOKEN` env var set → **neptune**
3. `MLFLOW_TRACKING_URI` env var set, or `mlruns/` dir present → **mlflow**
4. `runs/` or `lightning_logs/` dir present → **tensorboard**
5. `*results*.json` / `*meta*.json` files in run dirs → **local file format**

If none, ask the user where metrics live before guessing.

## The protocol

### 1. Identify the runs

Get full names (no shortcodes). If the user says "fvs-fm vs the baseline", clarify:

- which `fvs-fm` run (project + entity + run-id)
- which baseline (full run name; baselines often have several variants)

### 2. Fetch metric history (not just final value)

You need the full curve, not the last reported value. Final-value-only comparisons hide convergence dynamics.

For wandb:

```python
import wandb
api = wandb.Api()
run = api.run("entity/project/run-id")
history = run.history(samples=10000)  # full history, not just summary
```

For tensorboard, parse the event files (`tensorboard.backend.event_processing.event_accumulator.EventAccumulator`).

For neptune / mlflow, use their respective APIs.

### 3. Find the student's current step

The student is the run still in progress (or the one being evaluated). Get its current epoch / step from the latest history row.

### 4. Slice the baseline at the same step

This is the critical step. The baseline went all the way to (say) epoch 100. The student is at epoch 11. Pull the baseline's metrics _at epoch 11_, not at epoch 100.

```python
student_step = student_history['epoch'].max()
baseline_at_same_step = baseline_history[baseline_history['epoch'] == student_step]
```

If the baseline doesn't have an exactly-matching step, interpolate or pick the nearest. State which.

### 5. Separate proxy metrics from downstream

Most ML pipelines have a _proxy metric_ (cheap, computed during training, kNN accuracy on features, loss, perplexity) and a _target downstream metric_ (expensive, computed periodically or only at the end, finetuned linear probe accuracy, downstream task F1).

The proxy is for tracking convergence; the target is what the project is actually optimizing. Reporting only the proxy can mislead, a run that lags on kNN may close the gap on downstream finetune. Report both, separately:

```
                        | student (ep 11) | baseline (ep 11) | delta |
| proxy (kNN top-1)     | 36.4%           | 38.9%            | -2.5  |
| downstream (linear)   | not yet         | 42.1%            | n/a   |
```

If the user only has proxy data, say so explicitly. Never declare a winner from proxy alone.

### 6. Run names in output

In every line of the report, use full run names. Never `cs-ad vs fvs-fm`; always `phase1-7src-conv-s-adaptor-mlp vs phase1-7src-fastvit-s-featmap-mlp`. Future-you reading this will not remember the shortcode.

## Anti-patterns

- "X is behind baseline by 4pp": without saying _at what step_. Almost always wrong.
- "X has converged": without showing the last 5 epochs of the curve.
- "Best run is Y": based on a metric that was logged differently across runs (different reduction, different eval set).
- Single-seed comparison treated as definitive. Note variance if known; otherwise label as single-seed.

## Output

Compact comparison table per metric pair (proxy + downstream). Each row aligned at the student's current step. Each cell traceable to a specific tracker run-id and step. End with one or two sentences interpreting the comparison, `student is on track to catch up at step N, projected from current slope` is a useful framing; `student is winning / losing` is rarely warranted before convergence.
