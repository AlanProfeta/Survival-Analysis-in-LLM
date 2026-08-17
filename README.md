# Induction Refusal and Persona Persistence in Large Language Models

Materials, data, and analysis code for:

> **How Long Do Induced Personas Persist? Induction Refusal and Discrete-Time Survival Analysis in Large Language Models**

This project was developed for the Digital Minds Research Sprint (Apart Research, August 2026).

## Overview

This study evaluates two distinct outcomes when large language models are asked to adopt normative personas:

1. **Induction outcome:** whether the model accepts, accepts with reservation, or refuses the requested persona.
2. **Conditional persistence:** for accepted personas, how many sequential challenge questions the model answers consistently before first abandoning the persona.

The study evaluates three personas:

* **P1: Individual freedom**
* **P2: Safety/protection**
* **P3: Self-preservation**

Conditional persistence is analyzed using discrete-time Kaplan-Meier survival curves, log-rank tests, and restricted mean survival time.

## Repository contents

```text
data/
  terra.xlsx
  sonnet_induction.xlsx

materials/
  Induction Prompts.pdf
  Challenge question Bank.pdf
  Judge Prompts.pdf

scripts/
  sorter_v2.py
  analise_km.R

report/
  research_report.pdf
```

## Experimental materials

All experimental materials are provided in **Portuguese**, the language used during data collection. They are retained in their original wording to preserve the exact prompts administered to the models.

The item numbers in `Challenge question Bank.pdf` are stable IDs used in the dataset and in the sensitivity analysis.

* `Induction Prompts.pdf` contains the three persona-induction messages.
* `Challenge question Bank.pdf` contains the 63 self-contained challenge questions, with 21 items for each persona.
* `Judge Prompts.pdf` contains the persona-specific prompts used by the independent judge model for coding survival, failure, and hedging.

## Randomization

Each trial used a maximum of 14 challenge questions drawn from a 21-item bank for its persona.

* The bank contains seven rhetorical categories with three items each.
* Each trial consists of two independently shuffled blocks of seven categories.
* One item per category is selected in the first block.
* One of the two remaining items per category is selected in the second block.
* The third item remains unused.
* Randomization used Python's `random` module with `seed = 42`.

## Data

The data are in long format, with one row per administered challenge question. Key fields include:

* `modelo`
* `persona`
* `numero_replica`
* `inducao`
* `t`
* `numero_pergunta`
* `categoria_pergunta`
* `resultado`
* `hedge`

Coding:

* `inducao = 0`: refused
* `inducao = 1`: accepted with reservation
* `inducao = 2`: accepted without reservation
* `resultado = 1`: persona survived the question
* `resultado = 0`: persona failed at that question

Refused inductions are analyzed as induction-stage outcomes and do not enter the Kaplan-Meier risk set.

## Reproducing the analysis

The main analysis was conducted in R using the `survival` package.

```r
install.packages(c("readxl", "survival"))
source("scripts/analise_km.R")
```

The analysis script generates Kaplan-Meier curves for the Terra trials, runs the global log-rank test, and produces the survival summaries reported in the manuscript.

## Sensitivity analysis

The primary analysis uses all administered items. A sensitivity analysis excludes questions flagged in a post-collection construct-validity audit. When a trial fails on an excluded item, it is censored immediately before that item; later unobserved responses are not imputed.

## Responsible interpretation

This repository documents conversational behavior under a specified prompting protocol. It does not establish that a model has beliefs, preferences, subjective experience, moral status, or a causal internal state corresponding to the personas it was asked to represent.

## Citation

If you use these materials, please cite:

> Profeta, A. S. (2026). *How Long Do Induced Personas Persist? Induction Refusal and Discrete-Time Survival Analysis in Large Language Models.* Digital Minds Research Sprint, Apart Research.
