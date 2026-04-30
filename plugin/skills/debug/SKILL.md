---
name: debug
description: Evidence-before-action diagnosis of failing ML experiments. Probes the system before guessing causes, process list, dmesg, GPU stats, log scrollback, checkpoint state, then states a hypothesis as a hypothesis and runs a smoke before claiming a root cause. Use when the user asks why a run is failing, diverging, OOMing, hanging, slow, producing weird metrics, has crashed, or asks to debug, diagnose, troubleshoot, or investigate a training issue.
---

# Debug: evidence-before-action investigation

The most expensive class of mistake in ML debugging is asserting a cause based on plausibility, then attempting a "fix" that masks the real problem. This skill enforces the discipline of probe → hypothesis → smoke → controls → claim, in that order.

The agentic Stop hook routes here from `reason` when an assistant claims a cause without backing tool output.

## When to run

The user just said any of:

- "why is X failing / diverging / NaN / OOM / hung / slow / crashed"
- "the loss is going up", "metrics look weird", "GPU util is 0"
- "debug this", "diagnose", "troubleshoot", "investigate this run"
- pasted a log excerpt asking what's wrong

## Five-step protocol

### Step 1: cheap probes

Before forming any hypothesis, gather the cheap evidence. None of these cost more than a few seconds:

**Process state:**

```bash
ps aux | grep -E '(python|train|torchrun|accelerate)' | grep -v grep
```

Is the process still running? Zombie? Defunct? Multiple instances?

**Kernel / system events:**

```bash
dmesg | tail -100 # OOM kills, hardware errors, NFS errors
journalctl -xe --since "1 hour ago" | tail -50
```

**GPU state:**

```bash
nvidia-smi
nvidia-smi --query-gpu=utilization.gpu,memory.used,temperature.gpu --format=csv
```

Is the GPU even being used? Idle GPU during "training" means the process is blocked on data loading or has died.

**Disk / filesystem:**

```bash
df -h /path/to/run-dir
du -sh /path/to/run-dir/*
```

Out of disk? Checkpoints not being written?

**Log scrollback:**
Read the last few hundred lines of the training log. Don't trust the user's summary, they may have skimmed. Look for:

- exception tracebacks
- repeated "loss=NaN" or "grad_norm=Inf"
- early-stop announcements (the run may have completed normally)
- the _last_ successful epoch / step (where did progress stop)

**Checkpoint state:**

```bash
ls -la /path/to/run-dir/checkpoints/
```

When was the last checkpoint written? What does its size suggest? An empty `.pt` is different from a 2GB one cut short.

### Step 2: hypothesis (labeled as hypothesis)

After the probe, state what _might_ be happening, explicitly framed as a hypothesis:

> "Hypothesis: the run is OOMing because dmesg shows `oom-kill` 3 minutes ago and the process is gone. Alternative hypotheses I haven't ruled out: (a) NFS write timeout, (b) explicit kill from a sibling process."

Never skip to "the cause is X." The hypothesis labels what you don't yet know.

### Step 3: smoke run

The cheapest way to confirm or refute a hypothesis is to reproduce the failure shape under a controlled condition:

- **OOM hypothesis**: rerun with `batch_size=1` for 1 step. If it survives, OOM is confirmed; if it fails the same way, OOM is wrong.
- **Data hypothesis**: rerun with a synthetic in-memory dataset. If it works, the data path is implicated.
- **Model hypothesis**: forward pass only on a single batch with `eval()` mode. Loss finite? Outputs sane?
- **Optimizer hypothesis**: rerun with `lr=0`. If the loss still explodes, the loss itself is broken (not the optimizer).
- **Distributed hypothesis**: rerun on 1 GPU. If it works, DDP / NCCL is implicated.

A 30-second smoke beats a 30-minute restart-and-pray.

### Step 4: controls

If the smoke is ambiguous, run a control: change exactly one variable from the failing config and rerun the smoke. The differences narrow what mechanism is responsible.

Common control axes (change one at a time):

- single-source vs multi-source data
- default workers vs adjusted workers
- mixed-precision on vs off
- gradient checkpointing on vs off
- torch.compile on vs off

### Step 5: claim cause

Only after evidence stacks up, probe, smoke, control, do you assert a cause. The claim should cite the specific tool output that proves it:

> "Root cause: NFS write timeout. Evidence: dmesg shows `nfs server X not responding` at 14:23 (the same minute the last checkpoint was written), and the smoke with `batch=1` reproduces the timeout. Recommended fix: bind-mount a local scratch dir for checkpoints and rsync to NFS at end of epoch."

If the evidence isn't stacking up, do not promote a hypothesis to a cause. Say "I don't yet know" and propose the next probe.

## What to avoid

- "It's probably X, let me try Y" → no. Probe first.
- Restarting the run with a small change as the diagnostic. Smoke first, then restart deliberately.
- Citing only the user's narrative as evidence: re-read the actual log.
- Stopping at the first plausible cause when artifacts contradict it.

## Output

A concise diagnostic report: (1) what the probes showed, (2) the hypothesis, (3) the smoke outcome, (4) the cause-or-uncertain verdict, (5) the recommended next action. Each claim cites the tool output that backs it.
