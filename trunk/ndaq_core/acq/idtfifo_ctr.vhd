----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- Author: Herman Lima Jr
-- Company: CBPF
-- Description: State machine for the control of write operations in the external IDT FIFOs.
-- Notes:
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
--
entity idtfifo_ctr is
port(	-- CONTROL/STATUS signals
		rst						     : in std_logic;
		clk						     : in std_logic;		 -- Receives the inverted output (nclk) from 'core_clkman' component
		start_transfer				  : in std_logic;		 -- Control signal to start the readout (command register)
		noflag						  : out std_logic;	 -- Indicates a transfer cannot start due to some flag
		
		-- IDT FIFO signals
		idt_full					 	  : in std_logic;		 -- FULL flag
		idt_wren					 	  : out std_logic;	 -- WRITE enable
	
		-- Internal FIFO signals
		--
		-- *** Precisa tratar empty e used dos DOIS canais. ***
		--
		fifo_empty					 : in std_logic;								-- EMPTY flag
		fifo_used				 	 : in std_logic_vector(9 downto 0);		-- USED WORDS bus
		rden_A						 : out std_logic;								-- READ enable
		rden_B						 : out std_logic;								-- READ enable
		
		-- TEST signals		
		transfer_counter			 : out std_logic_vector(7 downto 0);    -- Only for TESTS
		state_out				     : out std_logic_vector(3 downto 0));	-- Only for TESTS
end idtfifo_ctr;
--
architecture one_idtfifo_ctr of idtfifo_ctr is
--
	constant TRANS_MAX 		: std_logic_vector(7 downto 0) := "01111111";		-- Number of 32-bit words transferred to the IDT FIFO each time (1 event)
	constant USEDFIFO			: std_logic_vector(9 downto 0) := "0001111111"; 	-- 128 words
	
	type state_values is (idle, test_empty, test_full, active_rden, transfer_idt, noway);
	signal stateval,next_stateval				: state_values;
	signal i_wren									: std_logic;
	signal enable_counter						: std_logic;
	signal transfer_count						: std_logic_vector(7 downto 0);
	signal i_state_out							: std_logic_vector(3 downto 0);
	signal i_rden									: std_logic;
	signal i_noflag								: std_logic;
--
begin
--
-- Asynchronous assignments of 'next_stateval'
NEXT_STATE_COMB: process(stateval, start_transfer, fifo_used, idt_full, transfer_count)
begin
	case stateval is
		when idle =>							-- IDLE state
			if start_transfer = '0' then
				next_stateval <= idle;
			else
				next_stateval <= test_empty;
			end if;

		when test_empty =>						-- Test if internal FIFO is empty
			if fifo_used > USEDFIFO then
				next_stateval <= test_full;			-- Abort readout
			else
				next_stateval <= test_empty;
			end if;

		when test_full =>						-- Test if IDT FIFO is empty
			if idt_full = '0' then
				next_stateval <= noway;			-- Abort readout
			else
				next_stateval <= active_rden;
			end if;
			
		when active_rden =>						-- Test if IDT FIFO is empty
			next_stateval <= transfer_idt;
		
		when transfer_idt =>					-- Transfer block data to IDT FIFO
			if transfer_count = TRANS_MAX then
				next_stateval <= idle;
			else
				next_stateval <= transfer_idt;
			end if;

		when noway =>
			next_stateval <= idle;
	
		when others =>
			null;
	end case;
end process;
--
-- Asynchronous assignments of internal signals
OUTPUT_COMB: process(next_stateval)
begin
	case next_stateval is
		when idle =>
			i_wren <= '1';
			i_state_out <= x"0";
			enable_counter <= '0';
			i_rden <= '0';
			i_noflag <= '0';
		when test_empty =>
			i_wren <= '1';
			i_state_out <= x"1";
			enable_counter <= '0';
			i_rden <= '0';
			i_noflag <= '0';
		when test_full =>
			i_wren <= '1';
			i_state_out <= x"2";
			enable_counter <= '0';
			i_rden <= '0';
			i_noflag <= '0';
		when active_rden =>
			i_wren <= '1';
			i_state_out <= x"3";
			enable_counter <= '0';
			i_rden <= '1';
			i_noflag <= '0';
		when transfer_idt =>			
			i_wren <= '0';
			i_state_out <= x"A";
			enable_counter <= '1';
			i_rden <= '1';
			i_noflag <= '0';
		when noway =>
			i_wren <= '1';
			i_state_out <= x"F";
			enable_counter <= '0';
			i_rden <= '0';
			i_noflag <= '1';
		when others =>
			i_wren <= '1';
			i_state_out <= x"E";
			enable_counter <= '1';
			i_rden <= '0';
			i_noflag <= '0';
	end case;
end process;
--
-- Registered states
STATE_FLOPS: process(clk,rst)
begin
if rst = '1' then
	stateval <= idle;
elsif rising_edge(clk) then
	stateval <= next_stateval;
end if;
end process;
--
-- Registered output assignments
OUTPUT_FLOPS: process(rst,clk)
begin
	if rst ='1' then
		idt_wren <= '1';
		state_out <= x"0";
		rden_A <= '0';
		rden_B <= '0';
		noflag <= '0';
	elsif rising_edge(clk) then
		idt_wren <= i_wren;
		state_out <= i_state_out;
		rden_A <= i_rden;
		rden_B <= i_rden;
		noflag <= i_noflag;
	end if;
end process;
--
-- Transfer counter
SYNC_COUNTER: process(rst,clk)
begin
	if rst = '1' then
		transfer_count <= "00000000";
	elsif rising_edge(clk) then
		if enable_counter = '1' then
			transfer_count <= transfer_count + 1;
		else
			transfer_count <= "00000000";
		end if;
	end if;
	transfer_counter <= transfer_count;
end process;
--
end one_idtfifo_ctr;
