# Teaching clock constraint only.
# Assumption: the actual board provides a 50 MHz clock on port clk.
# Replace this period and add board-derived input/output delays for real hardware.
create_clock -name board_clk -period 20.000 [get_ports {clk}]
