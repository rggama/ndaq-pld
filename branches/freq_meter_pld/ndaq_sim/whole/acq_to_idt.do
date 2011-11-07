onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Stream IN}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/acqin
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/trig0
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/wr
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/usedw
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/wmax
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/esize
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/rst_r
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/rst_l
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/scounter
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/state
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/wmax_r
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/wmax_l
add wave -noupdate -divider {FIFO Module}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/wr
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/d
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/rd
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/q
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/f
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/e
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/rdusedw
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/fifo_module/wrusedw
add wave -noupdate -divider {IDT Copier}
add wave -noupdate -format Literal -radix hexadecimal -expand /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_full
add wave -noupdate -format Literal -radix binary /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_wren
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_data
add wave -noupdate -format Literal -radix binary /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_empty
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_used_a
add wave -noupdate -format Literal -radix binary /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_rden
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_qa
add wave -noupdate -divider {IDT FIFO}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_fifo/wrclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_fifo/wrreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_fifo/wrusedw
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_fifo/rdclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_fifo/rdreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_fifo/q
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/transfer_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {194478 ps} 0} {{Cursor 4} {2307917 ps} 0}
configure wave -namecolwidth 456
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
WaveRestoreZoom {9810790 ps} {10009958 ps}
