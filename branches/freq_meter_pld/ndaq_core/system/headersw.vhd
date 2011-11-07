-- Headers Write Device
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

entity headersw is
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
end headersw;

--

architecture rtl of headersw is

	--component opndrn
  --  port 
  --  (
	--	a_in : in std_logic;
	--	a_out : out std_logic 
  --  );
	--end component;
	
	signal wr		: std_logic;
	signal dwait_r	: std_logic;
	--signal cntr		: signed(15 downto 0);
	
	-- Build an enumerated type for the state machine
	type state_type is (idle, wrloa, wrlod, wrhia, wrhid);

	-- Register to hold the current state
	signal state   : state_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe";

--

begin

	--opendrain:
	--opndrn port map
  --  (
	--	a_in 	=> wr,
	--	a_out 	=> wro
  --  );

  wro <= wr;
  
--	process (clk) 
--	begin
--		if (rising_edge(clk)) then
			dwait_r <= dwait;
--		end if;
--	end process;

	headerswfsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			--	
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
				when idle =>
					isidle  <= '1';
					--
					wr    <= 'Z';
					odata <= "ZZZZZZZZ";
					--
					if ((enable = '1') and (dwait_r = '0')) then
						state <= wrloa;
					else
						state <= idle;
					end if;
				
				-- Lo Byte	
				when wrloa =>
					isidle  <= '0';
					--
					wr    <= '0';
					odata <= x"55";
					--
					if (dwait_r = '1') then
						state <= wrlod;
					else
						state <= wrloa;
					end if;
				
				when wrlod =>
					wr    <= 'Z';
					--
					if (dwait_r = '0') then
						state <= wrhia;
					else
						state <= wrlod;
					end if;
				
				-- Hi Byte
				when wrhia =>
					wr    <= '0';
					odata <= x"AA";
					--
					if (dwait_r = '1') then
						state <= wrhid;
					else
						state <= wrhia;
					end if;
				
				when wrhid =>
					isidle  <= '1';
					wr    <= 'Z';
					--
					state <= idle;

			end case;
		end if;
	end process;

end rtl;