-- Synchronous Word Copier
-- v: svn controlled
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--use work.all;

--

entity swc is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in	std_logic; -- async if
		
		--flags
		signal dwait			: in	std_logic;
		signal dataa			: in	std_logic;

		--strobes
		signal wr				: out 	std_logic := '1';
		signal rd				: out 	std_logic := '1'
	);
end swc;

--

architecture rtl of swc is

	-- SWC finite state machine
	type swc_st_type	is (idle, read_st, write_st); 

	-- Register to hold the current state
	signal swc_st	: swc_st_type := idle;
	
	-- FSM attributes
	attribute syn_encoding : string;
	attribute syn_encoding of swc_st_type : type is "safe, one-hot";

begin

swc_fsm: 
process(rst, clk)
begin
	if (rst = '1') then
		swc_st	<= idle;
		--
		rd		<= '1';
		wr		<= '1';
		
	elsif (rising_edge(clk)) then
		case (swc_st) is
		
			when idle	=>	
				if (dataa = '1') then
					swc_st	<= read_st;
					--
					rd		<= '0';
				else
					swc_st	<= idle;
					--
					rd		<= '1';
				end if;
				
			when read_st	=>
				rd		<= '1';

				if (dwait = '0') then
					swc_st	<= write_st;
					--
					wr		<= '0';				
				else
					swc_st	<= read_st;
				end if;
				

			when write_st	=>
				swc_st	<= idle;
				--
				rd		<= '1';
				wr		<= '1';				
				
			when others	=>
				swc_st	<= idle;

		end case;	
	end if;
end process swc_fsm;

end rtl;