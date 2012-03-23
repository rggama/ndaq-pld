--------------------------------------------------------------------------------------
--	Centro Brasileiro de Pesquisas Fisicas - CBPF
--	Ministério da Ciência e Tecnologia - MCT
--	Rua Dr. Xavier Sigaud 150, Urca
--
--	Autor: Herman Lima Jr e Herivaldo Maia
--	Diretorio: D:/Projetos/Neutrinos/QuartusII/angratdc
--
--	Rio de Janeiro, 3 de Fevereiro de 2011.
--
--	Notas:
--  01/10/08_1: bits do TDC lidos são de 15..0. Desprezamos o bit mais significativo.
--              para ajuste do Start-Offset, fazer reg5 = 0(startoff1=0), aplicar um 
--              sinal de 12nS, ..... pag-26 datasheet
--  03/02/11_1: Inicio do estudo do código original (Maia) por Herman.
--  04/02/11_1: Alterei a máquina de estado 'sm_TDCx', de forma a simplificar e
--				reduzir o número de estados na configuração inicial dos registradores.
--				Criei os estados 'sInitTDC, sCSN, sWRdown, sWRup, sInitEnd'.
--	08/02/11_1: Removi completamente a máquina de estado 'smAcq', pois era usada
--				somente para cálculos específicos dos detectores 2D.
--  08/02/11_2: Removi diversos sinais relativos à máquina 'smAcq' que não serão mais
--				usados.
--  08/02/11_3: O sinal 'ioTDCBuWEn' é que sinaliza para máquina 'sm_TDCData' ler
--				o barramento de dados do TDC.
--  10/02/11_1: Para se conectar a entrada 'trigger_a' ao pino T_START do TDC, tem-se
--				que colocar o R198=50ohms ou um curto no lugar.
--	10/02/11_2: Troquei o nome do sinal 'ioTDCBuWEn' para 'TDC_DataOK'. 
--------------------------------------------------------------------------------------

library ieee;
library work;
--LIBRARY altera_mf; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--USE altera_mf.altera_mf_components.all;   

use work.tdc_pkg.all;

entity tdc is
	port
	(	
		signal rst				: in 		std_logic;
		signal clk				: in 		std_logic;	-- 40MHz clock
		signal dclk				: in	std_logic;
		
		-------------------
		-- TDC interface --
		-------------------
		signal iotdc_data		: inout	std_logic_vector(27 downto 0);
		signal otdc_stopdis	 	: out	std_logic_vector(1 to 4);
		signal tdc_start_dis 	: out	std_logic;
		signal otdc_rdn		 	: out	std_logic;
		signal otdc_wrn		 	: out  	std_logic;
		signal otdc_csn	 	 	: out	std_logic;
		signal otdc_alutr	 	: out  	std_logic;
		signal otdc_puresn	 	: out  	std_logic;
		signal tdc_oen		 	: out  	std_logic;
		signal otdc_adr		 	: out  	std_logic_vector(3 downto 0);
		signal itdc_irflag	 	: in   	std_logic;
		signal itdc_ef2		 	: in   	std_logic;
		signal itdc_ef1		 	: in   	std_logic;

		-----------------
		-- TDC control --
		-----------------
		signal start_conf		: in	std_logic;	-- Start the configuration machine (active high pulse with 2-periods width)
		signal conf_done		: out	std_logic;
		signal otdc_data		: out	std_logic_vector(27 downto 0);
		signal channel_ef		: out	CTDC_T;
		signal channel_rd		: in	CTDC_T;
		signal channel_out		: out	OTDC_A
	);
end tdc;

architecture one_tdc of tdc is 

	---------------------------------
	-- TDC Configuration component --
	---------------------------------
	component tdcconfig
	port
	( 	rst				: in  	std_logic;
		clk				: in  	std_logic;
		start_conf		: in	std_logic;
		conf_done		: out	std_logic;
		conf_select		: out	std_logic;
		iotdc_data	 	: inout std_logic_vector(27 downto 0);
		otdc_stopdis	: out	std_logic_vector(1 to 4);
		otdc_wrn		: out  	std_logic;
		otdc_csn	 	: out	std_logic;
		otdc_puresn	 	: out  	std_logic;
		tdc_oen		 	: out  	std_logic;
		otdc_adr		: out  	std_logic_vector(3 downto 0);
		itdc_irflag	 	: in   	std_logic
	);
	end component;
	
	---------------------------
	-- TDC Readout component --
	---------------------------	
	component tdcread
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
		-- Readout FIFOs
		signal channel_ef	: out	CTDC_T;
		signal channel_rd	: in	CTDC_T;
		signal channel_out	: out	OTDC_A
	);
	end component;

	-----------------
	-- TDC signals -- 	
	-----------------
	signal tdcCSN_read, tdcCSN_conf	: std_logic;
	signal tdcADR_read, tdcADR_conf	: std_logic_vector(3 downto 0);	
	signal conf_select : std_logic;

begin
 
	-- TEMPORARY ASSIGNMENTS !!! IMPROVE IT LATER !!!
	tdc_start_dis <= '0';
	
	-----------------------------------------
	-- TDC: control and buses multiplexing --
	-----------------------------------------	
	otdc_csn	<= tdcCSN_read when conf_select = '0' else
				 tdcCSN_conf;
	otdc_adr 	<= tdcADR_read when conf_select = '0' else
				 tdcADR_conf;

	------------------------------------------
	-- TDC: registers configuration (40MHz) --
	------------------------------------------
	TDC_INIT: tdcconfig port map (
		rst				=> rst,
		clk				=> clk,
		start_conf		=> start_conf,
		conf_done		=> conf_done,
		conf_select		=> conf_select,
		iotdc_data		=> iotdc_data,
		otdc_stopdis	=> otdc_stopdis,
		otdc_wrn		=> otdc_wrn,
		otdc_csn	 	=> tdcCSN_conf,
		otdc_puresn	 	=> otdc_puresn,
		tdc_oen		 	=> tdc_oen,
		otdc_adr		=> tdcADR_conf,
		itdc_irflag	 	=> itdc_irflag
	);
	
	--conf_done <= conf_select;
	
	------------------------
	-- TDC: FIFOs readout --
	------------------------
	TDC_READ: tdcread port map (
		rst				=> rst,
		clk				=> clk,
		dclk			=> dclk,
		
		itdc_data		=> iotdc_data, --"00" & "00" & x"000007",
		otdc_data		=> otdc_data,
		otdc_csn		=> tdcCSN_read,
		otdc_rdn		=> otdc_rdn,	
		otdc_adr		=> tdcADR_read,
		otdc_alutr		=> otdc_alutr,
		itdc_irflag		=> itdc_irflag,
		itdc_ef1		=> itdc_ef1, 
		itdc_ef2 		=> itdc_ef2,
		
		channel_ef		=> channel_ef,
		channel_rd		=> channel_rd,
		channel_out		=> channel_out
	);


end one_tdc;