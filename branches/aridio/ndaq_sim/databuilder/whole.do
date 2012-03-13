onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /databuilder_tbench/data_builder/clk
add wave -noupdate -format Logic /databuilder_tbench/data_builder/rst
add wave -noupdate -divider Interface
add wave -noupdate -format Literal /databuilder_tbench/data_builder/enable_a
add wave -noupdate -format Literal /databuilder_tbench/data_builder/enable_b
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/transfer
add wave -noupdate -format Literal /databuilder_tbench/data_builder/address
add wave -noupdate -format Literal -radix hexadecimal -expand /databuilder_tbench/data_builder/idata
add wave -noupdate -divider Internal
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/idata_bus
add wave -noupdate -format Logic /databuilder_tbench/data_builder/en_a
add wave -noupdate -format Logic /databuilder_tbench/data_builder/en_b
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/t_size
add wave -noupdate -format Logic /databuilder_tbench/data_builder/rds
add wave -noupdate -format Logic /databuilder_tbench/data_builder/wrs
add wave -noupdate -format Literal /databuilder_tbench/data_builder/stateval
add wave -noupdate -format Literal /databuilder_tbench/data_builder/next_stateval
add wave -noupdate -format Logic /databuilder_tbench/data_builder/s_counter_en
add wave -noupdate -format Logic /databuilder_tbench/data_builder/s_counter_cl
add wave -noupdate -format Logic /databuilder_tbench/data_builder/t_counter_en
add wave -noupdate -format Logic /databuilder_tbench/data_builder/t_counter_cl
add wave -noupdate -divider {Internal Counters}
add wave -noupdate -color {Sky Blue} -format Literal -itemcolor {Sky Blue} -radix hexadecimal /databuilder_tbench/data_builder/s_counter
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/t_counter
add wave -noupdate -divider {Transfer Interface}
add wave -noupdate -format Literal /databuilder_tbench/data_builder/rd
add wave -noupdate -format Literal /databuilder_tbench/data_builder/wr
add wave -noupdate -color {Orange Red} -format Literal -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/data_builder/odata
add wave -noupdate -divider {INP FIFO 0}
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/inp_fifo_construct__0/read_testfifo/data
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /databuilder_tbench/inp_fifo_construct__0/read_testfifo/rdreq
add wave -noupdate -format Logic /databuilder_tbench/inp_fifo_construct__0/read_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -format Literal -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/inp_fifo_construct__0/read_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/inp_fifo_construct__0/read_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/inp_fifo_construct__0/read_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/inp_fifo_construct__0/read_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/inp_fifo_construct__0/read_testfifo/wrusedw
add wave -noupdate -divider {INP FIFO 1}
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/inp_fifo_construct__1/read_testfifo/data
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /databuilder_tbench/inp_fifo_construct__1/read_testfifo/rdreq
add wave -noupdate -format Logic /databuilder_tbench/inp_fifo_construct__1/read_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -format Literal -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/inp_fifo_construct__1/read_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/inp_fifo_construct__1/read_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/inp_fifo_construct__1/read_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/inp_fifo_construct__1/read_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/inp_fifo_construct__1/read_testfifo/wrusedw
add wave -noupdate -divider {OUP FIFO 0}
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrclk
add wave -noupdate -color {Orange Red} -format Literal -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/data
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/rdreq
add wave -noupdate -color White -format Logic -itemcolor White /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -format Literal -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrusedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {Zero {0 ps} 0} {{FIFO 1 Read Start} {270000 ps} 0} {{FIFO 1 Read End} {590000 ps} 0} {{FIFO 2 Read Start} {630000 ps} 0} {{FIFO 2 Read End} {950000 ps} 0}
configure wave -namecolwidth 418
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
WaveRestoreZoom {3197103 ps} {3383523 ps}
