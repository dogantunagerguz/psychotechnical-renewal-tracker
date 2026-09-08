# SQL data dictionary

| Relation | Grain | Key fields / interpretation |
|---|---|---|
| `raw_trainees` | one generated commercial-licence trainee | candidate, licence and issue date |
| `raw_call_results` | one generated result row per trainee | assessment-date field is normalized into a contact status |
| `raw_external_pool` | one external source record | source date and source workbook |
| `stg_call_outcomes` | one trainee result | Interested, Not interested or Not called |
| `renewal_priority_2026` | one C/D/E trainee | legal anchor, next five-year due date and status at 2026-09-08 |
| `call_queue_2026` | one uncalled priority trainee | Overdue, Due now or Upcoming only |
| `contact_outcome_kpis` | one KPI row | called denominator excludes Not called records |
| `unified_contact_pool` | one eligible pool record | source plus date meaning; mixed date meanings are not trended together |
| `external_pool_monthly_trend` | one external-source month | excludes rows after 2026-09-08 |
| `quality_check_results` | one validation rule | `issue_count = 0` is required |

The 648/1,092 and 211/396 summaries remain separate reported populations and are not recreated from the public fixture.

