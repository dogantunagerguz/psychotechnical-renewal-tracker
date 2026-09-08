# SQL portfolio companion

These files implement equivalent renewal and contact-pool logic on a small, fully synthetic SQLite dataset. They do **not** imply that SQL was part of the original production workflow and contain no private driver, identity or contact data.

The synthetic contact KPI is deliberately separate from the published summaries. It does not reproduce or reconcile the reported **648 / 1,092 (59.34%)** trainee-call summary with the screenshot's **211 / 396 (53.28%)** result; their cohort, date and filter relationship remains undocumented.

## What this demonstrates

- the `2021-06-30` two-regime anchor rule
- five-year renewal cycles and the four-month lookback window
- deterministic Overdue / Due now / Upcoming / Later status logic at `2026-09-08`
- a call queue that excludes recorded outcomes
- an explicit interest-rate denominator and a source-tagged contact-pool union
- referential, date, scope, queue and denominator quality checks

## Run

Python 3 is the only requirement; the runner uses the standard-library SQLite engine.

```bash
python sql/run_demo.py
```

A successful run ends with `PASS: all SQL data-quality checks returned zero issues.`

## Files

| File | Purpose |
|---|---|
| `01_demo_schema_and_seed.sql` | normalized schema and invented renewal/contact records |
| `02_analysis.sql` | renewal priority, call queue, contact KPI and pool-trend views |
| `03_data_quality.sql` | auditable integrity and denominator checks |
| `run_demo.py` | reproducible execution and bounded output preview |

