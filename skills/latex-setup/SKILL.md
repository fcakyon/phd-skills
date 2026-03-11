---
name: latex-setup
description: >
  Use when the user wants to set up or troubleshoot a LaTeX environment,
  choose between biber and bibtex, install packages for a specific venue
  template, or configure compilation. Triggers on phrases like "setup
  latex", "biber vs bibtex", "latex compilation error", "install latex
  packages", "venue template", or "texlive setup".
---

# LaTeX Environment Setup

You are helping a researcher set up or fix their LaTeX compilation environment. Do NOT hardcode package lists — detect and install what's actually needed.

## Step 1: Detect Current State

Before installing anything:

1. **Check installed TeX distribution**:
   ```
   which pdflatex && pdflatex --version
   which xelatex && xelatex --version
   which lualatex && lualatex --version
   ```

2. **Check bibliography processor**:
   ```
   which biber && biber --version
   which bibtex && bibtex --version
   ```

3. **Check package manager**:
   ```
   which tlmgr && tlmgr --version
   ```

## Step 2: Analyze the Project

Read the main .tex file to determine requirements:

1. **Document class**: `\documentclass{article}`, `\documentclass{IEEEtran}`, etc.
2. **Bibliography system**:
   - `\usepackage{biblatex}` → needs `biber`
   - `\usepackage{natbib}` or `\bibliographystyle{...}` → needs `bibtex`
3. **Required packages**: extract from all `\usepackage{...}` declarations
4. **Special requirements**: TikZ, minted (needs pygments), algorithm2e, etc.

## Step 3: Venue Template Detection

If the user mentions a venue, search for the official template:
- Download from the venue's official website (NOT third-party mirrors)
- Check if the template specifies a required TeX distribution or class
- Note any venue-specific compilation instructions

Common venues and their requirements:
| Venue | Class | Bib system | Notes |
|-------|-------|-----------|-------|
| CVPR/ECCV | Custom class file | bibtex | Usually provided in template |
| NeurIPS | neurips_20XX.sty | natbib + bibtex | Style file changes yearly |
| ICLR | iclr20XX_conference.sty | natbib + bibtex | OpenReview format |
| ACL/EMNLP | acl.cls | bibtex | ACL Anthology format |
| IEEE | IEEEtran.cls | bibtex | Column formatting specific |
| Springer | llncs.cls | bibtex or biblatex | Depends on series |

## Step 4: Install Missing Components

Based on analysis, install only what's missing:

### On Ubuntu/Debian
```bash
# Base installation (if nothing installed)
sudo apt install texlive-base texlive-latex-recommended

# Common extras
sudo apt install texlive-latex-extra  # most \usepackage needs
sudo apt install texlive-fonts-recommended texlive-fonts-extra
sudo apt install texlive-bibtex-extra biber  # if biblatex used
sudo apt install texlive-science  # algorithm2e, etc.
```

### On macOS
```bash
# Full installation (recommended)
brew install --cask mactex

# Minimal
brew install --cask basictex
sudo tlmgr update --self
sudo tlmgr install <package-name>
```

### Individual packages via tlmgr
```bash
# If specific packages are missing
sudo tlmgr install <package-name>
```

## Step 5: Configure Compilation

Set up the correct compilation pipeline:

### For bibtex projects
```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

### For biblatex/biber projects
```bash
pdflatex main.tex
biber main
pdflatex main.tex
pdflatex main.tex
```

### Common compilation issues
- **Missing .bib file**: check `\bibliography{...}` path is correct
- **Undefined citations**: run bibtex/biber + pdflatex twice
- **Missing packages**: install via tlmgr, not apt (apt packages are coarse-grained)
- **Font errors**: install texlive-fonts-extra
- **TikZ externalize errors**: ensure write18 is enabled

## Step 6: Verify Setup

After configuration:

1. Run the full compilation pipeline
2. Check the PDF opens correctly
3. Verify bibliography entries appear
4. Check for any remaining warnings in the .log file

## Output Format

Produce:
1. **Current state**: what's installed, what's missing
2. **Project requirements**: detected from .tex files
3. **Installation commands**: only what's needed, OS-specific
4. **Compilation command**: the exact pipeline for this project
5. **Verification**: confirm successful compilation
