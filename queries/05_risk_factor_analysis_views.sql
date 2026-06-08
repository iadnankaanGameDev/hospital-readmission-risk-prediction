-- ============================================================
-- Hospital Readmission Analytics - Risk Factor Analysis Views
-- ============================================================
-- These views support descriptive analytics for patient profiles and risk factors.
-- They are not clinical recommendations.

-- ============================================================
-- Readmission by discharge disposition
-- ============================================================

-- Discharge disposition can help describe post-discharge readmission patterns.
DROP VIEW IF EXISTS vw_readmission_by_discharge_disposition;

CREATE VIEW vw_readmission_by_discharge_disposition AS
SELECT
    discharge_disposition,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM vw_patient_encounters_enriched
GROUP BY discharge_disposition
ORDER BY encounters DESC;

-- ============================================================
-- Readmission by medication status
-- ============================================================

-- Medication changes and diabetes medication status may be useful analytical signals.
DROP VIEW IF EXISTS vw_readmission_by_medication_status;

CREATE VIEW vw_readmission_by_medication_status AS
SELECT
    change,
    "diabetesMed" AS diabetes_med,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM vw_patient_encounters_enriched
GROUP BY change, "diabetesMed"
ORDER BY encounters DESC;

-- ============================================================
-- Readmission by prior inpatient visits
-- ============================================================

-- Prior inpatient visits may be useful for readmission risk analysis.
-- The CTE avoids grouping by a SELECT alias in PostgreSQL.
DROP VIEW IF EXISTS vw_readmission_by_prior_visits;

CREATE VIEW vw_readmission_by_prior_visits AS
WITH grouped AS (
    SELECT
        patient_nbr,
        readmitted_30_days,
        number_outpatient,
        number_emergency,
        number_inpatient,
        CASE
            WHEN number_inpatient = 0 THEN '0 inpatient visits'
            WHEN number_inpatient BETWEEN 1 AND 2 THEN '1-2 inpatient visits'
            WHEN number_inpatient BETWEEN 3 AND 5 THEN '3-5 inpatient visits'
            ELSE '6+ inpatient visits'
        END AS inpatient_visit_group,
        CASE
            WHEN number_inpatient = 0 THEN 1
            WHEN number_inpatient BETWEEN 1 AND 2 THEN 2
            WHEN number_inpatient BETWEEN 3 AND 5 THEN 3
            ELSE 4
        END AS sort_order
    FROM vw_patient_encounters_enriched
)
SELECT
    inpatient_visit_group,
    sort_order,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(number_outpatient), 2) AS avg_outpatient_visits,
    ROUND(AVG(number_emergency), 2) AS avg_emergency_visits,
    ROUND(AVG(number_inpatient), 2) AS avg_inpatient_visits
FROM grouped
GROUP BY inpatient_visit_group, sort_order
ORDER BY sort_order;

-- ============================================================
-- Readmission by time in hospital group
-- ============================================================

-- Length of stay groups help compare readmission rates by hospitalization duration.
DROP VIEW IF EXISTS vw_readmission_by_time_in_hospital_group;

CREATE VIEW vw_readmission_by_time_in_hospital_group AS
WITH grouped AS (
    SELECT
        patient_nbr,
        readmitted_30_days,
        time_in_hospital,
        num_lab_procedures,
        num_medications,
        number_diagnoses,
        CASE
            WHEN time_in_hospital BETWEEN 1 AND 3 THEN '1-3 days'
            WHEN time_in_hospital BETWEEN 4 AND 7 THEN '4-7 days'
            WHEN time_in_hospital BETWEEN 8 AND 14 THEN '8-14 days'
            ELSE '15+ days'
        END AS time_in_hospital_group,
        CASE
            WHEN time_in_hospital BETWEEN 1 AND 3 THEN 1
            WHEN time_in_hospital BETWEEN 4 AND 7 THEN 2
            WHEN time_in_hospital BETWEEN 8 AND 14 THEN 3
            ELSE 4
        END AS sort_order
    FROM vw_patient_encounters_enriched
)
SELECT
    time_in_hospital_group,
    sort_order,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM grouped
GROUP BY time_in_hospital_group, sort_order
ORDER BY sort_order;

-- ============================================================
-- Readmission by number of diagnoses group
-- ============================================================

-- Diagnosis count groups summarize patient complexity for descriptive analysis.
DROP VIEW IF EXISTS vw_readmission_by_number_diagnoses_group;

CREATE VIEW vw_readmission_by_number_diagnoses_group AS
WITH grouped AS (
    SELECT
        patient_nbr,
        readmitted_30_days,
        time_in_hospital,
        num_lab_procedures,
        num_medications,
        number_diagnoses,
        CASE
            WHEN number_diagnoses BETWEEN 1 AND 3 THEN '1-3 diagnoses'
            WHEN number_diagnoses BETWEEN 4 AND 6 THEN '4-6 diagnoses'
            WHEN number_diagnoses BETWEEN 7 AND 9 THEN '7-9 diagnoses'
            ELSE '10+ diagnoses'
        END AS number_diagnoses_group,
        CASE
            WHEN number_diagnoses BETWEEN 1 AND 3 THEN 1
            WHEN number_diagnoses BETWEEN 4 AND 6 THEN 2
            WHEN number_diagnoses BETWEEN 7 AND 9 THEN 3
            ELSE 4
        END AS sort_order
    FROM vw_patient_encounters_enriched
)
SELECT
    number_diagnoses_group,
    sort_order,
    COUNT(*) AS encounters,
    COUNT(DISTINCT patient_nbr) AS patients,
    SUM(readmitted_30_days) AS readmitted_30_days,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate,
    ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM grouped
GROUP BY number_diagnoses_group, sort_order
ORDER BY sort_order;
