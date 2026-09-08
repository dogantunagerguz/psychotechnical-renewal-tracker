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

    def test_pipeline_loads_all_public_demo_sources(self):
        row = self.connection.execute("SELECT * FROM pipeline_reconciliation").fetchone()
        self.assertEqual(tuple(row), (36, 36, 24, 20, 4, 36, 24, 32))

    def test_two_regime_anchor_and_due_date(self):
        row = self.connection.execute("""
            SELECT anchor_date, next_test_date, renewal_status
            FROM renewal_priority_2026
            WHERE candidate_id = 2001
        """).fetchone()
        self.assertEqual(tuple(row), ("2021-06-30", "2026-06-30", "Overdue"))

    def test_contact_rate_uses_called_denominator(self):
        row = self.connection.execute("SELECT * FROM contact_outcome_kpis").fetchone()
        self.assertEqual(tuple(row), (36, 24, 12, 12, 50.0))

    def test_unified_pool_preserves_source(self):
        rows = self.connection.execute("""
            SELECT source, COUNT(*) FROM unified_contact_pool GROUP BY source
        """).fetchall()
        self.assertEqual(dict(rows), {"External": 20, "Interested trainee": 12})

    def test_all_quality_checks_pass(self):
        failures = self.connection.execute(
            "SELECT check_name FROM quality_check_results WHERE issue_count <> 0"
        ).fetchall()
        self.assertEqual(failures, [])

    def test_committed_results_snapshot_is_current(self):
        expected = run_demo.render_results(self.connection)
        actual = (ROOT / "sql/RESULTS.md").read_text(encoding="utf-8")
        self.assertEqual(actual, expected)


if __name__ == "__main__":
    unittest.main()
