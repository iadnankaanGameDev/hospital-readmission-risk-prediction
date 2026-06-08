# Hospital Readmission Risk Analytics - SQL Query Layer

This folder contains the PostgreSQL query layer for a diabetes hospital readmission analytics project using the Diabetes 130-US Hospitals dataset.

## Database Tables

- `diabetic_data`: raw hospital encounter dataset
- `ids_mapping`: raw mapping file imported as one table with multiple mapping sections

## SQL Workflow

```text
raw tables
-> clean mapping views
-> enriched patient encounter view
-> data quality checks
-> Power BI analytical views
-> later ML modeling in Colab
```

## Target Variable

`readmitted_30_days` is created in SQL from the raw `readmitted` column:

- `readmitted = '<30'` -> `readmitted_30_days = 1`
- `readmitted = 'NO'` or `'>30'` -> `readmitted_30_days = 0`

This project is educational and portfolio-oriented. It is not intended for clinical decision-making.

## Files

- `00_database_checks.sql`: confirms raw table imports, row counts, schema, IDs, and readmission values.
- `01_clean_mapping_views.sql`: creates clean mapping views for admission type, discharge disposition, and admission source.
- `02_patient_encounters_enriched_view.sql`: creates the main enriched analytical view with readable labels and the ML target.
- `03_data_quality_checks.sql`: explores missing values and key distributions.
- `04_readmission_overview_views.sql`: creates Power BI overview views for KPI and dashboard visuals.
- `05_risk_factor_analysis_views.sql`: creates deeper descriptive analytics views for patient profile and risk factor exploration.
- `06_powerbi_export_checks.sql`: provides quick SELECT checks for Power BI-ready views.

## Power BI Dashboard Plan

- Page 1: Hospital Readmission Overview
- Page 2: Risk Factors & Patient Profiles

## ML Plan

1. Export or query `vw_patient_encounters_enriched`.
2. Clean missing values, especially fields using `?`.
3. Encode categorical features.
4. Train a classification model for `readmitted_30_days`.
5. Evaluate with recall, precision, F1, and ROC-AUC.
6. Export prediction probabilities back for dashboard use.
