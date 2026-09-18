# SQL data dictionary

| Relation | Grain | Key fields / interpretation |
|---|---|---|
| `raw_trainees` | one source trainee row; duplicates/invalid cells retained | intended candidate key; ID type is preserved rather than coerced |
| `raw_call_results` | one source result row; duplicates/invalid cells retained | intended candidate key; assessment cell is retained before validation |
| `raw_external_pool` | one external source row | intended key is source workbook + pool ID |
| `stg_trainees` | one raw trainee row | normalized fields, source row ID, key count and `is_valid`; invalid ID becomes NULL only in staging |
| `stg_call_outcomes` | one raw result row | Interested, Not interested, Not called or Quality error; NULL assessment and malformed assessment differ |
| `stg_external_pool` | one raw external row | key count uses workbook + positive integer pool ID; valid future source dates remain inspectable |
| `renewal_priority_2026` | one valid C/D/E trainee | project date anchor, next five-year due date and status at 2026-09-08 |
| `contact_population` | one unambiguous commercial trainee identity | left-joined result coverage; missing/duplicate/conflicting/invalid result becomes Quality error |
| `call_queue_2026` | one valid uncalled priority trainee | Overdue, Due now or Upcoming only; includes a present synthetic contact reference |
| `contact_outcome_kpis` | one KPI row | eligible cohort = called + not called + quality error; called = Interested + Not interested; invalid/duplicate identity rows counted separately |
| `unified_contact_pool` | one validated source record | `TRAINEE-<candidate_id>` or `EXTERNAL-<workbook>-<pool_id>`; source plus date meaning; not a deduplicated real-person master |
| `external_pool_monthly_trend` | one external-source month | only valid external rows on/before 2026-09-08; never mixes assessment dates with source-added dates |
| `quality_check_results` | one validation rule | `issue_count = 0` is required |

The 648/1,092 and 211/396 summaries remain separate reported populations and are not recreated from the public fixture.

`eligible_trainees` includes identifiable C/D/E trainees whose result is missing or invalid; these remain visible under `quality_error_trainees`. It excludes missing/invalid/duplicate trainee identities, reported as `excluded_identity_rows` (source rows, not people). A nonblank contact reference is required by this demo's conservative KPI and action policy; it is not a phone-number validity check. `interest_rate_among_called_pct` is NULL with no valid called records.

`source_row_id` is SQLite's row identifier within the current snapshot, for diagnosis only; it is not a stable business key. Raw tables are atomically replaced as one complete snapshot. No incremental history or CDC is implemented. See [quality and reload policy](README.md).
