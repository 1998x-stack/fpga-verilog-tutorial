import unittest
from scripts.frame_budget import estimate

class FrameBudgetTests(unittest.TestCase):
    def test_1080p_rgb888(self):
        x=estimate(1920,1080,3,60,2)
        self.assertEqual(x.bytes_per_frame,6220800)
        self.assertEqual(x.allocated_bytes,12441600)
        self.assertEqual(x.write_bytes_per_second,373248000)
        self.assertEqual(x.read_write_bytes_per_second,746496000)
    def test_stride(self):
        x=estimate(5,3,3,25,2,16)
        self.assertEqual(x.bytes_per_frame,48)
        self.assertEqual(x.allocated_bytes,96)
        self.assertEqual(x.write_bytes_per_second,1125)
    def test_invalid(self):
        for args in ((0,480,3,60),(640,-1,3,60),(640,480,0,60)):
            with self.assertRaises(ValueError): estimate(*args)
        with self.assertRaises(ValueError): estimate(640,480,3,60,stride_bytes=100)
        with self.assertRaises(ValueError): estimate(640,480,3,60,buffers=0)

if __name__=="__main__":
    unittest.main()
