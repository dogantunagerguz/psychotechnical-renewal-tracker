# SQL portfolio companion

This companion loads the **same four fully synthetic Excel workbooks used by the public Power BI project**, lands them in raw SQLite tables, standardizes call outcomes, and builds renewal and contact-pool marts. It does **not** imply that SQL was part of the original production workflow and contains no private driver, identity or contact data.

[View the executed result snapshot](RESULTS.md)

[Review the SQL data dictionary](DATA_DICTIONARY.md)

[Review executed regression checks](TEST_EVIDENCE.md)

## What this demonstrates

- source-to-mart lineage across trainee, call-result and external-pool workbooks
- the `2021-06-30` two-regime anchor rule and five-year renewal cycles
- deterministic Overdue / Due now / Upcoming / Later logic at `2026-09-08`
- strict date validation and call-outcome normalization, including the public demo's explicit sentinel value
- an open call queue that excludes recorded outcomes, ambiguous identities and incomplete contact records
- a source-tagged pool union and explicit called-person denominator
- correct date grain: self-reported assessment dates are not presented as pool-added dates
- as-of filtering that retains but excludes four future-dated external demo rows
- schedule, join, queue, key, missing-result and denominator reconciliation controls
- same-connection full-snapshot replay, with rollback if a workbook cannot be read or mapped

The synthetic contact KPI does not reproduce or reconcile the reported **648 / 1,092 (59.34%)** summary with the screenshot's **211 / 396 (53.28%)** result. Their cohort, date and filter relationship remains undocumented.

## Run

The runner generates the same public-demo workbooks in a temporary folder, loads them with `openpyxl`, and executes SQLite in memory.

```bash
python sql/run_demo.py
```

Refresh the committed evidence snapshot with `python sql/run_demo.py --write-results`. A successful run ends with `PASS: all SQL data-quality checks returned zero issues.`

## Data quality and decision boundaries

Raw cells remain available for diagnosis. Identity columns deliberately avoid SQLite type coercion: a source ID must be a positive integer cell, not a text value that happens to start with digits. Invalid IDs and all rows sharing a duplicate candidate ID are excluded from actionable outputs. External IDs are local to a workbook; the external key is `(source_workbook, pool_id)` and does not establish that two records in different workbooks are different real people.

Dates must be exact `YYYY-MM-DD` values representing real calendar dates. The checks reject empty/whitespace strings, malformed dates, impossible dates such as `2026-02-30`, and assessment dates after the fixed as-of date. The original values remain in raw. Excel formula text is read without evaluating it: an uncached assessment formula is retained and flagged, not converted into a NULL assessment. A **NULL assessment** means **Not called**; exactly **1968-01-01** is the source's **Not interested** sentinel; a valid nonfuture assessment means **Interested**, an interest proxy rather than a completed appointment or sale. Other invalid values produce **Quality error**, never Interested.

The action queue requires a valid commercial trainee, one valid matching result record, a present name/contact reference, a priority renewal date and an explicit Not called status. Interested trainee pool entries use the same validated population. Blank or whitespace-only contact references are blocked. Demo phone values are synthetic references: presence validation does not verify a dialable number, consent, or contactability. External records additionally require a valid source date no later than the as-of date. The four valid future-dated external fixture rows are counted as exclusions, not malformed-date errors.

`eligible_trainees` counts distinct, unambiguous positive-integer C/D/E trainee identities, including those with a missing or invalid result. Within that cohort, `called_trainees = interested + not_interested`; Not called and Quality error are excluded from this denominator and counted separately. This conservative demo policy also excludes invalid name, contact or licence-date records from the observed contact KPI, not only from the action queue. Missing result rows are quality errors, not assumed Not called. Invalid/duplicate trainee identity rows are counted separately as `excluded_identity_rows`, which is a row count rather than a number of people. If no valid called records remain, the counts are zero and the rate is NULL.

Quality rules may overlap; their issue counts must not be added as a distinct-person total. The runner exits unsuccessfully if any quality check is nonzero. A clean fixture demonstrates the rules on synthetic inputs, not the quality of private operational records.

## Snapshot replacement and replay

The four workbooks are treated as one **complete snapshot**. `load_workbooks(connection, folder)` deletes the previous raw rows and loads all four workbooks within a SQLite savepoint. Derived views immediately reflect the new snapshot. Reloading unchanged workbooks on the same connection leaves raw values, pool membership, queue and KPIs unchanged; a changed snapshot replaces removed rows and applies additions/changes once.

If any workbook is missing or cannot be mapped, the savepoint rolls back every source table, preserving the preceding snapshot. Required and unique headers are checked even when a workbook contains no data rows. Cell-level quality errors are retained in the new raw snapshot for inspection and quarantined from actions; they cause quality-check failure rather than a silent successful run. This distinction is intentional: a successful file read is not approval of its contents.

This implements atomic **full replacement**, not incremental loading, upserts, CDC, a durable ingestion service or operational Power BI refresh. The command-line demo still uses an in-memory database. Run the same-connection and failure regressions with:

```bash
python -m unittest discover -s tests -v
```

## Files

| File | Purpose |
|---|---|
| `01_raw_schema.sql` | landing tables matching the four generated workbooks |
| `02_staging.sql` | strict dates/identities, contact completeness and outcome normalization |
| `03_marts.sql` | renewal schedule, call queue, contact KPI and grain-safe pool views |
| `04_quality_checks.sql` | schedule, join, queue, key and denominator controls |
| `run_demo.py` | source generation, atomic snapshot replacement, execution and result rendering |
| `RESULTS.md` | committed output generated from the runnable pipeline |
| `DATA_DICTIONARY.md` | relation grains, keys and metric interpretation |
| `TEST_EVIDENCE.md` | executed regression scope and remaining operational boundaries |
