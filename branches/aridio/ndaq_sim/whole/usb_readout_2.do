onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/master_rst_gen/rst
add wave -noupdate -divider {IDT FIFO 2}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/rdclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrclk
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrreq
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/q
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/rdempty
add wave -noupdate -format Logic /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrfull
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/fake_idt_construct__2/fake_idt_fifo/wrusedw
add wave -noupdate -divider {IDT to Int FIFO}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/isidle
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/s_ef
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/s_rd
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/ena
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/enb
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/a_ff
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/a_wr
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/b_ff
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/b_wr
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/idt_to_intfifo/state
add wave -noupdate -divider {A Readout FIFO}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_readout_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_readout_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_readout_fifo/wrreq
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_readout_fifo/empty
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_readout_fifo/full
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_readout_fifo/q
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_readout_fifo/usedw
add wave -noupdate -divider {B Readout FIFO}
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_readout_fifo/data
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_readout_fifo/rdreq
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_readout_fifo/wrreq
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_readout_fifo/empty
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_readout_fifo/full
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_readout_fifo/q
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_readout_fifo/usedw
add wave -noupdate -divider {A Int FIFO to FT245BM if}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/isidle
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/ef
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/usedw
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/rd
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/q
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/dwait
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/wr
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/odata
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/a_to_ft_copier/state
add wave -noupdate -divider {B Int FIFO to FT245BM if}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/isidle
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/ef
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/usedw
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/rd
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/q
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/dwait
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/wr
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/odata
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_construct__1/b_to_ft_copier/state
add wave -noupdate -divider FT245BM
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_txf
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_rxf
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_wr
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_rd
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_transceiver_if/f_iodata
add wave -noupdate -divider {IDT Arbiter}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/isidle
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/en
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/ii
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/control
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/state
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/i_en
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/idt_arbiter/i_isidle
add wave -noupdate -divider {Readout Arbiter}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/clk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/rst
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/isidle
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/en
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/ii
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/control
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/state
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/i_en
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/usb_readout_arbiter/i_isidle
add wave -noupdate -divider {Main Arbiter}
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/clk
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/rst
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/enable
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/isidle
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/en
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/ii
add wave -noupdate -format Literal -radix hexadecimal /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/control
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/state
add wave -noupdate -format Literal /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/i_en
add wave -noupdate -format Logic /ndaq_sim_tbench/ndaq_vme_fpga/main_arbiter/i_isidle
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {430175633 ps} 0} {{Cursor 2} {104958718 ps} 0} {{Cursor 3} {181997383 ps} 0} {{Cursor 4} {274676 ps} 0}
configure wave -namecolwidth 490
configure wave -valuecolwidth 59
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
WaveRestoreZoom {0 ps} {5550080 ps}
