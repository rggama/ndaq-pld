--------------------------------------------------------------------------------------
--	Centro Brasileiro de Pesquisas Fisicas - CBPF
--	Ministério da Ciência e Tecnologia - MCT
--	Rua Dr. Xavier Sigaud 150, Urca
--
--	Autor: Herman Lima Jr
--	Diretorio: D:/Projetos/Neutrinos/QuartusII/angratdc
--
--	Rio de Janeiro, 8 de Fevereiro de 2011.
--
--	Notas:
--  18/02/11_1:  Implementei o mesmo mecanismo de latch e leitura em barramento de
--				 8 bits usado no projeto 'counter.vhd', diretorio Monrat.
--------------------------------------------------------------------------------------
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
	signal enable_read	: in	std_logic;	-- Enable the readout machine (active high level)
	signal data_valid	: out	std_logic;	-- Indicates valid data can be read
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
	signal channel_out	: out	OTDC_A;
	-- signal tdc_out_HB	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (HIGHEST Byte)
	-- signal tdc_out_MH	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (MEDIUM HIGH Byte)
	-- signal tdc_out_ML	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (MEDIUM LOW Byte)
	-- signal tdc_out_LB	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (HIGHEST Byte)
	-- signal rd_en			: in	std_logic_vector(3 downto 0)		-- Read enable to read TDC data
	);
end tdcread;
--
architecture one_tdcread of tdcread is

	constant REG8  : std_logic_vector(3 downto 0) := "1000";		-- TDC FIFO 1 Address
	constant REG9  : std_logic_vector(3 downto 0) := "1001";		-- TDC FIFO 2 Address
	
	type sm_tdc is (sIdle, sTestEFs, sSelectFIFO, sCSN, sRDdown, sRDup, sReadDone);
	signal sm_TDCx : sm_tdc;
	attribute syn_encoding : string;
	attribute syn_encoding of sm_tdc : type is "safe";
	
	signal tdc_addr			: std_logic_vector(3 downto 0);
	
	-- signal i_tdc_out_HB		: std_logic_vector(7 downto 0);	-- Internal TDC 8-bit data bus (HIGHEST Byte)
	-- signal i_tdc_out_MH		: std_logic_vector(7 downto 0);	-- Internal TDC 8-bit data bus (MEDIUM HIGH Byte)
	-- signal i_tdc_out_ML		: std_logic_vector(7 downto 0);	-- Internal TDC 8-bit data bus (MEDIUM LOW Byte)
	-- signal i_tdc_out_LB		: std_logic_vector(7 downto 0);	-- Internal TDC 8-bit data bus (LOWEST Byte)
	
	signal selected_fifo	: std_logic := '0';
	signal i_data_valid		: std_logic := '0';
	signal TDC_Data			: std_logic_vector(27 downto 0);
	signal channel_sel		: std_logic_vector(2 downto 0) := "000";
	signal channel_en		: std_logic_vector(7 downto 0) := x"00";
	
	
	----------------------
	-- TDC data readout --
	----------------------
	process (rst, clk, enable_read) begin
		if (rst = '1') then
			otdc_ADR <= "0000";
			otdc_CSN <= '1';
			otdc_RDN <= '1';
			--otdc_Data <= (others => 'Z');
			i_data_valid <= '0';
			tdc_addr <= REG8;
			sm_TDCx <= sIdle;
			otdc_alutr <= '0';
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
					if enable_read = '0' then	
						sm_TDCx <= sTestEFs;
					else
						sm_TDCx <= sm_TDCx;
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
						sm_TDCx <= sIdle;
					end if;
					
				when sSelectFIFO =>
					otdc_ADR <= "0000";
					otdc_CSN <= '1';
					otdc_RDN <= '1';
					--otdc_Data <= (others => 'Z');
					i_data_valid <= '0';
					otdc_alutr <= '0';
					if itdc_ef1 = '0' then
						tdc_addr <= REG8;
						selected_fifo <= '0';
					elsif itdc_ef2 = '0' then
						tdc_addr <= REG9;
						selected_fifo <= '1';	
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
					if enable_read = '1' then
						sm_TDCx <= sIdle;
					else
						sm_TDCx <= sm_TDCx;
					end if;
				
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
	
	data_valid	<= i_data_valid;
	
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
		end if;
	end process;

	--------------------------------------------------
	-- TDC data channel selector and output buffers --
	--------------------------------------------------
	channel_sel	<= selected_fifo & TDC_Data(27 downto 26);

	-- Channel Selector Demux
	process(channel_sel, i_data_valid)
	begin
		channel_en <= (others => '0');
		if (i_data_valid = '1') then
			channel_en(conv_integer(channel_sel))	<= '1';
		end if;
	end process;

	-- otdc_Data Output Buffer
	process(rst, clk, i_data_valid)
	begin
		if (rst = '1') then
			otdc_Data <= (others => '0');
		elsif rising_edge(clk) then
			if (i_data_valid = '1') then
				otdc_Data <= "000" & selected_fifo & TDC_Data;
			end if;
		end if;
	end process;

	-- Separated channel buffers
	channel_out_construct:
	for i in 0 to 7 generate
		channel_buffer:
		process(rst, clk)
		begin
			if (rst = '1') then
				channel_out(i)	<=	(others => '0');
			elsif (rising_edge(clk)) then
				if (channel_en(i) = '1') then
					channel_out(i)	<= TDC_Data(25 downto 0);
				end if;
			end if;
		end process;
	end generate channel_out_construct;

	-- ------------------------------------
	-- -- Reading the 8-bit TDC data bus --
	-- ------------------------------------
	-- process(rst, clk, rd_en)
	-- begin
		-- if rst ='1' then
			-- tdc_out_HB <= (others => 'Z');
			-- tdc_out_MH <= (others => 'Z');
			-- tdc_out_ML <= (others => 'Z');
			-- tdc_out_LB <= (others => 'Z');
		-- elsif rising_edge(clk) then
			-- case rd_en is
				-- when "1000" =>
					-- tdc_out_HB <= i_tdc_out_HB;
					-- tdc_out_MH <= (others => 'Z');
					-- tdc_out_ML <= (others => 'Z');
					-- tdc_out_LB <= (others => 'Z');				
				-- when "0100" =>
					-- tdc_out_HB <= (others => 'Z');
					-- tdc_out_MH <= i_tdc_out_MH;
					-- tdc_out_ML <= (others => 'Z');
					-- tdc_out_LB <= (others => 'Z');
				-- when "0010" =>
					-- tdc_out_HB <= (others => 'Z');
					-- tdc_out_MH <= (others => 'Z');
					-- tdc_out_ML <= i_tdc_out_ML;
					-- tdc_out_LB <= (others => 'Z');				
				-- when "0001" =>
					-- tdc_out_HB <= (others => 'Z');
					-- tdc_out_MH <= (others => 'Z');
					-- tdc_out_ML <= (others => 'Z');
					-- tdc_out_LB <= i_tdc_out_LB;	
				-- when others =>
					-- tdc_out_HB <= (others => 'Z');
					-- tdc_out_MH <= (others => 'Z');
					-- tdc_out_ML <= (others => 'Z');
					-- tdc_out_LB <= (others => 'Z');
			-- end case;
		-- end if;
	-- end process;
--		
end one_tdcread;