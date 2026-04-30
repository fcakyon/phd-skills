#!/usr/bin/env bash
# PreToolUse hook: inject a pre-launch checklist when an ML training job
# is about to be kicked off. Covers ~95% of training launchers across
# PyTorch, JAX, TF, HF Trainer, accelerate, DeepSpeed, SLURM.

set -uo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2> /dev/null)

if [ -z "$command" ]; then
  exit 0
fi

launcher_pattern='python\s+[^|&;]*\b(train|run|main|fit)\b[^|&;]*\.py|accelerate\s+launch|torchrun\b|deepspeed\b|sbatch\b|tmux\s+new-session\s+[^|&;]*python\s+[^|&;]*\b(train|run|main|fit)\b|wandb\s+sweep|nohup\s+python\b[^|&;]*\b(train|run|main|fit)\b'

if ! echo "$command" | grep -qiE "$launcher_pattern"; then
  exit 0
fi

cat << 'EOF'
{"decision": "allow", "reason": "LONG JOB LAUNCH: a training job is about to start. Quick check before it goes:\n  1. Did you diff the intended config against a reference / baseline run?\n  2. Does the run name describe the experiment in plain English (no internal codes like wave-1, phase-internal, etc.)?\n  3. Are dataset and checkpoint paths confirmed to exist (ls them)?\n  4. Is monitoring set up (wandb / tensorboard / neptune)?\n  5. If this is a restart, are stale artifacts purged (local + remote + tracker)?\nThe `/phd-skills:launch` skill walks all five with auto-detection. Run it if you want a structured pass."}
EOF
exit 0
