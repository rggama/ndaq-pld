-- $ Circular Priority Arbiter - 8 channels
-- v: 0.0
--
-- 0.0	First Version (Derived from priarb4 - 4 channels)
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity priarb8 is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal en0	 			: out	std_logic := '0';
		signal en1	 			: out	std_logic := '0';
		signal en2	 			: out	std_logic := '0';
		signal en3	 			: out	std_logic := '0';
		signal en4	 			: out	std_logic := '0';
		signal en5	 			: out	std_logic := '0';
		signal en6	 			: out	std_logic := '0';
		signal en7	 			: out	std_logic := '0';

		signal ii0				: in	std_logic;
		signal ii1				: in	std_logic;
		signal ii2				: in	std_logic;
		signal ii3				: in	std_logic;
		signal ii4				: in	std_logic;
		signal ii5				: in	std_logic;
		signal ii6				: in	std_logic;
		signal ii7				: in	std_logic;

		signal control        	: in	std_logic_vector(7 downto 0)
	);
end priarb8;

--

architecture rtl of priarb8 is
		
	-- Build an enumerated type for the state machine
	type state_type is (idle,	d0enable, d0notidle, d0disable,
								d1enable, d1notidle, d1disable,
								d2enable, d2notidle, d2disable,
								d3enable, d3notidle, d3disable,
								d4enable, d4notidle, d4disable,
								d5enable, d5notidle, d5disable,
								d6enable, d6notidle, d6disable,
								d7enable, d7notidle, d7disable
	
	
	);

	-- Register to hold the current state
	signal state		: state_type;
	
	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe";

	-- Priority encoder result signals
	signal s1,s2,s3,s4,s5,s6,s7,s8	: state_type;
--

begin

	-- Priority Encoder

	s1	 	<=	d0enable when control(0) = '1' else
				d1enable when control(1) = '1' else
				d2enable when control(2) = '1' else
				d3enable when control(3) = '1' else
				d4enable when control(4) = '1' else
				d5enable when control(5) = '1' else
				d6enable when control(6) = '1' else
				d7enable when control(7) = '1' else
				idle;

	s2	 	<=	d1enable when control(1) = '1' else
				d2enable when control(2) = '1' else
				d3enable when control(3) = '1' else
				d4enable when control(4) = '1' else
				d5enable when control(5) = '1' else
				d6enable when control(6) = '1' else
				d7enable when control(7) = '1' else
				idle;

	s3		<=	d2enable when control(2) = '1' else
				d3enable when control(3) = '1' else
				d4enable when control(4) = '1' else
				d5enable when control(5) = '1' else
				d6enable when control(6) = '1' else
				d7enable when control(7) = '1' else
				idle;

	s4		<=	d3enable when control(3) = '1' else
				d4enable when control(4) = '1' else
				d5enable when control(5) = '1' else
				d6enable when control(6) = '1' else
				d7enable when control(7) = '1' else
				idle;


	s5		<=	d4enable when control(4) = '1' else
				d5enable when control(5) = '1' else
				d6enable when control(6) = '1' else
				d7enable when control(7) = '1' else
				idle;

	s6		<=	d5enable when control(5) = '1' else
				d6enable when control(6) = '1' else
				d7enable when control(7) = '1' else
				idle;

	s7		<=	d6enable when control(6) = '1' else
				d7enable when control(7) = '1' else
				idle;

	s8		<=	d7enable when control(7) = '1' else
				idle;


	-- Circular FSM
	
	cfsm8:
	process (clk, rst)
	begin
		if (rst = '1') then
			en0 <= '0';
			en1 <= '0';
			en2 <= '0';
			en3 <= '0';
			en4 <= '0';
			en5 <= '0';
			en6 <= '0';
			en7 <= '0';
			--
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
			--#IDLE
				when idle =>
					en0 	<= '0';
					--
					isidle <= '1';
					--
					if (enable = '1') then
						state <= s1;
					else
						state <= idle;
					end if;
						
			--#0							
				when d0enable =>
					en0 <= '1';
					--
					isidle <= '0';
					--
					-- if it is not idle anymore...
					if (ii0 = '0') then
						state <= d0notidle;
					else
						state <= d0enable;
					end if;
				
				when d0notidle =>
					-- if it is idle back again, we shall finish...
					if (ii0 = '1') then
						state <= d0disable;
					else
						state <= d0notidle;
					end if;
				
				when d0disable =>
					en0 <= '0';
					--
					state	<= s2;

			--#1				
				when d1enable =>
					en1 <= '1';
					--
					-- if it is not idle anymore...
					if (ii1 = '0') then
						state <= d1notidle;
					else
						state <= d1enable;
					end if;
				
				when d1notidle =>
					-- if it is idle back again, we shall finish...
					if (ii1 = '1') then
						state <= d1disable;
					else
						state <= d1notidle;
					end if;
				
				when d1disable =>
					en1 <= '0';
					--
					state <= s3;

			--#2
				when d2enable =>
					en2 <= '1';
					--
					-- if it is not idle anymore...
					if (ii2 = '0') then
						state <= d2notidle;
					else
						state <= d2enable;
					end if;
				
				when d2notidle =>
					-- if it is idle back again, we shall finish...
					if (ii2 = '1') then
						state <= d2disable;
					else
						state <= d2notidle;
					end if;
				
				when d2disable =>
					en2 <= '0';
					--
					state <= s4;

				
			--#3
				when d3enable =>
					en3 <= '1';
					--
					-- if it is not idle anymore...
					if (ii3 = '0') then
						state <= d3notidle;
					else
						state <= d3enable;
					end if;
				
				when d3notidle =>
					-- if it is idle back again, we shall finish...
					if (ii3 = '1') then
						state <= d3disable;
					else
						state <= d3notidle;
					end if;
				
				when d3disable =>
					en3 <= '0';
					--
					state <= s5; --idle;

-----------------------------------------------------------------------------------------

			--#4							
				when d4enable =>
					en4 <= '1';
					--
					-- if it is not idle anymore...
					if (ii4 = '0') then
						state <= d4notidle;
					else
						state <= d4enable;
					end if;
				
				when d4notidle =>
					-- if it is idle back again, we shall finish...
					if (ii4 = '1') then
						state <= d4disable;
					else
						state <= d4notidle;
					end if;
				
				when d4disable =>
					en4 <= '0';
					--
					state	<= s6;

			--#5				
				when d5enable =>
					en5 <= '1';
					--
					-- if it is not idle anymore...
					if (ii5 = '0') then
						state <= d5notidle;
					else
						state <= d5enable;
					end if;
				
				when d5notidle =>
					-- if it is idle back again, we shall finish...
					if (ii5 = '1') then
						state <= d5disable;
					else
						state <= d5notidle;
					end if;
				
				when d5disable =>
					en5 <= '0';
					--
					state <= s7;

			--#6
				when d6enable =>
					en6 <= '1';
					--
					-- if it is not idle anymore...
					if (ii6 = '0') then
						state <= d6notidle;
					else
						state <= d6enable;
					end if;
				
				when d6notidle =>
					-- if it is idle back again, we shall finish...
					if (ii6 = '1') then
						state <= d6disable;
					else
						state <= d6notidle;
					end if;
				
				when d6disable =>
					en6 <= '0';
					--
					state <= s8;

				
			--#7
				when d7enable =>
					en7 <= '1';
					--
					-- if it is not idle anymore...
					if (ii7 = '0') then
						state <= d7notidle;
					else
						state <= d7enable;
					end if;
				
				when d7notidle =>
					-- if it is idle back again, we shall finish...
					if (ii7 = '1') then
						state <= d7disable;
					else
						state <= d7notidle;
					end if;
				
				when d7disable =>
					en7 <= '0';
					--
					state <= idle;

			end case;
		end if;
	end process;

end rtl;