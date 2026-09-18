-- Raw values remain available for diagnosis. Only exact, real ISO dates pass:
-- SQLite date(value) alone can accept impossible days such as 2026-02-30.
CREATE VIEW stg_trainees AS
WITH parsed AS (
    SELECT
        rowid AS source_row_id,
        CASE WHEN typeof(candidate_id) = 'integer' AND candidate_id > 0
             THEN candidate_id END AS candidate_id,
        NULLIF(TRIM(candidate_name), '') AS candidate_name,
        NULLIF(TRIM(phone_ref, char(9) || char(10) || char(13) || ' '), '') AS phone_ref,
        UPPER(TRIM(licence_class)) AS licence_class,
        CASE WHEN licence_issue_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                   AND date(licence_issue_date, '+0 days') = licence_issue_date AND licence_issue_date >= '0001-01-01'
             THEN licence_issue_date END AS licence_issue_date,
        TRIM(entry_type) AS entry_type
    FROM raw_trainees
), keyed AS (
    SELECT *, COUNT(*) OVER (PARTITION BY candidate_id) AS key_count FROM parsed
)
SELECT *, CASE WHEN candidate_id IS NOT NULL AND key_count = 1
                    AND candidate_name IS NOT NULL AND phone_ref IS NOT NULL
                    AND licence_class IN ('C', 'D', 'E')
                    AND licence_issue_date IS NOT NULL
                    AND licence_issue_date <= '2026-09-08'
               THEN 1 ELSE 0 END AS is_valid
FROM keyed;

-- NULL alone means Not called. Blank/invalid/future values are Quality error.
-- 1968-01-01 remains the documented, explicit Not interested sentinel.
CREATE VIEW stg_call_outcomes AS
WITH parsed AS (
    SELECT
        rowid AS source_row_id,
        CASE WHEN typeof(candidate_id) = 'integer' AND candidate_id > 0
             THEN candidate_id END AS candidate_id,
        NULLIF(TRIM(COALESCE(first_name, '') || ' ' || COALESCE(last_name, '')), '')
            AS candidate_name,
        NULLIF(TRIM(phone_ref, char(9) || char(10) || char(13) || ' '), '') AS phone_ref,
        CASE WHEN certificate_issue_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                   AND date(certificate_issue_date, '+0 days') = certificate_issue_date AND certificate_issue_date >= '0001-01-01'
             THEN certificate_issue_date END AS certificate_issue_date,
        psychotechnical_assessment_date AS raw_assessment_date,
        CASE WHEN psychotechnical_assessment_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                   AND date(psychotechnical_assessment_date, '+0 days') = psychotechnical_assessment_date AND psychotechnical_assessment_date >= '0001-01-01'
             THEN psychotechnical_assessment_date END AS assessment_date,
        UPPER(TRIM(licence_class)) AS licence_class
    FROM raw_call_results
), keyed AS (
    SELECT *, COUNT(*) OVER (PARTITION BY candidate_id) AS key_count FROM parsed
)
SELECT *,
    CASE
        WHEN candidate_id IS NULL OR key_count <> 1 OR candidate_name IS NULL
             OR phone_ref IS NULL OR certificate_issue_date IS NULL
             OR certificate_issue_date > '2026-09-08'
             OR COALESCE(licence_class, '') NOT IN ('C', 'D', 'E') THEN 'Quality error'
        WHEN raw_assessment_date IS NULL THEN 'Not called'
        WHEN assessment_date IS NULL OR assessment_date > '2026-09-08' THEN 'Quality error'
        WHEN assessment_date = '1968-01-01' THEN 'Not interested'
        ELSE 'Interested'
    END AS contact_status
FROM keyed;

CREATE VIEW stg_external_pool AS
WITH parsed AS (
    SELECT
        rowid AS source_row_id,
        CASE WHEN typeof(pool_id) = 'integer' AND pool_id > 0 THEN pool_id END AS pool_id,
        NULLIF(TRIM(customer_name), '') AS customer_name,
        NULLIF(TRIM(phone_ref, char(9) || char(10) || char(13) || ' '), '') AS phone_ref,
        CASE WHEN source_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                   AND date(source_date, '+0 days') = source_date AND source_date >= '0001-01-01'
             THEN source_date END AS source_date,
        NULLIF(TRIM(source_workbook), '') AS source_workbook
    FROM raw_external_pool
), keyed AS (
    SELECT *, COUNT(*) OVER (PARTITION BY source_workbook, pool_id) AS key_count FROM parsed
)
SELECT *, CASE WHEN pool_id IS NOT NULL AND source_workbook IS NOT NULL
                    AND key_count = 1 AND customer_name IS NOT NULL
                    AND phone_ref IS NOT NULL AND source_date IS NOT NULL
               THEN 1 ELSE 0 END AS is_valid
FROM keyed;
