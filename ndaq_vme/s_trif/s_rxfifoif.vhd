-- SLAVE RX FIFO Interface
-- v: 0.1
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

entity s_rxfifoif is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if

		signal snrd				: in	std_logic;
		signal sdavail 			: out	std_logic := '0';
		signal odata			: out 	std_logic_vector(3 downto 0);

		signal rxf				: in 	std_logic;
		signal rxrd				: out	std_logic := '1';
		signal idata        	: in	std_logic_vector(7 downto 0)
	);
end s_rxfifoif;

--

architecture rtl of s_rxfifoif is
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, rxready, 
						FTDI_rd_a, FTDI_waitst, FTDI_ldata, FTDI_rd_d,
						outp_LO, wait_HI, outp_HI,
						setup_LO, setup_HI); 

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";

	-- Buffer
	signal buf	: std_logic_vector(7 downto 0);
	
--

begin

	rxfifofsm:
	process (clk, clk_en, rst)
	begin
		if (rst = '1') then	
			--
			state	<= idle;
			-- to master
			odata	<= "ZZZZ";
			
		elsif (rising_edge(clk) and (clk_en = '1')) then
			case state is
				when idle =>
					--
					if (rxf = '0') then
						state <= rxready;
					else
						state <= idle;
					end if;
				
				when rxready =>
					--
					if ((rxf = '0') and (snrd = '0')) then	-- Wait for LO Request.
						state <= FTDI_rd_a;
					else
						state <= rxready;
					end if;
				  					
				when FTDI_rd_a =>
					--
					state <= FTDI_waitst;
				
				when FTDI_waitst =>
					state	<= FTDI_ldata; 
					-- Buffering
					buf		<= idata;
					
				when FTDI_ldata =>
					--
					state <= FTDI_rd_d;
				
				-- Pre-Charge Time T6(80ns), will be achieved with the next states.	
				--
				-- *** MAY PROBABLY BYPASS THE NEXT STATE
				when FTDI_rd_d =>
					--
					state <= setup_LO; --outp_LO;
					-- ftdi to master
					odata  <= buf(3 downto 0);
					
--***************************************************************************************************************

				
				-- After the WHOLE FTDI CYCLE...
				when setup_LO	=>
					state	<= outp_LO;
					
				when outp_LO =>
					--
					-- *** CYCLE FINISH TEST
					--
					--
					if (snrd = '1') then	-- If 'rd' = '1', then cycle has finished.
						state <= wait_HI;
					else
						state <= outp_LO;	-- 'rd' = '0', cycle is still pending.
					end if;
							
				when wait_HI =>
					--
					-- *** STROBE TEST
					--
					if (snrd = '0') then	-- Got HI request.
						state <= setup_HI; --outp_HI;
						-- ftdi to master
						odata  <= buf(7 downto 4);
					else
						state <= wait_HI;	-- Keep waiting for HI request.
					end if;

				when setup_HI	=>
					state	<= outp_HI;

				when outp_HI =>
					--
					-- *** CYCLE FINISH TEST
					--
					--
					if (snrd = '1') then	-- If 'rd' = '1', then cycle has finished.
						state <= idle;
						-- to master
						odata	<= "ZZZZ";
					else
						state <= outp_HI;	-- 'rd' = '0', cycle is still pending.
					end if;

--***************************************************************************************************************

			end case;
		end if;
	end process;


	process (state)
	begin
		case state is 
			when idle		=> 
				-- to master
				sdavail <= '0';
				-- ftdi		
				rxrd   	<= '1';

			when rxready	=> 
				-- to master
				sdavail	<= '1';
				-- ftdi		
				rxrd	<= '1';

			when FTDI_rd_a	=> 
				-- to master
				sdavail	<= '1';
				-- ftdi		
				rxrd	<= '0';

			when FTDI_waitst => 
				-- to master
				sdavail <= '1';
				-- ftdi		
				rxrd   	<= '0';

			when FTDI_ldata	=> 
				-- to master
				sdavail <= '1';
				-- ftdi		
				rxrd   	<= '0';

			when FTDI_rd_d	=> 
				-- to master
				sdavail <= '1';
				-- ftdi		
				rxrd   	<= '1';

			when outp_LO	=> 
				-- to master
				sdavail <= '0';		-- ACK
				-- ftdi		
				rxrd   	<= '1';

			when setup_LO	=> 
				-- to master
				sdavail <= '1';		-- just setup, NO ack
				-- ftdi		
				rxrd   	<= '1';

			when wait_HI	=> 
				-- to master
				sdavail <= '1';		-- Able to send data again
				-- ftdi		
				rxrd   	<= '1';

			when setup_HI	=> 
				-- to master
				sdavail <= '1';		-- just setup, NO ack
				-- ftdi		
				rxrd   	<= '1';

			when outp_HI	=> 
				-- to master
				sdavail <= '0';		-- ACK
				-- ftdi		
				rxrd   	<= '1';


		end case;
	end process;


end rtl;