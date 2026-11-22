# Questa / ModelSim regression

The maintained Altera simulator flow is **Questa-Altera FPGA Edition**. Older Quartus project settings may still mention ModelSim FPGA Edition; current Altera documentation describes the Questa-Altera replacement.

1. Install the simulator compatible with your Quartus release.
2. Obtain and configure the required license. Questa-Altera FPGA Starter Edition is free, but elaboration and simulation still require a no-cost license.
3. From the repository root, run:

```sh
vsim -c -do sim/questa/run.do
```

The script compiles the Chapter 19 AXI4-Lite subordinate and self-checking testbench, elaborates the top, adds waveforms, runs to `$finish`, and exits. Use `vsim -do sim/questa/run.do` to open the GUI if your installation supports the same script flow.

This Questa script is not run in public GitHub Actions because the simulator and its license are not provisioned there. The same RTL/testbench pair is compiled and executed in CI with Icarus Verilog; simulator implementations are not assumed to be bit-for-bit identical.
