# AF-PROM Integration Dashboard

An open-source R Shiny dashboard that operationalises a patient-reported outcome measure (PROM) integration framework for atrial fibrillation (AF) care, aligned with the 2024 ESC AF-CARE pathway.

Live demo: https://sevinc.shinyapps.io/af-prom-dashboard/

This dashboard accompanies:

Sokolova E, Sen SE, Goetz O, Mača-Kalēja A, Behmane D, Kalējs O. From Framework to Tool: Development and Preliminary Expert Evaluation of an Interactive Dashboard for PROM Integration in Atrial Fibrillation Care. Under review, 2026.

and operationalises the framework from the companion narrative review (Sokolova et al., *Healthcare*, 2026).

## What it does

Six interactive modules:

1. **Domain Coverage Explorer** — compare how five QoL instruments (AFEQT, EQ-5D, SF-36, MLHFQ, AFSS) cover 10 quality-of-life domains.
2. **Gap Analysis** — average coverage per domain across all instruments, highlighting measurement gaps.
3. **AF-CARE Pathway Mapper** — map PROM domains onto the four AF-CARE components (C, A, R, E).
4. **Implementation Readiness Scorecard** — a 15-item checklist across clinical, organisational, and policy levels.
5. **Cross-Country Context Comparator** — prevalence, hospitalisation cost estimates, and PROM-integration status across 9 countries. Figures are drawn from heterogeneous published sources and are illustrative of scale; they are not harmonised for year, definition, or purchasing power and should not be read as a direct comparison between countries.
6. **AFEQT Score Simulator** — visualise baseline/follow-up score changes against published thresholds.

> **Note:** This is a research, education, and implementation-planning tool. The suggested review points in Module 6 are illustrative and derived from guideline reasoning; they are not validated clinical decision rules and must not be used to guide the care of individual patients.

## Running locally

Requires R (>= 4.3).

```r
install.packages(c("shiny", "shinydashboard", "plotly", "DT", "RColorBrewer"))
shiny::runApp("app.R")
```

Or open `app.R` in RStudio and click **Run App**.

All data are embedded in `app.R`, so no external files are required to run the dashboard.

## Repository contents

| File | Purpose |
| --- | --- |
| `app.R` | The complete Shiny application (UI, server, embedded data) |
| `DATA_DICTIONARY.md` | Description and sources of every embedded dataset |
| `LICENSE` | MIT licence |
| `README.md` | This file |

## Data sources

All datasets are embedded in `app.R`. See `DATA_DICTIONARY.md` for the definition and source of each field. In brief:

- **Domain coverage matrix** — derived from the companion narrative review (65 studies, 1992–2024); instrument content analysis scored by the authors and validated by inter-rater agreement.
- **AF-CARE mapping** — informed by the 2024 ESC AF guidelines and the companion framework.
- **Cross-country burden** — AF prevalence (Chugh et al. 2014; Krijthe et al. 2013), hospitalisation cost estimates (Kim et al. 2011 and country-specific sources), reported in EUR. Illustrative only; not harmonised for direct comparison.
- **AFEQT thresholds** — severity categories and the ≥5-point clinically meaningful change threshold (Holmes et al. 2019; Spertus et al. 2011).

## Citation

If you use or adapt this dashboard, please cite the accompanying paper (above) and this repository.

## License

Released under the MIT License — see `LICENSE`.
