-- SLAVE Transceiver Interface (Interface to the USB Transceiver - FTDI FTD245BM)
-- v: 0.0
--
-- 0.0	First Verion
--
-- 0.1	Changed IOs to 'std_logic_vector'
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity s_trif is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- just enable comb logic

		-- ext bus
		signal sdwait			: out	std_logic;
		signal sdavail			: out	std_logic;
		signal snwr				: in 	std_logic;
		signal snrd				: in 	std_logic;
		signal mdata			: inout	std_logic_vector(3 downto 0);

		-- ftdi bus
		signal txf				: in	std_logic;
		signal rxf				: in 	std_logic;
		signal txwr				: out	std_logic;
		signal rxrd				: out	std_logic;
		signal iodata			: inout	std_logic_vector(7 downto 0)
	);
end s_trif;

--

architecture rtl of s_trif is

------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------

	component s_txfifoif
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if

		signal snwr				: in	std_logic;
		signal sdwait 			: out	std_logic := '1';
		signal idata			: in 	std_logic_vector(3 downto 0);

		signal txf				: in 	std_logic;
		signal txwr				: out	std_logic := '0';
		signal odata        	: out	std_logic_vector(7 downto 0)
	);
	end component;

	component s_rxfifoif
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if

		signal snrd				: in	std_logic;
		signal sdavail 			: out	std_logic := '0';
		signal odata			: out 	std_logic_vector(3 downto 0);

		signal rxf				: in 	std_logic;
		signal rxrd				: out	std_logic := '1';
		signal idata        	: in	std_logic_vector(7 downto 0)
	);
	end component;

	
---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------
	
	signal snwr_r, snrd_r	:	std_logic;
	signal idata_r			:	std_logic_vector(3 downto 0);

--

begin
	
-- ** Register Interface 
	process (clk, rst)
	begin
		if (rst = '1') then
			snwr_r	<=	'1';
			snrd_r	<=	'1';
			idata_r	<=	x"0";
			
		elsif rising_edge(clk) then
			snwr_r	<=	snwr;
			snrd_r	<=	snrd;
			idata_r	<=	mdata;
		
		end if;
	end process;


	s_tx_interface: 
	s_txfifoif port map
	(	
		clk				=> clk,
		clk_en			=> clk_en,
		rst				=> rst,
		
		enable			=> '1',

		snwr			=> snwr_r,
		sdwait			=> sdwait,
		idata			=> idata_r,

		txf				=> txf,
		txwr			=> txwr,
		odata			=> iodata
	);

	s_rx_interface: 
	s_rxfifoif port map
	(	
		clk				=> clk,
		clk_en			=> clk_en,
		rst				=> rst,

		enable			=> '1',

		snrd			=> snrd_r,
		sdavail			=> sdavail,
		odata			=> mdata,

		rxf				=> rxf,
		rxrd			=> rxrd,
		idata			=> iodata
	);
	
end rtl;