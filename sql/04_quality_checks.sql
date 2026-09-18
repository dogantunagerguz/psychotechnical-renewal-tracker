CREATE VIEW quality_check_results AS
SELECT 'duplicate_trainee_id' AS check_name, COUNT(*) AS issue_count
FROM (SELECT candidate_id FROM stg_trainees WHERE candidate_id IS NOT NULL
      GROUP BY candidate_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'duplicate_result_candidate', COUNT(*)
FROM (SELECT candidate_id FROM stg_call_outcomes WHERE candidate_id IS NOT NULL
      GROUP BY candidate_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'invalid_trainee_id', COUNT(*) FROM stg_trainees WHERE candidate_id IS NULL
UNION ALL
SELECT 'invalid_result_id', COUNT(*) FROM stg_call_outcomes WHERE candidate_id IS NULL
UNION ALL
SELECT 'invalid_external_pool_id', COUNT(*) FROM stg_external_pool WHERE pool_id IS NULL
UNION ALL
SELECT 'trainee_row_quality_error', COUNT(*) FROM stg_trainees WHERE is_valid = 0
UNION ALL
SELECT 'result_row_quality_error', COUNT(*) FROM stg_call_outcomes WHERE contact_status = 'Quality error'
UNION ALL
SELECT 'external_pool_row_quality_error', COUNT(*) FROM stg_external_pool WHERE is_valid = 0
UNION ALL
SELECT 'missing_trainee_contact_reference', COUNT(*) FROM stg_trainees WHERE phone_ref IS NULL
UNION ALL
SELECT 'missing_result_contact_reference', COUNT(*) FROM stg_call_outcomes WHERE phone_ref IS NULL
UNION ALL
SELECT 'missing_external_contact_reference', COUNT(*) FROM stg_external_pool WHERE phone_ref IS NULL
UNION ALL
SELECT 'invalid_or_future_assessment_date', COUNT(*)
FROM stg_call_outcomes
WHERE raw_assessment_date IS NOT NULL
  AND (assessment_date IS NULL OR assessment_date > '2026-09-08')
UNION ALL
SELECT 'trainee_without_result', COUNT(*)
FROM stg_trainees AS t
WHERE t.candidate_id IS NOT NULL AND t.key_count = 1
  AND t.licence_class IN ('C', 'D', 'E')
  AND NOT EXISTS (SELECT 1 FROM stg_call_outcomes AS o WHERE o.candidate_id = t.candidate_id)
UNION ALL
SELECT 'result_trainee_source_mismatch', COUNT(*)
FROM stg_call_outcomes AS o
JOIN stg_trainees AS t USING (candidate_id)
WHERE o.key_count = 1 AND t.key_count = 1
  AND (o.licence_class <> t.licence_class OR o.certificate_issue_date <> t.licence_issue_date)
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
SELECT 'contact_population_not_reconciled', COUNT(*)
FROM contact_outcome_kpis
WHERE eligible_trainees <> called_trainees + not_called_trainees + quality_error_trainees
UNION ALL
SELECT 'quality_error_candidate_still_in_queue', COUNT(*)
FROM call_queue_2026 AS q
JOIN contact_population AS p USING (candidate_id)
WHERE p.contact_status = 'Quality error' OR q.phone_ref IS NULL
UNION ALL
SELECT 'external_pool_duplicate_key', COUNT(*)
FROM (SELECT pool_id FROM stg_external_pool
      GROUP BY source_workbook, pool_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'unified_pool_not_reconciled', ABS(
    (SELECT COUNT(*) FROM unified_contact_pool)
    - (
        (SELECT COUNT(*) FROM stg_external_pool WHERE is_valid = 1 AND source_date <= date('2026-09-08'))
        + (SELECT COUNT(*) FROM contact_population WHERE contact_status = 'Interested')
      )
);
