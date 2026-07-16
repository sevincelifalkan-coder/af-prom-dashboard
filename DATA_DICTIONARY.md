# Data Dictionary

All data are embedded directly in `app.R` (no external files). This document defines each dataset, its fields, and its source. This satisfies the reproducibility requirement for the accompanying publication.

## 1. Domain coverage matrix (`cov_mat`, `cov_labels`)

A 10 × 5 matrix scoring how fully each instrument captures each QoL domain.

- **Rows (10):** Physical functioning, Symptoms, Emotional well-being, Social functioning, Cognitive function, Treatment satisfaction, Economic burden, Health perception, Sexual health, Sleep quality
- **Columns (5):** AFEQT, EQ-5D, SF-36, MLHFQ, AFSS
- **Values:** 2 = Full, 1 = Partial, 0 = None

**Source:** Instrument content analysis performed for the companion narrative review (65 studies, 1992–2024). Scoring performed by the lead author and validated by [N] co-authors via inter-rater agreement (see manuscript §2.5).

## 2. Domain relevance (`domain_info`)

Clinical and policy relevance annotations for each of the 10 domains.

- **Domain** — domain name
- **Clinical** — clinical relevance descriptor
- **Policy** — policy relevance descriptor

**Source:** Authors' synthesis, derived from the companion framework.

## 3. AF-CARE mapping (`afcare`)

Maps 8 PROM domains onto the four AF-CARE components.

- **Domain** — PROM domain
- **Component** — AF-CARE component: C (Comorbidity and risk factors), A (Avoid stroke), R (Rate/rhythm control), E (Evaluation and follow-up)
- **Label** — full component label
- **Diagnostic** — diagnostic relevance of the domain
- **Clinical** — possible clinical implication (illustrative, not a decision rule)

**Source:** Mapping informed by the 2024 ESC AF guidelines and the companion paper's framework.

## 4. Gap analysis (`gaps`)

Five underrepresented domains with coverage and diagnostic consequences.

- **Domain** — underrepresented domain
- **Status** — coverage status (Partially captured / Limited / Not captured)
- **Avg_Pct** — average coverage across instruments (%)
- **Consequence** — diagnostic consequence of the gap

**Source:** Derived from the domain coverage matrix (dataset 1) and the companion review.

## 5. Implementation framework (`impl`)

15 implementation items across three levels.

- **Level** — Clinical / Organisational / Policy (5 items each)
- **Action** — implementation action
- **Indicator** — measurable indicator
- **AFCARE** — AF-CARE alignment

**Source:** Operationalised by the authors from the companion paper's multilevel framework.

## 6. Cross-country AF burden (`countries`)

AF burden and PROM-integration status for 9 countries (Latvia, Ireland, Germany, Netherlands, United Kingdom, France, Italy, Spain, United States).

- **Country** — country name
- **Prevalence** — AF prevalence (%), age-unadjusted national average
- **Pop_M** — population (millions)
- **Cost_EUR** — average hospitalisation cost per AF patient (EUR)
- **PROM_Status** — PROM-integration status: Limited / Developing / Moderate / Advanced
- **AF_Patients** — estimated AF patient count (derived: Pop_M × 1e6 × Prevalence / 100)
- **Total_Cost_M** — estimated total cost (EUR millions; derived: AF_Patients × Cost_EUR / 1e6)

**Sources:**

- Prevalence: Chugh et al. (2014); Krijthe et al. (2013)
- Hospitalisation cost: Kim et al. (2011) and country-specific published sources
- US costs converted from USD at the 2024 average exchange rate (1 USD = 0.92 EUR)
- PROM-integration status: authors' classification based on published evidence of national-level PROM implementation. This is a descriptive comparison, not a validated maturity index.

**Caveat:** Prevalence estimates are age-unadjusted national averages and may not reflect demographic variation. Cost figures are indicative and should be replaced with local unit costs for any formal economic analysis.

## 7. AFEQT thresholds (`afeqt_cats`)

Severity categories for AFEQT scores.

- **Category** — Severe / Moderate / Mild / Minimal/No impact
- **Min, Max** — score range for the category (0–100 scale)
- **Hex** — display colour
- **Action** — suggested review point (illustrative, not a validated clinical decision rule)

**Source:** Severity bands and the ≥5-point clinically meaningful change threshold based on Holmes et al. (2019) and Spertus et al. (2011).

## References

- Chugh SS, et al. Worldwide epidemiology of atrial fibrillation. Circulation. 2014.
- Krijthe BP, et al. Projections on the number of individuals with atrial fibrillation in the European Union. Eur Heart J. 2013.
- Kim MH, et al. Estimation of total incremental health care costs in patients with atrial fibrillation in the United States. Circ Cardiovasc Qual Outcomes. 2011.
- Holmes DN, et al. Circ Cardiovasc Qual Outcomes. 2019;12:e005358.
- Spertus J, et al. Development and validation of the Atrial Fibrillation Effect on QualiTy-of-life (AFEQT) questionnaire. Circ Arrhythm Electrophysiol. 2011.
- 2024 ESC Guidelines for the management of atrial fibrillation (AF-CARE).

Full citations appear in the accompanying manuscript.
