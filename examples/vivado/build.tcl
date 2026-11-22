# Non-project Vivado batch build. Invoke from the repository root:
#   FPGA_PART=<your-exact-part> BOARD_XDC=/absolute/path/board.xdc \
#      vivado -mode batch -source examples/vivado/build.tcl
# This file is not run in public GitHub Actions: actual FPGA tools/board
# constraints/license are required. Do not suppress DRC or timing warnings.
foreach var {FPGA_PART BOARD_XDC} {
    if {![info exists ::env($var)] || [string trim $::env($var)] eq ""} {
        error "Required environment variable $var was not provided"
    }
}
set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir .. ..]]
set part $::env(FPGA_PART)
set board_xdc [file normalize $::env(BOARD_XDC)]
if {![file exists $board_xdc] || ![file isfile $board_xdc]} {
    error "BOARD_XDC is not an existing file: $board_xdc"
}
set outdir [file join $repo_root build vivado]
file mkdir $outdir
puts "BUILD part=$part board_xdc=$board_xdc"
puts "BUILD note: review I/O constraints, timing reports and DRC before programming hardware"

read_verilog [file join $script_dir blink_top.v]
read_xdc $board_xdc
synth_design -top blink_top -part $part
report_utilization -file [file join $outdir utilization_synth.rpt]
opt_design
place_design
report_timing_summary -file [file join $outdir timing_place.rpt]
route_design
report_timing_summary -file [file join $outdir timing_route.rpt]
report_drc -file [file join $outdir drc.rpt]
write_checkpoint -force [file join $outdir routed.dcp]
write_bitstream -force [file join $outdir blink_top.bit]
puts "Generated candidate bitstream. Review timing_route.rpt and drc.rpt; board testing not automatic."
