import sys
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "sql"))
import run_demo  # noqa: E402


class SqlPortfolioDemoTests(unittest.TestCase):
    def setUp(self):
        self.connection = run_demo.build_connection()

    def tearDown(self):
        self.connection.close()

    def test_two_regime_anchor_and_first_due_date(self):
        row = self.connection.execute("""
            SELECT anchor_date, next_test_date, renewal_status
            FROM renewal_priority_2026 WHERE candidate_id = 1
        """).fetchone()
        self.assertEqual(tuple(row), ("2021-06-30", "2026-06-30", "Overdue"))

    def test_status_distribution_matches_fixture(self):
        rows = self.connection.execute("""
            SELECT renewal_status, COUNT(*)
            FROM renewal_priority_2026
            GROUP BY renewal_status
        """).fetchall()
        self.assertEqual(dict(rows), {
            "Overdue": 2,
            "Due now": 2,
            "Upcoming": 1,
            "Later": 1,
        })

    def test_call_queue_excludes_recorded_outcomes(self):
        rows = self.connection.execute("""
            SELECT candidate_id FROM call_queue_2026
            ORDER BY candidate_id
        """).fetchall()
        self.assertEqual([row[0] for row in rows], [2, 4, 5])

    def test_contact_rate_uses_called_denominator(self):
        row = self.connection.execute("SELECT * FROM contact_outcome_kpis").fetchone()
        self.assertEqual(tuple(row), (6, 2, 1, 1, 50.0))

    def test_unified_pool_preserves_source(self):
        rows = self.connection.execute("""
            SELECT source, COUNT(*) FROM unified_contact_pool GROUP BY source
        """).fetchall()
        self.assertEqual(dict(rows), {"External": 3, "Interested trainee": 1})

    def test_all_quality_checks_pass(self):
        failures = self.connection.execute(
            "SELECT check_name FROM quality_check_results WHERE issue_count <> 0"
        ).fetchall()
        self.assertEqual(failures, [])


if __name__ == "__main__":
    unittest.main()

