#!/usr/bin/env python3
"""Transparent toy calculators; they do not replace vendor timing/power reports."""
from __future__ import annotations
import argparse
import math

def setup_slack_ns(period_ns: float, data_path_ns: float,
                   uncertainty_ns: float = 0.0, setup_ns: float = 0.0,
                   capture_skew_ns: float = 0.0) -> float:
    values = (period_ns, data_path_ns, uncertainty_ns, setup_ns, capture_skew_ns)
    if not all(math.isfinite(x) for x in values):
        raise ValueError("all timing inputs must be finite")
    if period_ns <= 0 or data_path_ns < 0 or uncertainty_ns < 0 or setup_ns < 0:
        raise ValueError("period must be > 0; path, uncertainty and setup must be >= 0")
    # Simplified register-to-register setup budget. Positive capture skew helps setup.
    return period_ns + capture_skew_ns - uncertainty_ns - setup_ns - data_path_ns

def dynamic_power_mw(activity: float, capacitance_pf: float,
                     voltage_v: float, frequency_mhz: float) -> float:
    values = (activity, capacitance_pf, voltage_v, frequency_mhz)
    if not all(math.isfinite(x) for x in values):
        raise ValueError("all power inputs must be finite")
    if not 0 <= activity <= 1 or capacitance_pf < 0 or voltage_v < 0 or frequency_mhz < 0:
        raise ValueError("activity must be 0..1; C, V and f must be >= 0")
    # alpha is defined here as average 0->1 charging transitions per clock cycle.
    # pF * MHz * V^2 gives micro-watts; convert to milli-watts.
    return activity * capacitance_pf * voltage_v**2 * frequency_mhz / 1000.0

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="mode", required=True)
    t = sub.add_parser("timing")
    t.add_argument("--period-ns", type=float, required=True)
    t.add_argument("--data-path-ns", type=float, required=True)
    t.add_argument("--uncertainty-ns", type=float, default=0)
    t.add_argument("--setup-ns", type=float, default=0)
    t.add_argument("--capture-skew-ns", type=float, default=0)
    p = sub.add_parser("power")
    p.add_argument("--activity", type=float, required=True)
    p.add_argument("--capacitance-pf", type=float, required=True)
    p.add_argument("--voltage-v", type=float, required=True)
    p.add_argument("--frequency-mhz", type=float, required=True)
    a = parser.parse_args()
    if a.mode == "timing":
        print(f"setup_slack_ns: {setup_slack_ns(a.period_ns,a.data_path_ns,a.uncertainty_ns,a.setup_ns,a.capture_skew_ns):.6f}")
    else:
        print(f"dynamic_power_mw: {dynamic_power_mw(a.activity,a.capacitance_pf,a.voltage_v,a.frequency_mhz):.6f}")

if __name__ == "__main__":
    main()
