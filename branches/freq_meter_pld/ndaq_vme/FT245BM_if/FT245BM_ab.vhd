-- FT245BM Transceiver Bus Arbiter
-- v: svn controlled
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity ft245bm_ab is
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
end ft245bm_ab;

--

architecture rtl of ft245bm_ab is

--

begin

--

	-- RX has priority over TX.
	-- RX and TX must NOT coexist.
	-- The 'f_rxf' and 'f_txf' are asserted when in low level.
	-- Other signals are asserted in high level.
	-- The 'enable' signal must be at a high level for any running.
	
	--txen  <= ((f_rxf or dataa) and not(f_txf) and rxidle and enable); 	 
	txen	<= ((f_rxf) and not(f_txf) and rxidle and enable); 	 

	--txen	<= not(f_txf);
	
	-- We're gonna enable TX when there is NO RX data avaiable (f_rxf - RX priority), 
	-- TX is ready to receiva data (not(f_txf)) and RX is idle.
	

	rxen	<= (not(f_rxf) and txidle and enable);
	-- We're gonna enable RX when there is data avaible (not(f_rxf)) and TX is idle.
	
	

end rtl;
