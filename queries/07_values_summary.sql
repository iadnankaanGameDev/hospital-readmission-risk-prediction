DROP VIEW IF EXISTS vw_missing_values_summary;

CREATE VIEW vw_missing_values_summary AS
SELECT 'weight' AS column_name, 
       SUM(CASE WHEN weight = '?' THEN 1 ELSE 0 END) AS missing_count
FROM vw_patient_encounters_enriched

UNION ALL
SELECT 'medical_specialty',
       SUM(CASE WHEN medical_specialty = '?' THEN 1 ELSE 0 END)
FROM vw_patient_encounters_enriched

UNION ALL
SELECT 'payer_code',
       SUM(CASE WHEN payer_code = '?' THEN 1 ELSE 0 END)
FROM vw_patient_encounters_enriched

UNION ALL
SELECT 'race',
       SUM(CASE WHEN race = '?' THEN 1 ELSE 0 END)
FROM vw_patient_encounters_enriched

UNION ALL
SELECT 'diag_3',
       SUM(CASE WHEN diag_3 = '?' THEN 1 ELSE 0 END)
FROM vw_patient_encounters_enriched

UNION ALL
SELECT 'diag_2',
       SUM(CASE WHEN diag_2 = '?' THEN 1 ELSE 0 END)
FROM vw_patient_encounters_enriched

UNION ALL
SELECT 'diag_1',
       SUM(CASE WHEN diag_1 = '?' THEN 1 ELSE 0 END)
FROM vw_patient_encounters_enriched;


SELECT *
FROM vw_missing_values_summary
ORDER BY missing_count DESC;


-------------------------------------------------------------------

DROP VIEW IF EXISTS vw_ml_prior_visits_by_target;

CREATE VIEW vw_ml_prior_visits_by_target AS
SELECT
    CASE
        WHEN readmitted_30_days = 1 THEN 'Readmitted within 30 days'
        ELSE 'Not readmitted within 30 days'
    END AS ml_target_group,

    COUNT(*) AS encounters,
    ROUND(AVG(number_outpatient), 2) AS avg_outpatient_visits,
    ROUND(AVG(number_emergency), 2) AS avg_emergency_visits,
    ROUND(AVG(number_inpatient), 2) AS avg_inpatient_visits
FROM vw_patient_encounters_enriched
GROUP BY readmitted_30_days
ORDER BY readmitted_30_days DESC;

SELECT *
FROM vw_ml_prior_visits_by_target;