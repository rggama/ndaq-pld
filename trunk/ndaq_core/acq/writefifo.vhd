-- $ FIFO Writer
-- v: svn controlled.
--
-- 0.0	First Version.
--
--
-- 0.1	Added a sync stage to the 'aclr' (reset) input.
--
-- 0.2	Making this module parameterizable.
--		Now, it's possible to configure the maximum number of words that may be 
--		written into the fifo. So, if this component is triggered when fifo's 'usedw'
--		(used words) is greater than 'WMAX' value, the write operation will NOT happen.
--		At this moment, that parameter should be independent for each channel. 
--		A mandadtory change is making this component manage only ONE fifo. (Manage one
--		channel). Other parameter is the size of samples in a EVENT: 'ESIZE'.
--
--		New parameters:
--
--			@ 'WMAX'	: Write is prohibited if 'usedw' > 'WMAX'
--			@ 'ESIZE'	: Number of samples (words) to build an event.
-- 
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.acq_pkg.all;
--

entity writefifo is
	port
	(	
		signal clk				: in 	std_logic; 			-- sync if
		signal rst				: in 	std_logic; 			-- async if
		
		signal acqin			: out std_logic := '0';
	
		signal tmode			: in 	std_logic;
		
		signal trig0 			: in	std_logic;
		signal trig1 			: in	std_logic;
		signal trig2			: in	std_logic;
		signal trig3			: in	std_logic;

		signal wr				: out	std_logic := '0';
				
		signal usedw			: in	USEDW_T;
		signal full				: in	std_logic;
		
		-- Parameters
		
		signal wmax				: in	USEDW_T; 			-- same size of 'usedw'
		signal esize			: in	USEDW_T				-- maximum value must be equal fifo word size (max 'usedw')
	);
end writefifo;

--

architecture rtl of writefifo is

	signal rst_r		: std_logic	:= '1';
	signal scounter	: USEDW_T;							-- sample counter
	
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, 	
						wrfifoa
						);

	-- Register to hold the current state
	signal state   : state_type := idle;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";
	
	--
	signal wmax_r		: USEDW_T;
	
	signal i_wr			: std_logic := '0';
	signal i_acqin		: std_logic := '0';
--

begin

-- ** ACLR (reset) Register Interface 
	process (clk)
	begin		
		if rising_edge(clk) then
			rst_r	<= rst;
		end if;
	end process;
	
-- ** WMAX Register Interface 
	process (clk)
	begin		
		if rising_edge(clk) then
			wmax_r	<= wmax;
		end if;
	end process;
--

	writefifofsm:
	process (clk, rst_r)
	begin
		if (rst_r = '1') then
			scounter <= (others => '0');
			--	
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
				when idle =>
					if(  
								(((trig0 = '1') or (trig1 = '1') or (trig2 = '1'))
								and (usedw < wmax_r) and (full = '0') and (tmode = '0'))
							or
								((trig3 = '1') and (usedw < wmax_r) and (full = '0') 
								and (tmode = '1'))
							
						) then
						
						state <= wrfifoa;
					else
						state <= idle;
					end if;

				-- FIF0 Write Assert (FIFO is deasserted on the 'idle' state)
				when wrfifoa =>
					scounter <= scounter + 1;
					--
					if (scounter = esize) then
						state <= idle;
						--
						scounter	<= (others => '0');
					else
						state <= wrfifoa;
					end if;

			end case;
		end if;
	end process;

	fsm_outputs:
	process (state)
	begin
		case (state) is

			when wrfifoa	=>
				i_wr	<= '1';
				i_acqin	<= '1';

			when others	=>
				i_wr	<= '0';
				i_acqin	<= '0';
			
		end case;
	end process;
	
	output_register:
	process (clk, rst)
	begin
		if (rst = '1') then
			wr		<= '0';
			acqin	<= '0';
		elsif (rising_edge(clk)) then
			wr		<= i_wr;
			acqin	<= i_acqin;
		end if;
	end process;


end rtl;