---------------------------------------------
-- 32-bit counter --
-- Author: Herman Lima Jr / CBPF		   	 --
-- Date: 06/12/2010						   	 --
---------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use work.tcounter_pkg.all;
--
--
entity tcounter is
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- Counter
		signal trigger_in			: in	std_logic;
		signal enable				: in	std_logic;
		signal srst					: in	std_logic;
		--
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal counter_q			: out	TCOUNTER_DATA_T := x"00000000"
	);	
end tcounter;
--
architecture rtl of tcounter is
	
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
	
	signal r_srst					: std_logic := '0';
	signal i_counter				: TCOUNTER_DATA_T := x"00000000";
	signal counter_reg				: TCOUNTER_DATA_T := x"00000000";
	
	signal fifo_full				: std_logic	:= '0';
	signal fifo_wen					: std_logic := '0';

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
		--
		r_srst			<= '0';
	elsif (rising_edge(clk)) then  
		--
		r_srst	<= srst;
		
		-- Synchronous Reset
		if (r_srst = '1') then
			i_counter	<= (others => '0');
		
		elsif ((enable = '1') and (trigger_in = '1')) then
			i_counter	<= i_counter + 1;
	
		end if;			
	end if;
end process;

--
-- Counter Register
COUNTER_REGISTER: process(rst, clk)
begin
	if (rst ='1') then
		counter_reg <= (others => '0');
	elsif (rising_edge(clk)) then
		counter_reg <= i_counter;
	end if;
end process;

--***********************************************************************************************

--
--Readout FIFO
READOUT_FIFO : counter_fifo PORT MAP 
(
	aclr	 	=> rst,
	data	 	=> counter_reg,
	rdclk	 	=> rdclk,
	rdreq	 	=> rden,
	wrclk	 	=> clk,
	wrreq	 	=> '1',
	q	 		=> counter_q,
	rdempty		=> fifo_empty,
	wrfull		=> fifo_full
);

--
--

end rtl;