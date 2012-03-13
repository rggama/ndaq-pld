onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Trigger
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/trigger_a
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/a_etrigger_cond/trig_in
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/a_etrigger_cond/trig_out
add wave -noupdate -divider {Stream IN}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/trig0
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/acqin
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/wr
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/usedw
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/wmax
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/esize
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/rst_r
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/scounter
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/state
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct__0/stream_in/wmax_r
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
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_full
add wave -noupdate -format Literal -radix binary /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_wren
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/idt_data
add wave -noupdate -format Literal -radix binary /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_empty
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_used_a
add wave -noupdate -format Literal -radix binary /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_rden
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo_qa
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/idt_writer/fifo1_idtfifo_ctr/transfer_counter
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/fifo_data_bus
add wave -noupdate -divider {IDT FIFO 1}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/rdclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/wrclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/wrreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/q
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/rdempty
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__1/fake_idt_fifo/wrusedw
add wave -noupdate -divider {IDT FIFO 2}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/rdclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/q
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/rdempty
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrusedw
add wave -noupdate -divider {IDT FIFO 3}
add wave -noupdate -format Literal /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/rdclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/wrclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/wrreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/q
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/rdempty
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__3/fake_idt_fifo/wrusedw
add wave -noupdate -divider {IDT FIFO 4}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/rdclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/wrclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/wrreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/q
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/rdempty
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__4/fake_idt_fifo/wrusedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {39438644 ps} 0} {{Cursor 4} {110896710 ps} 0}
configure wave -namecolwidth 498
configure wave -valuecolwidth 110
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
WaveRestoreZoom {0 ps} {136084992 ps}
