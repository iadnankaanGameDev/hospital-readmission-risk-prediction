-- ============================================================
-- Hospital Readmission Analytics - Enriched Encounter View
-- ============================================================
-- This view joins raw encounters to readable mapping labels and creates
-- the 30-day readmission target used for dashboarding and later ML work.

-- ============================================================
-- Main analytical view
-- ============================================================

-- CASCADE allows this view to be rebuilt after Power BI summary views exist.
DROP VIEW IF EXISTS vw_patient_encounters_enriched CASCADE;

CREATE VIEW vw_patient_encounters_enriched AS
SELECT
    d.encounter_id,
    d.patient_nbr,
    d.race,
    d.gender,
    d.age,
    d.weight,

    d.admission_type_id,
    COALESCE(atm.admission_type, 'Unknown') AS admission_type,

    d.discharge_disposition_id,
    COALESCE(ddm.discharge_disposition, 'Unknown') AS discharge_disposition,

    d.admission_source_id,
    COALESCE(asm.admission_source, 'Unknown') AS admission_source,

    d.time_in_hospital,
    d.payer_code,
    d.medical_specialty,

    d.num_lab_procedures,
    d.num_procedures,
    d.num_medications,

    d.number_outpatient,
    d.number_emergency,
    d.number_inpatient,

    d.diag_1,
    d.diag_2,
    d.diag_3,
    d.number_diagnoses,

    d.max_glu_serum,
    d."A1Cresult",

    d.metformin,
    d.repaglinide,
    d.nateglinide,
    d.chlorpropamide,
    d.glimepiride,
    d.acetohexamide,
    d.glipizide,
    d.glyburide,
    d.tolbutamide,
    d.pioglitazone,
    d.rosiglitazone,
    d.acarbose,
    d.miglitol,
    d.troglitazone,
    d.tolazamide,
    d.examide,
    d.citoglipton,
    d.insulin,

    d."glyburide-metformin",
    d."glipizide-metformin",
    d."glimepiride-pioglitazone",
    d."metformin-rosiglitazone",
    d."metformin-pioglitazone",

    d.change,
    d."diabetesMed",
    d.readmitted,

    CASE
        WHEN d.readmitted = '<30' THEN 1
        ELSE 0
    END AS readmitted_30_days,

    CASE
        WHEN d.readmitted = '<30' THEN 'Readmitted within 30 days'
        WHEN d.readmitted = '>30' THEN 'Readmitted after 30 days'
        WHEN d.readmitted = 'NO' THEN 'Not readmitted'
        ELSE 'Unknown'
    END AS readmission_status
FROM diabetic_data d
LEFT JOIN vw_admission_type_mapping atm
    ON d.admission_type_id = atm.admission_type_id
LEFT JOIN vw_discharge_disposition_mapping ddm
    ON d.discharge_disposition_id = ddm.discharge_disposition_id
LEFT JOIN vw_admission_source_mapping asm
    ON d.admission_source_id = asm.admission_source_id;

-- ============================================================
-- Validation checks
-- ============================================================

-- Preview rows for dashboard and ML feature review.
SELECT *
FROM vw_patient_encounters_enriched
LIMIT 100;

-- Confirm target counts and overall 30-day readmission rate.
SELECT
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT encounter_id) AS unique_encounters,
    COUNT(DISTINCT patient_nbr) AS unique_patients,
    SUM(readmitted_30_days) AS readmitted_30_days_count,
    ROUND(100.0 * SUM(readmitted_30_days) / COUNT(*), 2) AS readmission_30_day_rate
FROM vw_patient_encounters_enriched;
