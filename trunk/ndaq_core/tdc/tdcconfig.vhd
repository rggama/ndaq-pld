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
--  08/02/11_1:
--------------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.all;
--
entity tdcconfig is
	port
	(
	-- General control signals
	signal rst			: in std_logic;
	signal clk			: in std_logic;	-- 40MHz clock
	signal start_conf	: in std_logic;	-- Start the configuration machine (active high pulse with 2-periods clock width)
	signal conf_done	: out std_logic;	-- Indicates end of configuration (active high pulse) 
	signal conf_select	: out std_logic := '1';
	
	-- TDC inputs/outputs
	signal iotdc_data	 : inout std_logic_vector(27 downto 0);
	signal otdc_stopdis	 : out	 std_logic_vector(1 to 4);
	signal otdc_wrn		 : out  std_logic;	-- TDC Write
	signal otdc_csn	 	 : out	 std_logic;		-- TDC Chip Select
	signal otdc_puresn	 : out  std_logic;	-- TDC Power-up Reset (active low)
	signal tdc_oen		 : out  std_logic;	-- TDC Output Enable (active low)
	signal otdc_adr		 : out  std_logic_vector(3 downto 0) := x"0"; -- TDC Address
	signal itdc_irflag	 : in   std_logic		-- TDC Interrupt flag (active high)
	);
end tdcconfig;
--
architecture one_tdcconfig of tdcconfig is
	
	-- TDC registers address and assigned values
	constant REG0  : std_logic_vector(3 downto 0) := "0000";
	constant REG1  : std_logic_vector(3 downto 0) := "0001";
	constant REG2  : std_logic_vector(3 downto 0) := "0010";
	constant REG3  : std_logic_vector(3 downto 0) := "0011";
	constant REG4  : std_logic_vector(3 downto 0) := "0100";
	constant REG5  : std_logic_vector(3 downto 0) := "0101";
	constant REG6  : std_logic_vector(3 downto 0) := "0110";
	constant REG7  : std_logic_vector(3 downto 0) := "0111";
	constant REG8  : std_logic_vector(3 downto 0) := "1000";
	constant REG9  : std_logic_vector(3 downto 0) := "1001";
	constant REG11 : std_logic_vector(3 downto 0) := "1011";
	constant REG12 : std_logic_vector(3 downto 0) := "1100";
	constant REG14 : std_logic_vector(3 downto 0) := "1110";	
	constant VALOR_REG0  : std_logic_vector(27 downto 0) := x"007fc81"; 
	constant VALOR_REG1  : std_logic_vector(27 downto 0) := x"0000000"; --x"0720620";
	constant VALOR_REG2  : std_logic_vector(27 downto 0) := x"0000002"; -- Modo I
	constant VALOR_REG3  : std_logic_vector(27 downto 0) := x"0000000";
	constant VALOR_REG4  : std_logic_vector(27 downto 0) := x"60000C7";
	constant VALOR_REG5  : std_logic_vector(27 downto 0) := x"0E00000"; --x"0E001E0"; -- MASTER RESET por ALUTRIGGER
	constant VALOR_REG6  : std_logic_vector(27 downto 0) := x"0000000";
	constant VALOR_REG7  : std_logic_vector(27 downto 0) := x"0281FB4"; --Res 82.3045psx --0141fb4 MTIMER = 1us, --"0141F4A";--114ps by LF
	constant VALOR_REG11 : std_logic_vector(27 downto 0) := x"7FF0000"; --x"4000000";
	constant VALOR_REG12 : std_logic_vector(27 downto 0) := x"2000000"; --x"2000000";
	constant VALOR_REG14 : std_logic_vector(27 downto 0) := x"0000000";
	constant Master_Reset : std_logic_vector(27 downto 0) := x"6400000";
	
	signal reg_data		: std_Logic_Vector(7 downto 0);
	signal read_status : std_Logic;
	signal r_data		: std_Logic_Vector(31 downto 0);
	signal dma			: std_Logic_Vector(11 downto 0);
	
   signal rTDCDone 	: std_logic;
   signal rTDCDoneAck : std_logic;

   signal rst_int		: std_logic;
   signal oUSBRD  	: std_logic;
   signal readDataUSB : signed(7 downto 0);

	signal rCanHit : std_Logic;
	
	signal InitCounter : std_logic_vector(3 downto 0);  -- Herman
	signal TDC_Addr		: std_logic_vector(3 downto 0);  -- Herman
	signal TDC_Data		: std_logic_vector(27 downto 0); -- Herman

	type state_type is (s_test, s_assert_p0, s_assert_p1, s_check_fall);
	signal state_pulse : state_type;
	attribute syn_encoding : string;	-- Este atributo evita o travamento do projeto no SPRO
	attribute syn_encoding of state_type : type is "safe";
	
	signal start_conf_pulse	: std_logic := '0';

	type sm_tdc is (sPowerUp, sIdle, sInitTDC, sCSN, sWRdown, sWRup, sInitEnd, sConfDone);
	signal sm_TDCx : sm_tdc;
	--attribute syn_encoding : string;	-- Este atributo evita o travamento do projeto no SPRO
	attribute syn_encoding of sm_tdc : type is "safe";
	
	-- TEMPORARY SIGNALS !!!!!!!!!!!!
	signal start_in 		: std_logic;
	signal r_fifo	 		: std_logic;
	signal reset	 		: std_logic;
	signal rWaitAftEvent 	: std_logic_vector(7 downto 0);
	signal contagem		 	: std_logic_vector(1 downto 0);
	
	-- Reset Counter
	signal ResetCounter		: std_logic_vector(3 downto 0) := x"0";
	
begin

	tdc_oen <= '1';

	--------------------------------------------------------------
	-- Generates a 2 clock periods pulse from start_conf signal --
	--------------------------------------------------------------
	process (rst,clk) begin
		if (rst = '1') then
			state_pulse <= s_test;

		elsif (clk'event and clk = '1') then
				case state_pulse is
						
					when s_test =>
						if (start_conf = '1') then
							state_pulse <= s_assert_p0;
							start_conf_pulse <= '1';
						else
							state_pulse <= s_test;
							start_conf_pulse <= '0';
						end if;
						
					when s_assert_p0 =>
						start_conf_pulse <= '1';
						state_pulse <= s_assert_p1;
						
					when s_assert_p1 =>
						start_conf_pulse <= '0';
						state_pulse <= s_check_fall;

					when s_check_fall =>
						if (start_conf = '0') then
							state_pulse <= s_test;
						else
							state_pulse <= s_check_fall;
						end if;
	
					when others =>
						state_pulse <= s_test;
				
				end case;
		end if;
	end process;
	
	--conf_done <= start_conf_pulse;
	-------------------------------------------------------
	-- TDC registers configuration and readout handshake --
	-------------------------------------------------------
	process (rst, clk, start_in, rTDCDone, r_fifo) begin
		if (rst = '1') then
			sm_TDCx <= sIdle; --sPowerUp;
			oTDC_Adr <= (others => '0');
			oTDC_CSN <= '1';
			oTDC_WRN <= '1';
			ioTDC_Data <= (others => 'Z');
			InitCounter <= (others => '0');
			oTDC_StopDis <= "0000";
			conf_done <= '0';
			ResetCounter <= x"0";
			
		elsif (clk'event and clk = '1') then
			case sm_TDCx is
				when sIdle =>
					oTDC_PuResN <= '1';
					InitCounter <= (others => '0');
					oTDC_Adr <= "0000";
					oTDC_StopDis <= "0000";
					conf_done <= '0';
					conf_select <= '1';

					if start_conf_pulse = '1' then
						sm_TDCx <= sPowerUp; --sInitTDC;
					else
						sm_TDCx <= sIdle; --sm_TDCx;
					end if;

				-- It is a RESET state.
				when sPowerUp =>
					oTDC_PuResN <= '0';
					InitCounter <= (others => '0');
					oTDC_Adr <= "0000";
					oTDC_StopDis <= "0000";
					conf_done <= '0';
					conf_select <= '1';			
					-- Reset Counter
					ResetCounter <= ResetCounter + 1;
				
					if (ResetCounter = x"F") then
						sm_TDCx <= sInitTDC; --sIdle;
					else
						sm_TDCx <= sPowerUp;
					end if;
								
				when sInitTDC =>
					case InitCounter is
						when x"0" =>					-- sRingEdges
							TDC_Addr <= REG0;
							TDC_Data <= VALOR_REG0;
						when x"1" =>					-- sAdjBits
							TDC_Addr <= REG1;
							TDC_Data <= VALOR_REG1;
						when x"2" =>					-- sSetMode
							TDC_Addr <= REG2;
							TDC_Data <= VALOR_REG2;
						when x"3" =>					-- sSetTTL
							TDC_Addr <= REG3;
							TDC_Data <= VALOR_REG3;
						when x"4" =>					-- sMTimer
							TDC_Addr <= REG4;
							TDC_Data <= VALOR_REG4;
						when x"5" =>					-- sStartOffset
							TDC_Addr <= REG5;
							TDC_Data <= VALOR_REG5;
						when x"6" =>					-- sECLImp
							TDC_Addr <= REG6;
							TDC_Data <= VALOR_REG6;
						when x"7" =>					-- sRes
							TDC_Addr <= REG7;
							TDC_Data <= VALOR_REG7;
						when x"8" =>					-- sPLLStatus
							TDC_Addr <= REG11;
							TDC_Data <= VALOR_REG11;
						when x"9" =>					-- sMTimerStatus
							TDC_Addr <= REG12;
							TDC_Data <= VALOR_REG12;
						when x"A" =>					-- sREG14
							TDC_Addr <= REG14;
							TDC_Data <= x"0000000";
						when x"B" =>					-- sReset
							TDC_Addr <= REG4;
							TDC_Data <= x"6400000";
						when others =>
							TDC_Addr <= (others => '0');
							TDC_Data <= (others => 'Z');
					end case;
					oTDC_PuResN <= '1';
					oTDC_StopDis <= "1111";
					oTDC_Adr <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_WRN <= '1';
					ioTDC_Data <= (others => 'Z');
					conf_done <= '0';
					sm_TDCx <= sCSN;
				
				when sCSN =>							-- CS falling edge
					oTDC_PuResN <= '1';
					oTDC_Adr <= TDC_Addr;
					oTDC_CSN <= '0';
					oTDC_WRN <= '1';
					ioTDC_Data <= (others => 'Z');
					conf_done <= '0';
					sm_TDCx <= sWRdown;
				
				when sWRdown =>						-- WR falling edge
					oTDC_PuResN <= '1';
					oTDC_Adr <= TDC_Addr;
					oTDC_CSN <= '0';
					oTDC_WRN <= '0';
					ioTDC_Data <= TDC_Data;
					conf_done <= '0';
					sm_TDCx <= sWRup;
				
				when sWRup =>							-- CS and WR rising edge
					oTDC_PuResN <= '1';
					oTDC_Adr <= TDC_Addr;
					oTDC_CSN <= '1';
					oTDC_WRN <= '1';
					ioTDC_Data <= TDC_Data;
					conf_done <= '0';
					sm_TDCx <= sInitEnd;
				
				when sInitEnd =>						-- Remove Address and Data
					oTDC_PuResN <= '1';
					oTDC_Adr <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_WRN <= '1';
					ioTDC_Data <= (others => 'Z');
					InitCounter <= InitCounter + '1';
					conf_done <= '0';
					if (InitCounter < x"B") then 
						sm_TDCx <= sInitTDC;
					else

						conf_select <= '0';
						sm_TDCx <= sConfDone;
					end if;
				
				when sConfDone =>						-- Indicates configuration is done 'conf_done=1'
					oTDC_PuResN <= '1';
					oTDC_StopDis <= "0000";
					oTDC_Adr <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_WRN <= '1';
					ioTDC_Data <= (others => 'Z');
					InitCounter <= (others => '0');
					conf_done <= '1';
					ResetCounter <= x"0";
					if start_conf_pulse = '1' then 
						sm_TDCx <= sPowerUp; --Idle;
					else
						sm_TDCx <= sConfDone; --sm_TDCx;
					end if;
					
				when others =>
					oTDC_PuResN <= '1';
					oTDC_Adr <= (others => 'Z');
					oTDC_CSN <= '1';
					oTDC_WRN <= '1';
					ioTDC_Data <= (others => 'Z');
					conf_done <= '0';
					conf_select <= '0';
					sm_TDCx <= sIdle;
			end case;
		end if;
	end process;					
--
end one_tdcconfig;
	