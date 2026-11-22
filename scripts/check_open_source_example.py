#!/usr/bin/env python3
"""Static contract check for the documented iCEstick open-source flow."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
base = ROOT / "examples/open-source/ice40"
rtl = (base / "blink.v").read_text()
pcf = (base / "blink.pcf").read_text()
makefile = (base / "Makefile").read_text()
errors = []
for token in ("module blink", "SB_GB", "always @(posedge clk_global)", "counter[24]"):
    if token not in rtl: errors.append("blink.v missing " + token)
for token in ("set_io clki 21", "set_io led1 99", "set_io led5 95"):
    if token not in pcf: errors.append("blink.pcf missing " + token)
for token in ("synth_ice40", "nextpnr-ice40 --hx1k --package tq144",
              "icepack", 'CONFIRM_FLASH', "iceprog"):
    if token not in makefile: errors.append("Makefile missing " + token)
if errors:
    print("\n".join("ERROR " + e for e in errors)); sys.exit(1)
print("PASS iCEstick open-source flow contract (static only; no bitstream built)")
