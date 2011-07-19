onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Top
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/rst
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/clk
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/stateval
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/next_stateval
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/i_start_transfer
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/transfer_running
add wave -noupdate -divider Ctrl
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/start_transfer
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/running
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/i_running
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/stateval
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/next_stateval
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/i_enable_counter
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/i_clear_counter
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/transfer_counter
add wave -noupdate -divider {IDT Bus}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/clk
add wave -noupdate -format Literal -expand /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_wren
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_data
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/rden_a
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_qa
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/i_bus_enable
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/bus_enable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {154201 ps} 0} {{Cursor 2} {3649950 ps} 0} {{Cursor 3} {1535472 ps} 0}
configure wave -namecolwidth 452
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {355328 ps}
