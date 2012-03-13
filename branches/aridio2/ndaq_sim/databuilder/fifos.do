onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {FIFO 1}
add wave -noupdate -color {Orange Red} -format Literal -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/data
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/rdreq
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrclk
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -format Literal -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__0/write_testfifo/wrusedw
add wave -noupdate -divider {FIFO 2}
add wave -noupdate -color {Orange Red} -format Literal -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__1/write_testfifo/data
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__1/write_testfifo/rdreq
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__1/write_testfifo/wrclk
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /databuilder_tbench/oup_fifo_construct__1/write_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -format Literal -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__1/write_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__1/write_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__1/write_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__1/write_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__1/write_testfifo/wrusedw
add wave -noupdate -divider {FIFO 3}
add wave -noupdate -color {Orange Red} -format Literal -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__2/write_testfifo/data
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__2/write_testfifo/rdreq
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__2/write_testfifo/wrclk
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /databuilder_tbench/oup_fifo_construct__2/write_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -format Literal -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__2/write_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__2/write_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__2/write_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__2/write_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__2/write_testfifo/wrusedw
add wave -noupdate -divider {FIFO 4}
add wave -noupdate -color {Orange Red} -format Literal -itemcolor {Orange Red} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__3/write_testfifo/data
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__3/write_testfifo/rdreq
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__3/write_testfifo/wrclk
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /databuilder_tbench/oup_fifo_construct__3/write_testfifo/wrreq
add wave -noupdate -color {Medium Orchid} -format Literal -itemcolor {Medium Orchid} -radix hexadecimal /databuilder_tbench/oup_fifo_construct__3/write_testfifo/q
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__3/write_testfifo/rdempty
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__3/write_testfifo/rdusedw
add wave -noupdate -format Logic /databuilder_tbench/oup_fifo_construct__3/write_testfifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /databuilder_tbench/oup_fifo_construct__3/write_testfifo/wrusedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 398
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
WaveRestoreZoom {4988054 ps} {5179542 ps}
