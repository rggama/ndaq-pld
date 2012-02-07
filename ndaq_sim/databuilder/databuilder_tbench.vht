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

	constant	TRANSFER_SIZE	:	unsigned := x"10";
	
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
		
		--
		empty						: in	SLOTS_T;
		rd							: out	SLOTS_T;
		idata						: in	IDATA_A;
		
		--
		full						: in	SLOTS_T;
		wr							: out	SLOTS_T;
		odata						: out	ODATA_T
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
	
	--
	signal	empty		: SLOTS_T;
	signal	idata		: IDATA_A;
		
	--
	signal	full		: SLOTS_T;
	
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
		
		--
		empty						=> empty,
		rd							=> open,
		idata						=> idata,
		
		--
		full						=> full,
		wr							=> open,
		odata						=> open
	);

--
-- I/O Construct
--

io_construct:
for i in 0 to (slots - 1) generate

	enable_A(i)	<= '1';
	enable_B(i)	<= '1';
	transfer(i)	<= CONV_STD_LOGIC_VECTOR(TRANSFER_SIZE, NumBits(transfer_max));
	
	empty(i)	<= '0';
	idata(i)	<= CONV_STD_LOGIC_VECTOR(i, in_width);
	
	full(i)		<= '0';
	
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
