create_clock -period 8.000 -name clk_in [get_ports {clkcore}]
derive_pll_clocks
derive_clock_uncertainty
set_clock_groups -asynchronous -group {adc12_clk} -group {adc34_clk} -group {adc56_clk} -group {adc78_clk} -group {clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[0] clock_manager|core_pll_inst|altpll_component|auto_generated|pll1|clk[2] clk_in}
