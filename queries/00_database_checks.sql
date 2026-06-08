-- ============================================================
-- Hospital Readmission Analytics - Database Checks
-- ============================================================
-- Run these checks after importing diabetic_data.csv and IDS_mapping.csv.
-- They confirm that the raw tables exist and that the key fields look usable.

-- ============================================================
-- Raw table existence
-- ============================================================

-- Confirm that both imported raw tables are available in the public schema.
SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('diabetic_data', 'ids_mapping')
ORDER BY table_name;

-- ============================================================
-- Row counts
-- ============================================================

-- Count raw patient encounter rows.
SELECT
    COUNT(*) AS diabetic_data_rows
FROM diabetic_data;

-- Count raw mapping rows. This file contains several mapping sections.
SELECT
    COUNT(*) AS ids_mapping_rows
FROM ids_mapping;

-- ============================================================
-- Column metadata
-- ============================================================

-- Inspect imported column names and data types for the main dataset.
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'diabetic_data'
ORDER BY ordinal_position;

-- Inspect imported column names and data types for the raw mapping table.
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ids_mapping'
ORDER BY ordinal_position;

-- ============================================================
-- Key field checks
-- ============================================================

-- Encounter IDs should identify individual hospital encounters.
SELECT
    COUNT(DISTINCT encounter_id) AS distinct_encounters
FROM diabetic_data;

-- Patient numbers identify unique patients and can appear across encounters.
SELECT
    COUNT(DISTINCT patient_nbr) AS distinct_patients
FROM diabetic_data;

-- Check the raw readmission categories used to build the ML target.
SELECT
    readmitted,
    COUNT(*) AS encounters,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM diabetic_data
GROUP BY readmitted
ORDER BY encounters DESC;
