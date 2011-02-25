-- Trigger Pulse Generator

library ieee;
use ieee.std_logic_1164.all;
--
entity tpulse is
	port
	(	signal rst			: in std_logic;
		signal clk	        : in std_Logic;
		signal trig_in      : in std_logic;
		signal trig_out     : out std_Logic);
end tpulse;
--
architecture one of tpulse is
	type trig is (s_one, s_two, s_three);
	signal state_trig : trig;
begin
	process (rst,clk) begin
		if (rst = '1') then
			state_trig <= s_one;
			trig_out <= '0';
		elsif (clk'event and clk = '1') then
				case state_trig is
						
					when s_one =>
						if (trig_in = '1') then
							state_trig <= s_two;
							trig_out <= '1';
						else
							state_trig <= s_one;
							trig_out <= '0';
						end if;
						
					when s_two =>
						trig_out <= '0';
						state_trig <= s_three;
						
					when s_three =>
						trig_out <= '0';
						if (trig_in = '0') then
							state_trig <= s_one;
						else
							state_trig <= s_three;
						end if;
	
					when others =>
						trig_out <= '0';
						state_trig <= s_one;
				
				end case;
		end if;
	end process;
end one;