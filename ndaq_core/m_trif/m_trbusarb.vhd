-- MASTER Transceiver Bus Arbiter
-- v: 0.0
-- s: no
-- h: no

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity m_trbusarb is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- just enable comb logic
		--signal idle			: out	std_logic; -- arbiter if

		signal sdwait			: in	std_logic;
		signal sdavail			: in 	std_logic;

		signal txidle			: in 	std_logic;
		signal rxidle			: in 	std_logic;

		signal txen				: out	std_logic;
		signal rxen				: out	std_logic
	);
end m_trbusarb;

--

architecture rtl of m_trbusarb is

--

begin

--

	-- RX has priority over TX.
	-- RX and TX must NOT coexist.
	
	txen  <= ((not(sdavail)) and (not(sdwait)) and rxidle and enable); 	
	-- We're gonna enable TX when there is NO RX data avaiable (RX priority), 
	-- TX is ready do receiva data (not(sdwait)) and RX is idle.
	

	rxen  <= (sdavail and txidle and enable);
	-- We're gonna enable RX when there is data avaible (sdavail) and TX is idle.
	
	

end rtl;