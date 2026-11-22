#!/usr/bin/env python3
"""Lightweight source contract check; does NOT invoke Vivado or sign off timing."""
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
tcl = (root/"examples/vivado/build.tcl").read_text(encoding="utf-8")
rtl = (root/"examples/vivado/blink_top.v").read_text(encoding="utf-8")
xdc = (root/"examples/vivado/board.xdc.template").read_text(encoding="utf-8")
errors = []
needed = (
    "FPGA_PART", "BOARD_XDC", "read_verilog", "read_xdc",
    "synth_design", "opt_design", "place_design", "route_design",
    "report_utilization", "report_timing_summary", "report_drc",
    "write_checkpoint", "write_bitstream"
)
for command in needed:
    if command not in tcl:
        errors.append("Missing essential Tcl element: "+command)
for signal in ("clk", "rst_n", "led"):
    if signal not in rtl:
        errors.append("Top module port missing: "+signal)
if "module blink_top" not in rtl:
    errors.append("Expected top module blink_top")
if "create_clock" not in xdc:
    errors.append("Template must include clock declaration")
if any(line.strip().startswith("set_property PACKAGE_PIN")
       for line in xdc.splitlines()):
    errors.append("Template unexpectedly contains an active hardcoded pin")
if any("set_false_path" in line and not line.lstrip().startswith("#")
       for line in xdc.splitlines()):
    errors.append("Template must not hide timing via blanket false paths")
if errors:
    print("\n".join("FAIL "+s for s in errors))
    sys.exit(1)
print("PASS Vivado example static contract (not synthesis or hardware QA)")
