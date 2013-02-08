-- $ lvds.vhd
-- LVDS Receiver

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.lvds_pkg.all;

--
--
entity lvds is
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- 
		signal enable				: in	std_logic;
		signal trigger_in			: in	std_logic;
		signal lvds_in				: in	LVDS_DATA_T := x"0000";
		--
		signal t_sel				: in	T_SEL_T;
		signal d_sel				: in	D_SEL_T;
		-- Readout FIFO
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal fifo_full			: out	std_logic;
		signal lvds_q				: out	LVDS_DATA_T := x"0000"
	);	
end lvds;

--

architecture rtl of lvds is
	
	component lvds_fifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN LVDS_DATA_T; --STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT LVDS_DATA_T; --STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
	end component;

--***********************************************************************************************
	
	-- Registered Reset
	signal r_rst					: std_logic := '0';
	
	-- Buffered Trigger
	signal buffered_trigger			: BUFFERED_TRIGGER_T;

	-- Buffered Trigger
	signal buffered_data			: BUFFERED_DATA_A;
	
	-- Registered Trigger Sel
	signal r_t_sel					: T_SEL_T;
	
	-- Registered Data Sel
	signal r_d_sel					: D_SEL_T;

	-- Trigger Mux
	signal trigger					: std_logic := '0';
	
	-- Data Mux
	signal data						: BUFFERED_DATA_T;
	
	-- Registered Trigger Mux
	signal r_trigger				: std_logic := '0'; 
	
	-- Registered Data Mux
	signal r_data					: BUFFERED_DATA_T;
	
--
--
	
begin

--***********************************************************************************************

--
--
rst_reg: process(clk)
begin
	if (rising_edge(clk)) then  
		-- Registered Asynchronous Reset
		r_rst <= rst;
						
		end if;
end process;

--***********************************************************************************************

--
--
buffered_trigger(0) <= trigger_in;

--
--
trigger_buffer_construct:
for i in 1 to (t_stages-1) generate
	
	trigger_buffer:
	process (clk, r_rst)
	begin
		if (r_rst = '1') then
			buffered_trigger(i) <= '0';
		elsif (rising_edge(clk)) then
			buffered_trigger(i) <= buffered_trigger(i-1);
		end if;
	end process;
	
end generate trigger_buffer_construct;

--
--
buffered_data(0) <= lvds_in;

--
--
data_buffer_construct:
for i in 1 to (d_stages-1) generate
	
	data_buffer:
	process (clk, r_rst)
	begin
		if (r_rst = '1') then
			buffered_data(i) <= (others => '0');
		elsif (rising_edge(clk)) then
			buffered_data(i) <= buffered_data(i-1);
		end if;
	end process;
	
end generate data_buffer_construct;

--***********************************************************************************************

--
--
selector_buffer:
process (clk, r_rst)
begin
	if (r_rst = '1') then
		r_t_sel <= (others => '0');
		r_d_sel <= (others => '0');
	elsif (rising_edge(clk)) then
		r_t_sel <= t_sel;
		r_d_sel <= d_sel;
	end if;
end process;

--
-- Trigger Mux
trigger_mux: trigger	<=	buffered_trigger(conv_integer(r_t_sel));

--
-- Data Mux
data_mux: data			<=	buffered_data(conv_integer(r_d_sel));

--***********************************************************************************************

--
--
trigger_mux_buffer:
process (clk, r_rst)
begin
	if (r_rst = '1') then
		r_trigger <= '0';
	elsif (rising_edge(clk)) then
		r_trigger <= trigger;
	end if;
end process;

--
--
data_mux_buffer:
process (clk, r_rst)
begin
	if (r_rst = '1') then
		r_data <= (others => '0');
	elsif (rising_edge(clk)) then
		r_data <= data;
	end if;
end process;

--***********************************************************************************************

--
--Readout FIFO
READOUT_FIFO : lvds_fifo PORT MAP 
(
	aclr	 	=> r_rst,
	data	 	=> r_data,
	rdclk	 	=> rdclk,
	rdreq	 	=> rden,
	wrclk	 	=> clk,
	wrreq	 	=> r_trigger,
	q	 		=> lvds_q,
	rdempty		=> fifo_empty,
	wrfull		=> fifo_full
);

--
--

end rtl;