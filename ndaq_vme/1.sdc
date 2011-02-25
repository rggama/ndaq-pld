create_clock -period 20.000 -name clk_in [get_ports {clk50M}]
derive_pll_clocks
derive_clock_uncertainty