onerror {quit -f}
vlib work
vlog -work work ask_rcv.vo
vlog -work work ask_rcv.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.ask_rcv_vlg_vec_tst
vcd file -direction ask_rcv.msim.vcd
vcd add -internal ask_rcv_vlg_vec_tst/*
vcd add -internal ask_rcv_vlg_vec_tst/i1/*
add wave /*
run -all
