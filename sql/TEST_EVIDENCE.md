# SQL regression evidence

Executed locally for this change:

```text
python -m unittest discover -s tests -v
Ran 29 tests
OK

python sql/run_demo.py --write-results
PASS: all SQL data-quality checks returned zero issues.
```

The suite contains six existing portable-Power-BI-source checks and 23 SQL checks. The clean fixture retains its original 36 trainees, 24 valid called trainees, 12 interested, 12 not interested, 50% interest proxy and 32 pool records. The new quality-error and excluded-identity counts are both zero on this fixture.

| Regression | What is asserted |
|---|---|
| Malformed, empty, whitespace, nonexistent and future assessment dates | Raw value preserved; Quality error; excluded from interest numerator/denominator and actionable pool |
| NULL, explicit 1968 sentinel, valid leap day, exact as-of date | Distinct Not called / Not interested / Interested meanings |
| Missing result row | Trainee remains in eligible cohort with a visible quality error; no silent loss or assumed Not called |
| Invalid, text, missing or fractional identities | No cast into another person's ID; raw input retained; exclusions counted |
| Missing contact references | No actionable queue/pool record; quality diagnostics populated |
| Invalid licence, certificate and external source dates | Invalid source rows cannot create an actionable schedule or pool record |
| Duplicate trainees or conflicting result rows | No join multiplication; ambiguous identities excluded |
| Source attribute disagreement | Conflicting licence class is flagged and excluded from action |
| External record identity | Same local ID across workbooks stays distinct; duplicates within a workbook are quarantined |
| Zero called / empty cohort | Zero counts and NULL rate, without divide-by-zero or misleading 0% |
| Same-connection replay | Two loads of snapshot A preserve all raw values, queue, pool and KPIs |
| Changed-snapshot replay | Addition, changed outcome and deletion applied once; repeat of B leaves outputs unchanged |
| Late workbook failure | Missing final workbook rolls back earlier source replacements and preserves prior raw/mart values |
| Header-only wrong schema / duplicate headers | Invalid final workbook cannot silently erase a source; prior snapshot is preserved |
| Uncached Excel assessment formula | Formula text retained in raw; Quality error rather than an assumed Not called record |
| Workbook cell defect | Invalid Excel cell survives loading for diagnosis and is quarantined by SQL |
| Committed result snapshot | Rendered results equal `RESULTS.md` |

These are public synthetic-data regressions. They do not execute Power BI's DAX engine, validate the private Service refresh configuration, prove real contactability, constitute business-owner UAT or measure operational impact. The reload test proves complete-snapshot replacement on one SQLite connection, not incremental loading, CDC or recovery of a durable production database.
