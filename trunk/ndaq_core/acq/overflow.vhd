-- $ oveflow.vhd
-- Set an overflow flag based on a input flag.

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

--
--
entity overflow is
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- INs
		signal flag_in				: in	std_logic;
		signal srst					: in	std_logic;
		-- OUTs
		signal flag_out				: out	std_logic
	);	
end overflow;
--
architecture rtl of overflow is
	
--***********************************************************************************************	

	signal r_srst		: std_logic := '0';

	signal r_flag_in	: std_logic := '0';
	signal s_flag_in	: std_logic := '0';
	signal t_flag_in	: std_logic := '0';
	signal u_flag_in	: std_logic := '0';
	
	signal r_flag_out	: std_logic := '0';
	
--
--
begin

--***********************************************************************************************

--
-- Counter itself
overflow_fflop: process(rst, clk)
begin
	if (rst = '1') then
		r_srst		<= '0';
		--
		r_flag_in	<= '0';
		s_flag_in	<= '0';
		t_flag_in	<= '0';
		--
		r_flag_out	<= '0';
		
	elsif (rising_edge(clk)) then  
		
		-- Registered Synchronous Reset
		r_srst	<= srst;
				
		-- Triple Buffered Input
		r_flag_in <= flag_in;
		s_flag_in <= r_flag_in;
		t_flag_in <= s_flag_in;
		
		-- Buffer for 2 clock cycles pulse duration teste
		u_flag_in <= t_flag_in;
		
		-- Synchronous Reset
		if (r_srst = '1') then
			r_flag_out <= '0';
		
		-- 
		elsif ((t_flag_in = '1') and (u_flag_in = '1')) then
			r_flag_out <= '1';

		end if;			

	end if;
end process;

--
--
flag_out <= r_flag_out;

--***********************************************************************************************

--
--
end rtl;