onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /spi_tbench/master_spi/clk
add wave -noupdate -format Logic /spi_tbench/master_spi/rst
add wave -noupdate -format Logic /spi_tbench/master_spi/mosi
add wave -noupdate -format Logic /spi_tbench/master_spi/miso
add wave -noupdate -format Logic /spi_tbench/master_spi/sclk
add wave -noupdate -format Logic /spi_tbench/master_spi/dataa
add wave -noupdate -format Logic /spi_tbench/master_spi/wr
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/idata
add wave -noupdate -format Logic /spi_tbench/master_spi/rd
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/odata
add wave -noupdate -format Literal /spi_tbench/master_spi/state
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/ibuf
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/tmp
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/obuf
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/t_cntr
add wave -noupdate -format Logic /spi_tbench/master_spi/r_sclk
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /spi_tbench/master_spi/cg_clk_en
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/cg_clk_div
add wave -noupdate -format Logic /spi_tbench/master_spi/se_clk_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2042084 ps} 0} {{Cursor 2} {371977 ps} 0}
configure wave -namecolwidth 251
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
WaveRestoreZoom {0 ps} {3678208 ps}
