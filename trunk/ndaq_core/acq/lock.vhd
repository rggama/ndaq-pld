-- $ lock.vhd
-- v: svn controlled.

-- 
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--use work.acq_pkg.all;
--

entity lock is
	port
	(	
		signal clk				: in 	std_logic; 			-- sync if
		signal rst				: in 	std_logic; 			-- async if
		
		signal enable			: in 	std_logic;
		signal trig_in			: in	std_logic;
		signal acq_in			: in	std_logic_vector(7 downto 0);
		
		signal sys_lock			: out	std_logic;
		signal adc_lock			: out	std_logic			
	);
end lock;

--

architecture rtl of lock is

	--
	--
	signal rst_r		: std_logic	:= '1';

	--
	-- 
	signal r_acq_in		: std_logic_vector(7 downto 0) := x"00";
	signal s_acq_in		: std_logic_vector(7 downto 0) := x"00";
	signal t_acq_in		: std_logic_vector(7 downto 0) := x"00";
	
	--
	--
	signal all_locked	: std_logic := '0';
	signal any_locked	: std_logic := '0';
	
	-- Build an enumerated type for the state machine
	type state_type is (idle,
						half,
						full,
						delay,
						last
						);

	-- Register to hold the current state
	signal state   : state_type := idle;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";
	
	--
	--
	signal tcounter			: std_logic_vector(7 downto 0);
	
	--
	--
	signal i_sys_lock		: std_logic := '0';
	signal i_adc_lock		: std_logic := '0';
--

begin

	--
	-- ** ACLR (reset) Register Interface 
	process (clk)
	begin		
		if rising_edge(clk) then
			rst_r	<= rst;
		end if;
	end process;
	
	--
	-- Triple Buffered 'acq_in'
	process (clk, rst_r)
	begin
		if (rst_r = '1') then
			r_acq_in <= (others => '0');
			s_acq_in <= (others => '0');
			t_acq_in <= (others => '0');
			
		elsif (rising_edge(clk)) then
			r_acq_in <= acq_in;
			s_acq_in <= r_acq_in;
			t_acq_in <= s_acq_in;
		end if;	
	end process;
	
	--
	-- 
	all_locked <=	t_acq_in(0) and t_acq_in(1) and t_acq_in(2) and t_acq_in(3) and 
					t_acq_in(4) and t_acq_in(5) and t_acq_in(6) and t_acq_in(7); 

	any_locked <=	t_acq_in(0) or t_acq_in(1) or t_acq_in(2) or t_acq_in(3) or
					t_acq_in(4) or t_acq_in(5) or t_acq_in(6) or t_acq_in(7);
					
	--
	--
	lock_fsm:
	process (clk, rst_r)
	begin
		if (rst_r = '1') then
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case state is
				when idle =>
					if ((enable = '1') and (trig_in = '1')) then	
						state <= half;
					else
						state <= idle;
					end if;

				-- 
				when half =>
					if ((all_locked = '1')) then	
						state <= full;
					else
						state <= half;
					end if;
					
				-- 
				when full =>
					if ((any_locked = '1')) then	
						state <= full;
					else
						state <= delay;
					end if;
				
				when delay =>
					--tcounter <= tcounter + 1;
					--
					--if (tcounter = x"05") then
						state	<= last; --idle;
						--
					--	tcounter <= (others => '0');
					--else
					--	state <= delay;
					--end if;
				when last =>
						state	<= idle;
						
			end case;
		end if;
	end process;

	fsm_outputs:
	process (state)
	begin
		case (state) is

			when idle	=>
				i_sys_lock	<= '0';
				i_adc_lock	<= '0';

			when half	=>
				i_sys_lock	<= '1';
				i_adc_lock	<= '0';
				
			when full	=>
				i_sys_lock	<= '1';
				i_adc_lock	<= '1';

			when delay	=>
				i_sys_lock	<= '1';
				i_adc_lock	<= '1';
			
			when last	=>
				i_sys_lock	<= '1';
				i_adc_lock	<= '0';

			when others	=>
				i_sys_lock	<= '0';
				i_adc_lock	<= '0';
			
		end case;
	end process;
	
	--adc_lock <= i_adc_lock;
	
	--
	--
	output_register:
	process (clk, rst)
	begin
		if (rst = '1') then
			sys_lock	<= '0';
			adc_lock	<= '0';
		elsif (rising_edge(clk)) then
			sys_lock	<= i_sys_lock;
			adc_lock	<= i_adc_lock;
		end if;
	end process;


end rtl;