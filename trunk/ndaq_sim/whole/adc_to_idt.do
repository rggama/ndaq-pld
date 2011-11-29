onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ndaq_sim_tbench/adc_dco
add wave -noupdate -format Logic /ndaq_sim_tbench/clkcore
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/dcounter
add wave -noupdate -format Logic /ndaq_sim_tbench/trigger
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/adc_data
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo1_wen
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo2_wen
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo3_wen
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo4_wen
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo_wck
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo1_paf
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo2_paf
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo3_paf
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/fifo4_paf
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/fifo_data_bus
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 278
configure wave -valuecolwidth 62
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {129140 ps}
