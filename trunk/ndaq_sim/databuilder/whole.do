onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /databuilder_tbench/data_builder/clk
add wave -noupdate /databuilder_tbench/data_builder/rst
add wave -noupdate -divider Interface
add wave -noupdate /databuilder_tbench/data_builder/enable_a
add wave -noupdate /databuilder_tbench/data_builder/enable_b
add wave -noupdate /databuilder_tbench/data_builder/enable_c
add wave -noupdate -radix hexadecimal /databuilder_tbench/data_builder/transfer
add wave -noupdate /databuilder_tbench/data_builder/address
add wave -noupdate /databuilder_tbench/data_builder/mode
add wave -noupdate -radix hexadecimal /databuilder_tbench/data_builder/ctval
add wave -noupdate -radix hexadecimal -expand -subitemconfig {/databuilder_tbench/data_builder/idata(3) {-height 15 -radix hexadecimal} /databuilder_tbench/data_builder/idata(2) {-height 15 -radix hexadecimal} /databuilder_tbench/data_builder/idata(1) {-height 15 -radix hexadecimal} /databuilder_tbench/data_builder/idata(0) {-height 15 -radix hexadecimal}} /databuilder_tbench/data_builder/idata
add wave -noupdate -divider Internal
add wave -noupdate -radix hexadecimal /databuilder_tbench/data_builder/idata_bus
add wave -noupdate /databuilder_tbench/data_builder/en_a
add wave -noupdate -color Red -itemcolor Red /databuilder_tbench/data_builder/en_b
add wave -noupdate /databuilder_tbench/data_builder/en_c
add wave -noupdate /databuilder_tbench/data_builder/mode_sel
add wave -noupdate -radix hexadecimal /databuilder_tbench/data_builder/ctval_bus
add wave -noupdate -radix hexadecimal /databuilder_tbench/data_builder/t_size
add wave -noupdate /databuilder_tbench/data_builder/rds
add wave -noupdate /databuilder_tbench/data_builder/wrs
add wave -noupdate /databuilder_tbench/data_builder/stateval
add wave -noupdate /databuilder_tbench/data_builder/next_stateval
add wave -noupdate /databuilder_tbench/data_builder/s_counter_en
add wave -noupdate /databuilder_tbench/data_builder/s_counter_cl
add wave -noupdate /databuilder_tbench/data_builder/t_counter_en
add wave -noupdate /databuilder_tbench/data_builder/t_counter_cl
add wave -noupdate -divider {Constant Value Logic}
add wave -noupdate /databuilder_tbench/data_builder/ctval_en
add wave -noupdate /databuilder_tbench/data_builder/kctval_en
add wave -noupdate -divider {Internal Counters}
add wave -noupdate -color {Sky Blue} -itemcolor {Sky Blue} -radix hexadecimal /databuilder_tbench/data_builder/s_counter
add wave -noupdate -radix hexadecimal /databuilder_tbench/data_builder/t_counter
add wave -noupdate -divider {Transfer Interface}
add wave -noupdate /databuilder_tbench/data_builder/rd
add wave -noupdate /databuilder_tbench/data_builder/wr
add wave -noupdate -color {Orange Red} -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/data_builder/odata
add wave -noupdate -divider {INP FIFO 0}
add wave -noupdate -radix hexadecimal /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/data
add wave -noupdate -color Cyan -itemcolor Cyan /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/rdreq
add wave -noupdate /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/q
add wave -noupdate -color Red -itemcolor Red /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/rdempty
add wave -noupdate -radix hexadecimal /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/rdusedw
add wave -noupdate /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/wrfull
add wave -noupdate -radix hexadecimal /databuilder_tbench/inp_fifo_construct(0)/read_testfifo/wrusedw
add wave -noupdate -divider {INP FIFO 1}
add wave -noupdate -radix hexadecimal /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/data
add wave -noupdate -color Cyan -itemcolor Cyan /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/rdreq
add wave -noupdate /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/q
add wave -noupdate /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/rdempty
add wave -noupdate -radix hexadecimal /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/rdusedw
add wave -noupdate /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/wrfull
add wave -noupdate -radix hexadecimal /databuilder_tbench/inp_fifo_construct(1)/read_testfifo/wrusedw
add wave -noupdate -divider {OUP FIFO 0}
add wave -noupdate /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/wrclk
add wave -noupdate -color {Orange Red} -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/data
add wave -noupdate /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/rdreq
add wave -noupdate -color White -itemcolor White /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/q
add wave -noupdate /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/rdempty
add wave -noupdate -radix hexadecimal /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/rdusedw
add wave -noupdate /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/wrfull
add wave -noupdate -radix hexadecimal /databuilder_tbench/oup_fifo_construct(0)/write_testfifo/wrusedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 7} {17321290 ps} 0} {{Cursor 2} {581589 ps} 0}
configure wave -namecolwidth 418
configure wave -valuecolwidth 166
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
WaveRestoreZoom {29707533 ps} {40541709 ps}
