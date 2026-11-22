import unittest
from scripts.sta_budget import Budget, analyze


class BudgetTests(unittest.TestCase):
    def test_setup_demo(self):
        r = analyze(Budget())
        self.assertAlmostEqual(r["arrival_max"], 8.15)
        self.assertAlmostEqual(r["required_setup"], 9.70)
        self.assertAlmostEqual(r["setup_slack"], 1.55)

    def test_hold_demo(self):
        r = analyze(Budget())
        self.assertAlmostEqual(r["hold_slack"], 0.09)
        self.assertAlmostEqual(r["required_hold"], 0.21)

    def test_reducing_clock_period_only_affects_setup(self):
        original = analyze(Budget())
        fast = analyze(Budget(period=9.0))
        self.assertAlmostEqual(fast["setup_slack"], original["setup_slack"] - 1)
        self.assertAlmostEqual(fast["hold_slack"], original["hold_slack"])

    def test_negative_slack(self):
        r = analyze(Budget(data_max=9.6, data_min=0))
        self.assertLess(r["setup_slack"], 0)
        self.assertLess(r["hold_slack"], 0)

    def test_invalid_period(self):
        with self.assertRaises(ValueError):
            analyze(Budget(period=0))


if __name__ == "__main__":
    unittest.main()
