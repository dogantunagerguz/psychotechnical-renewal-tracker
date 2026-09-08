#!/usr/bin/env python3
"""Execute the self-contained renewal-tracker SQL portfolio companion."""

from pathlib import Path
import sqlite3

SQL_DIR = Path(__file__).resolve().parent
SQL_FILES = [
    "01_demo_schema_and_seed.sql",
    "02_analysis.sql",
    "03_data_quality.sql",
]
REPORTS = [
    ("Renewal priority", """
        SELECT candidate_name, anchor_date, next_test_date, months_to_due, renewal_status
        FROM renewal_priority_2026
        ORDER BY next_test_date, candidate_name
    """),
    ("Open call queue", """
        SELECT candidate_name, next_test_date, renewal_status
        FROM call_queue_2026
        ORDER BY priority_order, next_test_date
    """),
    ("Synthetic contact KPI", "SELECT * FROM contact_outcome_kpis"),
    ("Monthly pool trend", "SELECT * FROM monthly_pool_trend ORDER BY added_month, source"),
    ("Data-quality checks", "SELECT * FROM quality_check_results ORDER BY check_name"),
]


def build_connection():
    connection = sqlite3.connect(":memory:")
    connection.row_factory = sqlite3.Row
    for filename in SQL_FILES:
        connection.executescript((SQL_DIR / filename).read_text(encoding="utf-8"))
    return connection


def print_rows(title, rows):
    print(f"\n{title}")
    if not rows:
        print("(no rows)")
        return
    columns = rows[0].keys()
    print(" | ".join(columns))
    for row in rows:
        print(" | ".join("" if row[column] is None else str(row[column]) for column in columns))


def main():
    connection = build_connection()
    try:
        for title, query in REPORTS:
            print_rows(title, connection.execute(query).fetchall())
        failures = connection.execute(
            "SELECT check_name, issue_count FROM quality_check_results WHERE issue_count <> 0"
        ).fetchall()
        if failures:
            raise SystemExit("SQL demo failed one or more data-quality checks.")
        print("\nPASS: all SQL data-quality checks returned zero issues.")
    finally:
        connection.close()


if __name__ == "__main__":
    main()

