# MicroBlaze V system integration contract

This is a platform checklist, not a board-specific Vivado block design. Select a supported FPGA part and verify the IP catalogue and MicroBlaze V support for the installed Vivado release.

## Required architecture

- MicroBlaze V configured as RV32 or RV64 to match the firmware ABI.
- Instruction and data storage: local BRAM plus the corresponding LMB interfaces/controllers, or another supported memory architecture.
- AXI interconnect / SmartConnect for memory-mapped peripherals.
- The Chapter 19 `axi4lite_regs` block packaged as custom AXI4-Lite IP, with a generated address segment.
- Clock and reset sources with correctly connected reset synchronization.
- Debug module and JTAG path for software download/debug.
- Optional AXI4-Stream accelerator and DMA when moving blocks of data; do not poll a stream one word at a time from C.
- Optional interrupt controller / interrupt wiring only when the firmware actually enables and services interrupts.

## Software contract

The sample C application uses the generated `xparameters.h` base-address macro and `Xil_In32` / `Xil_Out32` from the Vitis standalone BSP. Change the macro to the exact generated name in your platform. The example register map must match the hardware IP and the address range assigned in the Address Editor.

## Build sequence

1. Create the MicroBlaze V block design and choose processor width / optional ISA features.
2. Connect instruction/data memories, clock/reset, debug, AXI interconnect and the custom peripheral.
3. Assign a non-overlapping address range; run Validate Design and review DRC.
4. Generate output products, create the HDL wrapper, implement and inspect timing/DRC.
5. Export the hardware platform (XSA) and open it in Vitis.
6. Build the standalone BSP and application; inspect the generated linker script and `xparameters.h`.
7. Program the FPGA, download the ELF, and test the peripheral ID / LED register.

The actual device, clock, memory size, address map, BSP, and generated macro depend on the selected board and tool version. No bitstream or board test is claimed by this generic example.
