-- $ FIFO Read and Output Streamer. (TX streamer)
-- v: 0.3
-- 
-- 0.1	Changed to 10 bits width to match NDAQ requirements.
--
-- 0.2	Changed everything to 'std_logic_vector'.
--
-- 0.3 	Changed to handle just one fifo path (pre+post), one channel.
--		Making this module parameterizable:
--
--		New parameters:
--
--			@ 'RMIN'	: Read is prohibited if 'usedw' < 'RMIN'
--			@ 'ESIZE'	: Number of samples (words) to build an event. 
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--

entity readfifo is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
	
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal rd				: out	std_logic;	
		signal q				: in	std_logic_vector(9 downto 0);
				
		signal usedw			: in	std_logic_vector(9 downto 0);
		
		signal wro				: out	std_logic;
		signal dwait 			: in	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0);
		
		-- Parameters
		
		signal rmin				: in 	std_logic_vector(9 downto 0);
		signal esize			: in	std_logic_vector(9 downto 0)
	);
end readfifo;

--

architecture rtl of readfifo is

	component opndrn
    port 
    (
		a_in : in std_logic;
		a_out : out std_logic 
    );
	end component;
	
	signal wr		: std_logic;
	signal dwait_r	: std_logic;
	signal scounter	: std_logic_vector(9 downto 0);
	
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, 	
						rdfifoa, rdfifod,
						wrlo0a, wrlo0d, wrhi0a, wrhi0d,
						test, pre
						);

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe";

--

begin

	opendrain:
	opndrn port map
    (
		a_in 	=> wr,
		a_out 	=> wro
    );

--	process (clk) 
--	begin
--		if (rising_edge(clk)) then
			dwait_r <= dwait;
--		end if;
--	end process;

	readfifofsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			scounter <= "0000000000";
			--	
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
				when idle =>
					isidle  <= '1';
					--
					wr		<= '1';
					rd		<= '0';
					odata	<= "ZZZZZZZZ";
					scounter	<= "0000000000";
					--
					if ((enable = '1') and (dwait_r = '0')
						and (usedw > rmin)) then
						
						state <= rdfifoa;
					else
						state <= idle;
					end if;

				-- FIF0 Read Assert
				when rdfifoa =>
					isidle  <= '0';
					--
					rd    <= '1';
					--
					state <= rdfifod;

				-- FIF0 Read Deassert
				when rdfifod =>
					rd    <= '0';
					--
					state <= wrhi0a; --wrlo0a;

				-- FIFO Write 0 Assert	
				when wrlo0a =>
					wr    <= '0';
					odata <= "000000" & q(1 downto 0);	
					--
					if (dwait_r = '1') then
						state <= wrlo0d;
					else
						state <= wrlo0a;
					end if;
				
				-- FIFO Write 0 Deassert
				when wrlo0d =>
					wr    <= '1';
					--
					if (dwait_r = '0') then
						state <= wrhi0a;
					else
						state <= wrlo0d;
					end if;
				
				-- FIFO Write 1 Assert
				when wrhi0a =>
					wr    <= '0';
					odata <= q(9 downto 2);
					--
					if (dwait_r = '1') then
						state <= wrhi0d;
					else
						state <= wrhi0a;
					end if;
				
				-- FIFO Write 1 Deassert
				when wrhi0d =>
					--isidle  <= '1';
					wr    <= '1';
					--
					scounter <= scounter + 1;
					--
					if (scounter = esize) then
						state <= pre;
					else
						state <= test;						
					end if;

				--
								
				when test =>
					if ((enable = '1') and (dwait_r = '0')) then
						state <= rdfifoa;
					else
						state <= test;
					end if;
					
				when pre =>
					isidle <= '1';
					--
					state <= idle;
			
			end case;
		end if;
	end process;

	
end rtl;