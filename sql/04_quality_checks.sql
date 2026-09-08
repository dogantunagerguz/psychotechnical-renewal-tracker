CREATE VIEW quality_check_results AS
SELECT 'duplicate_trainee_id' AS check_name, COUNT(*) AS issue_count
FROM (SELECT candidate_id FROM stg_trainees GROUP BY candidate_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'duplicate_result_candidate', COUNT(*)
FROM (SELECT candidate_id FROM stg_call_outcomes GROUP BY candidate_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'result_without_trainee', COUNT(*)
FROM stg_call_outcomes AS o
LEFT JOIN stg_trainees AS t USING (candidate_id)
WHERE t.candidate_id IS NULL
UNION ALL
SELECT 'commercial_trainee_without_schedule', COUNT(*)
FROM stg_trainees AS t
LEFT JOIN renewal_priority_2026 AS r USING (candidate_id)
WHERE t.licence_class IN ('C', 'D', 'E') AND r.candidate_id IS NULL
UNION ALL
SELECT 'due_date_outside_four_month_lookback', COUNT(*)
FROM renewal_priority_2026
WHERE next_test_date < date(as_of_date, '-4 months')
UNION ALL
SELECT 'called_candidate_still_in_queue', COUNT(*)
FROM call_queue_2026 AS q
JOIN stg_call_outcomes AS o USING (candidate_id)
WHERE o.contact_status <> 'Not called'
UNION ALL
SELECT 'contact_denominator_not_reconciled', COUNT(*)
FROM contact_outcome_kpis
WHERE called_trainees <> interested + not_interested
UNION ALL
SELECT 'external_pool_duplicate_key', COUNT(*)
FROM (SELECT pool_id FROM stg_external_pool GROUP BY pool_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'unified_pool_not_reconciled', ABS(
    (SELECT COUNT(*) FROM unified_contact_pool)
    - (
        (SELECT COUNT(*) FROM stg_external_pool WHERE source_date <= date('2026-09-08'))
        + (SELECT COUNT(*) FROM stg_call_outcomes WHERE contact_status = 'Interested')
      )
);
