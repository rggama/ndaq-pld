--
--

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tdc_pkg.all;

--
entity tdcread is
	port
	(
		-- General control signals
		signal rst			: in	std_logic;
		signal clk			: in	std_logic;	-- 40MHz clock
		-- TDC inputs/outputs
		signal itdc_data	: in	std_logic_vector(27 downto 0);
		signal otdc_data	: out	std_logic_vector(27 downto 0);
		signal otdc_csn	 	: out	std_logic;		-- TDC Chip Select
		signal otdc_rdn		: out	std_logic;		-- TDC Read strobe
		signal otdc_adr		: out	std_logic_vector(3 downto 0); -- TDC Address
		signal otdc_alutr	: out	std_logic;
		signal itdc_irflag	: in	std_logic;	-- TDC Interrupt flag (active high)
		signal itdc_ef1		: in	std_logic;	-- TDC FIFO-1 Empty flag (active high)
		signal itdc_ef2 	: in	std_logic;	-- TDC FIFO-2 Empty flag (active high)
		-- Readout FIFOs
		signal channel_ef	: out	CTDC_T;
		signal channel_rd	: in	CTDC_T;
		signal channel_out	: out	OTDC_A
	);
end tdcread;

--

architecture rtl of tdcread is
	
	-- Constants
	constant REG8  : std_logic_vector(3 downto 0) := "1000";		-- TDC FIFO 1 Address
	constant REG9  : std_logic_vector(3 downto 0) := "1001";		-- TDC FIFO 2 Address

	-- Components
	component tdcfifo
	port
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (25 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (25 DOWNTO 0)
	);
	end component;
	

	-- Signals
	type sm_tdc is (sIdle, sTestEFs, sSelectFIFO, sCSN, sRDdown, sRDup, sReadDone);
	signal sm_TDCx : sm_tdc;
	attribute syn_encoding : string;
	attribute syn_encoding of sm_tdc : type is "safe";

	signal enable_read		: std_logic := '0';
	signal tdc_addr			: std_logic_vector(3 downto 0);	
	signal selected_fifo	: std_logic := '0';
	signal fifo2_issue		: std_logic := '0';
	signal i_data_valid		: std_logic := '0';
	signal TDC_Data			: std_logic_vector(27 downto 0);
	signal channel_sel		: std_logic_vector(2 downto 0) := "000";
	signal channel_wr		: CTDC_T := x"00";
	signal channel_ff		: CTDC_T := x"00";
	
	
--
--
begin	

	enable_read	<=	not(channel_ff(0) or channel_ff(1) or
						channel_ff(2) or channel_ff(3) or
						channel_ff(4) or channel_ff(5) or
						channel_ff(6) or channel_ff(7));

	----------------------
	-- TDC data readout --
	----------------------
	process (rst, clk, enable_read, fifo2_issue) begin
		if (rst = '1') then
			otdc_ADR <= "0000";
			otdc_CSN <= '1';
			otdc_RDN <= '1';
			--otdc_Data <= (others => 'Z');
			i_data_valid <= '0';
			tdc_addr <= REG8;
			sm_TDCx <= sIdle;
			otdc_alutr <= '0';
			fifo2_issue	<= '0';
		elsif (clk'event and clk = '1') then
			case sm_TDCx is
				when sIdle =>
					otdc_ADR <= "0000";
					otdc_CSN <= '1';
					otdc_RDN <= '1';
					--otdc_Data <= (others => 'Z');
					i_data_valid <= '0';
					otdc_alutr <= '0';
					selected_fifo <= '0';
					-- if enable_read = '0' then	
						-- sm_TDCx <= sTestEFs;
					-- else
						-- sm_TDCx <= sm_TDCx;
					-- end if;
					if enable_read = '1' then	
						sm_TDCx <= sTestEFs;
					else
						sm_TDCx <= sIdle;
					end if;
				
				when sTestEFs =>
					otdc_ADR <= "0000";
					otdc_CSN <= '1';
					otdc_RDN <= '1';
					--otdc_Data <= (others => 'Z');
					i_data_valid <= '0';
					if (itdc_ef1 = '0' or itdc_ef2 = '0') then
						if itdc_irflag = '1' then
							otdc_alutr <= '1'; 	-- TDC reset, keeping the contents of the configuration registers								
							sm_TDCx <= sIdle;
						else
							otdc_alutr <= '0';
							sm_TDCx <= sSelectFIFO;
						end if;
					else
						--sm_TDCx <= sIdle;
						sm_TDCx <= sTestEFs;
					end if;
					
				when sSelectFIFO =>
					otdc_ADR <= "0000";
					otdc_CSN <= '1';
					otdc_RDN <= '1';
					--otdc_Data <= (others => 'Z');
					i_data_valid <= '0';
					otdc_alutr <= '0';
					--both fifos have data: read fifo1 and issue a fifo2 read for the next cycle.
					if itdc_ef1 = '0' and itdc_ef2 = '0' and fifo2_issue = '0' then
						tdc_addr <= REG8;
						selected_fifo <= '0';
						fifo2_issue	<= '1';
					--fifo2 have data or fifo2 read issued: read fifo2.
					elsif itdc_ef2 = '0' or fifo2_issue = '1' then
						tdc_addr <= REG9;
						selected_fifo <= '1';
						fifo2_issue	<= '0';
					--fifo1 have data: read fifo 1.
					elsif itdc_ef1 = '0' then
						tdc_addr <= REG8;
						selected_fifo <= '0';
						fifo2_issue	<= '0';
					else
						null;
					end if;
					sm_TDCx <= sCSN;

				when sCSN =>							
					otdc_ADR <= tdc_addr;				-- Address valid
					otdc_CSN <= '0';					-- CS falling edge
					oTDC_RDN <= '1';
					--otdc_Data <= (others => 'Z');
					i_data_valid <= '0';
					sm_TDCx <= sRDdown;
					otdc_alutr <= '0';
				
				when sRDdown =>						
					oTDC_ADR <= tdc_addr;				-- Address valid
					oTDC_CSN <= '0';					
					oTDC_RDN <= '0';					-- RD falling edge (25ns after CS falling-edge)
					--otdc_Data <= (others => 'Z');
					i_data_valid <= '0';
					sm_TDCx <= sRDup;
					otdc_alutr <= '0';
				
				when sRDup =>							-- CS and RD rising edge
					oTDC_ADR <= tdc_addr;
					oTDC_CSN <= '1';
					oTDC_RDN <= '1';
					--oTDC_Data <= iTDC_Data;				-- Data capture
					i_data_valid <= '0';
					sm_TDCx <= sReadDone;
					otdc_alutr <= '0';
				
				when sReadDone =>						-- Remove Address and Data
					oTDC_ADR <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_RDN <= '1';
					--oTDC_Data <= iTDC_Data;
					i_data_valid <= '1';				-- Data strobe indicating valid data
					otdc_alutr <= '0';
					--if enable_read = '1' then
						sm_TDCx <= sIdle;
					--else
						--sm_TDCx <= sm_TDCx;
					--end if;
				
				when others =>
					oTDC_ADR <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_RDN <= '1';
					--oTDC_Data <= (others => 'Z');
					i_data_valid <= '0';
					sm_TDCx <= sIdle;
					otdc_alutr <= '0';
			end case;
		end if;
	end process;
	
	------------------------------
	-- TDC data input buffering --
	------------------------------
	process(rst, clk)
	begin
		if (rst = '1') then
			TDC_Data <= (others => '0');
		elsif rising_edge(clk) then
			TDC_Data <= iTDC_Data;
		end if;
	end process;

	--------------------------------------------------
	-- TDC data channel selector and output buffers --
	--------------------------------------------------
	channel_sel	<= selected_fifo & TDC_Data(27 downto 26);

	-- Channel Selector Demux
	process(channel_sel, i_data_valid)
	begin
		channel_wr <= (others => '0');
		if (i_data_valid = '1') then
			channel_wr(conv_integer(channel_sel))	<= '1';
		end if;
	end process;

	-- otdc_Data Output Buffer
	process(rst, clk, i_data_valid)
	begin
		if (rst = '1') then
			otdc_Data <= (others => '0');
		elsif rising_edge(clk) then
			if (i_data_valid = '1') then
				otdc_Data <= TDC_Data;
			end if;
		end if;
	end process;

	-- Separated channel buffers
	channel_out_construct:
	for i in 0 to 7 generate
		readout_fifo:
		tdcfifo port map
		(
			aclr		=> rst,
			clock		=> clk,
			data		=> TDC_Data(25 downto 0),
			rdreq		=> channel_rd(i),
			wrreq		=> channel_wr(i),
			empty		=> channel_ef(i),
			full		=> channel_ff(i),
			q			=> channel_out(i)
		);
	end generate channel_out_construct;

--		

end rtl;