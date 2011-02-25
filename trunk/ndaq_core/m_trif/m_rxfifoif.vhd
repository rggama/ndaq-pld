-- MASTER RX FIFO Interface
-- v: 0.1
-- 
-- 0.1 Changed 'idata' and 'odata' to 'std_logic_vector'
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity m_rxfifoif is
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
end m_rxfifoif;

--

architecture rtl of m_rxfifoif is
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, rxready,
						rx_LO_a, rx_LO_data,
						rx_HI_a, rx_HI_data);

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";

--

begin

	rxfifofsm:
	process (clk, clk_en, rst)
	begin
		if (rst = '1') then	
			state <= idle;
			
		elsif (rising_edge(clk) and (clk_en = '1')) then
			case state is
				when idle =>
					--
					if (sdavail = '1') then
						state <= rxready;	-- data is avaible to be read
					else
						state <= idle;		-- keep waiting
					end if;
									
				when rxready =>
					--
					if ((sdavail = '1') and (nrd = '0') and (enable = '1')) then
						state <= rx_LO_a;	-- read strobed
					else
						state <= rxready;	-- wait for read strobe here
					end if;

--***************************************************************************************************************				

				when rx_LO_a =>
					--
					-- *** ACK TEST.
					--
					if (sdavail = '0') then
						state <= rx_LO_data;			-- data is at the bus to get (LO)
						-- local
						odata(3 downto 0)	<= idata;	-- get data
					else
						state <= rx_LO_a;				-- wait for data to be avaiable at the bus
					end if;
						
				-- *** INSERT A WAIT STATE BEFORE GET DATA FOR THE BITS ESTABILISH ? *** --
				
				when rx_LO_data =>
					--
					-- *** NO ACK/PARITY TEST.
					--
					if (sdavail = '1') then				-- data is avaiable again (HI)
						state	<= rx_HI_a;	
					else
						state	<= rx_LO_data;			-- wait...
					end if;
					
				when rx_HI_a	=>
					--
					-- *** ACK TEST.
					--
					if (sdavail = '0') then
						state <= rx_HI_data;			-- data is at the bus to get (HI)
						-- local
						odata(7 downto 4)	<= idata;	-- get data
					else
						state <= rx_HI_a;				-- wait for data to be avaiable at the bus
					end if;

				-- *** INSERT A WAIT STATE BEFORE GET DATA FOR THE BITS ESTABILISH ? *** --
					
				when rx_HI_data =>
					--
					-- *** NO LOCAL CYCLE FINISH TEST,
					-- *** AS LOCAL IS FASTER THAN THIS.
					--
					if (nrd = '1') then
						state	<= idle;		-- end the cycle returning to 'idle' state
					else
						state	<= rx_HI_data;	-- wait Local
					end if;


--***************************************************************************************************************

			end case;
		end if;
	end process;


	process (state)
	begin
		case state is 
			when idle		=> 
				isidle	<= '1';
				-- local
				davail	<= '0';
				-- ext
				snrd	<= '1';
			
			when rxready	=> 
				isidle	<= '1';
				-- local
				davail	<= '1';			-- tell the local bus that there is avaiable data
				-- ext
				snrd	<= '1';
			
			when rx_LO_a	=> 
				isidle	<= '0';
				-- local
				davail	<= '1';
				-- ext
				snrd	<= '0';			-- assert rx strobe for LO (0)
						
			when rx_LO_data	=> 
				isidle	<= '0';
				-- local
				davail	<= '1';
				-- ext
				snrd	<= '1';			-- deassert			
			
			when rx_HI_a	=> 
				isidle	<= '0';
				-- local
				davail	<= '1';
				-- ext
				snrd	<= '0';			-- assert rx strobe for HI (0)

			when rx_HI_data	=> 
				isidle	<= '0';
				-- local
				davail	<= '0';			-- acknowledge local bus ('nrd'), data is there
				-- ext
				snrd	<= '1';			-- deassert
				
		end case;
	end process;


end rtl;