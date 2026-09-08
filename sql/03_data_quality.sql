-- Auditable checks. Every row should return zero issues for the demo fixture.
CREATE VIEW quality_check_results AS
SELECT 'orphan_call_outcome' AS check_name, COUNT(*) AS issue_count
FROM call_outcomes AS o
LEFT JOIN trainees AS t ON t.candidate_id = o.candidate_id
WHERE t.candidate_id IS NULL
UNION ALL
SELECT 'call_before_licence_issue', COUNT(*)
FROM call_outcomes AS o
JOIN trainees AS t USING (candidate_id)
WHERE date(o.called_at) < date(t.licence_issue_date)
UNION ALL
SELECT 'future_licence_issue_date', COUNT(*)
FROM trainees
WHERE date(licence_issue_date) > date('2026-09-08')
UNION ALL
SELECT 'commercial_trainee_without_schedule', COUNT(*)
FROM trainees AS t
LEFT JOIN renewal_priority_2026 AS r USING (candidate_id)
WHERE t.licence_class IN ('C', 'D', 'E')
  AND r.candidate_id IS NULL
UNION ALL
SELECT 'noncommercial_candidate_in_priority', COUNT(*)
FROM renewal_priority_2026
WHERE licence_class NOT IN ('C', 'D', 'E')
UNION ALL
SELECT 'due_date_outside_model_window', COUNT(*)
FROM renewal_priority_2026
WHERE date(next_test_date) < date(as_of_date, '-4 months')
UNION ALL
SELECT 'called_candidate_still_in_queue', COUNT(*)
FROM call_queue_2026 AS q
JOIN call_outcomes AS o USING (candidate_id)
UNION ALL
SELECT 'contact_denominator_not_reconciled', COUNT(*)
FROM contact_outcome_kpis
WHERE called_trainees <> interested + not_interested;

