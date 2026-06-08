-- ============================================================
-- Hospital Readmission Analytics - Overview Views
-- ============================================================
-- These Power BI-ready views support the main dashboard overview page.

-- ============================================================
-- KPI overview
-- ============================================================

-- Supports KPI cards for total encounters, patients, readmissions, and averages.
DROP VIEW IF EXISTS vw_readmission_kpi_overview;

CREATE VIEW vw_readmission_kpi_overview AS
SELECT
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    ROUND(AVG(num_procedures), 2) AS avg_procedures,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM vw_patient_encounters_enriched;

-- ============================================================
-- Readmission by age
-- ============================================================

-- Supports a column or bar chart comparing readmission rate by age bucket.
DROP VIEW IF EXISTS vw_readmission_by_age;

CREATE VIEW vw_readmission_by_age AS
SELECT
    age,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM vw_patient_encounters_enriched
GROUP BY age
ORDER BY age;

-- ============================================================
-- Readmission by admission type
-- ============================================================

-- Supports a bar chart showing readmission patterns by admission type.
DROP VIEW IF EXISTS vw_readmission_by_admission_type;

CREATE VIEW vw_readmission_by_admission_type AS
SELECT
    admission_type,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM vw_patient_encounters_enriched
GROUP BY admission_type
ORDER BY encounters DESC;

-- ============================================================
-- Readmission by admission source
-- ============================================================

-- Supports a bar chart showing where readmitted patients came from.
DROP VIEW IF EXISTS vw_readmission_by_admission_source;

CREATE VIEW vw_readmission_by_admission_source AS
SELECT
    admission_source,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM vw_patient_encounters_enriched
GROUP BY admission_source
ORDER BY encounters DESC;

-- ============================================================
-- Readmission status distribution
-- ============================================================

-- Supports a donut chart or compact table for raw readmission categories.
DROP VIEW IF EXISTS vw_readmission_status_distribution;

CREATE VIEW vw_readmission_status_distribution AS
SELECT
    readmission_status,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM vw_patient_encounters_enriched
GROUP BY readmission_status
ORDER BY encounters DESC;
