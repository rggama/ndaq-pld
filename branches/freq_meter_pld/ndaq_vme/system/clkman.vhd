-- Clock Manager
-- v: 0.0
-- s: no
-- h: no

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.all;

--

entity clkman is
	port
	(	
		signal iclk				: in 	std_logic;
		
		signal pclk				: out	std_logic;
		signal nclk				: out	std_logic;
		signal mclk     : out std_logic;
		signal sclk     : out std_logic;
		signal clk_enable		: out	std_logic;
		signal tclk				: out	std_logic := '0'
	);
end clkman;

--

architecture rtl of clkman is	

------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------

---------
-- PLL --
---------

	component my_pll
	port
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0			: OUT STD_LOGIC ;
		c1			: OUT STD_LOGIC ;
		c2			: OUT STD_LOGIC ;
		c3			: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;

---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------

	signal clk			: std_logic;
	signal clk_en		: std_logic;
	signal clock_div	: std_logic_vector(3 downto 0) := x"0";
	signal tclk_u		: std_logic := '0';

--

begin

-------------------
-- PLL interface --
-------------------

		pll_inst : my_pll port map (
		inclk0 => iclk,
		areset => '0',
		c0	   => clk,
		c1     => nclk,
		c2	   => mclk,
		c3     => sclk
	);

------------------------------
-- CLK Divider/Enable Logic --
------------------------------

	process (clk) begin
		if (rising_edge(clk)) then
			if(clock_div = x"2") then -- 60MHz divided by 3 = 20.00MHz clock enable
				clk_en <= '1';
				clock_div <= x"0";
			else
				clk_en <= '0';
				clock_div <= clock_div + 1;
			end if;
		end if;
	end process;
	
-----------------------------
-- Uncorrelated Test Clock --
-----------------------------

		process (clk, clk_en) begin
		if (rising_edge(clk) and clk_en = '1') then
			tclk_u <= not(tclk_u); -- 10.00 MHz unregistered clock
		end if;
	end process;

---------------------------
-- Correlated Test Clock --
---------------------------

		process (clk) begin
		if (rising_edge(clk)) then
			tclk <= tclk_u; -- 10.00 MHz registered(correlated to clk60M) clock
		end if;
	end process;
	
-------------------------
-- Output Assignements --
-------------------------

	pclk		<= clk;
	clk_enable	<= clk_en;

end rtl;