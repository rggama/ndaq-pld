-- 32 Bits Counter for ID
-- v: 0.1
-- 
-- 0.1	Changed 'odata' to 'std_logic_vector'
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity bench0 is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal wro				: out	std_logic;
		signal dwait 			: in	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0)
	);
end bench0;

--

architecture rtl of bench0 is
	
	component opndrn
	port 
    (
		a_in : in std_logic;
		a_out : out std_logic 
    );
	end component;

	signal wr		: std_logic;
	signal dwait_r	: std_logic;
	signal cntr		: std_logic_vector(31 downto 0);
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, 
						wr0a, wr0d, 
						wr1a, wr1d, 
						wr2a, wr2d, 
						wr3a, wr3d,
						inc);

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

--  wro <= wr;
  
--	process (clk) 
--	begin
--		if (rising_edge(clk)) then
			dwait_r <= dwait;
--		end if;
--	end process;

	bench0fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			cntr <= x"00000000";
			--	
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
				when idle =>
					isidle  <= '1';
					--
					wr    <= '1'; --'Z';
					odata <= "ZZZZZZZZ";
					--
					if ((enable = '1') and (dwait_r = '0')) then
						state <= wr0a;
					else
						state <= idle;
					end if;
				
				-- Byte 0	
				when wr0a =>
					isidle  <= '0';
					--
					wr    <= '0';
					odata <= cntr(7 downto 0);
					--
					if (dwait_r = '1') then
						state <= wr0d;
					else
						state <= wr0a;
					end if;
				
				when wr0d =>
					wr    <= '1'; --'Z';
					--
					if (dwait_r = '0') then
						state <= wr1a;
					else
						state <= wr0d;
					end if;
				
				-- Byte 1
				when wr1a =>
					wr    <= '0';
					odata <= cntr(15 downto 8);
					--
					if (dwait_r = '1') then
						state <= wr1d;
					else
						state <= wr1a;
					end if;
				
				when wr1d =>
					wr    <= '1'; --'Z';
					--
					if (dwait_r = '0') then
						state <= wr2a;
					else
						state <= wr1d;
					end if;

				-- Byte 2	
				when wr2a =>
					isidle  <= '0';
					--
					wr    <= '0';
					odata <= cntr(23 downto 16);
					--
					if (dwait_r = '1') then
						state <= wr2d;
					else
						state <= wr2a;
					end if;
				
				when wr2d =>
					wr    <= '1'; --'Z';
					--
					if (dwait_r = '0') then
						state <= wr3a;
					else
						state <= wr2d;
					end if;
				
				-- Byte 3
				when wr3a =>
					wr    <= '0';
					odata <= cntr(31 downto 24);
					--
					if (dwait_r = '1') then
						state <= wr3d;
					else
						state <= wr3a;
					end if;
				
				when wr3d =>
					isidle	<= '0';
					wr    <= '1'; --'Z';
					--
					state <= inc;
					
				when inc =>
					cntr <= cntr + 1;
					--
					state <= idle;

			end case;
		end if;
	end process;

end rtl;