---------------------------------------------
-- Internal Trigger --
-- Author: Herman Lima Jr / CBPF		   	 --
-- Date: 06/12/2010						   	 --
---------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use work.acq_pkg.all;
--
--
entity itrigger is
	port
	(	signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- Trigger
		signal enable				: in	std_logic;
		signal pos_neg				: in	std_logic;								-- To set positive ('0') or negative ('1') trigger
		signal data_in				: in	signed(data_width-1 downto 0);			-- Signal from the ADC
		signal th1					: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal th2					: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal trigger_out			: out	std_logic
	);	
end itrigger;
--
architecture rtl of itrigger is
	
	signal s_data_in				: signed(data_width-1 downto 0);
	signal r_data_in				: signed(data_width-1 downto 0);
	
	type trig is (test_edge_a, test_ok, test_edge_b);
	signal current_state, next_state:	trig;

	signal i_trigger_out			: std_logic := '0';
	signal r_trigger_out			: std_logic := '0';

--	
--
	
begin

--***********************************************************************************************

--
--
-- Data input Registers (double FF sync. chain)
DATAIN_REGS: process(rst, clk)
begin
	if (rst = '1') then
		s_data_in	<= (others => '0');
		r_data_in	<= (others => '0');
	elsif rising_edge(clk) then
		s_data_in	<= data_in;
		r_data_in	<= s_data_in;
	end if;
end process;

--
-- Asynchronous assignments of 'next_stateval'
NEXT_STATE_COMB: process (current_state, r_data_in, th1, th2, pos_neg)
begin
	if (pos_neg = '0') then
		case current_state is
			-- when s_low =>
				-- if (r_data_in < threshold_fall) then	-- Wait that signal from the ADC is lower than threshold
					-- next_state <= s_high;
				-- else
					-- next_state <= s_low;
				-- end if;
			-- when s_high =>
				-- if (r_data_in > threshold_rise) then	-- When signal from the ADC is higher than threshold, counter is incremented
					-- next_state <= s_cnt;
				-- else
					-- next_state <= s_high;
				-- end if;
			-- when s_cnt =>
				-- next_state <= s_low;
			-- when others =>
				-- next_state <= s_low;

			-- Test RISE
			when test_edge_a =>
				if (r_data_in > th2) then
					next_state <= test_ok;
				else
					next_state <= test_edge_a;
				end if;
			
			-- Generate Trigger
			when test_ok =>
				next_state	<= test_edge_b;
			
			-- Test FALL
			when test_edge_b =>
				if (r_data_in < th1) then
					next_state <= test_edge_a;
				else
					next_state <= test_edge_b;
				end if;
				
			when others =>
				next_state <= test_edge_a;

		end case;
	else
		case current_state is
			-- when s_low =>
				-- if (r_data_in > threshold_fall) then	-- Wait that signal from the ADC is higher than threshold
					-- next_state <= s_high;
				-- else
					-- next_state <= s_low;
				-- end if;
			-- when s_high =>
				-- if (r_data_in < threshold_rise) then	-- When signal from the ADC is lower than threshold, counter is incremented
					-- next_state <= s_cnt;
				-- else
					-- next_state <= s_high;
				-- end if;
			-- when s_cnt =>
				-- next_state <= s_low;
			-- when others =>
				-- next_state <= s_low;

			-- Test FALL
			when test_edge_a =>
				if (r_data_in < th2) then
					next_state <= test_ok;
				else
					next_state <= test_edge_a;
				end if;
			
			-- Generate Trigger
			when test_ok =>
				next_state	<= test_edge_b;
			
			-- Test RISE
			when test_edge_b =>
				if (r_data_in > th1) then
					next_state <= test_edge_a;
				else
					next_state <= test_edge_b;
				end if;
				
			when others =>
				next_state <= test_edge_a;
		
		end case;
	end if;
end process;

--
-- Unregistered Combinational signals
OUTPUT_COMB: process(next_state)
begin
	case next_state is
		when test_ok =>
			i_trigger_out <= '1';
		when others => 
			i_trigger_out <= '0';
	end case;
end process;

--
-- Registered states
STATE_FLOPS: process(rst, clk)
begin
	if rst = '1' then
		current_state <= test_edge_a;
	elsif rising_edge(clk) then
		if enable = '1' then
			current_state <= next_state;
		else
			current_state <= test_edge_a;
		end if;
	end if;
end process;

--
-- Registered signals
OUTPUT_FLOPS: process(rst, clk)
begin
	if rst ='1' then
		r_trigger_out <= '0';
	elsif rising_edge(clk) then
		r_trigger_out <= i_trigger_out;
	end if;
end process;

trigger_out	<= r_trigger_out;
	
--
--

end rtl;