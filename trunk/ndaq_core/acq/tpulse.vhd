-- $Trigger Pulse Generator
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;
--
entity tpulse is
	port
	(	signal rst			: in	std_logic;
		signal clk	        : in	std_logic;
		signal enable		: in	std_logic;
		signal trig_in      : in	std_logic;
		signal trig_out     : out	std_logic := '0';
		signal delayedtrig_out     : out	std_logic := '0'
	);
end tpulse;
--
architecture rtl of tpulse is

	-- Build an enumerated type for the state machine
	type pdet_state_t	is (idle, p_low, p_high);

	-- Register to hold the current state
	signal pdet_state	: pdet_state_t := idle;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding	: string;
	attribute syn_encoding of pdet_state_t		: type is "safe, one-hot";
	
	signal	r_trig_in	: std_logic := '0';
	signal	i_trig_out	: std_logic := '0';
	signal	r_enable	: std_logic	:= '0';
	signal	r_delayedtrig_out : std_logic	:= '0';
	signal	s_delayedtrig_out : std_logic	:= '0';
	signal	t_delayedtrig_out : std_logic	:= '0';
	signal	u_delayedtrig_out : std_logic	:= '0';
	signal	v_delayedtrig_out : std_logic	:= '0';
	signal	x_delayedtrig_out : std_logic	:= '0';
	signal	z_delayedtrig_out : std_logic	:= '0';
	signal	a_delayedtrig_out : std_logic	:= '0';
	signal	b_delayedtrig_out : std_logic	:= '0';
	signal	c_delayedtrig_out : std_logic	:= '0';
	signal	d_delayedtrig_out : std_logic	:= '0';
	signal	e_delayedtrig_out : std_logic	:= '0';
	signal	f_delayedtrig_out : std_logic	:= '0';
	signal	g_delayedtrig_out : std_logic	:= '0';
	signal	h_delayedtrig_out : std_logic	:= '0';
	signal	i_delayedtrig_out : std_logic	:= '0';
	

begin

	input_register:
	process (clk, rst)
	begin
		if (rst = '1') then
			r_trig_in	<= '0';
			r_enable	<= '0';
		elsif (rising_edge(clk)) then
			r_trig_in	<= trig_in;
			r_enable	<= enable;
		end if;
	end process;
	
	pulse_detect_fsm:
	process (rst,clk) begin
		if (rst = '1') then
			pdet_state <= idle;
		elsif (clk'event and clk = '1') then
				case (pdet_state) is
						
					when idle =>
						if ((r_trig_in = '1') and (r_enable = '1')) then
							pdet_state	<=	p_high;
						else
							pdet_state	<=	idle;
						end if;
												
					when p_high =>
						pdet_state	<=	p_low; --idle;

					when p_low =>
						if (r_trig_in = '0') then	--and (r_enable = '1')
							pdet_state	<=	idle;
						else
							pdet_state	<=	p_low;
						end if;
	
					when others =>
						pdet_state	<=	idle;
				
				end case;
		end if;
	end process;
	
	fsm_outputs:
	process (pdet_state)
	begin
		case (pdet_state) is

			when p_high	=>
				i_trig_out	<= '1';

			when others	=>
				i_trig_out	<= '0';
			
		end case;
	end process;
	
	output_register:
	process (clk, rst)
	begin
		if (rst = '1') then
			trig_out	<= '0';
		elsif (rising_edge(clk)) then
			trig_out	<= i_trig_out;
			r_delayedtrig_out <= i_trig_out;
			s_delayedtrig_out <= r_delayedtrig_out;
			t_delayedtrig_out <= s_delayedtrig_out;
			u_delayedtrig_out <= t_delayedtrig_out;
			v_delayedtrig_out <= u_delayedtrig_out;
			x_delayedtrig_out <= v_delayedtrig_out;
			z_delayedtrig_out <= x_delayedtrig_out;
			a_delayedtrig_out <= z_delayedtrig_out;
			b_delayedtrig_out <= a_delayedtrig_out;
			c_delayedtrig_out <= b_delayedtrig_out;
			d_delayedtrig_out <= c_delayedtrig_out;
			e_delayedtrig_out <= d_delayedtrig_out;
			f_delayedtrig_out <= e_delayedtrig_out;
			g_delayedtrig_out <= f_delayedtrig_out;
			h_delayedtrig_out <= g_delayedtrig_out;
			i_delayedtrig_out <= h_delayedtrig_out;
			delayedtrig_out <= (a_delayedtrig_out or b_delayedtrig_out or c_delayedtrig_out or d_delayedtrig_out or e_delayedtrig_out);
		end if;
	end process;
	
end rtl;