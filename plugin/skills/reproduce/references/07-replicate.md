# Stage 7: Replication runs and comparison

The implementation works in smoke. Now run it at full scale and compare honestly to the paper's numbers.

## Plan the runs

Use the existing `experiment-design` skill to plan:

- minimum: one full run reproducing the paper's main result (e.g. their primary baseline)
- ideal: 3 seeds for the main result + 1 run per important ablation
- budget-aware: pick the subset of ablations that the paper itself reports as load-bearing

The plan goes into `repro/<arxiv-id>/run_plan.md` with one row per planned run:

| Run name           | Goal                          | Config                              | Expected duration | Expected metric |
| ------------------ | ----------------------------- | ----------------------------------- | ----------------- | --------------- |
| `repro-main-seed0` | reproduce paper table 1 row 1 | `configs/repro-default.yaml`        | 24 GPU-hours      | ~76.0% top-1    |
| `repro-main-seed1` | seed variance                 | `configs/repro-default.yaml seed=1` | 24 GPU-hours      | ~76.0% top-1    |
| `repro-no-ema`     | ablation: EMA off             | `configs/repro-default-noema.yaml`  | 24 GPU-hours      | ~74.5% top-1    |

## Launch with the launch checklist

Every full run goes through `/phd-skills:launch` first. The checklist will:

- diff your config against the previous reference run
- verify dataset and checkpoint paths
- confirm monitoring is set up (wandb tags scoped to this reproduction)
- verify the run name has no internal jargon (use `repro-main-seed0`, not `wave-1`)
- record an ETA in your local timezone

Do not skip the checklist for "small" runs. The hooks will warn anyway.

## Track progress at the paper's reported epochs

Don't only check the final number. The paper usually reports a metric trajectory or at least mid-training checkpoints. Use `/phd-skills:compare` to align comparisons:

> "Compare repro-main-seed0 to the paper's reported numbers at each of the paper's checkpoints (typically epochs 25, 50, 75, 100)."

Same-epoch comparisons surface convergence problems early, if the paper hits 60% top-1 by epoch 50 and your run is at 45%, that's diagnostic before the run finishes.

## Record results honestly

`repro/<arxiv-id>/results.md` is the final artifact:

```markdown
# Reproduction results

**Paper claim**: 76.0 ± 0.2 top-1 on ImageNet val (from table 1)

## Our runs

| Run              | Final top-1 | Final top-5 | Wall-clock  | Notes     |
| ---------------- | ----------- | ----------- | ----------- | --------- |
| repro-main-seed0 | 75.7        | 92.4        | 23.4 GPU-hr | clean run |
| repro-main-seed1 | 75.9        | 92.5        | 23.5 GPU-hr | clean run |
| repro-main-seed2 | 75.8        | 92.4        | 23.5 GPU-hr | clean run |

**Mean (3 seeds)**: 75.8 ± 0.1
**Paper claim**: 76.0 ± 0.2
**Delta**: -0.2 ± 0.2

## Verdict

**[matched within 0.3 pp]**, within paper's reported variance. Reproduction successful.

## Ablations

| Ablation | Our delta | Paper delta | Notes                                         |
| -------- | --------- | ----------- | --------------------------------------------- |
| no EMA   | -1.2      | -1.4        | matches direction; slightly smaller magnitude |
| no mixup | -0.8      | -1.1        | matches direction                             |
```

## Three verdict labels

Use exactly one per metric:

- **`[matched within X pp]`**: your number is within the paper's reported variance (or, if no variance reported, within ±0.5pp on top-1 / ±1pp on more variable metrics)
- **`[gap, hypothesis: ...]`**: your number is measurably below the paper's, with a stated cause hypothesis (e.g. "we used a smaller batch size and didn't rescale lr; expect ~1pp gap")
- **`[fundamental disagreement, see X]`**: your number contradicts the paper in a way that can't be explained by config mismatch, points at either a real reproduction failure or a paper claim that doesn't hold up

Be honest. Reproductions that find gaps are more valuable than reproductions that fudge numbers to match.

## Cite handoffs

In `results.md`, cite which skills were used at each stage:

> Implementation gaps tracked in `gaps_filled.md` and verified via the `paper-verification` skill (round-trip checked 2026-04-30).
> Smoke runs ran clean per `/phd-skills:reproduce` stage 6.
> Replication runs launched via `/phd-skills:launch` checklist (logs in `launch_logs/`).
> Numerical comparison aligned via `/phd-skills:compare` at paper's reported epochs.

This is also useful documentation for someone reviewing the reproduction later.

## Success criteria

- at least one full replication run completes successfully
- `results.md` exists with verdict labels for each metric the paper reports
- gaps and disagreements have stated hypotheses, not just "we didn't match"
- the workspace is portable: someone else with the same data could rerun your `repro-main-seed0` from `configs/repro-default.yaml` and get the same number
