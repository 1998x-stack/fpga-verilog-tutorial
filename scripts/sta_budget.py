#!/usr/bin/env python3
"""Educational single-clock STA arithmetic; NOT a substitute for Vivado STA.

All units are ns; positive skew means capture clock is later than launch.
Setup assumes next-edge capture; hold assumes same nominal-edge capture.
"""
from dataclasses import dataclass


@dataclass(frozen=True)
class Budget:
    period: float = 10.00
    skew: float = 0.10
    setup_uncertainty: float = 0.15
    setup_time: float = 0.25
    clkq_max: float = 0.35
    data_max: float = 7.80
    hold_uncertainty: float = 0.03
    hold_time: float = 0.08
    clkq_min: float = 0.20
    data_min: float = 0.10


def analyze(b: Budget) -> dict:
    if b.period <= 0:
        raise ValueError("clock period must be positive")
    if min(b.clkq_min, b.clkq_max, b.data_min, b.data_max) < 0:
        raise ValueError("delays must be nonnegative")
    arrival_max = b.clkq_max + b.data_max
    required_setup = b.period + b.skew - b.setup_uncertainty - b.setup_time
    setup_slack = required_setup - arrival_max
    arrival_min = b.clkq_min + b.data_min
    required_hold = b.skew + b.hold_time + b.hold_uncertainty
    hold_slack = arrival_min - required_hold
    return {
        "arrival_max": arrival_max,
        "required_setup": required_setup,
        "setup_slack": setup_slack,
        "arrival_min": arrival_min,
        "required_hold": required_hold,
        "hold_slack": hold_slack
    }


def main() -> None:
    print("SIMPLIFIED SINGLE-CLOCK PATH (not actual Vivado STA)")
    for name, value in analyze(Budget()).items():
        print(f"{name}: {value:+.2f} ns")


if __name__ == "__main__":
    main()
