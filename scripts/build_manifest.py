#!/usr/bin/env python3
"""Create a deterministic source manifest; generated FPGA output is excluded."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path

EXCLUDED_DIRS = {
    ".git", "build", "__pycache__", ".pytest_cache", ".Xil", "db", "incremental_db",
    "output_files", "ip_user_files", ".ip_cache", ".cache", ".runs", ".sim",
    ".hw", "work", "simulation", "qa", "node_modules", ".venv"
}
EXCLUDED_SUFFIXES = {
    ".sof", ".pof", ".jic", ".bit", ".bin", ".dcp", ".wlf", ".vcd", ".fst",
    ".jou", ".log", ".pyc"
}


def build_manifest(root: Path, device: str, tool_version: str, revision: str,
                   output: Path | None = None) -> dict:
    root = root.resolve()
    output_resolved = output.resolve() if output else None
    files = []
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(root)
        if any(part in EXCLUDED_DIRS for part in rel.parts):
            continue
        if path.suffix.lower() in EXCLUDED_SUFFIXES:
            continue
        if output_resolved == path.resolve():
            continue
        payload = path.read_bytes()
        files.append({
            "path": rel.as_posix(),
            "size_bytes": len(payload),
            "sha256": hashlib.sha256(payload).hexdigest()
        })
    return {
        "schema_version": 1,
        "git_revision": revision or "unspecified",
        "tool_version": tool_version or "unspecified",
        "target_device": device or "unspecified",
        "files": files
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--device", default=os.getenv("FPGA_DEVICE", "unspecified"))
    parser.add_argument("--tool-version", default=os.getenv("FPGA_TOOL_VERSION", "unspecified"))
    parser.add_argument("--revision", default=os.getenv("GIT_COMMIT", "unspecified"))
    args = parser.parse_args()
    result = build_manifest(args.root, args.device, args.tool_version,
                            args.revision, args.output)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(result['files'])} source hashes to {args.output}")


if __name__ == "__main__":
    main()
