onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/clk
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/ftclk
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/clk_en
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rst
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/f_txf
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/f_rxf
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/f_rd
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/f_iodata
add wave -noupdate -format Logic -radix hexadecimal /ft245bm_tbench/transceiver/f_wr
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/enable
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/isidle
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/dwait
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/wr
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/tx_interface/idata
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/tx_interface/buf
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/tx_interface/state
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/tx_interface/txlocalst
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/ft_req
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/tx_interface/ft_done
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rx_interface/enable
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rx_interface/isidle
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rx_interface/dataa
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rx_interface/rd
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/rx_interface/buf
add wave -noupdate -format Literal -radix hexadecimal /ft245bm_tbench/transceiver/rx_interface/odata
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/rx_interface/state
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/rx_interface/rxlocalst
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rx_interface/ft_req
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rx_interface/ft_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {578759 ps} 0} {{Cursor 2} {475409 ps} 0}
configure wave -namecolwidth 307
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
WaveRestoreZoom {0 ps} {1814528 ps}
