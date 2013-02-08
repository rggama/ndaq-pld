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
		signal dclk			: in	std_logic;
		
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
		signal itdc_erflag	: in	std_logic;	-- TDC Error Flag

		-- Trigger
		signal trig_in		: in	std_logic;
		signal trig_rst		: in	std_logic;
		signal start		: out	std_logic;
		
		-- Operation Mode
		signal mode			: in	std_logic; -- '0' for SINGLE, '1' for CONTINUOUS.

		-- Debug
		signal datavalid	: out	std_logic;
		
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

	component sel_tdcfifo
	port
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (25 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (25 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
	end component;

	component tdcfifo
	port
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (28 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
	end component;
	
	-------------
	-- Signals --
	-------------
	
	-- TDC Buffered Flags
	signal r_tdc_ef1 		: std_logic := '1';
	signal r_tdc_ef2 		: std_logic := '1';
	signal r_tdc_irflag		: std_logic := '0';
	--
	signal s_tdc_ef1 		: std_logic := '1';
	signal s_tdc_ef2 		: std_logic := '1';
	signal s_tdc_irflag 	: std_logic := '0';
	--
	signal t_tdc_ef1 		: std_logic := '1';
	signal t_tdc_ef2 		: std_logic := '1';
	--
	signal u_tdc_ef1 		: std_logic := '1';
	signal u_tdc_ef2 		: std_logic := '1';
	--
	signal v_tdc_ef1 		: std_logic := '1';
	signal v_tdc_ef2 		: std_logic := '1';

	-- TDC Readout FSM
	signal ef1				: std_logic;
	signal ef2				: std_logic;
	type sm_tdc 			is (sIdle, sTestEFs, sSelectFIFO, sCSN, sRDdown, sRDup, sReadDone, sTestData);
	signal sm_TDCx 			: sm_tdc;
	attribute syn_encoding	: string;
	attribute syn_encoding 	of sm_tdc : type is "safe";
	signal enable_read		: std_logic := '0';
	signal fifo2_issue		: std_logic := '0';
	signal i_data_valid		: std_logic := '0';
	
	-- Buffered TDC Data
	signal TDC_Data			: std_logic_vector(27 downto 0);

	-- Selection FIFO Write Enable Decoding
	signal tdc_addr			: std_logic_vector(3 downto 0);	
	signal selected_fifo	: std_logic := '0';
	signal channel_sel		: std_logic_vector(2 downto 0) := "000";

	-- Readout Window FSM
	type sm_rwindow_t 		is (idle, window, clear, transfer);
	signal sm_rwindow 		: sm_rwindow_t;
	attribute syn_encoding 	of sm_rwindow_t : type is "safe";
	signal i_clear			: std_logic := '0';
	signal i_transfer		: std_logic := '0';
	signal any_data			: std_logic := '0';
	signal scounter			: std_logic_vector(7 downto 0) := x"00";
	signal triggered		: std_logic := '0';

	-- Reset Window FSM
	signal no_reset			: std_logic := '0';
	type sm_rst_t	 		is (idle, rst_window, reset);
	signal sm_rst	 		: sm_rst_t;
	attribute syn_encoding 	of sm_rst_t : type is "safe";
	signal i_rst			: std_logic := '0';
	signal tcounter			: std_logic_vector(7 downto 0) := x"00";

	-- TDC Reset
	signal tdc_reset		: std_logic := '0';
	
	-- ReSTART
	signal restart			: std_logic := '0';
	
	-- Selection FIFO Signals
	signal sel_sclr			: CTDC_T := x"00";
	signal sel_wr			: CTDC_T := x"00";
	signal sel_ff			: CTDC_T := x"00";
	signal sel_rd			: CTDC_T := x"00";
	signal sel_ef			: CTDC_T := x"00";
	signal sel_usedw		: SEL_USEDW_A;
	signal sel_q			: SEL_A;

	-- Empty Error
	signal empty_error		: CTDC_T := x"00";
	
	-- Readout FIFO Signals
	signal readout_data		: OTDC_A;
	signal channel_wr		: CTDC_T := x"00";
	signal channel_ff		: CTDC_T := x"00";
	
	
		
--
--

begin

-- ************************************************************************* --
	
	--------------------------------------------------
	-- Read Enable Based on Readout FIFOs Full Flag --
	--------------------------------------------------
	
	
	-- enable_read	<=	not(channel_ff(0) or channel_ff(1) or
						-- channel_ff(2) or channel_ff(3) or
						-- channel_ff(4) or channel_ff(5) or
						-- channel_ff(6) or channel_ff(7));

	--
	-- Enable read logic.
	-- process(sm_rst)
	-- begin
		-- if (sm_rst = reset) then
			-- enable_read <= '1';
		-- else
			-- enable_read <= '0';
		-- end if;
	-- end process;
	enable_read <= '1'; --not(tdc_reset); 
	
	----------------------------------------------
	-- Registering ef1, ef2 and irflag - 2 chains.
	----------------------------------------------
	process(rst, clk)
	begin
		if (rst = '1') then
			r_tdc_ef1	 <= '1';
			r_tdc_ef2	 <= '1';
			r_tdc_irflag <= '0';
			--
			s_tdc_ef1	 <= '1';
			s_tdc_ef2	 <= '1';
			s_tdc_irflag <= '0';
			--
			t_tdc_ef1	 <= '1';
			t_tdc_ef2	 <= '1';
			--
			u_tdc_ef1	 <= '1';
			u_tdc_ef2	 <= '1';
			--
			v_tdc_ef1	 <= '1';
			v_tdc_ef2	 <= '1';
		elsif (rising_edge(clk)) then
			r_tdc_ef1	 <= itdc_ef1;
			r_tdc_ef2	 <= itdc_ef2;
			r_tdc_irflag <= itdc_irflag;
			--
			s_tdc_ef1	 <= r_tdc_ef1;
			s_tdc_ef2	 <= r_tdc_ef2;
			s_tdc_irflag <= r_tdc_irflag;
			--
			t_tdc_ef1	 <= s_tdc_ef1;
			t_tdc_ef2	 <= s_tdc_ef2;
			--
			u_tdc_ef1	 <= t_tdc_ef1;
			u_tdc_ef2	 <= t_tdc_ef2;
			--
			v_tdc_ef1	 <= u_tdc_ef1;
			v_tdc_ef2	 <= u_tdc_ef2;
		end if;
	end process;
	
	--
	--
	ef1 <= s_tdc_ef1 or v_tdc_ef1;
	ef2 <= s_tdc_ef2 or v_tdc_ef2;
	
	--------------------------
	-- TDC data readout FSM --
	--------------------------
	process (rst, clk, enable_read, fifo2_issue) begin
		if (rst = '1') then
			otdc_ADR <= "0000";
			otdc_CSN <= '1';
			otdc_RDN <= '1';
			i_data_valid <= '0';
			tdc_addr <= REG8;
			sm_TDCx <= sIdle;
			fifo2_issue	<= '0';

			
		elsif (clk'event and clk = '1') then
			case sm_TDCx is
				
				
				-- Idle
				when sIdle =>
					otdc_ADR <= "0000";
					otdc_CSN <= '1';
					otdc_RDN <= '1';
					i_data_valid <= '0';
					selected_fifo <= '0';

					
					-- -- Se o modo for o CONTINUOUS (mode = '1') n�o h� teste do MTimer. 
					-- if (mode = '1') then
						sm_TDCx <= sSelectFIFO;
					-- Caso contr�rio, se o modo for o SINGLE (mode = '0') o teste do MTimer � feito a seguir:
					-- else
						-- -- Se a IRflag estiver em nivel baixo (MTimer ainda n�o acabou), espere nesse estado.
						-- if (rtdc_irflag = '0') then
							-- sm_TDCx <= sIdle;
						-- -- Se a IRflag estiver em nivel alto, significa que a janela de tempo acabou e a medi��o pode ser lida.
						-- else
							-- sm_TDCx <= sSelectFIFO;
						-- end if;
					-- end if;
								
				
				-- Testa EF1, EF2 e 'enable_read'.
				when sSelectFIFO =>
					otdc_ADR <= "0000";
					otdc_CSN <= '1';
					otdc_RDN <= '1';
					--otdc_Data <= (others => 'Z');
					i_data_valid <= '0';
										
					-- O sinal 'enable_read' fica inativo ('0') quando qualquer uma das 8 FIFOs de 
					-- leitura do TDC (sintetizadas no FPGA) ficam cheias.
					if (enable_read = '1') then	
						--both fifos have data: read fifo1 and issue a fifo2 read for the next cycle.
						if ((ef1 = '0') and (ef2 = '0') and (fifo2_issue = '0')) then
							tdc_addr <= REG8;
							selected_fifo <= '0';
							fifo2_issue	<= '1';
							sm_TDCx <= sCSN;
						--fifo2 have data or fifo2 read issued: read fifo2.
						elsif ((ef2 = '0') or (fifo2_issue = '1')) then
							tdc_addr <= REG9;
							selected_fifo <= '1';
							fifo2_issue	<= '0';
							sm_TDCx <= sCSN;
						--fifo1 have data: read fifo 1.
						elsif (ef1 = '0') then
							tdc_addr <= REG8;
							selected_fifo <= '0';
							fifo2_issue	<= '0';
							sm_TDCx <= sCSN;
						else
							sm_TDCx <= sSelectFIFO;
						end if;
					else
						sm_TDCx <= sSelectFIFO;
					end if;
			

				-- Come�a a Leitura
				when sCSN =>							
					otdc_ADR <= tdc_addr;				-- Address valid
					otdc_CSN <= '0';					-- CS falling edge
					oTDC_RDN <= '1';
					--
					i_data_valid <= '0';
					sm_TDCx <= sRDdown;
									
				-- Leitura
				when sRDdown =>						
					oTDC_ADR <= tdc_addr;				-- Address valid
					oTDC_CSN <= '0';					
					oTDC_RDN <= '0';					-- RD falling edge (25ns after CS falling-edge)
					--
					i_data_valid <= '0';
					sm_TDCx <= sRDup;
									
				-- Leitura
				when sRDup =>							-- CS and RD rising edge
					oTDC_ADR <= tdc_addr;
					oTDC_CSN <= '1';
					oTDC_RDN <= '1';
					--
					i_data_valid <= '1';				-- Write Strobe for the 8 READOUT FIFOs (inside the FPGA)
					sm_TDCx <= sReadDone;
					
				
				-- Leitura (final)
				when sReadDone =>						-- Remove Address and Data
					oTDC_ADR <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_RDN <= '1';
					--
					i_data_valid <= '0';
										
					-- Se o modo for o CONTINUOUS (mode = '1'), deve-se simplesmente ler os dados dispon�veis nas FIFOs do TDC. 
					if (mode = '1') then
						sm_TDCx <= sSelectFIFO;
					-- Caso contr�rio, modo SINGLE, deve-se fazer o teste abaixo:
					else
						sm_TDCx <= sTestData;
					end if;
				
				-- Testa se ainda h� dados na FIFO 1 ou FIFO 2 do TDC.
				when sTestData =>						
					oTDC_ADR <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_RDN <= '1';
					--
					i_data_valid <= '0';
										
					-- Se ainda h� dados nas FIFOs, o ciclo deve come�ar de novo sem Reset e
					-- sem passar pelo teste do MTimber (via IRFlag no estado sIdle).
					if ((ef1 = '0') or (ef2 = '0')) then
						sm_TDCx <= sSelectFIFO;
					-- Caso contr�rio, os resultados das duas FIFOs para uma janela de tempo j� foram lidos.
					-- Deve-se resetar e come�ar do 'sIdle'.
					else	
						sm_TDCx <= sIdle;
					end if;
										
					
				when others =>
					oTDC_ADR <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_RDN <= '1';
					i_data_valid <= '0';
					sm_TDCx <= sIdle;
			end case;
		end if;
	end process;
	
	-----------------------------------------------------------------------------------------
	-- TDC data input buffering  (1 Chain. Change to 2 chains if there is data instability --
	-----------------------------------------------------------------------------------------
	process(rst, clk)
	begin
		if (rst = '1') then
			TDC_Data <= (others => '0');
		elsif rising_edge(clk) then
			TDC_Data <= iTDC_Data;
		end if;
	end process;

	-------------------------------------
	-- TDC data channel WRITE SELECTOR --
	-------------------------------------
	channel_sel	<= selected_fifo & TDC_Data(27 downto 26);
		
	-- Channel Selector Demux
	process(channel_sel, i_data_valid)
	begin
		sel_wr <= (others => '0');
		if (i_data_valid = '1') then
			sel_wr(conv_integer(channel_sel))	<= '1';
		end if;
	end process;

	
-- ************************************************************************* --

	any_data <= not(sel_ef(0)) or not(sel_ef(1)) or not(sel_ef(2)) or not(sel_ef(3)) or
				not(sel_ef(4)) or not(sel_ef(5)) or not(sel_ef(6)) or not(sel_ef(7));
				
				
	------------------------
	-- Readout Window FSM --
	------------------------
	readout_window_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			triggered <= '0';
			--
			scounter <= (others => '0');
			--	
			sm_rwindow <= idle;
			
		elsif (rising_edge(clk)) then
			case sm_rwindow is
				when idle =>
					
					if (any_data = '1') then
						sm_rwindow <= window;
					else
						sm_rwindow <= idle;
					end if;
				
				when window =>
					-- Trigger Buffer (Holder)
					if (trig_in = '1') then
						triggered <= '1'; 
					end if;
					
					-- Window Counter
					scounter <= scounter + 1;
					
					-- WHAT TO DO!?!?!?!
					if (scounter = x"44") then
						scounter <= (others => '0');
						--
						if (triggered = '1') then
							sm_rwindow <= transfer;
							--
							triggered <= '0'; 
						else
							sm_rwindow <= clear;
						end if;
					end if;
									
				when clear =>
					sm_rwindow <= idle;
					--
					scounter <= (others => '0');
					
				when transfer =>
					sm_rwindow <= idle;
					--
					scounter <= (others => '0');
					
			end case;
		end if;
	end process;

	readout_window_fsm_outputs:
	process (sm_rwindow)
	begin
		case (sm_rwindow) is
			
			when idle =>
				i_clear		<= '0';
				i_transfer	<= '0';

				
			when window =>
				i_clear		<= '0';
				i_transfer	<= '0';
			
			when clear =>
				i_clear		<= '1';
				i_transfer	<= '0';
			
			when transfer =>
				i_clear		<= '0';
				i_transfer	<= '1';
				
			when others	=>
				i_clear		<= '0';
				i_transfer	<= '0';

			
		end case;
	end process;
	
-- ************************************************************************* --
					
	-- Reset Inhibit
	process (s_tdc_ef1, s_tdc_ef2, sm_rwindow)
	begin
		if ((s_tdc_ef1 = '0') or (s_tdc_ef2 = '0') or 
			(sm_rwindow = window)) then
			
			no_reset <= '1';
		else
			no_reset <= '0';
		end if;
	end process;
	
	---------------
	-- Reset FSM --
	---------------
	rst_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			--
			tcounter <= (others => '0');
			--	
			sm_rst <= idle;
			
		elsif (rising_edge(clk)) then
			case sm_rst is
				when idle =>
					--
					if (trig_rst = '1') then
						sm_rst <= rst_window;
					else
						sm_rst <= idle;
					end if;
				
				when rst_window =>
					-- Reset Window Counter
					tcounter <= tcounter + 1;
					
					-- WHAT TO DO!?!?!?!
					if (tcounter = x"88") then
						tcounter <= (others => '0');
						--
						if (no_reset = '1') then
							sm_rst <= idle;
						else
							sm_rst <= reset;
						end if;
					end if;
									
				when reset =>
					sm_rst <= idle;
										
			end case;
		end if;
	end process;

	rst_fsm_outputs:
	process (sm_rst)
	begin
		case (sm_rst) is
			
			when idle =>
				i_rst	<= '0';
				
			when rst_window =>
				i_rst	<= '0';
			
			when reset =>
				i_rst	<= '1';
			
			when others	=>
				i_rst	<= '0';
			
		end case;
	end process;

	
-- ************************************************************************* --

	--------------------------------------
	-- TDC Master Reset via ALU Trigger --
	--------------------------------------
	process (clk, rst)
	begin
		if (rst = '1') then
			tdc_reset <= '0';
		elsif (rising_edge(clk)) then
			--if ((i_rst = '1') and (no_reset = '0')) then 
				--tdc_reset <= '1';
			--else
				--tdc_reset <= '0'; 
			--end if;
			tdc_reset <= i_rst;
		end if;
	end process;

	otdc_alutr <= tdc_reset;
	
	--------------------
	-- Restart Signal --
	--------------------
	-- process (clk, rst)
	-- begin
		-- if (rst = '1') then
			-- restart <= '0';
		-- elsif (rising_edge(clk)) then
			-- restart <= tdc_reset;
		-- end if;
	-- end process;
	
	
	------------------
	-- Start Signal --
	------------------
	-- process (clk, rst)
	-- begin
		-- if (rst = '1') then
			-- start <= '0';
		-- elsif (rising_edge(clk)) then
			-- start <= trig_in or restart;
		-- end if;
	-- end process;
	

-- ************************************************************************* --
	
	---------------------------------------------
	-- Separated channels SEL and OUTPUT FIFOs --
	---------------------------------------------	
	channel_out_construct:
	for i in 0 to 7 generate
		
		sel_sclr(i) <= i_clear;
		
		selection_fifo:
		sel_tdcfifo port map
		(
			aclr		=> rst,
			clock		=> clk,
			data		=> TDC_Data(25 downto 0),
			rdreq		=> sel_rd(i),
			sclr		=> sel_sclr(i),
			wrreq		=> sel_wr(i),
			empty		=> sel_ef(i),
			full		=> sel_ff(i),
			q			=> sel_q(i),
			usedw		=> sel_usedw(i)
		);

		-- Selection FIFOs Read Enable
		process (i_transfer, sel_ef)
		begin
			if ((i_transfer = '1') and (sel_ef(i) = '0')) then
				sel_rd(i) <= '1';
			else
				sel_rd(i) <= '0';
			end if;
		end process;
				
		-- Readout FIFOs Write Enable
		process (clk, rst)
		begin
			if (rst = '1') then 
				channel_wr(i) <= '0';
			elsif (rising_edge(clk)) then
				channel_wr(i) <= sel_rd(i);
			end if;
		end process;
		
		-- Empty Error
		empty_error(i) <= not(sel_ef(i));
		
		-- Readout Data
		readout_data(i) <= itdc_irflag & itdc_erflag & empty_error(i) & sel_q(i);
		
		readout_fifo:
		tdcfifo port map
		(
			aclr		=> rst,
			wrclk		=> clk,
			rdclk		=> dclk,
			data		=> readout_data(i),
			wrreq		=> channel_wr(i),
			rdreq		=> channel_rd(i),
			wrfull		=> channel_ff(i),
			rdempty		=> channel_ef(i),
			q			=> channel_out(i)
		);
	end generate channel_out_construct;
	
	
	-----------------------------
	-- otdc_Data Output Buffer --
	-----------------------------
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
	
	------------
	-- DEBUG! --
	------------
	datavalid <= i_data_valid;
--		

end rtl;