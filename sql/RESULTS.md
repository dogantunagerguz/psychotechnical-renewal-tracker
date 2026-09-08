# Executed SQL results

> Generated from the same fully synthetic Excel workbooks used by the public Power BI demo. These are portfolio-demo outputs, not private or operational results.

**As-of date:** 2026-09-08; legal anchor 2021-06-30; five-year renewal cycles. Four future-dated external demo rows are retained in raw data but excluded from as-of marts.

**Scope note:** the synthetic contact KPI below does not reproduce or reconcile the reported 648 / 1,092 summary with the screenshot's 211 / 396 result. Their cohort, date and filter relationship remains undocumented.

## Pipeline reconciliation

| trainee_rows | result_rows | external_pool_rows | external_pool_rows_as_of | future_external_rows_excluded | scheduled_trainees | called_trainees | unified_pool_rows |
|---|---|---|---|---|---|---|---|
| 36 | 36 | 24 | 20 | 4 | 36 | 24 | 32 |

## Renewal-status distribution

| renewal_status | trainees |
|---|---|
| Overdue | 14 |
| Due now | 1 |
| Upcoming | 1 |
| Later | 20 |

## Open call queue sample

| candidate_name | licence_class | next_test_date | renewal_status |
|---|---|---|---|
| DEMO CANDIDATE 002 | D | 2026-06-30 | Overdue |
| DEMO CANDIDATE 008 | D | 2026-06-30 | Overdue |
| DEMO CANDIDATE 017 | D | 2026-06-30 | Overdue |
| DEMO CANDIDATE 023 | D | 2026-06-30 | Overdue |
| DEMO CANDIDATE 029 | D | 2026-06-30 | Overdue |

## Synthetic contact KPI

| eligible_trainees | called_trainees | interested | not_interested | interest_rate_among_called_pct |
|---|---|---|---|---|
| 36 | 24 | 12 | 12 | 50.0 |

## Unified-pool sources

| source | records |
|---|---|
| External | 20 |
| Interested trainee | 12 |

## Recent external-pool source trend

| source_month | records_added |
|---|---|
| 2025-10 | 1 |
| 2025-11 | 1 |
| 2025-12 | 1 |
| 2026-01 | 1 |
| 2026-02 | 1 |
| 2026-03 | 1 |
| 2026-04 | 1 |
| 2026-05 | 1 |
| 2026-06 | 1 |
| 2026-07 | 1 |
| 2026-08 | 1 |

## Data-quality checks

| check_name | issue_count |
|---|---|
| called_candidate_still_in_queue | 0 |
| commercial_trainee_without_schedule | 0 |
| contact_denominator_not_reconciled | 0 |
| due_date_outside_four_month_lookback | 0 |
| duplicate_result_candidate | 0 |
| duplicate_trainee_id | 0 |
| external_pool_duplicate_key | 0 |
| result_without_trainee | 0 |
| unified_pool_not_reconciled | 0 |
