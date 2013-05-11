-- $ FIFO Module (PRE+POST)
-- v: svn controlled;
--
--

library ieee;
use ieee.std_logic_1164.all;

use work.acq_pkg.all;
--

entity dcfifom is
	port
	(	
		signal wrclk			: in 	std_logic; -- write clock
		signal rdclk			: in 	std_logic; -- read clock
		signal rst				: in 	std_logic; -- async reset
		
		signal wmode			: in	std_logic; -- Word Mode: '0' for 8 bits, '1' for 10 bits.
		signal bmode			: in	std_logic_vector(1 downto 0); -- 8 Bits mode bit selection: See docs.
		
		signal wr				: in 	std_logic;
		signal d				: in	DATA_T;
		
		signal rd				: in	std_logic;	
		signal q				: out	EFDATA_T;
		
		signal f				: out	std_logic;	--full flag
		signal e				: out	std_logic;	--empty flag

		signal rdusedw			: out	DUSEDW_T;	-- used words sync'ed to read clock
		signal wrusedw			: out	USEDW_T	-- used words sync'ed to write clock
	);
end dcfifom;

--

architecture rtl of dcfifom is

	component prefifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN DATA_T;
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full	: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT DATA_T
	);
	end component;
	
	component postfifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN DATA_T;
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT DDATA_T;
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT DUSEDW_T;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT USEDW_T
	);
	end component;
	
	--
	
	signal ar		: std_logic;
	signal dbus		: DATA_T;
	signal data_r	: DATA_T;
	signal obus		: DDATA_T;
	signal adata	: EFDATA_T;
	signal bdata	: EFDATA_T;
	signal asel		: EFDATA_T;
	signal bsel		: EFDATA_T;	
	signal csel		: EFDATA_T;	
	
--

begin

	--Data input registers
	process (wrclk, rst)
	begin
		if (rst = '1') then
			data_r	<= (others => '0');
		elsif (rising_edge(wrclk)) then
			data_r	<= d;
		end if;
	end process;
		
--
	
	pre:
	prefifo port map
	(
		aclr		=> rst,
		clock		=> wrclk,
		data		=> data_r,
		rdreq		=> ar,
		wrreq		=> '1',
		almost_full	=> ar,
		empty		=> open,
		full		=> open,
		q			=> dbus
	);
	
	post:
	postfifo port map
	(
		aclr	 	=> rst,
		data	 	=> dbus,
		rdclk	 	=> rdclk,
		rdreq	 	=> rd,
		wrclk	 	=> wrclk,
		wrreq	 	=> wr,
		q	 		=> obus,
		rdempty	 	=> e,
		rdusedw	 	=> rdusedw,
		wrfull	 	=> f,
		wrusedw	 	=> wrusedw		
	);
	
	-- 8 LSBits
	asel <= x"0000" & obus(17 downto 10) & obus(7 downto 0);

	-- Signal Bit + 7 LSbits
	bsel <= x"0000" & obus(19) & obus(16 downto 10) & obus(9) & obus(6 downto 0);

	-- 8 MSbits
	csel <= x"0000" & obus(19 downto 12) & obus(9 downto 2);
	
	-- 8 bits data
	adata <= asel when (bmode = "00") else
	         bsel when (bmode = "01") else
			 csel when (bmode = "10") else
			 (others => 'X');
			 
	-- 10 bits data
	bdata <= "00" & x"0" & obus(19 downto 10) & "00" & x"0" & obus(9 downto 0);
	
	-- Output Selector (Mux)
	q <= adata when (wmode = '0') else 
		 bdata when (wmode = '1');
		 
	
end rtl;