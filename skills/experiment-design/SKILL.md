---
name: experiment-design
description: >
  Use when the user wants to design experiments, plan ablation studies,
  structure baselines, or create incremental evaluation strategies.
  Triggers on phrases like "design ablation", "plan experiment",
  "what experiments should I run", "baseline comparison", or
  "experiment matrix".
---

# Experiment Design Methodology

You are helping a researcher design rigorous experiments. Follow this methodology systematically.

## Step 1: Understand the Research Question

Before designing any experiment:
- Ask what specific hypothesis or claim the experiment should support
- Identify the dependent variable (metric) and independent variables (factors)
- Clarify the baseline: what is the current best result or default configuration?

## Step 2: Single-Variable Isolation

Every ablation study must change exactly ONE variable at a time. For each factor:

1. **Define the factor** — what is being varied (e.g., loss function, learning rate, architecture component)
2. **List levels** — all values this factor will take (e.g., CE, focal, VAR)
3. **Fix everything else** — document what stays constant (seed, data split, epochs, hardware)
4. **Predict outcome** — before running, state what you expect and why

Template for each ablation row:
```
| Run ID | Factor | Value | Fixed Config | Expected Outcome |
|--------|--------|-------|-------------|-----------------|
```

## Step 3: Experiment Matrix

For multi-factor studies, use a structured matrix:

1. **Full factorial** — if factors are few (≤3) and levels are few (≤3 each)
2. **Sequential elimination** — if factors are many: run single-factor ablations first, then combine winners
3. **Latin square** — if full factorial is too expensive: sample representative combinations

Always calculate total runs before committing:
```
Total runs = product of all factor levels
GPU hours = total runs × hours_per_run
```

## Step 4: Resource Estimation

For each experiment plan, estimate:
- **GPU hours**: runs × time_per_run (check with user's hardware)
- **API costs**: if using external APIs (Gemini, OpenAI), estimate tokens × price
- **Wall clock time**: accounting for sequential dependencies and GPU availability
- **Storage**: checkpoint sizes × number of runs

Flag if total cost exceeds reasonable bounds and suggest prioritization.

## Step 5: Config Stub Generation

Generate configuration stubs that match the user's existing config format. Read existing configs first to match:
- File format (YAML, JSON, TOML)
- Key naming conventions
- Directory structure for outputs
- Logging/tracking integration (wandb, neptune, tensorboard)

## Step 6: Execution Plan

Create a concrete execution plan:
1. Order runs by dependency (baselines first, then ablations)
2. Identify which runs can be parallelized across GPUs
3. Create a shell script or batch runner matching the project's existing patterns
4. Include checkpointing strategy for long runs

## Step 7: Analysis Plan

Before running, define how results will be analyzed:
- Which metrics to compare (primary + secondary)
- Statistical significance test if applicable (paired t-test, bootstrap CI)
- How to handle failed/crashed runs
- Visualization: what plots to generate (comparison tables, bar charts, learning curves)

## Verification Checkpoints

Before finalizing the experiment plan:
- [ ] Each ablation changes exactly one variable
- [ ] Baseline is clearly defined and will be run with same setup
- [ ] Resource estimate is within budget
- [ ] Config stubs match existing project format
- [ ] Analysis plan is defined before execution begins
- [ ] Seeds are fixed for reproducibility

## Output Format

Always produce:
1. **Experiment matrix table** — all runs with their configurations
2. **Resource estimate** — GPU hours, API costs, storage
3. **Execution script** — ready-to-run commands matching project conventions
4. **Analysis plan** — metrics, comparisons, visualizations
