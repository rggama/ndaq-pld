onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/rst_gen/rst
add wave -noupdate -divider Tpulse
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/rst
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/clk
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/enable
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/trig_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/trig_out
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/pdet_state
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/r_trig_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/i_trig_out
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/a_etrigger_cond/r_enable
add wave -noupdate -divider Mighty
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/rst
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/clk
add wave -noupdate -color Cyan -itemcolor Cyan /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/trigger_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/enable
add wave -noupdate -color Magenta -itemcolor Magenta /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/lock
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/srst
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/rdclk
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/rden
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/fifo_empty
add wave -noupdate -color {Medium Blue} -itemcolor {Medium Blue} -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/counter_q
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/i_counter
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/counter_reg
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/fifo_full
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/fifo_wen
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/fifo_data
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/r_fifo_wen
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/r_trigger_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/s_trigger_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/incremented
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/r_incremented
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/r_lock
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/s_lock
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/t_lock
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/mtrigger_counter/u_lock
add wave -noupdate -divider {Trigger Counter}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/clk
add wave -noupdate -color Cyan -itemcolor Cyan /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/trigger_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/enable
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/srst
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/fifowen_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/rdclk
add wave -noupdate -color Coral -itemcolor Coral /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/rden
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/fifo_empty
add wave -noupdate -color {Medium Blue} -itemcolor {Medium Blue} -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/counter_q
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/r_srst
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/i_counter
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/counter_reg
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/reg_wait
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/fifo_full
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/fifo_wen
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/r_fifo_wen
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/r_timebase_en
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/s_timebase_en
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/r_trigger_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/s_trigger_in
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/incremented
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/trigger_counter/r_incremented
add wave -noupdate -divider {Write ADC 1}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/enough_room_flag
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/scounter
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/i_acqin
add wave -noupdate -divider {Write ADC 2}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(1)/stream_IN/i_acqin
add wave -noupdate -divider {Write ADC 3}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(2)/stream_IN/i_acqin
add wave -noupdate -divider {Write ADC 4}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(3)/stream_IN/i_acqin
add wave -noupdate -divider {Write ADC 5}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(4)/stream_IN/i_acqin
add wave -noupdate -divider {Write ADC 6}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(5)/stream_IN/i_acqin
add wave -noupdate -divider {Write ADC 7}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(6)/stream_IN/i_acqin
add wave -noupdate -divider {Write ADC 8}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/clk
add wave -noupdate -color Red -itemcolor Red /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(7)/stream_IN/i_acqin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3204804 ps} 0} {{Cursor 2} {443082 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 392
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
WaveRestoreZoom {0 ps} {1785232 ps}
