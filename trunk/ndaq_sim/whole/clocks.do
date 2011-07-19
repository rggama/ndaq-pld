onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CORE FPGA Clocks}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/iclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/pclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/nclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/mclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/sclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/clk_enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/tclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/clk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/clk_en
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/clock_div
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/clock_manager/tclk_u
add wave -noupdate -divider {VME FPGA Clocks}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/iclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/pclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/nclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/mclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/sclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/clk_enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/tclk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/clk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/clk_en
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/clock_div
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/clock_manager/tclk_u
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 424
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {821564 ps}
