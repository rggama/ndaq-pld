-- MASTER Transceiver Interface (Interface to the USB Transceiver - FTDI FTD245BM)
-- v: 0.2
--
-- 0.0	First Verion
-- 
-- 0.1	Changed 'idata', 'odata' and 'iodata' to 'std_logic_vector'
--
-- 0.2	Registered 'LOCAL' inputs to achieve timing requirements.
--
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity m_trif is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rstc				: in	std_logic;
		
		--params
		signal bcount			: in	std_logic_vector(15 downto 0);
		
		-- local
		signal dwait			: out	std_logic;
		signal davail			: out	std_logic;
		signal nwr				: in	std_logic;
		signal nrd				: in 	std_logic;
		signal idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out 	std_logic_vector(7 downto 0);

		-- ext
		signal sdwait			: in	std_logic;
		signal sdavail			: in 	std_logic;
		signal snwr				: out	std_logic;
		signal snrd				: out	std_logic;
		signal iodata			: inout	std_logic_vector(3 downto 0)
	);
end m_trif;

--

architecture rtl of m_trif is

------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------


	component m_trbusarb
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- just enable comb logic

		signal sdwait			: in	std_logic;
		signal sdavail			: in 	std_logic;

		signal txidle			: in 	std_logic;
		signal rxidle			: in 	std_logic;

		signal txen				: out	std_logic;
		signal rxen				: out	std_logic
	);
	end component;

	component m_txfifoif
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rstc				: in	std_logic;

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic := '1'; -- arbiter if

		--params
		signal bcount			: in	std_logic_vector(15 downto 0);

		--local
		signal nwr				: in	std_logic;
		signal dwait 			: out	std_logic := '1';
		signal idata			: in 	std_logic_vector(7 downto 0);

		--ext
		signal snwr				: out	std_logic := '1';
		signal sdwait			: in 	std_logic;
		signal odata        	: out	std_logic_vector(3 downto 0)
	);
	end component;

	component m_rxfifoif
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic := '1'; -- arbiter if

		-- local
		signal nrd				: in	std_logic;
		signal davail 			: out	std_logic := '0';
		signal odata			: out 	std_logic_vector(7 downto 0);

		-- ext
		signal snrd				: out	std_logic := '1';
		signal sdavail			: in	std_logic;
		signal idata        	: in	std_logic_vector(3 downto 0)
	);
	end component;
	
---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------
	signal txidle, rxidle		:	std_logic;
	signal txen, rxen			:	std_logic;
	
	signal sdwait_r, sdavail_r	:	std_logic;
	signal ext_idata_r			:	std_logic_vector(3 downto 0);
	
	signal nwr_r, nrd_r			:	std_logic;
	signal local_idata_r		:	std_logic_vector(7 downto 0);
--

begin

-- ** EXT Register Interface 
	process (clk, rst)
	begin
		if (rst = '1') then
			sdwait_r	<=	'1';
			sdavail_r	<=	'0';
			ext_idata_r	<=	x"0";
			
		elsif rising_edge(clk) then
			sdwait_r	<=	sdwait;
			sdavail_r	<=	sdavail;
			ext_idata_r	<=	iodata;
		
		end if;
	end process;
	

-- ** LOCAL Register Interface 
	process (clk, rst)
	begin
		if (rst = '1') then
			nwr_r			<=	'1';
			nrd_r			<=	'1';
			local_idata_r	<=	x"00";
			
		elsif rising_edge(clk) then
			nwr_r			<=	nwr;
			nrd_r			<=	nrd;
			local_idata_r	<=	idata;
		
		end if;
	end process;
	
--

	master_tr_arbiter: 
	m_trbusarb port map
	(	
		clk				=> clk,
		clk_en			=> clk_en,
		rst				=> rst,

		enable			=> '1', --enable,

		sdwait			=> sdwait_r,
		sdavail			=> sdavail_r,

		txidle			=> txidle,
		rxidle			=> rxidle,

		txen			=> txen,
		rxen			=> rxen
	);


	master_tx_interface: 
	m_txfifoif port map
	(	
		clk				=> clk,
		clk_en			=> clk_en,
		rst				=> rst,
		rstc			=> rstc,
		
		enable			=> txen,
		isidle			=> txidle,
		
		bcount			=> bcount,
		
		nwr				=> nwr_r,
		dwait			=> dwait,
		idata			=> local_idata_r,

		snwr			=> snwr,
		sdwait			=> sdwait_r,
		odata			=> iodata
	);
	

	master_rx_interface: 
	m_rxfifoif port map
	(	
		clk				=> clk,
		clk_en			=> clk_en,
		rst				=> rst,

		enable			=> rxen,
		isidle			=> rxidle,

		nrd				=> nrd_r,
		davail			=> davail,
		odata			=> odata,

		snrd			=> snrd,
		sdavail			=> sdavail_r,
		idata			=> ext_idata_r
	);
	
	
end rtl;