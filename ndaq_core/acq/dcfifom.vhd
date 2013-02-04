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
		
		signal wr				: in 	std_logic;
		signal d				: in	DATA_T;
		
		signal rd				: in	std_logic;	
		signal q				: out	DATA_T;
		
		signal f				: out	std_logic;	--full flag
		signal e				: out	std_logic;	--empty flag

		signal rdusedw			: out	USEDW_T;	-- used words sync'ed to read clock
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
		q			: OUT DATA_T;
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT USEDW_T;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT USEDW_T
	);
	end component;
	
	--
	
	signal ar		: std_logic;
	signal dbus		: DATA_T;
	signal data_r	: DATA_T;
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
		q	 		=> q,
		rdempty	 	=> e,
		rdusedw	 	=> rdusedw,
		wrfull	 	=> f,
		wrusedw	 	=> wrusedw		
	);
	

end rtl;