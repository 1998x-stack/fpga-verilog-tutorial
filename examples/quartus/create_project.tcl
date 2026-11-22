# Run with:
# FPGA_FAMILY="<exact Quartus family>" FPGA_DEVICE="<exact full part>" \
#   quartus_sh -t examples/quartus/create_project.tcl
# Then compile:
#   quartus_sh --flow compile build/quartus/fpga_lab -c rev_a
# Generic project shell only: no board pin assignments are guessed.
foreach name {FPGA_FAMILY FPGA_DEVICE} {
    if {![info exists ::env($name)] || [string trim $::env($name)] eq ""} {
        error "Set $name from the exact target board / device documentation"
    }
}
set root [file normalize [file join [file dirname [info script]] .. ..]]
set build_dir [file join $root build quartus]
file mkdir $build_dir
cd $build_dir
load_package project
project_new -overwrite -revision rev_a -family "$::env(FPGA_FAMILY)" -part "$::env(FPGA_DEVICE)" fpga_lab
set_global_assignment -name TOP_LEVEL_ENTITY led_counter
set_global_assignment -name VERILOG_FILE [file join $root examples quartus led_counter.v]
set_global_assignment -name SDC_FILE [file join $root examples quartus base.sdc]
project_close
puts "Created Quartus project at [file join $build_dir fpga_lab.qpf]"
puts "No board pins or I/O standards were guessed. Add verified assignments before programming."
