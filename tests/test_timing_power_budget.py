import unittest
from scripts.timing_power_budget import setup_slack_ns, dynamic_power_mw

class TimingPowerBudgetTests(unittest.TestCase):
    def test_setup_slack_and_capture_skew(self):
        self.assertAlmostEqual(setup_slack_ns(5.0, 4.0, 0.2, 0.1, 0.1), 0.8)
        self.assertAlmostEqual(setup_slack_ns(5.0, 4.0, 0.2, 0.1, -0.1), 0.6)

    def test_dynamic_power(self):
        # alpha=0.2, C=100 pF, V=0.9 V, f=100 MHz -> 1.62 mW
        self.assertAlmostEqual(dynamic_power_mw(0.2, 100, 0.9, 100), 1.62)

    def test_invalid_inputs(self):
        with self.assertRaises(ValueError):
            setup_slack_ns(0, 1)
        with self.assertRaises(ValueError):
            dynamic_power_mw(1.1, 10, 1, 100)

if __name__ == "__main__":
    unittest.main()
