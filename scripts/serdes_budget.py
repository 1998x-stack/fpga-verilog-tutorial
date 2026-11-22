#!/usr/bin/env python3
"""Compute an NRZ serial-link coding upper bound; not a PHY/PCIe throughput model."""
from __future__ import annotations
import argparse
import math

CODING_EFFICIENCY = {
    "none": 1.0,
    "8b10b": 8 / 10,
    "128b130b": 128 / 130,
}

def estimate(line_rate_gbps: float, lanes: int, coding: str,
             protocol_efficiency: float = 1.0) -> dict[str, float]:
    if not math.isfinite(line_rate_gbps) or line_rate_gbps <= 0:
        raise ValueError("line_rate_gbps must be finite and > 0")
    if not isinstance(lanes, int) or lanes < 1:
        raise ValueError("lanes must be a positive integer")
    if coding not in CODING_EFFICIENCY:
        raise ValueError(f"unsupported coding: {coding}")
    if not math.isfinite(protocol_efficiency) or not 0 <= protocol_efficiency <= 1:
        raise ValueError("protocol_efficiency must be between 0 and 1")
    raw = line_rate_gbps * lanes
    coded = raw * CODING_EFFICIENCY[coding]
    useful = coded * protocol_efficiency
    return {
        "raw_gbps_per_direction": raw,
        "after_line_coding_gbps": coded,
        "after_protocol_overhead_gbps": useful,
        "after_protocol_overhead_gBps": useful / 8,
    }

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--line-rate-gbps", type=float, required=True,
                        help="NRZ raw bit rate per lane in Gbit/s")
    parser.add_argument("--lanes", type=int, default=1)
    parser.add_argument("--coding", choices=CODING_EFFICIENCY, default="none")
    parser.add_argument("--protocol-efficiency", type=float, default=1.0,
                        help="illustrative fraction after line coding, 0..1")
    args = parser.parse_args()
    result = estimate(args.line_rate_gbps, args.lanes, args.coding,
                      args.protocol_efficiency)
    for key, value in result.items():
        print(f"{key}: {value:.6f}")

if __name__ == "__main__":
    main()
