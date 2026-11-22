# EDUCATIONAL ONLY: not a valid board-specific constraints file.
# Assumes a hypothetical external source-synchronous interface and
# illustrative min/max delay values. Derive numbers from the actual
# external device datasheet, PCB timing and clock relationship.
# Example port names (clk/din/dout) require matching real RTL.
create_clock -name sys_clk -period 10.000 [get_ports clk]
set_input_delay  -clock sys_clk -max 2.1 [get_ports din]
set_input_delay  -clock sys_clk -min 0.3 [get_ports din]
set_output_delay -clock sys_clk -max 1.7 [get_ports dout]
set_output_delay -clock sys_clk -min -0.4 [get_ports dout]
# Not for FPGA programming: no board IOSTANDARD/PACKAGE_PIN mapping.
