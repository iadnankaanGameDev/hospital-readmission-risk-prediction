-- ============================================================
-- Hospital Readmission Analytics - Data Quality Checks
-- ============================================================
-- The source dataset uses '?' as a missing value marker.
-- Handle '?' carefully before ML modeling.

-- ============================================================
-- Missing value checks
-- ============================================================

-- weight has many missing values and may be excluded from ML.
-- medical_specialty and payer_code can be converted to Unknown.
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN race = '?' THEN 1 ELSE 0 END) AS missing_race,
    SUM(CASE WHEN weight = '?' THEN 1 ELSE 0 END) AS missing_weight,
    SUM(CASE WHEN payer_code = '?' THEN 1 ELSE 0 END) AS missing_payer_code,
    SUM(CASE WHEN medical_specialty = '?' THEN 1 ELSE 0 END) AS missing_medical_specialty,
    SUM(CASE WHEN diag_1 = '?' THEN 1 ELSE 0 END) AS missing_diag_1,
    SUM(CASE WHEN diag_2 = '?' THEN 1 ELSE 0 END) AS missing_diag_2,
    SUM(CASE WHEN diag_3 = '?' THEN 1 ELSE 0 END) AS missing_diag_3
FROM vw_patient_encounters_enriched;

-- ============================================================
-- Target and demographic distributions
-- ============================================================

-- Review target class balance for the readmission problem.
SELECT
    readmission_status,
    COUNT(*) AS encounters,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM vw_patient_encounters_enriched
GROUP BY readmission_status
ORDER BY encounters DESC;

-- Review age bucket distribution.
SELECT
    age,
    COUNT(*) AS encounters
FROM vw_patient_encounters_enriched
GROUP BY age
ORDER BY age;

-- Review gender distribution.
SELECT
    gender,
    COUNT(*) AS encounters
FROM vw_patient_encounters_enriched
GROUP BY gender
ORDER BY encounters DESC;

-- Review race distribution, including '?' values.
SELECT
    race,
    COUNT(*) AS encounters
FROM vw_patient_encounters_enriched
GROUP BY race
ORDER BY encounters DESC;

-- ============================================================
-- Admission and discharge distributions
-- ============================================================

-- Review encounter volume by admission type label.
SELECT
    admission_type,
    COUNT(*) AS encounters
FROM vw_patient_encounters_enriched
GROUP BY admission_type
ORDER BY encounters DESC;

-- Review encounter volume by discharge disposition label.
SELECT
    discharge_disposition,
    COUNT(*) AS encounters
FROM vw_patient_encounters_enriched
GROUP BY discharge_disposition
ORDER BY encounters DESC;

-- Review encounter volume by admission source label.
SELECT
    admission_source,
    COUNT(*) AS encounters
FROM vw_patient_encounters_enriched
GROUP BY admission_source
ORDER BY encounters DESC;
