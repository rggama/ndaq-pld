-- $ mcounter.vhd
-- Mighty Counter - The one who see everything.

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use work.mcounter_pkg.all;
use work.tcounter_pkg.all;
--
--
entity mcounter is
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- Counter
		signal trigger_in			: in	std_logic;
		signal hetrigger_in			: in	std_logic;
		signal enable				: in	std_logic;
		signal lock					: in 	std_logic;
		signal srst					: in	std_logic;
		-- Readout FIFO
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal counter_q			: out	MCOUNTER_DATA_T := x"000000000"
	);	
end mcounter;
--
architecture rtl of mcounter is
	
	component mcounter_fifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (35 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
	end component;

--***********************************************************************************************
	
	signal r_srst					: std_logic := '0';
	signal i_counter				: TCOUNTER_DATA_T := x"00000000";
	signal counter_reg				: TCOUNTER_DATA_T := x"00000000";
	
	signal fifo_full				: std_logic	:= '0';
	signal fifo_wen					: std_logic := '0';
	
	signal fifo_data				: MCOUNTER_DATA_T := x"000000000";
	signal r_fifo_wen				: std_logic := '0';
	
	signal r_trigger_in				: std_logic := '0';
	signal s_trigger_in				: std_logic := '0';
	
	signal incremented				: std_logic := '0';
	signal r_incremented			: std_logic := '0';

	signal r_lock					: std_logic := '0';
	signal s_lock					: std_logic := '0';
	signal t_lock					: std_logic := '0'; 

	signal r_hetrigger_in				: std_logic := '0';
	signal s_hetrigger_in				: std_logic := '0';
	signal hetrigger				: std_logic := '0';	
--
--
	
begin

--***********************************************************************************************

--
-- Counter itself
COUNTER: process(rst, clk)
begin
	if (rst = '1') then
		i_counter		<= (others => '0');
		counter_reg		<= (others => '0');
		--
		r_srst			<= '0';
		--
		incremented		<= '0';
		r_incremented	<= '0';
		
	elsif (rising_edge(clk)) then  
		
		-- Registered Synchronous Reset
		r_srst	<= srst;
				
		-- Synchronous Reset
		if (r_srst = '1') then
			i_counter	<= (others => '0');
		
		-- Counter
		elsif ((enable = '1') and (trigger_in = '1')) then
			i_counter	<= i_counter + 1;
			incremented <= '1';
			
		else
			incremented <= '0';
			
		end if;			

		-- Buffered counter
		counter_reg		<= i_counter;

		-- Double Buffered 'trigger_in' input 
		-- Necessary to generate the readout fifo's write enable.
		r_trigger_in <= trigger_in;
		s_trigger_in <= r_trigger_in;
		
		-- Buffered 'incremented': 
		-- Flag that indicates that the counter was incremented.
		r_incremented <= incremented;
		
		-- Quad Buffered 'lock':
		r_lock <= lock;
		s_lock <= r_lock;
		t_lock <= s_lock;
		
		-- 11 bufered hetrigger !!
		r_hetrigger_in <= hetrigger_in;
		s_hetrigger_in <= r_hetrigger_in;
		
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

		if ((r_incremented = '1') and (s_trigger_in = '1') and (fifo_full = '0')) then
			fifo_wen	<= '1';
		else
			fifo_wen	<= '0';
		end if;
		
		r_fifo_wen	<= fifo_wen;
		
	end if;
end process;


--
--
hetrigger <= s_hetrigger_in;
fifo_data <= t_lock & hetrigger & "00" & counter_reg; 

--
--Readout FIFO
READOUT_FIFO : mcounter_fifo PORT MAP 
(
	aclr	 	=> rst,
	data	 	=> fifo_data,
	rdclk	 	=> rdclk,
	rdreq	 	=> rden,
	wrclk	 	=> clk,
	wrreq	 	=> r_fifo_wen,
	q	 		=> counter_q,
	rdempty		=> fifo_empty,
	wrfull		=> fifo_full
);

--
--

end rtl;