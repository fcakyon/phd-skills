# Stage 3: Gap analysis

The paper says "trained for 100 epochs with AdamW." That sentence hides at least 8 hyperparameters. This stage extracts every value needed to launch a training run, with a provenance tag for each so you know how confident you are.

## What to extract

For each missing component identified in stage 2, fill in:

### Optimizer block

| Knob                   | Value        | Provenance                                                |
| ---------------------- | ------------ | --------------------------------------------------------- |
| optimizer name         | AdamW        | `[paper §4.1]`                                            |
| learning rate (peak)   | 3e-4         | `[paper hyperparam table]`                                |
| learning rate schedule | cosine       | `[paper §4.1]`                                            |
| warmup steps / epochs  | 5 epochs     | `[paper §4.1]`                                            |
| warmup type            | linear       | `[guess: framework default]`                              |
| weight decay           | 0.05         | `[paper hyperparam table]`                                |
| betas (Adam)           | (0.9, 0.999) | `[guess: PyTorch default; paper says "default settings"]` |
| epsilon                | 1e-8         | `[guess: PyTorch default]`                                |
| gradient clipping      | 1.0          | `[paper §4.1]`                                            |
| layerwise lr decay     | none         | `[code: not implemented]`                                 |

### Batch size block

| Knob                  | Value   | Provenance                                          |
| --------------------- | ------- | --------------------------------------------------- |
| per-device batch size | 64      | `[paper §4.1]`                                      |
| total devices         | 8x A100 | `[paper §4.1]`                                      |
| global batch size     | 512     | computed; verify matches `[paper hyperparam table]` |
| gradient accumulation | 1       | `[code]`                                            |

### Schedule block

| Knob                   | Value                     | Provenance            |
| ---------------------- | ------------------------- | --------------------- |
| epochs                 | 100                       | `[paper §4.1]`        |
| total steps (computed) | dataset_size \* 100 / 512 | computed              |
| eval every             | 5 epochs                  | `[code]` or `[guess]` |
| save every             | 5 epochs                  | `[code]` or `[guess]` |

### Augmentation pipeline

Reconstruct the _order_ of augmentations, not just the list. Order matters (random crop before vs after color jitter changes statistics). For each:

```yaml
augmentation:
  - { name: RandomResizedCrop, size: 224, scale: [0.08, 1.0] } # [paper §4.2]
  - { name: RandomHorizontalFlip, p: 0.5 } # [paper §4.2]
  - { name: ColorJitter, brightness: 0.4, contrast: 0.4 } # [paper §4.2]
  - { name: RandAugment, N: 2, M: 9 } # [code, default config]
  - { name: ToTensor } # [framework]
  - { name: Normalize, mean: imagenet, std: imagenet } # [framework]
```

If the paper says "standard ImageNet augmentations," that's a `[guess: venue convention]` tag, note the assumption explicitly.

### Loss formulation

For each loss term in the paper's main equation, fill in:

```yaml
loss:
  - name: CrossEntropy
    weight: 1.0
    label_smoothing: 0.1 # [paper eq 3, λ_smooth = 0.1]
  - name: KLDivergenceWithTeacher
    weight: 0.5 # [paper eq 4, β = 0.5]
    temperature: 4.0 # [paper §4.1]
```

If the paper's equation has a coefficient, find and tag every coefficient. Equation numbers help when you re-read later.

### Tricks

The "tricks" section often hides the most reproduction-critical details. Check for:

- label smoothing
- mixup / cutmix (probability + alpha)
- stochastic depth (drop_path_rate)
- exponential moving average (decay rate, update freq)
- gradient checkpointing
- mixed precision (fp16 / bf16)
- distillation temperature (if applicable)
- specific weight init scheme (trunc_normal, kaiming, etc.)

Each gets a row in `gaps_filled.md` with provenance.

## Provenance tags

Every value should have one of:

- `[paper §X]`: explicit in the paper text or table
- `[code: <path>:<lineno>]`: found in the official code
- `[venue convention]`: guessed from common practice in the venue (e.g. "ImageNet augs" at CVPR are usually a specific recipe)
- `[framework default]`: explicitly using the framework's default
- `[guess: assumption stated]`: your best guess; document the reasoning

The fewer `[guess]` tags, the higher confidence the reproduction will replicate.

## Round-trip check

After filling in `gaps_filled.md`, hand off to the existing `paper-verification` skill:

> "Verify that gaps_filled.md is consistent with paper.md, every hyperparam I claimed `[paper §X]` for must actually be in section X."

This catches transcription errors and over-confident attributions before they propagate to stage 4.

## Output

`repro/<arxiv-id>/gaps_filled.md` with:

- All seven blocks above (optimizer, batch, schedule, augmentation, loss, tricks, plus any architecture-specific block)
- Every value provenance-tagged
- Round-trip-verified against `paper.md`

## Success criteria

- Every component identified as "missing" in stage 2's inventory now has values in `gaps_filled.md`
- < 30% of values are `[guess]` tagged (more than that means the paper is genuinely under-specified and the reproduction will be approximate)
- Round-trip with `paper-verification` raises no contradictions
