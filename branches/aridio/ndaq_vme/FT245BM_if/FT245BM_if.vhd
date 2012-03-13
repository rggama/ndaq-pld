-- FT245BM Transceiver Interface (Interface to the USB Transceiver - FTDI FT245BM)
-- v: svn controlled
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

entity ft245bm_if is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal ftclk			: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- just enable comb logic

		-- local bus
		signal dwait			: out	std_logic;
		signal dataa			: out	std_logic;
		signal wr				: in 	std_logic;
		signal rd				: in 	std_logic;
		signal idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out	std_logic_vector(7 downto 0);

		-- ftdi bus
		signal f_txf			: in	std_logic;
		signal f_rxf			: in 	std_logic;
		signal f_wr				: out	std_logic;
		signal f_rd				: out	std_logic;
		signal f_iodata			: inout	std_logic_vector(7 downto 0)
	);
end ft245bm_if;

--

architecture rtl of ft245bm_if is

------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------

	component ft245bm_ab is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- just enable comb logic

		signal f_txf			: in	std_logic;
		signal f_rxf			: in 	std_logic;
		
		signal dataa			: in 	std_logic;
		
		signal txidle			: in 	std_logic;
		signal rxidle			: in 	std_logic;

		signal txen				: out	std_logic;
		signal rxen				: out	std_logic
	);
	end component;
	
	component ft245bm_tx
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal ftclk			: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal wr				: in	std_logic;
		signal dwait 			: out	std_logic := '0';
		signal idata			: in 	std_logic_vector(7 downto 0);

		signal f_txf			: in 	std_logic;
		signal f_wr				: out	std_logic := '0';
		signal f_odata        	: out	std_logic_vector(7 downto 0)
	);
	end component;

	component ft245bm_rx
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal ftclk			: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal rd				: in	std_logic;
		signal dataa 			: out	std_logic := '0';
		signal odata			: out 	std_logic_vector(7 downto 0);

		signal f_rxf			: in 	std_logic;
		signal f_rd				: out	std_logic := '1';
		signal f_idata        	: in	std_logic_vector(7 downto 0)
	);
	end component;

	
---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------

	signal rxen		: std_logic := '0';
	signal txen		: std_logic := '0';
	signal txidle	: std_logic := '1';
	signal rxidle	: std_logic := '1';
	signal w_dataa	: std_logic := '0';
	--

begin
	
	dataa	<= w_dataa;
	
	arbiter:
	ft245bm_ab port map
	(	
		clk				=> clk,
		clk_en			=> clk_en,
		rst				=> rst,

		enable			=> enable,

		f_txf			=> f_txf,
		f_rxf			=> f_rxf,
		
		dataa			=> w_dataa,
		
		txidle			=> txidle,
		rxidle			=> rxidle,

		txen			=> txen,
		rxen			=> rxen
	);

	
	tx_interface: 
	ft245bm_tx port map
	(	
		clk				=> clk,
		ftclk			=> ftclk,
		clk_en			=> clk_en,
		rst				=> rst,
		
		enable			=> txen,
		isidle			=> txidle,

		wr				=> wr,
		dwait			=> dwait,
		idata			=> idata,

		f_txf			=> f_txf,
		f_wr			=> f_wr,
		f_odata			=> f_iodata
	);

	rx_interface: 
	ft245bm_rx port map
	(	
		clk				=> clk,
		ftclk			=> ftclk,
		clk_en			=> clk_en,
		rst				=> rst,

		enable			=> rxen,
		isidle			=> rxidle,
		
		rd				=> rd,
		dataa			=> w_dataa,
		odata			=> odata,

		f_rxf			=> f_rxf,
		f_rd			=> f_rd,
		f_idata			=> f_iodata
	);
	
end rtl;