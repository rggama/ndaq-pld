---------------------------------------------------
-- Data multiplexer/reducer with 3 clock latency --
-- Author: Herman Lima Jr / CBPF		             --
-- Date: 22/09/2011						             --
---------------------------------------------------
--
-- Component usage:
-- If 'selector=x"0":	data_out <= data_in(11) & data_in(6 downto 0)
-- If 'selector=x"1":	data_out <= data_in(11) & data_in(7 downto 1)
-- If 'selector=x"2":	data_out <= data_in(11) & data_in(8 downto 2)
-- If 'selector=x"3":	data_out <= data_in(11) & data_in(9 downto 3)
-- If 'selector=x"4":	data_out <= data_in(11 downto 4)
--
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.regs_pkg.all;
--
entity datamux is
	port
	(	signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		signal data_in				: in	signed(ADC_BITS-1 downto 0);			-- Signal from the ADC
		signal data_out_lsb		: out	signed(7 downto 0);						-- Signal to FIFOs and Itrigger (lowest BYTE)
		signal data_out_msb		: out	signed(7 downto 0);						-- Signal to FIFOs and Itrigger (highest BYTE)
		signal selector			: in	std_logic_vector(7 downto 0)			-- Multiplexer selector input
	);	
end datamux;
--
architecture rtl of datamux is
	
	signal	idata			: 	signed(ADC_BITS-1 downto 0);
	signal	odata_lsb	:	signed(7 downto 0);
	signal	odata_msb	:	signed(7 downto 0);
	
	constant	ZEROS			:	signed(15-ADC_BITS downto 0)	:=	(others =>'0');
		
begin
--
-- Data input registers
DATAIN_REGS: process(rst, clk)
begin
	if (rst = '1') then
		idata	<= (others => '0');
	elsif rising_edge(clk) then
		idata	<= data_in;
	end if;
end process;
--
-- Internal bus assignment
MUX_PROC: process (rst,clk)
begin
	if (rst = '1') then
		odata_lsb <= (others => '0');
		odata_msb <= (others => '0');
	elsif rising_edge(clk) then
		case selector(3 downto 0) is
			when x"0" =>															-- No shift on input data: using the LSB of 'data_in'
				odata_lsb <= idata(ADC_BITS-1) & idata(6 downto 0);
				odata_msb <= (others => '0');
			when x"1" =>
				odata_lsb <= idata(ADC_BITS-1) & idata(7 downto 1);
				odata_msb <= (others => '0');
			when x"2" =>
				odata_lsb <= idata(ADC_BITS-1) & idata(8 downto 2);
				odata_msb <= (others => '0');
			when x"3" =>
				odata_lsb <= idata(ADC_BITS-1) & idata(9 downto 3);
				odata_msb <= (others => '0');
			when x"4" =>															-- DEFAULT (defined in 'regs_pkg')
				odata_lsb <= idata(ADC_BITS-1 downto 4);
				odata_msb <= (others => '0');
			when x"5" =>															-- Reading all the ADC bits	
				odata_lsb <= idata(7 downto 0);
				odata_msb <= ZEROS & idata(ADC_BITS-1 downto 8);
			when others =>
				odata_lsb <= idata(ADC_BITS-1 downto 4);
				odata_msb <= (others => '0');
		end case;
	end if;
end process;
--
--	Output data assignment
ASSIGN_PROC: process (rst,clk)
begin
	if (rst = '1') then
		data_out_lsb <= (others => '0');
		data_out_msb <= (others => '0');
	elsif rising_edge(clk) then
		data_out_lsb <= odata_lsb;
		data_out_msb <= odata_msb;
	end if;
end process;
--
end rtl;