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
		signal th1					: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal th2					: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal trigger_out			: out	std_logic;
		-- Counter
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal counter_q			: out	std_logic_vector(31 downto 0) := x"00000000";
		-- Debug
		signal state_out			: out	std_logic_vector(3 downto 0)
	);	
end itrigger;
--
architecture rtl of itrigger is

	constant TIME_DIV				: unsigned := x"186A0";	--x"F4240"; in microseconds.
	
--***********************************************************************************************

	component timebase_pll
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0			: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;

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
	
	signal s_data_in				: signed(data_width-1 downto 0);
	signal r_data_in				: signed(data_width-1 downto 0);
	
	type trig is (test_edge_a, test_ok, test_edge_b);
	signal current_state, next_state:	trig;

	signal i_trigger_out			: std_logic := '0';
	signal r_trigger_out			: std_logic := '0';

	-- signal i_count_out_HB			: std_logic_vector(7 downto 0) := x"00";
	-- signal i_count_out_MH			: std_logic_vector(7 downto 0) := x"00";
	-- signal i_count_out_ML			: std_logic_vector(7 downto 0) := x"00";
	-- signal i_count_out_LB			: std_logic_vector(7 downto 0) := x"00";
	
	signal locked					: std_logic := '0';
	signal timebase_clk				: std_logic := '0';
	signal timebase_div				: std_logic_vector(19 downto 0) := "00000000000000000000";
	signal timebase_en				: std_logic := '0';
	signal r_timebase_en			: std_logic := '0';
	signal i_counter				: std_logic_vector(31 downto 0) := x"00000000";
	signal counter_reg				: std_logic_vector(31 downto 0) := x"00000000";
	signal reg_wait					: std_logic := '0';
	
	signal fifo_full				: std_logic	:= '0';
	signal fifo_wen					: std_logic := '0';
	
	signal r_fifo_wen				: std_logic := '0';
	
begin

--***********************************************************************************************

--
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
NEXT_STATE_COMB: process (current_state, r_data_in, th1, th2, pos_neg)
begin
	if (pos_neg = '0') then
		case current_state is
			-- when s_low =>
				-- if (r_data_in < threshold_fall) then	-- Wait that signal from the ADC is lower than threshold
					-- next_state <= s_high;
				-- else
					-- next_state <= s_low;
				-- end if;
			-- when s_high =>
				-- if (r_data_in > threshold_rise) then	-- When signal from the ADC is higher than threshold, counter is incremented
					-- next_state <= s_cnt;
				-- else
					-- next_state <= s_high;
				-- end if;
			-- when s_cnt =>
				-- next_state <= s_low;
			-- when others =>
				-- next_state <= s_low;

			-- Test RISE
			when test_edge_a =>
				if (r_data_in > th2) then
					next_state <= test_ok;
				else
					next_state <= test_edge_a;
				end if;
			
			-- Generate Trigger
			when test_ok =>
				next_state	<= test_edge_b;
			
			-- Test FALL
			when test_edge_b =>
				if (r_data_in < th1) then
					next_state <= test_edge_a;
				else
					next_state <= test_edge_b;
				end if;
				
			when others =>
				next_state <= test_edge_a;

		end case;
	else
		case current_state is
			-- when s_low =>
				-- if (r_data_in > threshold_fall) then	-- Wait that signal from the ADC is higher than threshold
					-- next_state <= s_high;
				-- else
					-- next_state <= s_low;
				-- end if;
			-- when s_high =>
				-- if (r_data_in < threshold_rise) then	-- When signal from the ADC is lower than threshold, counter is incremented
					-- next_state <= s_cnt;
				-- else
					-- next_state <= s_high;
				-- end if;
			-- when s_cnt =>
				-- next_state <= s_low;
			-- when others =>
				-- next_state <= s_low;

			-- Test FALL
			when test_edge_a =>
				if (r_data_in < th2) then
					next_state <= test_ok;
				else
					next_state <= test_edge_a;
				end if;
			
			-- Generate Trigger
			when test_ok =>
				next_state	<= test_edge_b;
			
			-- Test RISE
			when test_edge_b =>
				if (r_data_in > th1) then
					next_state <= test_edge_a;
				else
					next_state <= test_edge_b;
				end if;
				
			when others =>
				next_state <= test_edge_a;
		
		end case;
	end if;
end process;

--
-- Unregistered Combinational signals
OUTPUT_COMB: process(next_state)
begin
	case next_state is
		when test_ok =>
			i_trigger_out <= '1';
		when others => 
			i_trigger_out <= '0';
	end case;
end process;

--
-- Registered states
STATE_FLOPS: process(rst, clk)
begin
	if rst = '1' then
		current_state <= test_edge_a;
	elsif rising_edge(clk) then
		if enable = '1' then
			current_state <= next_state;
		else
			current_state <= test_edge_a;
		end if;
	end if;
end process;

--
-- Registered signals
OUTPUT_FLOPS: process(rst, clk)
begin
	if rst ='1' then
		r_trigger_out <= '0';
	elsif rising_edge(clk) then
		r_trigger_out <= i_trigger_out;
	end if;
end process;

trigger_out	<= r_trigger_out;
	
--***********************************************************************************************

--
-- Timebase PLL
timebase_pll_inst: 
timebase_pll PORT MAP 
(
	areset	=> rst,
	inclk0	=> clk,
	c0		=> timebase_clk,
	locked	=> locked
);

--
-- Timebase generator
TIMEBASE_GEN: process(rst, timebase_clk)
begin
	if (rst = '1') then
		timebase_div	<= (others => '0');
		timebase_en		<= '0';		
	
	elsif (rising_edge(timebase_clk)) then  
		if (locked = '1') then
			if (timebase_div = CONV_STD_LOGIC_VECTOR(TIME_DIV, 20)) then
				timebase_div	<= (others => '0');
				timebase_en		<= '0';		
			else
				timebase_div	<= timebase_div + 1;
				timebase_en		<= '1';
			end if;
		end if;
	end if;
end process;

--
-- Counter itself
COUNTER: process(rst, clk) --, next_state, timebase_en
begin
	if (rst = '1') then
		i_counter		<= (others => '0');
		r_timebase_en	<= '0';
		
	elsif (rising_edge(clk)) then  
		if (locked = '1') then
			if (r_timebase_en = '0') then
				i_counter	<= (others => '0');
			
			elsif ((r_trigger_out = '1') and (r_timebase_en = '1')) then --(next_state = s_cnt) and 
				i_counter	<= i_counter + 1;
		
			end if;			
		end if;
		r_timebase_en		<= timebase_en;		
	end if;
end process;

--
-- Counter Register
COUNTER_REGISTER: process(rst, clk)
begin
	if (rst ='1') then
		counter_reg <= (others => '0');
		reg_wait		<= '0';
	elsif (rising_edge(clk)) then

		if ((r_timebase_en = '0') and (reg_wait = '0')) then
			counter_reg <= i_counter;
			reg_wait		<= '1';
		end if;
		
		if (r_timebase_en = '1') then
			reg_wait		<= '0';
		end if;

	end if;
end process;

--***********************************************************************************************

--
-- Register Copier
REGISTER_COPIER: process(rst, clk)
begin
	if (rst ='1') then
		fifo_wen	<= '0';
		r_fifo_wen	<= '0';
		
	elsif (rising_edge(clk)) then

		if ((r_timebase_en = '0') and (reg_wait = '0') and (fifo_full = '0')) then
			fifo_wen	<= '1';
		else
			fifo_wen	<= '0';
		end if;
		
		r_fifo_wen	<= fifo_wen;
		
	end if;
end process;

--
--Readout FIFO
READOUT_FIFO : counter_fifo PORT MAP 
(
	aclr	 	=> rst,
	data	 	=> counter_reg,
	rdclk	 	=> rdclk,
	rdreq	 	=> rden,
	wrclk	 	=> clk, --fifo_wen, --not(r_timebase_en),
	wrreq	 	=> r_fifo_wen,
	q	 		=> counter_q,
	rdempty		=> fifo_empty,
	wrfull		=> fifo_full
);

end rtl;