onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/clk
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/clk_en
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rst
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/enable
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/dwait
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/dataa
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/wr
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rd
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/idata
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/odata
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/f_txf
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/f_rxf
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/f_wr
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/f_rd
add wave -noupdate -format Literal /ft245bm_tbench/transceiver/f_iodata
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rxen
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/txen
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/txidle
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/rxidle
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/i_dwait
add wave -noupdate -format Logic /ft245bm_tbench/transceiver/i_dataa
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {209785 ps} 0}
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
WaveRestoreZoom {0 ps} {1682434 ps}
