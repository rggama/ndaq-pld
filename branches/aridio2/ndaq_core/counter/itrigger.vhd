---------------------------------------------
-- 32-bit counter based on trigger machine --
-- Author: Herman Lima Jr / CBPF		   	 --
-- Date: 06/12/2010						   	 --
---------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use work.core_regs.all;				-- Registers handling definitions
use work.acq_pkg.all;
--
--
entity itrigger is
	port
	(	signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- Trigger
		signal enable				: in	std_logic;
		signal pos_neg				: in	std_logic;								-- To set positive ('0') or negative ('1') trigger
		signal data_in				: in	signed(data_width-1 downto 0);			-- Signal from the ADC
		signal threshold_rise		: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal threshold_fall		: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal trigger_out			: out	std_logic;
		-- Counter
		signal rdclk				: in	std_logic := '0';
		signal rden					: in	std_logic := '0';
		signal fifo_empty			: out	std_logic := '0';
		signal counter_q			: out	std_logic_vector(31 downto 0) := x"00000000";
		-- Debug
		signal state_out			: out	std_logic_vector(3 downto 0)
	);	
end itrigger;
--
architecture rtl of itrigger is

	-- Old Frequency Meter implementation
	-- constant TIME_DIV				: unsigned := x"00BEBC20";
	
--***********************************************************************************************

	-- Timebase PLL was used for the FREQUENCY METER. 
	-- component timebase_pll
	-- PORT
	-- (
		-- areset		: IN STD_LOGIC  := '0';
		-- inclk0		: IN STD_LOGIC  := '0';
		-- c0			: OUT STD_LOGIC ;
		-- locked		: OUT STD_LOGIC 
	-- );
	-- end component;

	component counter_fifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
	end component;

--***********************************************************************************************
	
	signal q_data_in						: signed(data_width-1 downto 0);
	signal r_data_in						: signed(data_width-1 downto 0);
	signal s_data_in						: signed(data_width-1 downto 0);
	
	type trig 								is (s_low, s_high, s_cnt, s_wait);
	signal current_state, next_state		: trig;
	attribute syn_encoding 					: string;
	attribute syn_encoding of trig			: type is "safe, one-hot";

	signal i_trigger_out					: std_logic := '0';
	signal r_trigger_out					: std_logic := '0';
	signal i_dtrigger_out					: std_logic := '0';
	signal r_dtrigger_out					: std_logic := '0';
	signal l_trigger_out					: std_logic := '0';
	
	signal l_counter						: std_logic_vector(3 downto 0) := x"0";
	
	--signal locked							: std_logic := '0';
	--signal timebase_clk					: std_logic := '0';
	--signal timebase_div					: std_logic_vector(31 downto 0) := x"00000000";
	--signal timebase_en					: std_logic;
	--signal r_timebase_en					: std_logic := '0';
	signal i_counter						: std_logic_vector(31 downto 0) := x"00000000";
	--signal counter_reg					: std_logic_vector(31 downto 0);
	--signal reg_wait						: std_logic := '0';
	
	signal fifo_full						: std_logic	:= '0';
	signal fifo_wen							: std_logic := '0';
	
begin

--***********************************************************************************************

--
-- Data input Registers (double FF sync. chain)
DATAIN_REGS: process(rst, clk)
begin
	if (rst = '1') then
		s_data_in	<= (others => '0');
		r_data_in	<= (others => '0');
	elsif rising_edge(clk) then
		s_data_in	<= data_in;
		r_data_in	<= s_data_in;
	end if;
end process;

--
-- Asynchronous assignments of 'next_stateval'
NEXT_STATE_COMB: process (current_state, r_data_in, threshold_rise, threshold_fall, pos_neg)
begin
	if (pos_neg = '0') then
		case current_state is
			when s_low =>
				--if (abs(r_data_in) < threshold_rise) then	-- Wait that signal from the ADC is lower than threshold
				if (r_data_in < threshold_rise) then	-- Wait that signal from the ADC is lower than threshold
					next_state <= s_high;
				else
					next_state <= s_low;
				end if;
			when s_high =>
				--if (abs(r_data_in) > threshold_rise) then	-- When signal from the ADC is higher than threshold, counter is incremented
				if (r_data_in > threshold_rise) then	-- When signal from the ADC is higher than threshold, counter is incremented
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
				--if (abs(r_data_in) > threshold_rise) then	-- Wait that signal from the ADC is higher than threshold
				if (r_data_in > -(threshold_rise)) then	-- Wait that signal from the ADC is higher than threshold
					next_state <= s_high;
				else
					next_state <= s_low;
				end if;
			when s_high =>
				--if (abs(r_data_in) < threshold_rise) then	-- When signal from the ADC is lower than threshold, counter is incremented
				if (r_data_in < -(threshold_rise)) then	-- When signal from the ADC is lower than threshold, counter is incremented
					next_state <= s_cnt;
				else
					next_state <= s_high;
				end if;
			when s_cnt =>
				next_state <= s_wait; --s_low;
			when s_wait =>
				next_state <= s_low;
			when others =>
				next_state <= s_low;
		end case;
	end if;
end process;
--
-- Unregistered Combinational signals
OUTPUT_COMB: process(next_state)
begin
	case next_state is
		when s_low =>
			i_trigger_out	<= '0';
			i_dtrigger_out	<= '0';
			state_out		<= x"0";
		when s_high =>
			i_trigger_out 	<= '0';
			i_dtrigger_out	<= '0';
			state_out 		<= x"1";
		when s_cnt =>
			i_trigger_out	<= '1';
			i_dtrigger_out	<= '1';
			state_out 		<= x"2";
		when s_wait =>
			i_trigger_out 	<= '0';
			i_dtrigger_out	<= '1';
			state_out 		<= x"3";
		when others => 
			null;
	end case;
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
OUTPUT_FLOPS: process(rst, clk)
begin
	if rst ='1' then
		r_trigger_out	<= '0';
		r_dtrigger_out	<= '0';
	elsif rising_edge(clk) then
		r_trigger_out	<= i_trigger_out;
		r_dtrigger_out	<= i_dtrigger_out;
	end if;
end process;

--trigger_out	<= r_dtrigger_out;	--Trigger out with DOUBLE period
	
--
-- Long Trigger out
--
L_TOUT: process(rst, clk)
begin
	if rst='1' then
		l_trigger_out	<= '0';
		l_counter		<= x"0";
	elsif rising_edge(clk) then
		if (i_trigger_out = '1') then
			l_trigger_out	<= '1';
		end if;
		if ((i_trigger_out = '1') or (l_trigger_out = '1')) then
			if (l_counter = x"7") then
				l_counter		<= x"0";
				l_trigger_out	<= '0';
			else
				l_counter		<= l_counter + 1;
			end if;
		end if;
	end if;
end process;

trigger_out	<= l_trigger_out;	--Trigger out with SEVEN periods
	
--***********************************************************************************************

--
-- Timebase PLL
-- timebase_pll_inst: 
-- timebase_pll PORT MAP 
-- (
	-- areset	=> rst,
	-- inclk0	=> clk,
	-- c0			=> timebase_clk,
	-- locked	=> locked
-- );

--
-- Timebase generator
-- TIMEBASE_GEN: process(rst, timebase_clk)
-- begin
	-- if (rst = '1') then
		-- timebase_div	<= (others => '0');
		-- timebase_en		<= '0';		
	
	-- elsif (rising_edge(timebase_clk)) then  
		-- if (locked = '1') then
			-- if (timebase_div = CONV_STD_LOGIC_VECTOR(TIME_DIV, 32)) then
				-- timebase_div	<= (others => '0');
				-- timebase_en		<= '0';		
			-- else
				-- timebase_div	<= timebase_div + 1;
				-- timebase_en		<= '1';
			-- end if;
		-- end if;
	-- end if;
-- end process;

--
-- Counter itself
COUNTER: process(rst, clk) --, next_state, timebase_en
begin
	if (rst = '1') then
		i_counter		<= (others => '0');
		--r_timebase_en	<= '0';
		
	elsif (rising_edge(clk)) then  
--		if (locked = '1') then
--			if (r_timebase_en = '0') then
--				i_counter	<= (others => '0');
--			
--			elsif ((r_trigger_out = '1') and (r_timebase_en = '1')) then --(next_state = s_cnt) and 
--				i_counter	<= i_counter + 1;
--		
--			end if;			
--		end if;


		--if (locked = '1') then
			--if (r_timebase_en = '0') then
				--i_counter	<= (others => '0');
			
			if (r_trigger_out = '1') then
				i_counter	<= i_counter + 1;
		
			end if;			

		--end if;

		--r_timebase_en		<= timebase_en;		
	end if;
end process;

--
-- Needed for the Freq. Meter implementation.
--
-- -- Counter Register
-- COUNTER_REGISTER: process(rst, clk)
-- begin
	-- if (rst ='1') then
		-- counter_reg <= (others => '0');
		-- reg_wait		<= '0';
	-- elsif (rising_edge(clk)) then

		-- if ((r_timebase_en = '0') and (reg_wait = '0')) then
			-- counter_reg <= i_counter;
			-- reg_wait		<= '1';
		-- end if;
		
		-- if (r_timebase_en = '1') then
			-- reg_wait		<= '0';
		-- end if;

	-- end if;
-- end process;

--***********************************************************************************************

--
-- Register Copier
REGISTER_COPIER: process(rst, clk)
begin
	if (rst ='1') then
		fifo_wen	<= '0';
		
	elsif (rising_edge(clk)) then

		--if ((r_timebase_en = '0') and (reg_wait = '0') and (fifo_full = '0')) then
		if (fifo_full = '0') then
			fifo_wen	<= '1';
		else
			fifo_wen	<= '0';
		end if;
		
	end if;
end process;

--
--Readout FIFO
READOUT_FIFO : counter_fifo PORT MAP 
(
	aclr	 	=> rst,
	data	 	=> i_counter, --counter_reg,
	--data		=> x"AA55",
	rdclk	 	=> rdclk,
	rdreq	 	=> rden,
	wrclk	 	=> clk,
	wrreq	 	=> fifo_wen,
	q	 		=> counter_q,
	rdempty	=> fifo_empty,
	wrfull	=> fifo_full
);

end rtl;
