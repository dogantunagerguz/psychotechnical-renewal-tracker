CREATE VIEW stg_trainees AS
SELECT
    CAST(candidate_id AS INTEGER) AS candidate_id,
    TRIM(candidate_name) AS candidate_name,
    UPPER(TRIM(licence_class)) AS licence_class,
    date(licence_issue_date) AS licence_issue_date,
    TRIM(entry_type) AS entry_type
FROM raw_trainees;

-- The public workbook uses 1968-01-01 as the explicit not-interested sentinel.
CREATE VIEW stg_call_outcomes AS
SELECT
    CAST(candidate_id AS INTEGER) AS candidate_id,
    TRIM(first_name || ' ' || last_name) AS candidate_name,
    date(certificate_issue_date) AS certificate_issue_date,
    date(psychotechnical_assessment_date) AS assessment_date,
    UPPER(TRIM(licence_class)) AS licence_class,
    CASE
        WHEN psychotechnical_assessment_date IS NULL THEN 'Not called'
        WHEN date(psychotechnical_assessment_date) = '1968-01-01' THEN 'Not interested'
        ELSE 'Interested'
    END AS contact_status
FROM raw_call_results;

CREATE VIEW stg_external_pool AS
SELECT
    CAST(pool_id AS INTEGER) AS pool_id,
    TRIM(customer_name) AS customer_name,
    date(source_date) AS source_date,
    TRIM(source_workbook) AS source_workbook
FROM raw_external_pool;

