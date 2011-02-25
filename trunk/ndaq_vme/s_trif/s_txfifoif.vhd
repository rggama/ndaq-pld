-- SLAVE TX FIFO Interface
-- v: 0.1
--
-- 0.0	First Version
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

entity s_txfifoif is
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
end s_txfifoif;

--

architecture rtl of s_txfifoif is
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, txready, get_LO, wait_HI, get_HI, FTDI_wr_a, FTDI_wr_d);

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";

	-- Buffer
	signal buf	: signed(7 downto 0);
	
--

begin	

	txfifofsm:
	process (clk, clk_en, rst)
	begin
		if (rst = '1') then	
			state	<= idle;
			odata <= "ZZZZZZZZ";
			
		elsif (rising_edge(clk) and (clk_en = '1')) then
			case state is
				when idle =>
					--
					if (txf = '0') then 
						state <= txready;
					else
						state <= idle;
					end if;
				
				when txready =>
					--
					if ((txf = '0') and (snwr = '0')) then	-- Waiting for LO strobe (0)
						state <= get_LO;
						-- Buffering
						--buf(3 downto 0)	<= idata;
						-- No Buffering
						odata(3 downto 0)	<= idata;
					else
						state <= txready;
					end if;

--***************************************************************************************************************  						

				when get_LO =>
					--
					-- *** CYCLE FINISH TEST
					--
					--
					if ((txf = '0') and (snwr = '1')) then	-- If 'wr' = '1', cycle has finished
						state <= wait_HI;
					else
						state <= get_LO;					-- 'wr' = '0', cycle is still pending
					end if;
				
				when wait_HI =>
					--
					-- *** STROBE TEST
					--
					--
					if ((txf = '0') and (snwr = '0')) then	-- Waiting for HI strobe (0)
						state <= get_HI;
						-- Buffering
						--buf(7 downto 4)	<= idata;
						-- No Buffering
						odata(7 downto 4)	<= idata;
					else
						state <= wait_HI;
					end if;
				
				when get_HI =>
					--
					-- *** CYCLE FINISH TEST
					--
					--
					if ((txf = '0') and (snwr = '1')) then	-- If 'wr' = '1', cycle has finished
						state <= FTDI_wr_a;
						--
						--odata	<= buf;	-- *** SENDING BUFFER !
					else
						state <= get_HI;					-- 'wr' = '0', cycle is still pending
					end if;

--***************************************************************************************************************  						

				when FTDI_wr_a =>
					--
					state	<= FTDI_wr_d;
				
				-- Pre-Charge
				when FTDI_wr_d =>
					--
					-- *** NO MASTER CYCLE FINISH TEST,
					-- *** WHY !?
					--
					-- Probably because the master cycle has finished at the 'get_HI' state.
					--
					state <= idle;
					--
					odata <= "ZZZZZZZZ";
					 
			end case;
		end if;
	end process;


	process (state)
	begin
		case state is
			when idle		=> 
				-- to master
				sdwait	<= '1'; 	-- Busy
				-- ftdi
				txwr	<= '0';

			when txready	=> 
				-- to master
				sdwait	<= '0';		-- Able to get data (LO) 
				-- ftdi
				txwr	<= '0';

			when get_LO		=> 
				-- to master
				sdwait	<= '1'; 	-- ACK (LO)
				-- ftdi
				txwr	<= '0';

			when wait_HI	=> 
				-- to master
				sdwait	<= '0';		-- Able to get data again (HI) 
				-- ftdi
				txwr	<= '0';

			when get_HI		=> 
				-- to master
				sdwait	<= '1';		-- ACK (HI) 
				-- ftdi
				txwr	<= '0';

			when FTDI_wr_a	=> 
				-- to master
				sdwait	<= '1'; 	-- Busy
				-- ftdi
				txwr	<= '1';

			when FTDI_wr_d	=> 
				-- to master
				sdwait	<= '1'; 	-- Busy
				-- ftdi
				txwr	<= '0';


		end case;
	end process;

end rtl;