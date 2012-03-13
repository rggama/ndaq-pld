create_clock -period 20.000 -name clk_in [get_ports {clk50M}]
derive_pll_clocks
derive_clock_uncertainty

create_clock -period 33.333 -name spi_clk [get_nets {*r_sclk}]

set_clock_groups -asynchronous -group {spi_clk} 
