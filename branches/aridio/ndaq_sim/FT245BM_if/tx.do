onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/ftclk
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/clk
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/clk_en
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/rst
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/arbiter/f_txf
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/arbiter/txen
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/arbiter/txidle
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/tx_interface/state
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/ft_done
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/tx_interface/idata
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/tx_interface/buf
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/tx_interface/f_odata
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/f_wr
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/tx_interface/txlocalst
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/wr
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/dwait
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/ft_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {723849 ps} 0} {{Cursor 2} {625924 ps} 0}
configure wave -namecolwidth 326
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
WaveRestoreZoom {237691 ps} {1286267 ps}
