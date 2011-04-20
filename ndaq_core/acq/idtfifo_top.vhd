----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- $IDT FIFO Top
-- Author: Herman Lima Jr
-- Company: CBPF
-- Description: Top-level control of write operations in the external IDT FIFOs.
-- Notes:
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
--
entity idtfifo_top is
port(	-- CONTROL/STATUS signals
		rst						    : in std_logic;
		clk						    : in std_logic;						
		start_transfer				 : in std_logic;						-- Control signal to start the readout (command register)
		enable_fifo				 	 : in std_logic_vector(1 to 4);	-- Indicates if the FIFO transfer is enabled ('1') 
		idt_full					 	 : in std_logic_vector(1 to 4);
		idt_wren					 	 : out std_logic_vector(1 to 4);
		idt_data						 : out std_logic_vector(31 downto 0);
		fifo_empty					 : in std_logic_vector(1 to 8);
		fifo_used_A					 : in std_logic_vector(9 downto 0);
		fifo_used_B					 : in std_logic_vector(9 downto 0);
		fifo_used_C					 : in std_logic_vector(9 downto 0);
		fifo_used_D					 : in std_logic_vector(9 downto 0);
		fifo_used_E					 : in std_logic_vector(9 downto 0);
		fifo_used_F					 : in std_logic_vector(9 downto 0);
		fifo_used_G					 : in std_logic_vector(9 downto 0);
		fifo_used_H					 : in std_logic_vector(9 downto 0);
		fifo_rden					 : out std_logic_vector(1 to 8);
		fifo_qA						 : in std_logic_vector(9 downto 0);
		fifo_qB						 : in std_logic_vector(9 downto 0);
		fifo_qC						 : in std_logic_vector(9 downto 0);
		fifo_qD						 : in std_logic_vector(9 downto 0);
		fifo_qE						 : in std_logic_vector(9 downto 0);
		fifo_qF						 : in std_logic_vector(9 downto 0);
		fifo_qG						 : in std_logic_vector(9 downto 0);
		fifo_qH						 : in std_logic_vector(9 downto 0)
);
end idtfifo_top;
--
architecture one_idtfifo_top of idtfifo_top is

--	Components

	-- IDT FIFO control
	component idtfifo_ctr
	port
	(	
		rst				: in std_logic;
		clk				: in std_logic;
		start_transfer	: in std_logic;
		i_running		: out std_logic;	 -- Indicates a block transfer running
		idt_full			: in std_logic;
		idt_wren			: out std_logic;
		fifo_empty		: in std_logic;
		fifo_used		: in std_logic_vector(9 downto 0);
		rden_A			: out std_logic;						-- READ enable
		rden_B			: out std_logic						-- READ enable
	);
	end component;

--

-- Signals

	type state_values is (fifo1_select, fifo1_start, fifo1_wait_test, fifo1_wait_transfer,
								fifo2_select, fifo2_start, fifo2_wait_test, fifo2_wait_transfer,
								fifo3_select, fifo3_start, fifo3_wait_test, fifo3_wait_transfer,
								fifo4_select, fifo4_start, fifo4_wait_test, fifo4_wait_transfer);

	signal stateval,next_stateval	: state_values;
	signal i_start_transfer			: std_logic_vector(1 to 4);
	signal transfer_running			: std_logic_vector(1 to 4);
--	
--

begin
--
-- Asynchronous assignments of 'next_stateval'
NEXT_STATE_COMB: process(stateval, enable_fifo, start_transfer, transfer_running)
begin
	case stateval is

		--------------------------
		-- FIFO 1 / Channel 1-2 --
		--------------------------		
		when fifo1_select =>									-- test if the fifo is enabled			
			if ((enable_fifo(1) = '1') and (start_transfer = '1')) then
				next_stateval <= fifo1_start;
			else
				next_stateval <= fifo2_select;			-- fifo not enabled, go try next fifo
			end if;
		
		when fifo1_start =>									-- start the transfer component
			next_stateval <= fifo1_wait_test;
			
		when fifo1_wait_test =>								-- wait for the transfer component to complete its tests
			next_stateval <= fifo1_wait_transfer;

		when fifo1_wait_transfer =>
			if transfer_running(1) = '1' then
				next_stateval <= fifo1_wait_transfer;	-- Transfering 
			else
				next_stateval <= fifo2_select;			-- No transfer, go try next fifo
			end if;

		--------------------------
		-- FIFO 2 / Channel 3-4 --
		--------------------------		
		when fifo2_select =>									-- test if the fifo is enabled			
			if ((enable_fifo(2) = '1') and (start_transfer = '1')) then
				next_stateval <= fifo2_start;
			else
				next_stateval <= fifo3_select;			-- fifo not enabled, go try next fifo
			end if;
		
		when fifo2_start =>									-- start the transfer component
			next_stateval <= fifo2_wait_test;
			
		when fifo2_wait_test =>								-- wait for the transfer component to complete its tests
			next_stateval <= fifo2_wait_transfer;

		when fifo2_wait_transfer =>
			if transfer_running(2) = '1' then
				next_stateval <= fifo2_wait_transfer;	-- Transfering 
			else
				next_stateval <= fifo3_select;			-- No transfer, go try next fifo
			end if;

		--------------------------
		-- FIFO 3 / Channel 5-6 --
		--------------------------		
		when fifo3_select =>									-- test if the fifo is enabled			
			if ((enable_fifo(3) = '1') and (start_transfer = '1')) then
				next_stateval <= fifo3_start;
			else
				next_stateval <= fifo4_select;			-- fifo not enabled, go try next fifo
			end if;
		
		when fifo3_start =>									-- start the transfer component
			next_stateval <= fifo3_wait_test;
			
		when fifo3_wait_test =>								-- wait for the transfer component to complete its tests
			next_stateval <= fifo3_wait_transfer;

		when fifo3_wait_transfer =>
			if transfer_running(3) = '1' then
				next_stateval <= fifo3_wait_transfer;	-- Transfering 
			else
				next_stateval <= fifo4_select;			-- No transfer, go try next fifo
			end if;

		--------------------------
		-- FIFO 4 / Channel 7-8 --
		--------------------------		
		when fifo4_select =>									-- test if the fifo is enabled			
			if ((enable_fifo(4) = '1') and (start_transfer = '1')) then
				next_stateval <= fifo4_start;
			else
				next_stateval <= fifo1_select;			-- fifo not enabled, go try next fifo
			end if;
		
		when fifo4_start =>									-- start the transfer component
			next_stateval <= fifo4_wait_test;
			
		when fifo4_wait_test =>								-- wait for the transfer component to complete its tests
			next_stateval <= fifo4_wait_transfer;

		when fifo4_wait_transfer =>
			if transfer_running(4) = '1' then
				next_stateval <= fifo4_wait_transfer;	-- Transfering 
			else
				next_stateval <= fifo1_select;			-- No transfer, go try next fifo
			end if;

		when others =>
			next_stateval <= fifo1_select;
			
	end case;
end process;
--
-- Asynchronous assignments of internal signals
OUTPUT_COMB: process(next_stateval, fifo_qA, fifo_qB, fifo_qC, fifo_qD, fifo_qE, fifo_qF, fifo_qG, fifo_qH)
begin
	case next_stateval is
		when fifo1_select =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo1_start =>
			i_start_transfer <= "1000";
			idt_data <= (others => 'Z');
		when fifo1_wait_test =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo1_wait_transfer =>
			i_start_transfer <= "0000";
			idt_data <= "000000" & fifo_qB & "000000" & fifo_qA;

		when fifo2_select =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo2_start =>
			i_start_transfer <= "0100";
			idt_data <= (others => 'Z');
		when fifo2_wait_test =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo2_wait_transfer =>
			i_start_transfer <= "0000";
			idt_data <= "000000" & fifo_qD & "000000" & fifo_qC;

		when fifo3_select =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo3_start =>
			i_start_transfer <= "0010";
			idt_data <= (others => 'Z');
		when fifo3_wait_test =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo3_wait_transfer =>
			i_start_transfer <= "0000";
			idt_data <= "000000" & fifo_qF & "000000" & fifo_qE;

		when fifo4_select =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo4_start =>
			i_start_transfer <= "0001";
			idt_data <= (others => 'Z');
		when fifo4_wait_test =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
		when fifo4_wait_transfer =>
			i_start_transfer <= "0000";
			idt_data <= "000000" & fifo_qH & "000000" & fifo_qG;

		when others =>
			i_start_transfer <= "0000";
			idt_data <= (others => 'Z');
	end case;
end process;
--
-- Registered states
STATE_FLOPS: process(clk,rst)
begin
if rst = '1' then
	stateval <= fifo1_select;
elsif rising_edge(clk) then
	stateval <= next_stateval;
end if;
end process;

--
---- Registered output assignments
--OUTPUT_FLOPS: process(rst,clk)
--begin
--	if rst ='1' then
--	--
--	elsif rising_edge(clk) then
--	--
--	end if;
--end process;
--


--
-- FIFO control instantiation
--

FIFO1_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> i_start_transfer(1),
		i_running			=> transfer_running(1),
		idt_full			   => idt_full(1),
		idt_wren				=> idt_wren(1),
		fifo_empty			=> fifo_empty(1),
		fifo_used			=> fifo_used_A,
		rden_A				=> fifo_rden(1),
		rden_B				=> fifo_rden(2)
	);


FIFO2_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> i_start_transfer(2),
		i_running			=> transfer_running(2),
		idt_full				=> idt_full(2),
		idt_wren				=> idt_wren(2),
		fifo_empty			=> fifo_empty(3),
		fifo_used			=> fifo_used_C,
		rden_A				=> fifo_rden(3),
		rden_B				=> fifo_rden(4)
	);


FIFO3_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> i_start_transfer(3),
		i_running			=> transfer_running(3),
		idt_full				=> idt_full(3),
		idt_wren				=> idt_wren(3),
		fifo_empty			=> fifo_empty(5),
		fifo_used			=> fifo_used_E,
		rden_A				=> fifo_rden(5),
		rden_B				=> fifo_rden(6)
	);


FIFO4_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> i_start_transfer(4),
		i_running			=> transfer_running(4),
		idt_full				=> idt_full(4),
		idt_wren				=> idt_wren(4),
		fifo_empty			=> fifo_empty(7),
		fifo_used			=> fifo_used_H,
		rden_A				=> fifo_rden(7),
		rden_B				=> fifo_rden(8)
	);

--
end one_idtfifo_top;