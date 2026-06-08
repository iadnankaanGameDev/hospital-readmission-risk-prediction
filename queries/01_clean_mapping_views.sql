-- ============================================================
-- Hospital Readmission Analytics - Clean Mapping Views
-- ============================================================
-- The raw ids_mapping table has only two imported columns:
-- admission_type_id and description.
-- The file actually stores three mapping sections in one table:
-- admission type, discharge disposition, and admission source.

-- ============================================================
-- Admission type mapping
-- ============================================================

-- Split the first section of ids_mapping into a clean admission type view.
-- CASCADE allows this setup script to be rerun after dependent views exist.
DROP VIEW IF EXISTS vw_admission_type_mapping CASCADE;

CREATE VIEW vw_admission_type_mapping AS
WITH ordered AS (
    SELECT
        ctid,
        row_number() OVER (ORDER BY ctid) AS rn,
        admission_type_id,
        description
    FROM ids_mapping
),
markers AS (
    SELECT
        MIN(CASE WHEN admission_type_id = 'discharge_disposition_id' THEN rn END) AS discharge_start
    FROM ordered
)
SELECT
    admission_type_id::int AS admission_type_id,
    description AS admission_type
FROM ordered, markers
WHERE rn < discharge_start
  AND admission_type_id ~ '^[0-9]+$';

-- ============================================================
-- Discharge disposition mapping
-- ============================================================

-- Split the middle section into discharge disposition labels.
-- CASCADE allows this setup script to be rerun after dependent views exist.
DROP VIEW IF EXISTS vw_discharge_disposition_mapping CASCADE;

CREATE VIEW vw_discharge_disposition_mapping AS
WITH ordered AS (
    SELECT
        ctid,
        row_number() OVER (ORDER BY ctid) AS rn,
        admission_type_id,
        description
    FROM ids_mapping
),
markers AS (
    SELECT
        MIN(CASE WHEN admission_type_id = 'discharge_disposition_id' THEN rn END) AS discharge_start,
        MIN(CASE WHEN admission_type_id = 'admission_source_id' THEN rn END) AS source_start
    FROM ordered
)
SELECT
    admission_type_id::int AS discharge_disposition_id,
    description AS discharge_disposition
FROM ordered, markers
WHERE rn > discharge_start
  AND rn < source_start
  AND admission_type_id ~ '^[0-9]+$';

-- ============================================================
-- Admission source mapping
-- ============================================================

-- Split the final section into admission source labels.
-- This fixes the missing view referenced by the enriched encounter view.
-- CASCADE allows this setup script to be rerun after dependent views exist.
DROP VIEW IF EXISTS vw_admission_source_mapping CASCADE;

CREATE VIEW vw_admission_source_mapping AS
WITH ordered AS (
    SELECT
        ctid,
        row_number() OVER (ORDER BY ctid) AS rn,
        admission_type_id,
        description
    FROM ids_mapping
),
markers AS (
    SELECT
        MIN(CASE WHEN admission_type_id = 'admission_source_id' THEN rn END) AS source_start
    FROM ordered
)
SELECT
    admission_type_id::int AS admission_source_id,
    description AS admission_source
FROM ordered, markers
WHERE rn > source_start
  AND admission_type_id ~ '^[0-9]+$';

-- ============================================================
-- Validation checks
-- ============================================================

-- Confirm the admission type labels.
SELECT *
FROM vw_admission_type_mapping
ORDER BY admission_type_id;

-- Confirm the discharge disposition labels.
SELECT *
FROM vw_discharge_disposition_mapping
ORDER BY discharge_disposition_id;

-- Confirm the admission source labels.
SELECT *
FROM vw_admission_source_mapping
ORDER BY admission_source_id;
