onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /databuilder_tbench/data_builder/clk
add wave -noupdate -format Logic /databuilder_tbench/data_builder/rst
add wave -noupdate -divider Interface
add wave -noupdate -format Literal /databuilder_tbench/data_builder/enable_a
add wave -noupdate -format Literal /databuilder_tbench/data_builder/enable_b
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/transfer
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/idata
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
add wave -noupdate -divider {Transfer Interface}
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/s_counter
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/t_counter
add wave -noupdate -format Literal /databuilder_tbench/data_builder/rd
add wave -noupdate -format Literal /databuilder_tbench/data_builder/wr
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/odata
add wave -noupdate -divider {INP FIFO 0}
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/fifo_construct__0/read_testfifo/data
add wave -noupdate -format Logic /databuilder_tbench/fifo_construct__0/read_testfifo/rdreq
add wave -noupdate -format Logic /databuilder_tbench/fifo_construct__0/read_testfifo/wrreq
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/fifo_construct__0/read_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/fifo_construct__0/read_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/fifo_construct__0/read_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/fifo_construct__0/read_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/fifo_construct__0/read_testfifo/wrusedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {150000 ps} 0} {{Cursor 2} {350000 ps} 0}
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
WaveRestoreZoom {0 ps} {372836 ps}
