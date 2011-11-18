-- $ f2f_copier.vhd - FIFO to FIFO copier.
-- v: svn controlled.
--
-- !!! SINGLE WORD COPIER !!!
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--

entity f2f_copier is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
	
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal s_ef				: in	std_logic;
		signal s_rd				: out	std_logic;	
		
		signal ena				: in	std_logic;
		signal enb				: in	std_logic;
		
		signal a_ff				: in	std_logic;
		signal a_wr				: out	std_logic;		

		signal b_ff				: in	std_logic;
		signal b_wr				: out	std_logic;		
		
		signal esize			: in	std_logic_vector(7 downto 0)
	);
end f2f_copier;

--

architecture rtl of f2f_copier is

	constant REGISTER_OPS			: boolean	:= false;
	
	constant SOURCE_NOT_EMPTY		: std_logic := '1';	-- IDT External FIFO
	constant DEST_NOT_FULL			: std_logic	:= '0';	-- Altera's SC FIFO: NOT Full

	constant SOURCE_RD_ASSERT		: std_logic := '0';	-- IDT External FIFO
	constant SOURCE_RD_DEASSERT		: std_logic := '1';	-- IDT External FIFO
	constant DEST_WR_ASSERT			: std_logic := '1';	-- Altera's SC FIFO
	constant DEST_WR_DEASSERT		: std_logic := '0';	-- Altera's SC FIFO
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, read_st, write_st, test_st);

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";
	
	--
	
	signal i_rd			: std_logic := SOURCE_RD_DEASSERT;
	signal i_a_wr		: std_logic := DEST_WR_DEASSERT;
	signal i_b_wr		: std_logic := DEST_WR_DEASSERT;
	signal i_isidle		: std_logic := '1';	
	signal scounter		: std_logic_vector(6 downto 0);
	signal dest_enable	: std_logic := '0';
	
--

begin
	-- Dest Enable Comb Logic
	process(ena, enb, a_ff, b_ff)
	begin
		if ((ena = '1') and (enb = '1') and (a_ff = DEST_NOT_FULL) and (b_ff = DEST_NOT_FULL)) then
			dest_enable	<= '1';
		elsif ((ena = '1') and (enb = '0') and (a_ff = DEST_NOT_FULL)) then
			dest_enable	<= '1';
		elsif ((ena = '0') and (enb = '1') and (b_ff = DEST_NOT_FULL)) then
			dest_enable <= '1';
		else
			dest_enable <= '0';
		end if;
	end process;
	
	-- Copy FSM
	copy_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			state		<= idle;
			--
			scounter	<= (others => '0');
			
		elsif (rising_edge(clk)) then
			case state is
				when idle	=>
					if ((enable = '1') and (s_ef = SOURCE_NOT_EMPTY) and (dest_enable = '1')) then
						state	<= write_st; --read_st;
					else
						state	<= idle;
					end if;
				
				when read_st	=>
					state	<= write_st;
					
				when write_st	=>
					state		<= idle;
					--
					scounter	<= scounter + 1;
				
				when test_st	=>
					if (scounter = esize) then
						state		<= idle;
						--
						scounter	<= (others => '0');
						
					elsif ((dest_enable = '1')) then
						state		<= write_st;
						
					else
						state		<= test_st;
						
					end if;
					
				when others	=>
					state		<= idle;
					--
					scounter	<= (others => '0');
			end case;
		end if;
	end process;

	-- FSM Outputs
	copy_fsm_ops:
	process(state, ena, enb)
	begin
		case (state) is			
			
			when idle		=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_a_wr		<= DEST_WR_DEASSERT;
				i_b_wr		<= DEST_WR_DEASSERT;
				i_isidle	<= '1';
				
			when read_st	=>
				i_rd		<= SOURCE_RD_ASSERT;
				i_a_wr		<= DEST_WR_DEASSERT;	
				i_b_wr		<= DEST_WR_DEASSERT;
				i_isidle	<= '0';

			when write_st	=>
				i_rd		<= SOURCE_RD_ASSERT;
				--
				if (ena = '1') then
					i_a_wr	<= DEST_WR_ASSERT;	
				else
					i_a_wr	<= DEST_WR_DEASSERT;
				end if;
				--
				if (enb = '1') then
					i_b_wr	<= DEST_WR_ASSERT;	
				else
					i_b_wr	<= DEST_WR_DEASSERT;
				end if;
				--
				i_isidle	<= '0';

			when test_st	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_a_wr		<= DEST_WR_DEASSERT;	
				i_b_wr		<= DEST_WR_DEASSERT;	
				i_isidle	<= '0';

			when others		=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_a_wr		<= DEST_WR_DEASSERT;
				i_b_wr		<= DEST_WR_DEASSERT;
				i_isidle	<= '1';
			
		end case;
	end process;
	
	test_register_ops:
	if (REGISTER_OPS = true) generate
	
		ops_registers:
		process(clk, rst)
		begin
			if (rst = '1') then
				s_rd	<= SOURCE_RD_DEASSERT;
				a_wr	<= DEST_WR_DEASSERT;
				b_wr	<= DEST_WR_DEASSERT;
				isidle	<= '1';
				
			elsif (rising_edge(clk)) then
				s_rd	<= i_rd;
				a_wr	<= i_a_wr;
				b_wr	<= i_b_wr;
				isidle	<= i_isidle;
			end if;
		end process;
		
	end generate test_register_ops;
	
	test_direct_ops:
	if (REGISTER_OPS = false) generate
		
		direct_ops:
		s_rd	<= i_rd;
		a_wr	<= i_a_wr;
		b_wr	<= i_b_wr;
		isidle	<= i_isidle;
		
	end generate test_direct_ops;
	
end rtl;