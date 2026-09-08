-- Portfolio companion queries: deterministic SQLite 3.25+ analysis.
-- The reference date is explicit so reviewers receive reproducible results.

CREATE VIEW renewal_priority_2026 AS
WITH parameters AS (
    SELECT
        date('2026-09-08') AS as_of_date,
        date('2021-06-30') AS legal_cutoff
),
commercial_trainees AS (
    SELECT t.*, p.as_of_date, p.legal_cutoff
    FROM trainees AS t
    CROSS JOIN parameters AS p
    WHERE t.licence_class IN ('C', 'D', 'E')
),
anchors AS (
    SELECT
        commercial_trainees.*,
        CASE
            WHEN date(licence_issue_date) < legal_cutoff THEN legal_cutoff
            ELSE date(licence_issue_date)
        END AS anchor_date
    FROM commercial_trainees
),
cycle_offsets(cycle_months) AS (
    VALUES (60), (120), (180), (240), (300)
),
candidate_cycles AS (
    SELECT
        a.*,
        c.cycle_months,
        date(a.anchor_date, '+' || c.cycle_months || ' months') AS due_date
    FROM anchors AS a
    CROSS JOIN cycle_offsets AS c
),
next_dates AS (
    SELECT
        candidate_id,
        MIN(due_date) AS next_test_date
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
    candidate_id,
    candidate_name,
    licence_class,
    licence_issue_date,
    anchor_date,
    as_of_date,
    next_test_date,
    months_to_due,
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
LEFT JOIN call_outcomes AS o ON o.candidate_id = r.candidate_id
WHERE r.renewal_status IN ('Overdue', 'Due now', 'Upcoming')
  AND o.candidate_id IS NULL;

CREATE VIEW contact_outcome_kpis AS
WITH population AS (
    SELECT candidate_id
    FROM trainees
    WHERE licence_class IN ('C', 'D', 'E')
),
counts AS (
    SELECT
        COUNT(*) AS eligible_trainees,
        COUNT(o.candidate_id) AS called_trainees,
        SUM(CASE WHEN o.outcome = 'interested' THEN 1 ELSE 0 END) AS interested,
        SUM(CASE WHEN o.outcome = 'not_interested' THEN 1 ELSE 0 END) AS not_interested
    FROM population AS p
    LEFT JOIN call_outcomes AS o USING (candidate_id)
)
SELECT
    eligible_trainees,
    called_trainees,
    interested,
    not_interested,
    ROUND(100.0 * interested / NULLIF(called_trainees, 0), 2) AS interest_rate_among_called_pct
FROM counts;

CREATE VIEW unified_contact_pool AS
SELECT
    'TRAINEE-' || CAST(o.candidate_id AS TEXT) AS pool_key,
    'Interested trainee' AS source,
    o.called_at AS added_date
FROM call_outcomes AS o
WHERE o.outcome = 'interested'
UNION ALL
SELECT
    'EXTERNAL-' || CAST(e.pool_id AS TEXT) AS pool_key,
    'External' AS source,
    e.source_date AS added_date
FROM external_pool AS e;

CREATE VIEW monthly_pool_trend AS
SELECT
    strftime('%Y-%m', added_date) AS added_month,
    source,
    COUNT(*) AS records_added
FROM unified_contact_pool
GROUP BY strftime('%Y-%m', added_date), source;

