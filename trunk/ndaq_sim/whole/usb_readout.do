onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {IDT FIFO}
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_fifo/rdreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_fifo/q
add wave -noupdate -divider {IDT to Int FIFO}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/isidle
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/s_ef
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/s_rd
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/d_ef
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/d_wr
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/state
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/i_rd
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/i_wr
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/idt_to_intfifo/scounter
add wave -noupdate -divider {Readout FIFO}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/usb_readout_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/usb_readout_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/usb_readout_fifo/wrreq
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/usb_readout_fifo/empty
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/usb_readout_fifo/full
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/usb_readout_fifo/q
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/usb_readout_fifo/usedw
add wave -noupdate -divider {Int FIFO to FT245BM if}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/isidle
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/ef
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/usedw
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/rd
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/q
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/dwait
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/wr
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/odata
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/rmin
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/esize
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/state
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/scounter
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/tmp
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/i_rd
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/i_wr
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__0/fifo_to_ft_copier/i_isidle
add wave -noupdate -divider FT245BM
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_txf
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_rxf
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_wr
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_rd
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_iodata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {284616804 ps} 0} {{Cursor 2} {348721 ps} 0} {{Cursor 3} {3739005 ps} 0}
configure wave -namecolwidth 519
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
WaveRestoreZoom {38777460 ps} {64629108 ps}
