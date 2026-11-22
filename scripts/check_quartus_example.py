#!/usr/bin/env python3
"""Static source-contract checks only; does not execute Quartus or select a board."""
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
tcl = (root / "examples/quartus/create_project.tcl").read_text(encoding="utf-8")
rtl = (root / "examples/quartus/led_counter.v").read_text(encoding="utf-8")
sdc = (root / "examples/quartus/base.sdc").read_text(encoding="utf-8")
errors = []
for token in ("FPGA_FAMILY", "FPGA_DEVICE", "project_new", "TOP_LEVEL_ENTITY",
              "VERILOG_FILE", "SDC_FILE", "project_close"):
    if token not in tcl:
        errors.append("Missing Quartus project Tcl token: " + token)
for token in ("module led_counter", "posedge clk", "reset_n"):
    if token not in rtl:
        errors.append("Missing RTL token: " + token)
if "create_clock" not in sdc:
    errors.append("SDC must define an explicit example clock")
if any("set_location_assignment" in line and not line.lstrip().startswith("#")
       for line in tcl.splitlines()):
    errors.append("Do not hardcode board pin assignments in generic project Tcl")
if errors:
    print("\n".join("FAIL " + x for x in errors))
    sys.exit(1)
print("PASS Quartus example static contract (not a Quartus compilation or board sign-off)")
