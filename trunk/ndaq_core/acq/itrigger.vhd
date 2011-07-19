---------------------------------------------
-- 32-bit counter based on trigger machine --
-- Author: Herman Lima Jr / CBPF		   --
-- Date: 06/12/2010						   --
---------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

use work.acq_pkg.all;				-- ACQ definitions
use work.regs_pkg.all;				-- Registers handling definitions
--
--
entity itrigger is
	port
	(	signal rst					: in std_logic;
		signal clk					: in std_logic;
		signal enable				: in std_logic;
		signal pos_neg				: in std_logic;									-- To set positive ('0') or negative ('1') trigger
		signal data_in				: in signed(data_width-1 downto 0);			-- Signal from the ADC
		signal threshold_rise	: in signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal threshold_fall	: in signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal count_latcher		: buffer std_logic_vector(31 downto 0);	-- Trigger counter
		signal latch_en			: in std_logic;									-- Signal to latch the counter in 8-bit words
		signal rd_en				: in std_logic_vector(3 downto 0);			-- Read enable to read the counter
		signal count_out_HB		: out std_logic_vector(7 downto 0);
		signal count_out_MH		: out std_logic_vector(7 downto 0);
		signal count_out_ML		: out std_logic_vector(7 downto 0);
		signal count_out_LB		: out std_logic_vector(7 downto 0);
		signal trigger_out		: out std_logic;
		signal state_out			: out std_logic_vector(3 downto 0));	
end itrigger;
--
architecture rtl of itrigger is

	signal i_count_latcher	: std_logic_vector(31 downto 0) := x"00000000";
	
	type trig is (s_low, s_high, s_cnt);
	signal current_state, next_state:	trig;

	signal i_count_out_HB		: std_logic_vector(7 downto 0);
	signal i_count_out_MH		: std_logic_vector(7 downto 0);
	signal i_count_out_ML		: std_logic_vector(7 downto 0);
	signal i_count_out_LB		: std_logic_vector(7 downto 0);

	signal i_trigger_out		: std_logic;
	
begin
--
-- Asynchronous assignments of 'next_stateval'
NEXT_STATE_COMB: process (current_state, data_in, threshold_rise, threshold_fall, pos_neg)
begin
	if pos_neg = '0' then
		case current_state is
			when s_low =>
				if (abs(data_in) < threshold_fall) then	-- Wait that signal from the ADC is lower than threshold
					next_state <= s_high;
				else
					next_state <= s_low;
				end if;
			when s_high =>
				if (abs(data_in) > threshold_rise) then	-- When signal from the ADC is higher than threshold, counter is incremented
					next_state <= s_cnt;
				else
					next_state <= s_high;
				end if;
			when s_cnt =>
				next_state <= s_low;
			when others =>
				next_state <= s_low;
		end case;
	else
		case current_state is
			when s_low =>
				if (abs(data_in) > threshold_fall) then	-- Wait that signal from the ADC is higher than threshold
					next_state <= s_high;
				else
					next_state <= s_low;
				end if;
			when s_high =>
				if (abs(data_in) < threshold_rise) then	-- When signal from the ADC is lower than threshold, counter is incremented
					next_state <= s_cnt;
				else
					next_state <= s_high;
				end if;
			when s_cnt =>
				next_state <= s_low;
			when others =>
				next_state <= s_low;
		end case;
	end if;
end process;
--
-- Asynchronous signals
OUTPUT_COMB: process(next_state)
begin
	case next_state is
		when s_low =>
			--i_count_latcher <= i_count_latcher;
			i_trigger_out <= '0';
			state_out <= x"0";
		when s_high =>
			--i_count_latcher <= i_count_latcher;
			i_trigger_out <= '0';
			state_out <= x"1";
		when s_cnt =>
			--i_count_latcher <= i_count_latcher + 1;
			i_trigger_out <= '1';
			state_out <= x"2";
		when others => 
			null;
	end case;
end process;
--
-- Counter itself
COUNTER: process(rst, clk, next_state)
begin
	if rst = '1' then
		i_count_latcher <= x"00000000";
	elsif rising_edge(clk) then  
		if next_state = s_cnt then
			i_count_latcher <= i_count_latcher + 1;
		end if;
	end if;
end process;
--
-- Registered states
STATE_FLOPS: process(rst, clk)
begin
	if rst = '1' then
		current_state <= s_low;
	elsif rising_edge(clk) then
		if enable = '1' then
			current_state <= next_state;
		else
			current_state <= s_low;
		end if;
	end if;
end process;
--
-- Registered signals
OUTPUT_FLOPS: process(rst,clk)
begin
	if rst ='1' then
		count_latcher <= (others => '0');
		trigger_out <= '0';
	elsif rising_edge(clk) then
		count_latcher <= i_count_latcher;
		trigger_out <= i_trigger_out;
	end if;
end process;
--
-- Latching the counter in the internal 8-bit data bus
COUNTER_OUTPUT_LATCH: process(rst,clk,latch_en)
begin
	if rst ='1' then
		i_count_out_HB <= (others => '0');
		i_count_out_MH <= (others => '0');
		i_count_out_ML <= (others => '0');
		i_count_out_LB <= (others => '0');
	elsif rising_edge(clk) then
		if latch_en = '1' then
			i_count_out_HB <= count_latcher(31 downto 24);
			i_count_out_MH <= count_latcher(23 downto 16);
			i_count_out_ML <= count_latcher(15 downto 8);
			i_count_out_LB <= count_latcher(7 downto 0);
		else
			i_count_out_HB <= i_count_out_HB;
			i_count_out_MH <= i_count_out_MH;
			i_count_out_ML <= i_count_out_ML;
			i_count_out_LB <= i_count_out_LB;
		end if;
	end if;
end process;
--
-- Reading the 8-bit counter output data bus
COUNTER_OUTPUT_READOUT: process(rst,clk,rd_en)
begin
	if rst ='1' then
		count_out_HB <= (others => 'Z');
		count_out_MH <= (others => 'Z');
		count_out_ML <= (others => 'Z');
		count_out_LB <= (others => 'Z');
	elsif rising_edge(clk) then
		case rd_en is
			when "1000" =>
				count_out_HB <= i_count_out_HB;
				count_out_MH <= (others => 'Z');
				count_out_ML <= (others => 'Z');
				count_out_LB <= (others => 'Z');				
			when "0100" =>
				count_out_HB <= (others => 'Z');
				count_out_MH <= i_count_out_MH;
				count_out_ML <= (others => 'Z');
				count_out_LB <= (others => 'Z');
			when "0010" =>
				count_out_HB <= (others => 'Z');
				count_out_MH <= (others => 'Z');
				count_out_ML <= i_count_out_ML;
				count_out_LB <= (others => 'Z');				
			when "0001" =>
				count_out_HB <= (others => 'Z');
				count_out_MH <= (others => 'Z');
				count_out_ML <= (others => 'Z');
				count_out_LB <= i_count_out_LB;	
			when others =>
				count_out_HB <= (others => 'Z');
				count_out_MH <= (others => 'Z');
				count_out_ML <= (others => 'Z');
				count_out_LB <= (others => 'Z');
		end case;
	end if;
end process;
end rtl;