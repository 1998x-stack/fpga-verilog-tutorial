#!/usr/bin/env python3
"""Uncompressed active-pixel frame storage and traffic lower bounds, not DDR sign-off."""
from __future__ import annotations
import argparse
from dataclasses import dataclass

@dataclass(frozen=True)
class FrameBudget:
    bytes_per_frame: int
    allocated_bytes: int
    write_bytes_per_second: int
    read_write_bytes_per_second: int

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
    return FrameBudget(frame_bytes,frame_bytes*buffers,
                       active_line*height*fps,2*active_line*height*fps)
def main() -> None:
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--width",type=int,required=True)
    p.add_argument("--height",type=int,required=True)
    p.add_argument("--bytes-per-pixel",type=int,required=True)
    p.add_argument("--fps",type=int,required=True)
    p.add_argument("--buffers",type=int,default=2)
    p.add_argument("--stride-bytes",type=int,default=None)
    a=p.parse_args()
    res=estimate(a.width,a.height,a.bytes_per_pixel,a.fps,a.buffers,a.stride_bytes)
    for name,value in vars(res).items():
        print(f"{name}: {value}")
if __name__=="__main__":
    main()
