create_clock -period 8.000 -name clk_in [get_ports {clkcore}]
create_clock -period 8.000 -name adc12_clk [get_ports {adc12_dco}]
create_clock -period 8.000 -name adc34_clk [get_ports {adc34_dco}]
create_clock -period 8.000 -name adc56_clk [get_ports {adc56_dco}]
create_clock -period 8.000 -name adc78_clk [get_ports {adc78_dco}]

create_clock -period 33.333 -name spi_clk [get_ports {spiclk}]

create_clock -period 8.000 -name virtual_dco

derive_pll_clocks
derive_clock_uncertainty

#set_clock_groups -asynchronous -group {adc12_clk} -group {adc34_clk} -group {adc56_clk} -group {adc78_clk} -group {clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[0] clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[2] clk_in}
#set_clock_groups -asynchronous -group {adc12_clk adc34_clk adc56_clk adc78_clk} -group {clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[0] clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[2] clk_in}
set_clock_groups -asynchronous -group {spi_clk} {clk_in adc12_clk adc34_clk adc56_clk adc78_clk virtual_dco} -group {clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[2]} 
#clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[0] 

#12
set_input_delay -max 4.1 -clock [get_clocks virtual_dco] [get_ports {adc12_data*}]
set_input_delay -min -2.0 -clock [get_clocks virtual_dco] [get_ports {adc12_data*}]

set_input_delay -max 4.1 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc12_data*}] -add_delay
set_input_delay -min -2.0 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc12_data*}] -add_delay

#34
set_input_delay -max 4.1 -clock [get_clocks virtual_dco] [get_ports {adc34_data*}]
set_input_delay -min -2.0 -clock [get_clocks virtual_dco] [get_ports {adc34_data*}]

set_input_delay -max 4.1 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc34_data*}] -add_delay
set_input_delay -min -2.0 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc34_data*}] -add_delay

#56
set_input_delay -max 4.1 -clock [get_clocks virtual_dco] [get_ports {adc56_data*}]
set_input_delay -min -2.0 -clock [get_clocks virtual_dco] [get_ports {adc56_data*}]

set_input_delay -max 4.1 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc56_data*}] -add_delay
set_input_delay -min -2.0 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc56_data*}] -add_delay

#78
set_input_delay -max 4.1 -clock [get_clocks virtual_dco] [get_ports {adc78_data*}]
set_input_delay -min -4.0 -clock [get_clocks virtual_dco] [get_ports {adc78_data*}]

set_input_delay -max 4.1 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc78_data*}] -add_delay
set_input_delay -min -2.0 -clock [get_clocks virtual_dco] -clock_fall [get_ports {adc78_data*}] -add_delay
