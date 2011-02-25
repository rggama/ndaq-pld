-- $ Circular Priority Arbiter - 4 channels
-- v: 0.1
--
-- 0.0	First Version
--
-- 0.1	Changed the coding style.
--		Added an explicit priority encoder
--
--


library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity priarb4 is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		--signal enable			: in	std_logic; -- arbiter if
		--signal isidle			: out	std_logic; -- arbiter if

		signal en0	 			: out	std_logic := '0';
		signal en1	 			: out	std_logic := '0';
		signal en2	 			: out	std_logic := '0';
		signal en3	 			: out	std_logic := '0';

		signal ii0				: in	std_logic;
		signal ii1				: in	std_logic;
		signal ii2				: in	std_logic;
		signal ii3				: in	std_logic;

		signal control        	: in	std_logic_vector(7 downto 0)
	);
end priarb4;

--

architecture rtl of priarb4 is
		
	-- Build an enumerated type for the state machine
	type state_type is (idle,	d0enable, d0notidle, d0disable,
								d1enable, d1notidle, d1disable,
								d2enable, d2notidle, d2disable,
								d3enable, d3notidle, d3disable
	);

	-- Register to hold the current state
	signal state		: state_type;
	
	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe";

	-- Priority encoder result signals
	signal s1,s2,s3,s4	: state_type;
--

begin

	-- Priority Encoder

	s1	 	<=	d0enable when control(0) = '1' else
				d1enable when control(1) = '1' else
				d2enable when control(2) = '1' else
				d3enable when control(3) = '1' else
				idle;

	s2	 	<=	d1enable when control(1) = '1' else
				d2enable when control(2) = '1' else
				d3enable when control(3) = '1' else
				idle;

	s3	 	<=	d2enable when control(2) = '1' else
				d3enable when control(3) = '1' else
				idle;

	s4	 	<=	d3enable when control(3) = '1' else
				idle;


	-- Circular FSM
	
	marbfsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			en0 <= '0';
			en1 <= '0';
			en2 <= '0';
			--
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
			--#0
				when idle =>
					en0 <= '0';
					--
--					if (control(0) = '1') then
--						state <= d0enable;
--					elsif (control(1) = '1') then
--						state <= d1enable;
--					elsif (control(2) = '1') then
--						state <= d2enable;
--					elsif (control (3) = '1') then
--						state <= d3enable;
--					else
--						state <= idle;
--					end if;
					
--					case control is
--						when x"01"	=> state <= d0enable;
--						when x"02"	=> state <= d1enable;
--						when x"03"	=> state <= d2enable;
--						when x"04"	=> state <= d3enable;
--						when others	=> state <= d0enable;
--					end case;
					
					state <= s1;
					
								
				when d0enable =>
					en0 <= '1';
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
					-- test __control__ here.

--					if (control(1) = '1') then
--						state <= d1enable;
--					elsif (control(2) = '1') then
--						state <= d2enable;
--					elsif (control (3) = '1') then
--						state <= d3enable;
--					else
--						state <= idle;
--					end if;

					state <= s2;

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
					-- test __control__ here

--					if (control(2) = '1') then
--						state <= d2enable;
--					elsif (control (3) = '1') then
--						state <= d3enable;
--					else
--						state <= idle;
--					end if;

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

--					if (control (3) = '1') then
--						state <= d3enable;
--					else
--						state <= idle;
--					end if;

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
					state <= idle;

			end case;
		end if;
	end process;

end rtl;