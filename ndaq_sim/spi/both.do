onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clock/Reset
add wave -noupdate -format Logic /spi_tbench/mclk
add wave -noupdate -format Logic /spi_tbench/sclk
add wave -noupdate -format Logic /spi_tbench/master_spi/rst
add wave -noupdate -divider Master
add wave -noupdate -format Logic /spi_tbench/master_spi/busy
add wave -noupdate -format Logic /spi_tbench/master_spi/wr
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/idata
add wave -noupdate -format Literal /spi_tbench/master_spi/state
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/tmp
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/t_cntr
add wave -noupdate -format Literal /spi_tbench/master_spi/rxstate
add wave -noupdate -format Logic /spi_tbench/master_spi/dataa
add wave -noupdate -format Logic /spi_tbench/master_spi/rd
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/obuf
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/master_spi/odata
add wave -noupdate -divider Interface
add wave -noupdate -color {Slate Blue} -format Logic /spi_tbench/master_spi/mosi
add wave -noupdate -color {Blue Violet} -format Logic /spi_tbench/master_spi/miso
add wave -noupdate -format Logic /spi_tbench/master_spi/sclk
add wave -noupdate -divider Slave
add wave -noupdate -format Logic /spi_tbench/slave_spi/busy
add wave -noupdate -format Logic /spi_tbench/slave_spi/dataa
add wave -noupdate -format Logic /spi_tbench/slave_spi/rd
add wave -noupdate -format Logic /spi_tbench/slave_spi/wr
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/slave_spi/odata
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/slave_spi/obuf
add wave -noupdate -format Literal /spi_tbench/slave_spi/state
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/slave_spi/rxtmp
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/slave_spi/txtmp
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/slave_spi/t_cntr
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/slave_spi/ibuf
add wave -noupdate -format Logic /spi_tbench/slave_spi/cntr_end
add wave -noupdate -format Logic /spi_tbench/slave_spi/r_cntr_end
add wave -noupdate -format Logic /spi_tbench/slave_spi/s_cntr_end
add wave -noupdate -format Logic /spi_tbench/slave_spi/cntr_zro
add wave -noupdate -format Logic /spi_tbench/slave_spi/r_cntr_zro
add wave -noupdate -format Logic /spi_tbench/slave_spi/s_cntr_zro
add wave -noupdate -format Literal /spi_tbench/slave_spi/txstate
add wave -noupdate -format Literal -radix hexadecimal /spi_tbench/slave_spi/idata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {986743 ps} 0} {{Cursor 2} {256246544 ps} 0}
configure wave -namecolwidth 251
configure wave -valuecolwidth 99
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
WaveRestoreZoom {0 ps} {1840535 ps}
