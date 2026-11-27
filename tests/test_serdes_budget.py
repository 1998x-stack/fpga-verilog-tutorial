import unittest
from scripts.serdes_budget import estimate

class SerdesBudgetTests(unittest.TestCase):
    def test_pcie5_x16_line_coding_upper_bound(self):
        result = estimate(32.0, 16, "128b130b")
        self.assertAlmostEqual(result["raw_gbps_per_direction"], 512.0)
        self.assertAlmostEqual(result["after_line_coding_gbps"], 504.1230769231)
        self.assertAlmostEqual(result["after_protocol_overhead_gBps"], 63.0153846154)

    def test_8b10b_efficiency(self):
        result = estimate(5.0, 1, "8b10b")
        self.assertAlmostEqual(result["after_line_coding_gbps"], 4.0)

    def test_protocol_efficiency_is_separate(self):
        result = estimate(10.0, 2, "128b130b", 0.9)
        self.assertAlmostEqual(result["after_protocol_overhead_gbps"],
                               20 * 128 / 130 * 0.9)

    def test_invalid_inputs(self):
        for args in [(0,1,"none"), (1,0,"none"), (1,1,"bad"),
                     (1,1,"none",1.1)]:
            with self.assertRaises(ValueError):
                estimate(*args)

if __name__ == "__main__":
    unittest.main()
