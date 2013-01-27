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

	signal r_srst	: std_logic := '0';
	signal r_flag	: std_logic := '0';
	
--
--
begin

--***********************************************************************************************

--
-- Counter itself
overflow_fflop: process(rst, clk)
begin
	if (rst = '1') then
		r_flag <= '0';
		
	elsif (rising_edge(clk)) then  
		
		-- Registered Synchronous Reset
		r_srst	<= srst;
				
		-- Synchronous Reset
		if (r_srst = '1') then
			r_flag <= '0';
		
		-- 
		elsif (flag_in = '1') then
			r_flag <= '1';

		end if;			

	end if;
end process;

--
--
flag_out <= r_flag;

--***********************************************************************************************

--
--
end rtl;