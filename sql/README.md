# SQL portfolio companion

This companion loads the **same four fully synthetic Excel workbooks used by the public Power BI project**, lands them in raw SQLite tables, standardizes call outcomes, and builds renewal and contact-pool marts. It does **not** imply that SQL was part of the original production workflow and contains no private driver, identity or contact data.

[View the executed result snapshot](RESULTS.md)

[Review the SQL data dictionary](DATA_DICTIONARY.md)

## What this demonstrates

- source-to-mart lineage across trainee, call-result and external-pool workbooks
- the `2021-06-30` two-regime anchor rule and five-year renewal cycles
- deterministic Overdue / Due now / Upcoming / Later logic at `2026-09-08`
- call-outcome normalization, including the public demo's explicit sentinel value
- an open call queue that excludes recorded outcomes
- a source-tagged pool union and explicit called-person denominator
- correct date grain: self-reported assessment dates are not presented as pool-added dates
- as-of filtering that retains but excludes four future-dated external demo rows
- schedule, join, queue, key and denominator reconciliation controls

The synthetic contact KPI does not reproduce or reconcile the reported **648 / 1,092 (59.34%)** summary with the screenshot's **211 / 396 (53.28%)** result. Their cohort, date and filter relationship remains undocumented.

## Run

The runner generates the same public-demo workbooks in a temporary folder, loads them with `openpyxl`, and executes SQLite in memory.

```bash
python sql/run_demo.py
```

Refresh the committed evidence snapshot with `python sql/run_demo.py --write-results`. A successful run ends with `PASS: all SQL data-quality checks returned zero issues.`

## Files

| File | Purpose |
|---|---|
| `01_raw_schema.sql` | landing tables matching the four generated workbooks |
| `02_staging.sql` | typing and contact-outcome normalization |
| `03_marts.sql` | renewal schedule, call queue, contact KPI and grain-safe pool views |
| `04_quality_checks.sql` | schedule, join, queue, key and denominator controls |
| `run_demo.py` | source generation, loading, execution and result rendering |
| `RESULTS.md` | committed output generated from the runnable pipeline |
| `DATA_DICTIONARY.md` | relation grains, keys and metric interpretation |
