-- $ Internal Trigger's Counter Copier
-- v: svn controlled.
-- 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--use work.acq_pkg.all;
--

entity c_counter is
	port
	(	
		signal clk				: in 	std_logic; 			-- sync if
		signal rst				: in 	std_logic; 			-- async if
		
		signal enable			: in 	std_logic;
		signal isidle			: out std_logic := '1';
	
		signal empty			: in	std_logic;
		signal rden				: out std_logic := '0';	-- Read enable to read the counter
		
		signal afull			: in	std_logic;
		signal wr				: out	std_logic := '1'				
	);
end c_counter;

--

architecture rtl of c_counter is
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, read_state, write_state);

	-- Register to hold the current state
	signal state   : state_type := idle;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";
	
	--
	
	signal i_isidle	: std_logic := '1';
	signal i_rden		: std_logic	:= '0';
	signal i_wr			: std_logic := '1';
--

begin
	
	c_counter_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			--	
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is

				when idle	=>
					if((enable = '1') and (empty = '0') and (afull = '1')) then --if counter fifo NOT empty and IDT NOT almost full, we're ok to copy 1 word.
						state <= read_state;
					else
						state <= idle;
					end if;

				when read_state	=>
					state	<= write_state;
				
				when write_state	=>
					state	<= idle;
					
				when others	=>
					state	<= idle;

			end case;
		end if;
	end process;

	fsm_outputs:
	process (state)
	begin
		case (state) is
		
			when idle	=>
				i_isidle		<= '1';
				i_rden		<= '0';
				i_wr			<= '1';	--Deasserted

			when read_state	=>
				i_isidle		<= '0';
				i_rden		<= '1';
				i_wr			<= '1';	--Deasserted

			when write_state	=>
				i_isidle		<= '0';
				i_rden		<= '0';
				i_wr			<= '0';	--Asserted
			
			when others	=>
				i_isidle		<= '1';
				i_rden		<= '0';
				i_wr			<= '1';	--Deasserted
			
		end case;
	end process;
	
	output_register:
	process (clk, rst)
	begin
		if (rst = '1') then
			isidle	<= '1';
			rden		<= '0';
			wr			<= '1';			--Deasserted
		elsif (rising_edge(clk)) then
			isidle	<= i_isidle;
			rden		<= i_rden;
			wr			<= i_wr;
		end if;
	end process;


end rtl;