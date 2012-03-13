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

	constant	TRANSFER_SIZE	:	unsigned 	:= x"0F";	-- Real Size is the declared size plus one.
	constant	FIFO_ADDRESS	:	unsigned 	:= x"00";
	constant	INP				:	integer		:= 4;
	constant	OUP				:	integer		:= 4;

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
		mode						: in	SLOTS_T;
		
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
		rdfull		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		wrempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
	end component;

--	
-- Signals
--
	--
	signal	rst				: std_logic := '0';
	signal	clk				: std_logic := '0';
	signal	clkwr			: std_logic := '0';
	signal	clkrd			: std_logic := '0';
	
	--
	signal	enable_A		: SLOTS_T;
	signal	enable_B		: SLOTS_T;
	signal	transfer		: TRANSFER_A;
	signal	address			: ADDRESS_A;
	signal	mode			: SLOTS_T;
	
	--
	signal	rd				: SLOTS_T;
	signal  idata			: IDATA_A;
	
	--
	signal	wr				: ADDRESS_T;
	signal	odata			: ODATA_T;
	
	--
	subtype	INP_USEDW_T		is std_logic_vector(3 downto 0);
	type	INP_USEDW_A		is array ((INP-1) downto 0) of INP_USEDW_T;

	signal	inp_q			: IDATA_A;	
	signal	inp_data		: IDATA_A;
	signal	inp_rd			: SLOTS_T;
	signal	inp_wr			: SLOTS_T;
	signal	inp_wrempty		: SLOTS_T;
	signal	inp_wrfull		: SLOTS_T;
	signal	inp_rdempty		: SLOTS_T;
	signal	inp_rdfull		: SLOTS_T;
	signal	inp_rdusedw		: INP_USEDW_A;
	signal	inp_enable		: SLOTS_T;

	subtype	INP_COUNTER_T	is std_logic_vector(3 downto 0);
	type	INP_COUNTER_A	is array ((INP-1) downto 0) of INP_COUNTER_T;
	
	signal	inp_counter		: INP_COUNTER_A;
	signal	inp_counter_en	: std_logic_vector((INP-1) downto 0);
	
	--
	signal	oup_data		: ODATA_T;
	signal	oup_rd			: ADDRESS_T;
	signal	oup_wr			: ADDRESS_T;
	signal	oup_wrempty		: ADDRESS_T;
	signal	oup_wrfull		: ADDRESS_T;
	signal	oup_rdempty		: ADDRESS_T;
	signal	oup_rdfull		: ADDRESS_T;

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
		mode						=> mode,
		
		--
		rd							=> rd,
		idata						=> idata,
		
		--
		wr							=> wr,
		odata						=> odata
	);

	
inp_fifo_construct:
for i in 0 to (INP - 1) generate

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
		rdempty		=> inp_rdempty(i),
		rdfull		=> inp_rdfull(i),
		rdusedw		=> inp_rdusedw(i),
		wrempty		=> inp_wrempty(i),
		wrfull		=> inp_wrfull(i),
		wrusedw		=> open
	);

end generate inp_fifo_construct;

oup_fifo_construct:
for i in 0 to (OUP - 1) generate

	write_testfifo:
	test_fifo port map
	(
		aclr		=> rst,
		data		=> oup_data,
		rdclk		=> clkrd,
		rdreq		=> oup_rd(i),
		wrclk		=> clkwr,
		wrreq		=> oup_wr(i),
		q			=> open,
		rdempty		=> oup_rdempty(i),
		rdfull		=> oup_rdfull(i),
		rdusedw		=> open,
		wrempty		=> oup_wrempty(i),
		wrfull		=> oup_wrfull(i),
		wrusedw		=> open
	);

end generate oup_fifo_construct;

--
-- INPUT FIFO Data Construct
--

inp_data_construct:
for i in 0 to (INP - 1) generate
		
	input_counter:
	process(clk, rst)
	begin
		if (rst = '1') then
			inp_counter(i) <= (others => '1');
		elsif (rising_edge(clk)) then
			if (inp_counter_en(i) = '1') then
				inp_counter(i) <= inp_counter(i) + 1;
			end if;
		end if;
	end process;

	inp_counter_en(i)	<= not(inp_wrfull(i));
	inp_data(i)			<= CONV_STD_LOGIC_VECTOR(i, 4) & x"000000" & inp_counter(i);
	inp_wr(i)			<= '1';
	
end generate inp_data_construct;

--
-- Data Builder Slots Construct
--

slots_construct:
for i in 0 to (slots - 1) generate

	inp_read_test:
	process(inp_rdusedw, inp_rdempty)
	begin
		-- Means that the FIFO is FULL of data.
		if (inp_rdusedw(i) = x"0") and (inp_rdempty(i) = '0') then
			inp_enable(i) <= '1';
		else
			inp_enable(i) <= '0';
		end if;
	end process;
	
	enable_A(i)	<= '1';
	--enable_B(i)	<= inp_rdfull(i) and oup_wrempty(i/2);
	enable_B(i)	<= inp_enable(i) and oup_wrempty(i/2);
	transfer(i)	<= CONV_STD_LOGIC_VECTOR(TRANSFER_SIZE, NumBits(transfer_max));
	address(i)	<= CONV_STD_LOGIC_VECTOR((i/2), NumBits(address_max));
	mode(i)		<= '0';
		
end generate slots_construct;

--
-- Data Builder Read Side Construct
--

read_side_construct:
for i in 0 to (slots - 1) generate

	inp_rd(i)	<= rd(i);
	idata(i)	<= inp_q(i);
	
end generate read_side_construct;

--
-- Data Builder Ouput Construct
--

write_side_construct:
for i in 0 to (OUP - 1) generate

	oup_wr(i)		<= wr(i);
	oup_data		<= odata;
	oup_rd(i)		<= not(oup_rdempty(i));
	
end generate write_side_construct;

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

-- clk @ 50 MHz - 180 deg
clkwr_gen: process
begin
loop
	--wait for 5000 ps;
	clkwr	<= '1';
	wait for 10000 ps;
	clkwr	<= '0';
	wait for 10000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process clkwr_gen;

-- clk @ 10 MHz - 180 deg
clkrd_gen: process
begin
loop
	--wait for 5000 ps;
	clkrd	<= '1';
	wait for 10000 ps;
	clkrd	<= '0';
	wait for 10000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process clkrd_gen;

-- Reset 
rst_gen: process
begin
	rst <= '1';
	wait for 150 ns;
	rst <= '0';
	wait;
end process rst_gen;
	
end testbench;
