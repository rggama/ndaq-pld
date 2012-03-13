-- TDC Reader and Output Streamer. (TX streamer)
-- v: 0.0
--
-- Based on the 32 bits counter reader on MPD (container version) project.
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity readtdc is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
	
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal data_valid		: in	std_logic;
		
		signal rd_en			: out 	std_logic := '0';						-- Signal to latch the counter in 8-bit words
		signal rd_stb			: out 	std_logic_vector(3 downto 0) := "0000";	-- Read enable to read the counter
		
		signal wro				: out	std_logic;
		signal dwait 			: in	std_logic
	);
end readtdc;

--

architecture rtl of readtdc is

	component opndrn
    port 
    (
		a_in : in std_logic;
		a_out : out std_logic 
    );
	end component;
	
	signal wr		: std_logic;
	signal dwait_r	: std_logic;
	
	
	-- Build an enumerated type for the state machine
	type state_type is (idle,
						rd_en_a, 	
						rd0_a, rd1_a, rd2_a, rd3_a,
						wr0_a, wr1_a, wr2_a, wr3_a
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

	readcounterfsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			--	
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
				when idle =>
					isidle  	<= '1';
					--
					wr			<= '1';
					rd_en		<= '1';
					rd_stb		<= "0000";
					--
					if ((enable = '1') and (dwait_r = '0')) then		
						
						state <= rd_en_a;
					else
						state <= idle;
					end if;

				-- assert 'rd_en' and wait for 'data_valid'
				when rd_en_a =>
					isidle		<= '0';
					--
					rd_en		<= '0';
					--
					if (data_valid = '0') then
						state		<= rd0_a;
					else
						state		<= rd_en_a;
					end if;

				-- rd_en(0) assert
				when rd0_a =>
					rd_stb		<= "0001";
					--
					state <= wr0_a;

				-- Write (0) assert	
				when wr0_a =>
					wr    		<= '0';
					--
					if (dwait_r = '1') then
						state <= rd1_a;
					else
						state <= wr0_a;
					end if;

				-- rd_en(1) assert
				when rd1_a =>
					wr    		<= '1';
					rd_stb		<= "0010";
					--
					if (dwait_r = '0') then
						state <= wr1_a;
					else
						state <= rd1_a;
					end if;

				-- Write (1) assert	
				when wr1_a =>
					wr    		<= '0';
					--
					if (dwait_r = '1') then
						state <= rd2_a;
					else
						state <= wr1_a;
					end if;

				-- rd_en(2) assert
				when rd2_a =>
					wr    		<= '1';
					rd_stb		<= "0100";
					--
					if (dwait_r = '0') then
						state <= wr2_a;
					else
						state <= rd2_a;
					end if;

				-- Write (2) assert	
				when wr2_a =>
					wr    		<= '0';
					--
					if (dwait_r = '1') then
						state <= rd3_a;
					else
						state <= wr2_a;
					end if;

				-- rd_en(3) assert
				when rd3_a =>
					wr    		<= '1';
					rd_stb		<= "1000";
					--
					if (dwait_r = '0') then
						state <= wr3_a;
					else
						state <= rd3_a;
					end if;

				-- Write (2) assert	
				when wr3_a =>
					wr    		<= '0';
					--
					if (dwait_r = '1') then
						state <= idle;
					else
						state <= wr3_a;
					end if;
								
			end case;
		end if;
	end process;
	
end rtl;