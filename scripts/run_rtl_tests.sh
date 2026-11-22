#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
run() {
  local top="$1"; shift
  echo "=== $top ==="
  iverilog -g2012 -Wall -s "$top" -o "$TEMP_DIR/$top.vvp" "$@"
  vvp "$TEMP_DIR/$top.vvp"
}
run tb_mux4 examples/rtl/mux4.v examples/tb/tb_mux4.v
run tb_alu4 examples/rtl/alu4.v examples/tb/tb_alu4.v
run tb_tick_counter examples/rtl/tick_counter.v examples/tb/tb_tick_counter.v
run tb_debounce examples/rtl/debounce.v examples/tb/tb_debounce.v
run tb_detect101 examples/rtl/detect101.v examples/tb/tb_detect101.v
run tb_uart_loopback examples/rtl/uart_tx.v examples/rtl/uart_rx.v examples/tb/tb_uart_loopback.v
run tb_spi_master_mode0 examples/rtl/spi_master_mode0.v examples/tb/tb_spi_master_mode0.v
run tb_i2c_bit_cell examples/rtl/i2c_bit_cell.v examples/tb/tb_i2c_bit_cell.v
echo "PASS: eight RTL testbenches"
