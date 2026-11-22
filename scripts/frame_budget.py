#!/usr/bin/env python3
"""Frame storage and AXI transfer budgets; not DDR-controller sign-off."""
from __future__ import annotations
import argparse
from dataclasses import dataclass

@dataclass(frozen=True)
class FrameBudget:
    active_line_bytes: int
    stride_bytes: int
    bytes_per_frame: int
    allocated_bytes: int
    active_pixel_write_bytes_per_second: int
    active_pixel_read_write_bytes_per_second: int
    stride_write_bytes_per_second: int
    stride_read_write_bytes_per_second: int

def estimate(width: int, height: int, bytes_per_pixel: int,
             fps: int, buffers: int=2, stride_bytes: int | None=None) -> FrameBudget:
    for name,value in (("width",width),("height",height),("bytes_per_pixel",bytes_per_pixel),
                       ("fps",fps),("buffers",buffers)):
        if type(value) is not int or value <= 0:
            raise ValueError(f"{name} must be a positive integer")
    active_line=width*bytes_per_pixel
    if stride_bytes is None:
        stride_bytes=active_line
    if type(stride_bytes) is not int or stride_bytes < active_line:
        raise ValueError("stride_bytes must be an integer >= active line bytes")
    frame_bytes=stride_bytes*height
    active_write=active_line*height*fps
    stride_write=stride_bytes*height*fps
    return FrameBudget(
        active_line_bytes=active_line,
        stride_bytes=stride_bytes,
        bytes_per_frame=frame_bytes,
        allocated_bytes=frame_bytes*buffers,
        active_pixel_write_bytes_per_second=active_write,
        active_pixel_read_write_bytes_per_second=2*active_write,
        stride_write_bytes_per_second=stride_write,
        stride_read_write_bytes_per_second=2*stride_write,
    )

def main() -> None:
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--width",type=int,required=True)
    p.add_argument("--height",type=int,required=True)
    p.add_argument("--bytes-per-pixel",type=int,required=True)
    p.add_argument("--fps",type=int,required=True)
    p.add_argument("--buffers",type=int,default=2)
    p.add_argument("--stride-bytes",type=int,default=None,
                   help="bytes per stored line; defaults to width * bytes-per-pixel")
    a=p.parse_args()
    res=estimate(a.width,a.height,a.bytes_per_pixel,a.fps,a.buffers,a.stride_bytes)
    for name,value in vars(res).items():
        print(f"{name}: {value}")

if __name__=="__main__":
    main()
