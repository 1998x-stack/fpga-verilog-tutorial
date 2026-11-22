# Run from repository root: vsim -c -do sim/questa/run.do
onerror {quit -f -code 1}
transcript on
if {[file exists work]} { vdel -lib work -all }
vlib work
vlog -sv -work work examples/rtl/axi4lite_regs.v examples/tb/tb_axi4lite_regs.sv
vsim -c -voptargs=+acc work.tb_axi4lite_regs
add wave -r /*
run -all
quit -f
