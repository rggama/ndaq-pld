-- $ FIFO Writer
-- v: 0.2
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

--

entity writefifo is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rclk				: in	std_logic; -- clock from reset generator domain
		
		signal acqin			: out 	std_logic := '0';
	
		signal trig0 			: in	std_logic;
		signal trig1 			: in	std_logic;
		signal trig2			: in	std_logic;

		signal wr				: out	std_logic := '0';
				
		signal usedw			: in	std_logic_vector(9 downto 0);
		
		-- Parameters
		
		signal wmax				: in	std_logic_vector(9 downto 0); 	-- same size of 'usedw'
		signal esize			: in	std_logic_vector(9 downto 0)	-- maximum value must be equal fifo word size (max 'usedw')
	);
end writefifo;

--

architecture rtl of writefifo is

	signal rst_r, rst_l	: std_logic	:= '1';
	signal scounter		: std_logic_vector(9 downto 0);	-- sample counter
	
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, 	
						wrfifoa--, wrfifod
						);

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe";
	
	--
	signal wmax_r, wmax_l	: std_logic_vector(9 downto 0);
	
--

begin

-- ** ACLR (reset) Register Interface 
	process (rclk)
	begin		
		if rising_edge(rclk) then
			rst_r	<= rst;
		end if;
	end process;

	process (clk)
	begin		
		if rising_edge(clk) then
			rst_l	<= rst_r;
		end if;
	end process;
	
-- ** WMAX Register Interface 
	process (rclk)
	begin		
		if rising_edge(rclk) then
			wmax_r	<= wmax;
		end if;
	end process;

	process (clk)
	begin		
		if rising_edge(clk) then
			wmax_l	<= wmax_r;
		end if;
	end process;
--

	writefifofsm:
	process (clk, rst_l)
	begin
		if (rst_l = '1') then
			scounter <= "0000000000";
			--	
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
				when idle =>
					acqin  <= '0';
					--
					wr		<= '0';
					scounter	<= "0000000000";
					--
					if ( ((trig0 = '1') or (trig1 = '1') or (trig2 = '1'))
						and (usedw < wmax_l)) then	-- x"37E"
						
						state <= wrfifoa;
					else
						state <= idle;
					end if;

				-- FIF0 Write Assert (FIFO is deasserted on the 'idle' state)
				when wrfifoa =>
					acqin  <= '1';
					--
					wr    <= '1';
					--
					scounter <= scounter + 1;
					--
					if (scounter = esize) then	-- "0001111111"
						state <= idle;
					else
						state <= wrfifoa;
					end if;

--				-- FIF0 0 and FIFO 1 Write Deassert
--				when wrfifod =>
--					wr    <= '0';
--					--
--					scounter <= scounter + 1;
--					--
--					if (scounter = "0001111111") then
--						state <= idle;
--					else
--						state <= wrfifoa;
--					end if;

			end case;
		end if;
	end process;


end rtl;