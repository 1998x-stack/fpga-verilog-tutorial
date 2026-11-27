import hashlib
import tempfile
import unittest
from pathlib import Path

from scripts.build_manifest import build_manifest


class BuildManifestTests(unittest.TestCase):
    def test_hashes_inputs_and_excludes_generated_output(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "src").mkdir()
            (root / "build").mkdir()
            (root / "src" / "top.v").write_text("module top; endmodule\n")
            (root / "build" / "top.sof").write_bytes(b"binary")
            output = root / "manifest.json"
            manifest = build_manifest(root, "part-1", "tool-26.3", "abc123", output)
            self.assertEqual(manifest["target_device"], "part-1")
            self.assertEqual(len(manifest["files"]), 1)
            self.assertEqual(manifest["files"][0]["path"], "src/top.v")
            self.assertEqual(
                manifest["files"][0]["sha256"],
                hashlib.sha256(b"module top; endmodule\n").hexdigest()
            )

    def test_manifest_is_path_sorted_and_repeatable(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "b").mkdir()
            (root / "a").mkdir()
            (root / "b" / "z.sv").write_text("z")
            (root / "a" / "x.sv").write_text("x")
            first = build_manifest(root, "", "", "")
            second = build_manifest(root, "", "", "")
            self.assertEqual(first, second)
            self.assertEqual([x["path"] for x in first["files"]], ["a/x.sv", "b/z.sv"])


if __name__ == "__main__":
    unittest.main()
