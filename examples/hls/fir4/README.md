# FIR4 — portable C-simulation boundary of an HLS example

This four-tap FIR uses coefficients [1,2,2,1], signed 16-bit samples and
a signed 32-bit intermediate. Division by six uses C++ truncation toward zero.
An explicit reset invocation clears static history. It is NOT a specified
hardware reset pin or AXI streaming interface.

Run without AMD tools:

    make -C examples/hls/fir4 test

The HLS PIPELINE II=1 pragma is a *request*, not an achieved scheduling metric.
C++ testing validates values and history, not initiation interval, latency,
LUT/DSP/BRAM usage, Fmax, generated RTL, interface protocol, or bitstream.
To study the actual hardware, use a real device, clock, and Vitis HLS version,
run C simulation, C synthesis and C/RTL co-simulation, and inspect the report.

Source: https://docs.amd.com/r/en-US/ug1399-vitis-hls/Pipeline
