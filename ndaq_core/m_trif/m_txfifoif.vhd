-- MASTER TX FIFO Interface
-- v: 0.2
--
-- 0.0 First Version
-- 
--	- Added a Byte Counter
--	TX will stop when byte count reaches 63488 bytes (max host buffer size)
-- 
-- 0.1	Changed 'idata' and 'odata' to 'std_logic_vector'
--
-- 0.2	Added a new parameter.
--
--			@ 'BCOUNT'	: Byte Counter Maximum Value. Data Blocks will 
--							be 'BCOUNT' bytes in size.
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity m_txfifoif is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rstc				: in	std_logic;

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic := '1'; -- arbiter if

		--params
		signal bcount			: in	std_logic_vector(15 downto 0);
		
		--local
		signal nwr				: in	std_logic;
		signal dwait 			: out	std_logic := '1';
		signal idata			: in 	std_logic_vector(7 downto 0);

		--ext
		signal snwr				: out	std_logic := '1';
		signal sdwait			: in 	std_logic;
		signal odata        	: out	std_logic_vector(3 downto 0)
	);
end m_txfifoif;

--

architecture rtl of m_txfifoif is

	-- Build an enumerated type for the state machine
	type state_type is (idle, txready, 
						tx_LO_a, tx_HI_a,
						tx_LO_d, tx_HI_d,
						tx_LO_setup, tx_HI_setup);

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";

	-- Byte Counter
	signal cntr	:	std_logic_vector(15 downto 0);
--

begin		

	txfifofsm:
	process (clk, clk_en, rst, rstc)
	begin
		if ((rst = '1') or (rstc = '1')) then	
			state	<= idle;
			cntr	<= x"0000";
			odata	<= "ZZZZ";
			
		elsif (rising_edge(clk) and (clk_en = '1')) then
			case state is
				when idle =>
					--
					if (sdwait = '0' and (cntr < bcount)) then
						state	<= txready;		-- ready to go
					else
						state	<= idle;		-- keep waiting
					end if;
				
				when txready =>
					--
					if ((sdwait = '0') and (nwr = '0') and (enable = '1')) then 
						-- counter
						cntr	<= cntr + 1;	-- increment counter
						-- state
						state	<= tx_LO_setup;	-- tx ready, write strobe and counter ok
						--
						odata	<= idata(3 downto 0);	-- setup LO
					else
						state	<= txready;		-- wait for a write strobe here
					end if;

--***************************************************************************************************************					
				when tx_LO_setup	=>
					state 	<= tx_LO_a;
					--
					odata	<= idata(3 downto 0);	-- output LO
					
				when tx_LO_a =>
					--
					-- *** ACK TEST.
					--
					if (sdwait = '1') then			-- Slave has received data
						state	<= tx_LO_d;
					else
						state	<= tx_LO_a;			-- Keep sending data
					end if;
					
				when tx_LO_d =>
					--
					-- *** WAIT TEST.
					--
					if (sdwait = '0') then
						state	<= tx_HI_setup;			-- Able to send again, setup HI
						--
						odata	<= idata(7 downto 4);	-- setup HI
					else
						state	<= tx_LO_d;				-- Wait here to setup HI
					end if;
					
				when tx_HI_setup =>
					state	<= tx_HI_a;
					--
					odata	<= idata(7 downto 4);	-- output HI

				when tx_HI_a =>
					--
					-- *** ACK TEST.
					--
					if (sdwait = '1') then			-- Slave has received data
						state	<= tx_HI_d;
					else
						state	<= tx_HI_a;			-- Keep sending data
					end if;
					
				when tx_HI_d =>
					--
					-- *** NO LOCAL CYCLE FINISH TEST,
					-- *** AS LOCAL IS FASTER THAN THIS
					--
					if (nwr = '0') then
						state	<= tx_HI_d;			-- Keep waiting Local finish
					else
						state	<= idle;			-- Local cycle has finished
						--
						odata	<= "ZZZZ";
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
			dwait	<= '1';				-- *** WILL ALSO ACKNOWLEDGE LOCAL BUS
			-- ext
			snwr	<= '1';
			
			when txready	=> 
			isidle	<= '1';
			-- local
			dwait	<= '0';        		-- tell local bus we're ready to go 
			-- ext
			snwr	<= '1';
			
			when tx_LO_setup	=> 
			isidle	<= '0';
			-- local
			dwait	<= '0';        		-- tell local bus data is being transmitted
			-- ext 
			snwr	<= '1';				-- just setup, no assertion

			when tx_LO_a	=> 
			isidle	<= '0';
			-- local
			dwait	<= '0';        		-- tell local bus data is being transmitted
			-- ext 
			snwr	<= '0';				-- assert data strobe for LO (0)
			
			when tx_LO_d	=> 
			isidle	<= '0';
			-- local
			dwait	<= '0';        		-- tell local bus data is being transmitted
			-- ext 
			snwr	<= '1';				-- deassert data strobe for LO (1)

			when tx_HI_setup	=> 
			isidle	<= '0';
			-- local
			dwait	<= '0';        		-- tell local bus data is being transmitted 
			-- ext 
			snwr	<= '1';				-- just setup, no assertion

			when tx_HI_a	=> 
			isidle	<= '0';
			-- local
			dwait	<= '0';        		-- tell local bus data is being transmitted 
			-- ext 
			snwr	<= '0';				-- assert data strobe for HI (0)

			when tx_HI_d	=> 
			isidle	<= '0';
			-- local
			dwait	<= '1';        		-- ACK Local bus 
			-- ext 
			snwr	<= '1';				-- deassert data strobe for HI (1)

		end case;
	end process;


end rtl;