-- ============================================================
-- Hospital Readmission Analytics - Power BI Export Checks
-- ============================================================
-- Run these quick SELECT queries before connecting Power BI.

-- KPI cards for dashboard totals and averages.
SELECT *
FROM vw_readmission_kpi_overview;

-- Column chart for readmission rate by age bucket.
SELECT *
FROM vw_readmission_by_age;

-- Bar chart for readmission rate by admission type.
SELECT *
FROM vw_readmission_by_admission_type;

-- Bar chart for readmission rate by admission source.
SELECT *
FROM vw_readmission_by_admission_source;

-- Table or bar chart for discharge disposition analysis.
SELECT *
FROM vw_readmission_by_discharge_disposition
LIMIT 30;

-- Matrix or clustered bar chart for medication change and diabetes medication status.
SELECT *
FROM vw_readmission_by_medication_status;

-- Column chart for prior inpatient visit groups.
SELECT *
FROM vw_readmission_by_prior_visits;

-- Donut chart for readmission status distribution.
SELECT *
FROM vw_readmission_status_distribution;
