--
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library std;                                                            
--use std.textio.all;                                                     

entity ft245bm_tbench is
end ft245bm_tbench;


architecture testbench of ft245bm_tbench is

type datavec is array (0 to 1) of std_logic_vector(7 downto 0);

-- devices under test

component ft245bm_if
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
end component;



-- Signals                                                   
signal clock	: std_logic;

signal rst		: std_logic := '1';

signal txe		: std_logic;
signal rxf		: std_logic;
signal nrd		: std_logic;
signal nwr		: std_logic;
signal data		: std_logic_vector(7 downto 0) := x"00";
signal value	: datavec;
signal toggle	: std_logic := '0';
signal counter	: std_logic_vector(7 downto 0) := x"00";

signal clkcore	: std_logic;

signal swr		: std_logic := '1';
signal srd		: std_logic := '1';
signal sidata	: std_logic_vector(7 downto 0) := x"00";
signal sodata	: std_logic_vector(7 downto 0) := x"00";

signal sbusy	: std_logic := '0';
signal sdataa	: std_logic := '0';

signal srdst	: std_logic_vector(3 downto 0) := x"0";

-- signal bridge_data	: std_logic_vector(3 downto 0);
-- signal bridge_dw	: std_logic;
-- signal bridge_da	: std_logic;
-- signal bridge_wr	: std_logic;
-- signal bridge_rd	: std_logic;

signal adc12_dco	: std_logic;

-- arch begin
begin
	
	transceiver:
	ft245bm_if port map
	(	
		clk				=> clkcore,
		ftclk			=> clock,
		clk_en			=> '1',
		rst				=> rst,

		enable			=> '1',

		-- local bus
		dwait			=> sbusy,
		dataa			=> sdataa,
		wr				=> swr,
		rd				=> srd,
		idata			=> sidata,
		odata			=> sodata,

		-- ftdi bus
		f_txf			=> txe,
		f_rxf			=> rxf,
		f_wr			=> nwr,
		f_rd			=> nrd,
		f_iodata		=> data
	);

	
-- adc12_dco
adc12_dco_gen: process
begin
loop
	adc12_dco <= '1';
	wait for 4000 ps;
	adc12_dco <= '0';
	wait for 4000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process adc12_dco_gen;

-- clkcore
clkcore_gen: process
begin
loop
	clkcore <= '1';
	wait for 8333 ps;
	clkcore <= '0';
	wait for 8333 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process clkcore_gen;

-- clk
clk_gen: process
begin
loop
	clock <= '0';
	wait for 25000 ps;
	clock <= '1';
	wait for 25000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process clk_gen;

-- Reset 
rst_gen: process
begin
	rst <= '1';
	wait for 150 ns;
	rst <= '0';
	wait;
end process rst_gen;

-- data values
value(0)  <= x"12";
value(1)  <= x"34";

-- rxf
rxf_gen: process
begin
  
  --initil transceiver condition
	rxf  <= '1';
	data <= "ZZZZZZZZ";
  --wait for 28572 us;
  
loop
  --wait for 300 ns;
  --let's indicate that there is data avaiable
	rxf  <= '0'; --'0';

  --now, we're gonna wait for the counterpart's read strobe
	wait until (nrd = '0');
	
	-- Transceiver's RD strobe to valid data output latency
	wait for 50 ns; -- T3: 20 to 50ns
	
	-- if (toggle = '0') then
	 -- data    <= value(0);
	 -- toggle  <= '1';
	-- else
	 -- data    <= value(1);
	 -- toggle  <= '0';
	-- end if;
	
	data	<= counter;
	counter	<= counter+1;
	
  --now, we're gonna wait for the counterpart to end the cycle
  wait until (nrd = '1');
  
  -- Transceiver's Valid Data Hold Time from RD Strobe inactive
  wait for 0 ns; -- T4: 0ns

	data <= "ZZZZZZZZ";

  -- RD inactive to RXF = '1'
  wait for 25 ns; -- T5: 0 to 25 ns;
  
  rxf <= '1';
  
  -- RXF inactive after cycle
  wait for 80 ns; -- T6: 80 ns; 
end loop; 

end process rxf_gen;

-- txe
txe_gen: process
begin 
  --initil transceiver condition
	txe  <= '1';
  --wait for 28572 us;
  
loop
  --wait for 300 ns;
	txe  <= '0'; --'0';
 
  --now, we're gonna wait for the counterpart to end the cycle
  wait until (nwr = '0');
  
  wait for 0 ns; -- T10: 0ns
 
  -- WR inactive to TXF = '1'
  wait for 25 ns; -- T11: 5 to 25 ns;
  
  txe <= '1';
  
  -- TXF inactive after cycle
  wait for 80 ns; -- T12: 80 ns; 
end loop; 

end process txe_gen;

sidata <= sodata;

s_loop_gen: process(rst, clkcore)
begin
	if (rst = '1') then
		srd			<= '1';
		swr			<= '1';
		srdst		<= x"0";
		--sidata		<= x"00";
		
	elsif (rising_edge(clkcore)) then
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

end testbench;
