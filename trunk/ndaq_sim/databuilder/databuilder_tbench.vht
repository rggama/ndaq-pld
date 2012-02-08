library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).
--use ieee.std_logic_signed.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as signed integers (used together with std_logic_unsigned is ambiguous).
--use ieee.numeric_std.all;		-- altenative to std_logic_arith, used for maths too (will conflict with std_logic_arith if 'signed' is used in interfaces).

use work.functions_pkg.all;
use work.databuilder_pkg.all;

entity databuilder_tbench is
end databuilder_tbench;


architecture testbench of databuilder_tbench is

	constant	TRANSFER_SIZE	:	unsigned := x"09";
	constant	FIFO_ADDRESS	:	unsigned := x"03";
	
--
-- DUT: Data Builder
--
	
	component databuilder
	port
	(	
		--
		rst							: in	std_logic;
		clk							: in	std_logic;		 

		--
		enable_A					: in	SLOTS_T;
		enable_B					: in	SLOTS_T;
		transfer					: in	TRANSFER_A;
		address						: in	ADDRESS_A;
		
		--
		rd							: out	SLOTS_T;
		idata						: in	IDATA_A;
		
		--
		wr							: out	ADDRESS_T;
		odata						: out	ODATA_T
	);
	end component;

-- Test FIFO
	component test_fifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
	end component;

--	
-- Signals
--
	--
	signal	rst			: std_logic := '0';
	signal	clk			: std_logic := '0';
	
	--
	signal	enable_A	: SLOTS_T;
	signal	enable_B	: SLOTS_T;
	signal	transfer	: TRANSFER_A;
	signal	address		: ADDRESS_A;
	
	--
	signal  idata		: IDATA_A;
	
	--
	signal inp_q		: IDATA_A;	
	signal inp_data		: IDATA_A;
	signal inp_rd		: SLOTS_T;
	signal inp_wr		: SLOTS_T;
	signal inp_empty	: SLOTS_T;
	signal inp_full		: SLOTS_T;
			
--

begin

--
-- Maps
--

	data_builder: 
	databuilder port map 
	(
		--
		rst							=> rst,
		clk							=> clk,

		--
		enable_A					=> enable_A,
		enable_B					=> enable_B,
		transfer					=> transfer,
		address						=> address,
		
		--
		rd							=> inp_rd,
		idata						=> inp_q,
		
		--
		wr							=> open,
		odata						=> open
	);

	
fifo_construct:
for i in 0 to (slots - 1) generate

	read_testfifo:
	test_fifo port map
	(
		aclr		=> rst,
		data		=> inp_data(i),
		rdclk		=> clk,
		rdreq		=> inp_rd(i),
		wrclk		=> clk,
		wrreq		=> inp_wr(i),
		q			=> inp_q(i),
		rdempty		=> inp_empty(i),
		rdusedw		=> open,
		wrfull		=> inp_full(i),
		wrusedw		=> open
	);

end generate fifo_construct;


--
-- INPUT FIFO Data Construct
--

inp_data_construct:
for i in 0 to (slots - 1) generate
	
	inp_data(i)	<= CONV_STD_LOGIC_VECTOR(i, in_width);
	inp_wr(i)	<= '1';
	
end generate inp_data_construct;

--
-- I/O Construct
--

io_construct:
for i in 0 to (slots - 1) generate

	enable_A(i)	<= '1';
	enable_B(i)	<= not(inp_empty(i));
	transfer(i)	<= CONV_STD_LOGIC_VECTOR(TRANSFER_SIZE, NumBits(transfer_max));
	address(i)	<= CONV_STD_LOGIC_VECTOR(FIFO_ADDRESS, NumBits(address_max));
	
	idata(i)	<= inp_q(i);
		
end generate io_construct;

--	
-- Stimulus!
--

-- clk @ 50 MHz
clkvme_gen: process
begin
loop
	clk	<= '0';
	wait for 10000 ps;
	clk	<= '1';
	wait for 10000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process clkvme_gen;

-- Reset 
rst_gen: process
begin
	rst <= '1';
	wait for 150 ns;
	rst <= '0';
	wait;
end process rst_gen;
	
end testbench;
