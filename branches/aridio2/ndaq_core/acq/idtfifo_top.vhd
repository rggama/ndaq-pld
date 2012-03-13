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

use work.acq_pkg.all;

--
entity idtfifo_top is
port(	-- CONTROL/STATUS signals
		rst						     : in std_logic;
		clk						     : in std_logic;						
		start_transfer				 : in std_logic;				-- Control signal to start the readout (command register)
		enable_fifo				 	 : in std_logic_vector(1 to 4);	-- Indicates if the FIFO transfer is enabled ('1') 
		idt_full					 : in std_logic_vector(1 to 4);
		idt_wren					 : out std_logic_vector(1 to 4);
		idt_data					 : out std_logic_vector(31 downto 0);
		fifo_empty					 : in std_logic_vector(1 to 8);
		fifo_used_A					 : in USEDW_T;
		fifo_used_B					 : in USEDW_T;
		fifo_used_C					 : in USEDW_T;
		fifo_used_D					 : in USEDW_T;
		fifo_used_E					 : in USEDW_T;
		fifo_used_F					 : in USEDW_T;
		fifo_used_G					 : in USEDW_T;
		fifo_used_H					 : in USEDW_T;
		fifo_rden					 : out std_logic_vector(1 to 8);
		fifo_qA						 : in DATA_T;
		fifo_qB						 : in DATA_T;
		fifo_qC						 : in DATA_T;
		fifo_qD						 : in DATA_T;
		fifo_qE						 : in DATA_T;
		fifo_qF						 : in DATA_T;
		fifo_qG						 : in DATA_T;
		fifo_qH						 : in DATA_T
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
		running			: out std_logic;	 -- Indicates a block transfer running
		idt_full			: in std_logic;
		idt_wren			: out std_logic;
		fifo_empty		: in std_logic;
		fifo_used		: in USEDW_T;
		rden_A			: out std_logic;					-- READ enable
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
	signal r_start_transfer			: std_logic_vector(1 to 4);
	signal transfer_running			: std_logic_vector(1 to 4);
	

	signal i_bus_enable				: std_logic_vector(2 downto 0);
	signal bus_enable				: std_logic_vector(2 downto 0);
	
	signal empty         : std_logic_vector(1 to 4);
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
OUTPUT_COMB: process(next_stateval)
begin
	case next_stateval is
		when fifo1_start =>
			i_start_transfer	<= "1000";
			i_bus_enable		<= "000";

		when fifo1_wait_transfer =>
			i_start_transfer	<= "0000";
			i_bus_enable		<= "001";


		when fifo2_start =>
			i_start_transfer	<= "0100";
			i_bus_enable		<= "000";

		when fifo2_wait_transfer =>
			i_start_transfer	<= "0000";
			i_bus_enable		<= "010";

		when fifo3_start =>
			i_start_transfer	<= "0010";
			i_bus_enable		<= "000";

		when fifo3_wait_transfer =>
			i_start_transfer	<= "0000";
			i_bus_enable		<= "011";

		when fifo4_start =>
			i_start_transfer	<= "0001";
			i_bus_enable		<= "000";

		when fifo4_wait_transfer =>
			i_start_transfer	<= "0000";
			i_bus_enable		<= "100";

		when others =>
			i_start_transfer	<= "0000";
			i_bus_enable		<= "000";
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
-- Registered output assignments
OUTPUT_FLOPS: process(rst,clk)
begin
	if rst ='1' then
		r_start_transfer	<= "0000";
		bus_enable			<= "000";
	elsif rising_edge(clk) then
		r_start_transfer	<= i_start_transfer;
		bus_enable			<= i_bus_enable;
	end if;
end process;
--

-- REGISTER OUTPUTS AS SOON AS POSSIBLE ! ! !  
-- BUS Selector amd Tri-State 
bus_tri_state: process(bus_enable, fifo_qA, fifo_qB, fifo_qC, fifo_qD, fifo_qE, fifo_qF, fifo_qG, fifo_qH)
begin
	case (bus_enable) is
		
		when "000"	=>
			idt_data				<= (others => 'Z');
			
		when "001"	=>
			idt_data(9 downto 0)	<= fifo_qA;
			idt_data(15 downto 10)	<= (others => '0');
			idt_data(25 downto 16)	<= fifo_qB;
			idt_data(31 downto 26)	<= (others => '0');

		when "010"	=>
			idt_data(9 downto 0)	<= fifo_qC;
			idt_data(15 downto 10)	<= (others => '0');
			idt_data(25 downto 16)	<= fifo_qD;
			idt_data(31 downto 26)	<= (others => '0');

		when "011"	=>
			idt_data(9 downto 0)	<= fifo_qE;
			idt_data(15 downto 10)	<= (others => '0');
			idt_data(25 downto 16)	<= fifo_qF;
			idt_data(31 downto 26)	<= (others => '0');

		when "100"	=>
			idt_data(9 downto 0)	<= fifo_qG;
			idt_data(15 downto 10)	<= (others => '0');
			idt_data(25 downto 16)	<= fifo_qH;
			idt_data(31 downto 26)	<= (others => '0');

		when others	=>
			idt_data				<= (others => 'Z');

	end case;
end process;

--
-- FIFO control instantiation
--

empty(1)  <= (fifo_empty(1) or fifo_empty(2));

FIFO1_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> r_start_transfer(1),
		running				=> transfer_running(1),
		idt_full			=> idt_full(1),
		idt_wren			=> idt_wren(1),
		fifo_empty			=> empty(1),
		fifo_used			=> fifo_used_A,
		rden_A				=> fifo_rden(1),
		rden_B				=> fifo_rden(2)
	);

empty(2)  <= (fifo_empty(3) or fifo_empty(4));

FIFO2_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> r_start_transfer(2),
		running				=> transfer_running(2),
		idt_full			=> idt_full(2),
		idt_wren			=> idt_wren(2),
		fifo_empty			=> empty(2),
		fifo_used			=> fifo_used_C,
		rden_A				=> fifo_rden(3),
		rden_B				=> fifo_rden(4)
	);

empty(3)  <= (fifo_empty(5) or fifo_empty(6));

FIFO3_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> r_start_transfer(3),
		running				=> transfer_running(3),
		idt_full			=> idt_full(3),
		idt_wren			=> idt_wren(3),
		fifo_empty			=> empty(3),
		fifo_used			=> fifo_used_E,
		rden_A				=> fifo_rden(5),
		rden_B				=> fifo_rden(6)
	);

empty(4)  <= (fifo_empty(7) or fifo_empty(8));

FIFO4_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> r_start_transfer(4),
		running				=> transfer_running(4),
		idt_full			=> idt_full(4),
		idt_wren			=> idt_wren(4),
		fifo_empty			=> empty(4),
		fifo_used			=> fifo_used_H,
		rden_A				=> fifo_rden(7),
		rden_B				=> fifo_rden(8)
	);

--
end one_idtfifo_top;