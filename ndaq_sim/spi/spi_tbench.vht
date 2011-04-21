--
-- $SPI Test Bench
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library std;                                                            
--use std.textio.all;                                                     

entity spi_tbench is
end spi_tbench;


architecture testbench of spi_tbench is

--type datavec is array (0 to 1) of std_logic_vector(7 downto 0);

-- D.U.T.(s)

-- Master SPI

component m_spi
	port
	(	
		signal clk				: in 	std_logic;						-- sytem clock (@20 MHz)
		signal rst				: in 	std_logic;						-- asynchronous reset
		
		signal mosi				: out 	std_logic;						-- master serial out	- slave serial in
		signal miso				: in	std_logic;						-- master serial in	- slave serial out
		signal sclk				: out	std_logic;						-- spi clock out
		
		signal wr				: in	std_logic;						-- write strobe
		signal rd				: in  	std_logic;						-- read strobe
		
		signal dwait			: out	std_logic;						-- busy flag
		signal dataa			: out	std_logic;						-- data avaiable flag
		
		signal idata			: in	std_logic_vector(7 downto 0);	-- data input parallel bus
		signal odata			: out	std_logic_vector(7 downto 0)	-- data output parallel bus	
	);
end component;

-- Slave SPI

component s_spi
	port
	(	
		signal clk				: in 	std_logic;						-- sytem clock (@20 MHz)
		signal rst				: in 	std_logic;						-- asynchronous reset
		
		signal mosi				: in	std_logic;						-- master serial out	- slave serial in
		signal miso				: out	std_logic;						-- master serial in	- slave serial out
		signal sclk				: in	std_logic;						-- spi clock out
		
		signal wr				: in	std_logic;						-- write strobe
		signal rd				: in  	std_logic;						-- read strobe
		
		signal dwait			: out	std_logic;						-- busy flag
		signal dataa			: out	std_logic;						-- data avaiable flag
		
		signal idata			: in	std_logic_vector(7 downto 0);	-- data input parallel bus
		signal odata			: out	std_logic_vector(7 downto 0)	-- data output parallel bus	
	);
end component;


-- Signals                                                   
signal mclk  	: std_logic := '0';
signal sclk  	: std_logic := '0';
signal rst		: std_logic := '0';

signal mosi		: std_logic := '0';
signal miso		: std_logic := '0';
signal spiclk	: std_logic := '0';

signal mwr		: std_logic := '1';
signal mrd		: std_logic := '1';
signal mdata	: std_logic_vector(7 downto 0) := x"00";

signal swr		: std_logic := '1';
signal srd		: std_logic := '1';
signal sidata	: std_logic_vector(7 downto 0) := x"00";
signal sodata	: std_logic_vector(7 downto 0) := x"00";

signal sbusy	: std_logic := '0';
signal sdataa	: std_logic := '0';

signal mbusy	: std_logic := '0';
signal mdataa	: std_logic := '0';

signal mcounter	: std_logic_vector(7 downto 0) := x"00";

signal mwrst	: std_logic_vector(3 downto 0) := x"0";
signal srdst	: std_logic_vector(3 downto 0) := x"0";
signal mrdst	: std_logic_vector(3 downto 0) := x"0";

-- arch begin
begin

-- Master SPI Map
Master_SPI : m_spi
	port map
	(	
		clk				=> mclk,	-- sytem clock (@20 MHz)
		rst				=> rst,		-- asynchronous reset
		
		mosi			=> mosi,	-- master serial out	- slave serial in
		miso			=> miso,	-- master serial in	- slave serial out
		sclk			=> spiclk,	-- spi clock out
		
		wr				=> mwr,		-- write strobe
		rd				=> mrd,		-- read strobe
		
		dwait			=> mbusy,	-- busy flag
		dataa			=> mdataa,	-- data avaiable flag
		
		idata			=> mdata,	-- data input parallel bus
		odata			=> open		-- data output parallel bus	
	);
		

-- Slave SPI Map
Slave_SPI : s_spi
	port map
	(	
		clk				=> sclk,	-- sytem clock (@20 MHz)
		rst				=> rst,		-- asynchronous reset
		
		mosi			=> mosi,	-- master serial out	- slave serial in
		miso			=> miso,	-- master serial in	- slave serial out
		sclk			=> spiclk,	-- spi clock out
		
		wr				=> swr,		-- write strobe
		rd				=> srd,		-- read strobe
		
		dwait			=> sbusy,	-- busy flag
		dataa			=> sdataa,	-- data avaiable flag
		
		idata			=> sidata,	-- data input parallel bus
		odata			=> sodata	-- data output parallel bus	
	);


-- Stimulus!

-- mclk @ 20MHz
mclk_gen: process
begin
loop
	mclk <= '0';
	wait for 25000 ps;
	mclk <= '1';
	wait for 25000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process mclk_gen;

-- sclk @ 10MHz
sclk_gen: process
begin
loop
	sclk <= '1';
	wait for 8333 ps;
	sclk <= '0';
	wait for 8333 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process sclk_gen;

-- Reset 
rst_gen: process
begin
	rst <= '1';
	wait for 150 ns;
	rst <= '0';
	wait;
end process rst_gen;

-- Master Write Process
m_wr_gen: process(rst, mclk)
begin
	if (rst = '1') then
		mdata		<= (others => 'Z');
		mwr			<= '1';
		mcounter	<= x"00";
		mwrst		<= x"0";
		
	elsif (rising_edge(mclk)) then
		case (mwrst) is
		
			when x"0"	=>	
				if (mbusy = '0') then
					mdata	<= mcounter;
					mcounter	<= mcounter+1;
					mwr		<= '0';
					mwrst	<= x"1";
				else
					mwr		<= '1';
					mwrst	<= x"0";
				end if;
		
			when x"1"	=>
				mwr		<= '1';
				mwrst	<= x"0";
			
			when others	=>
				mwr		<= '1';
				mwrst	<= x"0";

		end case;	
	end if;
end process m_wr_gen;


-- Slave Loopback Process;
sidata <= sodata;

s_loop_gen: process(rst, sclk)
begin
	if (rst = '1') then
		srd			<= '1';
		swr			<= '1';
		srdst		<= x"0";
		--sidata		<= x"00";
		
	elsif (rising_edge(sclk)) then
		case (srdst) is
		
			when x"0"	=>	
				if (sdataa = '1') then
					srd		<= '0';
					srdst	<= x"1";
				else
					srd		<= '1';
					srdst	<= x"0";
				end if;
				
			when x"1"	=>
					srd		<= '1';

				if (sbusy = '0') then
					swr		<= '0';				
					srdst	<= x"2";
				else
					srdst	<= x"1";
				end if;
				
				--sidata	<= sodata;

			when x"2"	=>
				srd		<= '1';
				swr		<= '1';				
				srdst	<= x"0";
				
			when others	=>
				srd		<= '1';
				srdst	<= x"0";

		end case;	
	end if;
end process s_loop_gen;


-- Master Read Process
m_rd_gen: process(rst, mclk)
begin
	if (rst = '1') then
		mrd			<= '1';
		mrdst		<= x"0";
		
	elsif (rising_edge(mclk)) then
		case (mrdst) is
		
			when x"0"	=>	
				if (mdataa = '1') then
					mrd		<= '0';
					mrdst	<= x"1";
				else
					mrd		<= '1';
					mrdst	<= x"0";
				end if;
		
			when x"1"	=>
				mrd		<= '1';
				mrdst	<= x"0";
			
			when others	=>
				mrd		<= '1';
				mrdst	<= x"0";

		end case;	
	end if;
end process m_rd_gen;


---- rxf
--rxf_gen: process
--begin
--  
--  --initil transceiver condition
--	rxf  <= '1';
--	data <= "ZZZZZZZZ";
--  --wait for 28572 us;
--  
--loop
--  --wait for 300 ns;
--  --let's indicate that there is data avaiable
--	rxf  <= '0'; --'0';
--
--  --now, we're gonna wait for the counterpart's read strobe
--	wait until (nrd = '0');
--	
--	-- Transceiver's RD strobe to valid data output latency
--	wait for 50 ns; -- T3: 20 to 50ns
--	
--	if (toggle = '0') then
--	 data    <= value(0);
--	 toggle  <= '1';
--	else
--	 data    <= value(1);
--	 toggle  <= '0';
--	end if;
--	 
-- 
--  --now, we're gonna wait for the counterpart to end the cycle
--  wait until (nrd = '1');
--  
--  -- Transceiver's Valid Data Hold Time from RD Strobe inactive
--  wait for 0 ns; -- T4: 0ns
--
--	data <= "ZZZZZZZZ";
--
--  -- RD inactive to RXF = '1'
--  wait for 25 ns; -- T5: 0 to 25 ns;
--  
--  rxf <= '1';
--  
--  -- RXF inactive after cycle
--  wait for 80 ns; -- T6: 80 ns; 
--end loop; 
--
--end process rxf_gen;

end testbench;
