-- Timebase Generator and Timebase Counter.
--

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

--use work.core_regs.all;				-- Registers handling definitions
--use work.acq_pkg.all;

--
--
entity timebase is
	port
	(	signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		--
		signal trigger_in			: in 	std_logic;
		-- Timebase Counter
		signal enable				: in	std_logic;
		signal srst					: in	std_logic;
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal counter_q			: out	std_logic_vector(31 downto 0) := x"00000000"
	);	
end timebase;
--
architecture rtl of timebase is

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
		
	signal timebase_en				: std_logic := '0';
	signal r_timebase_en			: std_logic := '0';
	signal timebase_cntr			: std_logic_vector(31 downto 0) := x"00000000";
	signal r_srst					: std_logic := '0';
	signal int_rst					: std_logic := '0';
	signal r_timebase_cntr			: std_logic_vector(31 downto 0) := x"00000000";
	
	signal fifo_full				: std_logic	:= '0';
	signal fifo_wen					: std_logic := '0';
	
--***********************************************************************************************
	
begin

--***********************************************************************************************

--
-- Timebase Post Scaler - Timebase generator
TIMEBASE_GEN: process(rst, clk)
begin
	if (rst = '1') then
		timebase_en		<= '0';		
	elsif (rising_edge(clk)) then 	
		timebase_en		<= not(timebase_en);		
	end if;
end process;

--
-- Timebase Signal Register
TIMEBASE_SIG_REG: process(rst, clk)
begin
	if (rst = '1') then
		r_timebase_en	<= '0';
	elsif (rising_edge(clk)) then  
		r_timebase_en	<= timebase_en;		
	end if;
end process;

--
-- Timebase Counter
TIMEBASE_COUNTER: process(rst, clk)
begin
	if (rst ='1') then
		timebase_cntr	<= (others => '0');
		r_timebase_cntr	<= (others => '0');
		--
		r_srst			<= '0';
		--
		int_rst			<= '0';
		
	elsif (rising_edge(clk)) then
		
		--	
		r_srst	<= srst;
		
		--
		int_rst <= trigger_in;
		
		--
		if ((r_srst = '1') or (int_rst = '1')) then
			timebase_cntr <= (others => '0');
			
		elsif ((r_timebase_en = '1')) then --(enable = '1') and 
			timebase_cntr	<= timebase_cntr + 1;
		end if;
		
		--
		r_timebase_cntr		<= timebase_cntr;
		
	end if;
end process;

--***********************************************************************************************

--
-- Register Copier
REGISTER_COPIER: process(rst, clk)
begin
	if (rst ='1') then
		fifo_wen	<= '0';
		
	elsif (rising_edge(clk)) then

		if ((enable = '1') and (trigger_in = '1') and (fifo_full = '0')) then
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
	data	 	=> r_timebase_cntr,
	rdclk	 	=> rdclk,
	rdreq	 	=> rden,
	wrclk	 	=> clk,
	wrreq	 	=> fifo_wen,
	q	 		=> counter_q,
	rdempty		=> fifo_empty,
	wrfull		=> fifo_full
);

--
--

end rtl;