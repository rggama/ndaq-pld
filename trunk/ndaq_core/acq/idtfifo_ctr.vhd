----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- $IDT FIFO Block Transfer Control
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
		clk						     : in std_logic;		 
		start_transfer				  : in std_logic;		 -- Control signal to start the readout
		i_running					  : out std_logic;	 -- Indicates a block transfer running
		
		-- IDT FIFO signals
		idt_full					 	  : in std_logic;		 -- FULL flag
		idt_wren					 	  : out std_logic;	 -- WRITE enable
	
		-- Internal FIFO signals
		--
		--
		fifo_empty					 : in std_logic;								-- EMPTY flag
		fifo_used				 	 : in std_logic_vector(9 downto 0);		-- USED WORDS bus
		rden_A						 : out std_logic;								-- READ enable
		rden_B						 : out std_logic								-- READ enable		
);
end idtfifo_ctr;
--
architecture one_idtfifo_ctr of idtfifo_ctr is
--
	constant TRANS_MAX 		: std_logic_vector(7 downto 0) := "01111111";		-- Number of 32-bit words transferred to the IDT FIFO each time (1 event)
	constant USEDFIFO			: std_logic_vector(9 downto 0) := "0001111111"; 	-- 128 words
	
	type state_values is (idle, test, active_rden, block_transfer, transfer_wait);
	signal stateval,next_stateval				: state_values;
	signal i_wren									: std_logic;
	signal i_rden									: std_logic;
	signal i_enable_counter						: std_logic;
	signal i_clear_counter						: std_logic;
	signal transfer_counter						: std_logic_vector(7 downto 0);

--

begin
--
-- Asynchronous assignments of 'next_stateval'
NEXT_STATE_COMB: process(stateval, start_transfer, fifo_used, idt_full, transfer_counter)
begin
	case stateval is
		when idle =>							-- IDLE state
			if start_transfer = '0' then
				next_stateval <= idle;
			else
				next_stateval <= test;
			end if;

		when test =>							-- Internal FIFO must have 'USEDFIFO' words and external FIFO must not be full
			if ((fifo_used > USEDFIFO) and (idt_full = '1')) then
				next_stateval <= active_rden;			
			else
				next_stateval <= idle;
			end if;
			
		when active_rden =>						
			next_stateval <= block_transfer;
		
		when block_transfer =>				-- Transfer block data to IDT FIFO
			if transfer_counter = TRANS_MAX then
				next_stateval <= idle;
			else
				next_stateval <= block_transfer;
			end if;
	
--		when transfer_wait =>
--			next_stateval <= block_transfer;
			
		when others =>
			next_stateval <= idle;
			
	end case;
end process;
--
-- Asynchronous assignments of internal signals
OUTPUT_COMB: process(next_stateval)
begin
	case next_stateval is
		when idle =>
			i_wren				<= '1';
			i_rden				<= '0';
			i_clear_counter	<= '1';		
			i_enable_counter	<= '0';
			i_running			<= '0';
		when test =>
			i_wren				<= '1';
			i_rden				<= '0';
			i_clear_counter	<= '0';		
			i_enable_counter	<= '0';
			i_running			<= '0';
		when active_rden =>
			i_wren				<= '1';
			i_rden				<= '1';
			i_clear_counter	<= '0';		
			i_enable_counter	<= '0';
			i_running			<= '1';
		when block_transfer =>			
			i_wren				<= '0';
			i_rden				<= '1';
			i_clear_counter	<= '0';		
			i_enable_counter	<= '1';
			i_running			<= '1';
--		when transfer_wait =>			
--			i_wren				<= '1';
--			i_rden				<= '0';
--			i_clear_counter	<= '0';		
--			i_enable_counter	<= '0';
--			i_running			<= '1';
		when others =>
			i_wren				<= '1';
			i_rden				<= '0';
			i_clear_counter	<= '1';		
			i_enable_counter	<= '0';
			i_running			<= '0';
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
		rden_A	<= '0';
		rden_B	<= '0';
	elsif rising_edge(clk) then
		idt_wren	<= i_wren;
		rden_A	<= i_rden;
		rden_B	<= i_rden;
	end if;
end process;
--
-- Transfer counter
SYNC_COUNTER: process(rst,clk)
begin
	if rst = '1' then
		transfer_counter <= "00000000";
	elsif rising_edge(clk) then
		if i_enable_counter = '1' then
			transfer_counter <= transfer_counter + 1;
		elsif i_clear_counter = '1' then
			transfer_counter <= "00000000";
		else
			transfer_counter <= transfer_counter; --"00000000";
		end if;
	end if;
end process;
--
end one_idtfifo_ctr;
