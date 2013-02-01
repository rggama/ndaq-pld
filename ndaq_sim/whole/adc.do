onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Write FIFO}
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/clk
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/rst
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/enable
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/acqin
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/tmode
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/trig0
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/trig1
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/trig2
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/trig3
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/wr
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/usedw
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/full
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/enough_room_flag
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/wmax
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/esize
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/rst_r
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/scounter
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/tcounter
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/state
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/wmax_r
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/enough_room
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/i_wr
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/stream_IN/i_acqin
add wave -noupdate -divider FIFOs
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/wrclk
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/rdclk
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/rst
add wave -noupdate -color Cyan -itemcolor Cyan /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/wr
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/d
add wave -noupdate -color {Medium Orchid} -itemcolor {Medium Orchid} /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/rd
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/q
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/f
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/e
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/rdusedw
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/wrusedw
add wave -noupdate /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/ar
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/dbus
add wave -noupdate -radix hexadecimal /ndaq_sim_tbench/ndaq_core_fpga/adc_data_acq_construct(0)/fifo_module/data_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {4115384 ps} {5139384 ps}
