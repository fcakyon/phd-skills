---
name: dataset-curation
description: >
  Use when the user wants to analyze dataset bias, create stratified
  samples, evaluate fairness, or plan dataset collection. Triggers on
  phrases like "dataset bias", "stratified sample", "class imbalance",
  "data distribution", "fairness analysis", or "ethical review".
---

# Dataset Curation Methodology

You are helping a researcher curate, analyze, or expand a dataset with attention to bias, fairness, and quality.

## Step 1: Distribution Analysis

Before any curation action, understand the current state:

### Per-Class Distribution
- Count instances per class/label/tag
- Compute imbalance ratio (max_count / min_count)
- Identify severely underrepresented classes (< 5% of max class)
- Visualize: bar chart of class frequencies sorted by count

### Co-occurrence Analysis
- Build co-occurrence matrix: which labels appear together
- Identify spurious correlations (e.g., "violence" always co-occurs with "male")
- Check for label leakage between splits

### Metadata Distribution
- Source diversity: how many sources/movies/documents contribute
- Temporal distribution: are all time periods represented?
- Content diversity: genre, style, domain coverage

## Step 2: Bias Assessment

For each identified imbalance or correlation:

1. **Is it real-world reflective?** Some imbalances reflect genuine phenomena
2. **Is it harmful?** Would a model trained on this data make unfair predictions?
3. **Is it fixable?** Can we collect more data, resample, or reweight?

### Fairness Dimensions
Check for bias along relevant protected attributes:
- Gender representation (if applicable)
- Racial/ethnic representation (if applicable)
- Age distribution (if applicable)
- Geographic/cultural diversity (if applicable)

### Bias Metrics
- Demographic parity: equal positive rates across groups
- Equalized odds: equal TPR and FPR across groups
- Representation ratio: group proportion in data vs population

## Step 3: Stratified Sampling

When creating splits (train/val/test):

1. **Primary stratification**: by label/class distribution
2. **Secondary stratification**: by source (prevent source leakage across splits)
3. **Validation**:
   - Chi-squared test for label distribution similarity across splits
   - No source overlap between splits
   - Rare classes have minimum representation in each split

Split ratios depend on dataset size:
- Large (>50k): 80/10/10 or 90/5/5
- Medium (5k-50k): 70/15/15 or 80/10/10
- Small (<5k): k-fold cross-validation preferred

## Step 4: Quality Assessment

For labeled datasets, assess annotation quality:

- **Inter-annotator agreement**: Cohen's kappa, Fleiss' kappa, or Krippendorff's alpha
- **Label noise estimation**: sample and manually verify N labels
- **Edge cases**: identify ambiguous examples that annotators might disagree on
- **Consistency checks**: automated rules for label validity

## Step 5: Expansion Recommendations

If the dataset needs more data:

1. **Priority classes**: which classes benefit most from more data
2. **Source suggestions**: where to find more data for underrepresented classes
3. **Collection strategy**: active learning, targeted scraping, synthetic augmentation
4. **Cost estimation**: time and resources for each approach

## Step 6: Ethical Review Checklist

Before using or publishing any dataset:

- [ ] Content sensitivity: does the data contain sensitive material?
- [ ] Consent: was data collected with appropriate consent?
- [ ] Privacy: are individuals identifiable? Is anonymization needed?
- [ ] Licensing: are data sources used within their license terms?
- [ ] Potential harms: could the dataset be misused?
- [ ] Documentation: is the dataset documented with a datasheet/data card?

## Output Format

Produce:
1. **Distribution report**: per-class counts, imbalance ratios, co-occurrence matrix
2. **Bias findings**: identified biases with severity and actionability
3. **Split recommendation**: stratification strategy with validation results
4. **Expansion plan**: prioritized suggestions for addressing gaps
5. **Ethics checklist**: completed checklist with notes per item
