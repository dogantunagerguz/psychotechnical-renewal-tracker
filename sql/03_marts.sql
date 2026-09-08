CREATE VIEW renewal_priority_2026 AS
WITH parameters AS (
    SELECT date('2026-09-08') AS as_of_date, date('2021-06-30') AS legal_cutoff
),
commercial_trainees AS (
    SELECT t.*, p.as_of_date, p.legal_cutoff
    FROM stg_trainees AS t
    CROSS JOIN parameters AS p
    WHERE t.licence_class IN ('C', 'D', 'E')
),
anchors AS (
    SELECT
        *,
        CASE WHEN licence_issue_date < legal_cutoff THEN legal_cutoff
             ELSE licence_issue_date END AS anchor_date
    FROM commercial_trainees
),
cycle_offsets(cycle_months) AS (
    VALUES (60), (120), (180), (240), (300)
),
candidate_cycles AS (
    SELECT
        a.*,
        date(a.anchor_date, '+' || o.cycle_months || ' months') AS due_date
    FROM anchors AS a
    CROSS JOIN cycle_offsets AS o
),
next_dates AS (
    SELECT candidate_id, MIN(due_date) AS next_test_date
    FROM candidate_cycles
    WHERE due_date >= date(as_of_date, '-4 months')
    GROUP BY candidate_id
),
with_month_difference AS (
    SELECT
        a.candidate_id,
        a.candidate_name,
        a.licence_class,
        a.licence_issue_date,
        a.anchor_date,
        a.as_of_date,
        n.next_test_date,
        (CAST(strftime('%Y', n.next_test_date) AS INTEGER)
         - CAST(strftime('%Y', a.as_of_date) AS INTEGER)) * 12
        + CAST(strftime('%m', n.next_test_date) AS INTEGER)
        - CAST(strftime('%m', a.as_of_date) AS INTEGER) AS months_to_due
    FROM anchors AS a
    JOIN next_dates AS n USING (candidate_id)
)
SELECT
    *,
    CASE
        WHEN months_to_due BETWEEN -3 AND -1 THEN 'Overdue'
        WHEN months_to_due BETWEEN 0 AND 1 THEN 'Due now'
        WHEN months_to_due BETWEEN 2 AND 3 THEN 'Upcoming'
        ELSE 'Later'
    END AS renewal_status
FROM with_month_difference;

CREATE VIEW call_queue_2026 AS
SELECT
    r.candidate_id,
    r.candidate_name,
    r.licence_class,
    r.next_test_date,
    r.months_to_due,
    r.renewal_status,
    CASE r.renewal_status
        WHEN 'Overdue' THEN 1
        WHEN 'Due now' THEN 2
        WHEN 'Upcoming' THEN 3
        ELSE 4
    END AS priority_order
FROM renewal_priority_2026 AS r
JOIN stg_call_outcomes AS o USING (candidate_id)
WHERE r.renewal_status IN ('Overdue', 'Due now', 'Upcoming')
  AND o.contact_status = 'Not called';

CREATE VIEW contact_outcome_kpis AS
WITH population AS (
    SELECT o.*
    FROM stg_call_outcomes AS o
    JOIN stg_trainees AS t USING (candidate_id)
    WHERE t.licence_class IN ('C', 'D', 'E')
)
SELECT
    COUNT(*) AS eligible_trainees,
    SUM(CASE WHEN contact_status <> 'Not called' THEN 1 ELSE 0 END) AS called_trainees,
    SUM(CASE WHEN contact_status = 'Interested' THEN 1 ELSE 0 END) AS interested,
    SUM(CASE WHEN contact_status = 'Not interested' THEN 1 ELSE 0 END) AS not_interested,
    ROUND(
        100.0 * SUM(CASE WHEN contact_status = 'Interested' THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN contact_status <> 'Not called' THEN 1 ELSE 0 END), 0),
        2
    ) AS interest_rate_among_called_pct
FROM population;

CREATE VIEW unified_contact_pool AS
SELECT
    'TRAINEE-' || CAST(candidate_id AS TEXT) AS pool_key,
    candidate_name,
    'Interested trainee' AS source,
    assessment_date AS reference_date,
    'Self-reported assessment date; not pool-added date' AS date_meaning
FROM stg_call_outcomes
WHERE contact_status = 'Interested'
UNION ALL
SELECT
    'EXTERNAL-' || CAST(pool_id AS TEXT),
    customer_name,
    'External',
    source_date,
    'External source-record date'
FROM stg_external_pool
WHERE source_date <= date('2026-09-08');

CREATE VIEW external_pool_monthly_trend AS
SELECT
    strftime('%Y-%m', source_date) AS source_month,
    COUNT(*) AS records_added
FROM stg_external_pool
WHERE source_date <= date('2026-09-08')
GROUP BY strftime('%Y-%m', source_date);

CREATE VIEW pipeline_reconciliation AS
SELECT
    (SELECT COUNT(*) FROM raw_trainees) AS trainee_rows,
    (SELECT COUNT(*) FROM raw_call_results) AS result_rows,
    (SELECT COUNT(*) FROM raw_external_pool) AS external_pool_rows,
    (SELECT COUNT(*) FROM stg_external_pool WHERE source_date <= date('2026-09-08'))
        AS external_pool_rows_as_of,
    (SELECT COUNT(*) FROM stg_external_pool WHERE source_date > date('2026-09-08'))
        AS future_external_rows_excluded,
    (SELECT COUNT(*) FROM renewal_priority_2026) AS scheduled_trainees,
    (SELECT called_trainees FROM contact_outcome_kpis) AS called_trainees,
    (SELECT COUNT(*) FROM unified_contact_pool) AS unified_pool_rows;
