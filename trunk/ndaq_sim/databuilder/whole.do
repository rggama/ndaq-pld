onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /databuilder_tbench/data_builder/clk
add wave -noupdate -format Logic /databuilder_tbench/data_builder/rst
add wave -noupdate -divider Interface
add wave -noupdate -format Literal /databuilder_tbench/data_builder/enable_a
add wave -noupdate -format Literal /databuilder_tbench/data_builder/enable_b
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/transfer
add wave -noupdate -format Literal /databuilder_tbench/data_builder/empty
add wave -noupdate -format Literal /databuilder_tbench/data_builder/rd
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/idata
add wave -noupdate -format Literal /databuilder_tbench/data_builder/full
add wave -noupdate -format Literal /databuilder_tbench/data_builder/wr
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/odata
add wave -noupdate -divider Internal
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/idata_bus
add wave -noupdate -format Logic /databuilder_tbench/data_builder/en_a
add wave -noupdate -format Logic /databuilder_tbench/data_builder/en_b
add wave -noupdate -format Literal /databuilder_tbench/data_builder/t_size
add wave -noupdate -format Logic /databuilder_tbench/data_builder/eflag
add wave -noupdate -format Logic /databuilder_tbench/data_builder/fflag
add wave -noupdate -format Literal /databuilder_tbench/data_builder/stateval
add wave -noupdate -format Literal /databuilder_tbench/data_builder/next_stateval
add wave -noupdate -format Logic /databuilder_tbench/data_builder/s_counter_en
add wave -noupdate -format Logic /databuilder_tbench/data_builder/s_counter_cl
add wave -noupdate -format Logic /databuilder_tbench/data_builder/t_counter_en
add wave -noupdate -format Logic /databuilder_tbench/data_builder/t_counter_cl
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/s_counter
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/data_builder/t_counter
add wave -noupdate -format Logic /databuilder_tbench/data_builder/rds
add wave -noupdate -format Logic /databuilder_tbench/data_builder/wrs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {150220 ps} 0} {{Cursor 2} {527579 ps} 0}
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
WaveRestoreZoom {0 ps} {1491344 ps}
