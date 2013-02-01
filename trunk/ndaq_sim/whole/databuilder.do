onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/rst
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/clk
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/enable
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/enable_A
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/enable_B
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/enable_C
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/transfer
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/address
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/mode
add wave -noupdate -expand /ndaq_sim_tbench/ndaq_core_fpga/data_builder/rd
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/idata
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/ctval
add wave -noupdate -color Orange -itemcolor Orange /ndaq_sim_tbench/ndaq_core_fpga/busy
add wave -noupdate -expand -subitemconfig {/ndaq_sim_tbench/ndaq_core_fpga/data_builder/wr(1) {-color Magenta -itemcolor Magenta} /ndaq_sim_tbench/ndaq_core_fpga/data_builder/wr(0) {-color {Violet Red} -height 15 -itemcolor {Violet Red}}} /ndaq_sim_tbench/ndaq_core_fpga/data_builder/wr
add wave -noupdate -color Blue -itemcolor Blue -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/odata
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/s_counter_en
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/s_counter_cl
add wave -noupdate -color {Orange Red} -itemcolor {Orange Red} -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/s_counter
add wave -noupdate -color {Cornflower Blue} -itemcolor {Cornflower Blue} -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/idata_bus
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/ctval_bus
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/en_a
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/en_b
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/en_c
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/t_size
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/addr_bus
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/mode_sel
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/rds
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/wrs
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/rda
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/wra
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/stateval
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/next_stateval
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/t_counter_en
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/t_counter_cl
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/data_builder/t_counter
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/ctval_en
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/data_builder/kctval_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1928730 ps} 0} {{Cursor 2} {2024252 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {4298076 ps} {6346076 ps}
