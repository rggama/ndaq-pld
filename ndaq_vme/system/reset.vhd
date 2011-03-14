-- Reset FSM - Generates Reset Pulse
-- v: 0.0
-- s: no
-- h: no

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity rstgen is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		
		signal reset			: in 	std_logic_vector(7 downto 0);
		
		signal rst				: out	std_logic := '1'
	);
end rstgen;

--

architecture rtl of rstgen is
	
------------------------------
-- Reset State Machine		--
------------------------------

	type reset_type is (reset_a, reset_d);
	
	signal reset_state 	: reset_type := reset_a; -- Hope it power-up at 'reset_a' state.

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of reset_type : type is "safe";	

--

begin

----------------------------------	
-- Reset State Machine			--
--								--
-- Generates the 'rst' pulse	--
----------------------------------

	rstfsm:
	process(clk, reset)
	begin
		if (rising_edge(clk)) then
			case reset_state is
				
				when reset_a =>
					rst			<= '1';		-- reset asserted
										
					reset_state	<= reset_d;
						
				when reset_d =>
					rst			<= '0';		-- reset deasserted
					
					if (reset = x"55") then
						reset_state <= reset_a;
					else	
						reset_state <= reset_d;
					end if;
					
			end case;
		end if;
	end process;	

end rtl;