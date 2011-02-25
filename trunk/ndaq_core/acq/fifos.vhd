-- $ POSITIVE Transistion DUAL CLOCK FIFO Module (PRE+POST)
-- v: 0.5
-- 
-- 0.1	10 bits wide (NDAQ)
-- 		Modified for 2 channels. (1 pre and 1 post per channel)
--
-- 0.2	Changed everything to 'std_logic_vector'.
--
--
-- 0.3	Changed 'postfifo' from 'scfifo' to 'dcfifo'.
--		Added a 'rdclk' (read clock) input.	
--		Added rd/wr 'usedw' (used words) outputs.
--
--
-- 0.4	Added a sync stage to the 'aclk' (reset) input.
--
-- 0.5	Changed this module to integrate just one 'PRE FIFO' then
--		'POST FIFO' path (one channel). Main reasons: 1) 'writefifo' 
--		component was changed to handle just one fifo path and 
--		2) flexibility for one channel hardware like the SPRO.
--
--

library ieee;
use ieee.std_logic_1164.all;

--

entity dcfifom is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rdclk			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rclk				: in	std_logic;
		
		signal wr				: in 	std_logic;
		signal d				: in	std_logic_vector(9 downto 0);
		
		signal rd				: in	std_logic;	
		signal q				: out	std_logic_vector(9 downto 0);
		
		signal f				: out	std_logic;	
		signal e				: out	std_logic;

		signal rdusedw			: out	std_logic_vector(9 downto 0);
		signal wrusedw			: out	std_logic_vector(9 downto 0)
	);
end dcfifom;

--

architecture rtl of dcfifom is

	component prefifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN std_logic_vector (9 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full	: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT std_logic_vector (9 DOWNTO 0)
	);
	end component;
	
	component postfifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
	end component;
	
	--
	
	signal rst_0	: std_logic;
	signal rst_1	: std_logic;
	signal rst_2	: std_logic;
	signal rst_3	: std_logic;
	signal rst_l	: std_logic;
	signal ar		: std_logic;
	signal dbus		: std_logic_vector(9 downto 0);

--

begin

-- ** ACLR (reset) Register Interface 

	process (clk)
	begin		
		if rising_edge(clk) then
			rst_0	<= rst;
			rst_1	<= rst_0;
			rst_2	<= rst_1;
			rst_3	<= rst_2;
			rst_l	<= rst_3;
		end if;
	end process;
		
--
	
	pre:
	prefifo port map
	(
		aclr		=> rst_l,
		clock		=> clk,
		data		=> d,
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
		aclr	 	=> rst_l,
		data	 	=> dbus,
		rdclk	 	=> rdclk,
		rdreq	 	=> rd,
		wrclk	 	=> clk,
		wrreq	 	=> wr,
		q	 		=> q,
		rdempty	 	=> e,
		rdusedw	 	=> rdusedw,
		wrfull	 	=> f,
		wrusedw	 	=> wrusedw		
	);
	

end rtl;