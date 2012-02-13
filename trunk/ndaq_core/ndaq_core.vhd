-- $ CORE
-- v: https://ndaq-pld.googlecode.com/svn/trunk
--
-- ****************************************************************************
--
-- Company:			CBPF
-- Author:			Rafael Gama, Herman Lima Jr
--
-- Date:			08 July 2010
-- First Release:	n/a
--
-- ****************************************************************************
--
-- History:
--
-- 0.0.0	First Verion
--
-- 0.0.1	Minor changes in components
--	 to
-- 0.0.12	Minor change in components
--
-- 0.0.13	Changes in 'writefifo' component.
--
-- 0.0.14	Changes in 'dcfifom' component.
--
-- 0.0.15	Changes in 'readfifo' component.
--
-- 0.0.16 	Changes in 	'priarb4' component.
--
-- 0.0.17 	Added 'priarb8' component, changes in 'cmddec' component and
--			8 channels readout implementation.
--
-- 0.0.18	Changes in 'cmddec' component, added 'adcpwdn' register.
--
-- 0.0.19	Changes in 'mtrif' and 'cmddec' component. Added 'BCOUNT' parameter.
--
-- x.x.xx	From this point, versions are controlled by SVN.
--
-- ****************************************************************************

library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).
--use ieee.std_logic_signed.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as signed integers (used together with std_logic_unsigned is ambiguous).
--use ieee.numeric_std.all;		-- altenative to std_logic_arith, used for maths too (will conflict with std_logic_arith if 'signed' is used in interfaces).

use work.functions_pkg.all;
use work.acq_pkg.all;				-- ACQ definitions
use work.core_regs.all;				-- Registers handling definitions
use work.databuilder_pkg.all;


entity ndaq_core is 
	port
	(	
		------------------
		-- Clock inputs --
		------------------
		signal clkcore			:in		std_logic;	-- Same frequency of DCOs (125MHz in first version)
		
		--------------------
		-- ADCs interface --
		--------------------
		signal adc12_data 		:in  	std_logic_vector(11 downto 2);
		signal adc34_data 		:in  	std_logic_vector(11 downto 2);
		signal adc56_data 		:in  	std_logic_vector(11 downto 2);
		signal adc78_data 		:in  	std_logic_vector(11 downto 2);
		
		signal adc12_dco		:in 	std_logic;				-- ADC 1 Data Clock
		signal adc34_dco		:in 	std_logic;				-- ADC 2 Data Clock
		signal adc56_dco		:in 	std_logic;				-- ADC 3 Data Clock
		signal adc78_dco		:in 	std_logic;				-- ADC 4 Data Clock
		
		signal adc12_pwdn		:out	std_logic;				-- ADC 1 Power Down control
		signal adc34_pwdn		:out	std_logic;				-- ADC 2 Power Down control
		signal adc56_pwdn		:out	std_logic;				-- ADC 3 Power Down control
		signal adc78_pwdn		:out	std_logic;				-- ADC 4 Power Down control

		-------------------
		-- TDC interface --
		-------------------
		signal tdc_data			: inout	std_logic_vector(27 downto 0); --***WATCH OUT***
		signal tdc_stop_dis		: out		std_logic_vector(1 to 4);
		signal tdc_start_dis 	: out		std_logic;
		signal tdc_wrn		 	: out		std_logic;
		signal tdc_rdn		 	: out		std_logic;
		signal tdc_csn		 	: out		std_logic;
		signal tdc_alutr	 	: out  	std_logic;
		signal tdc_puresn	 	: out  	std_logic;
		signal tdc_oen		 	: out  	std_logic;
		signal tdc_adr		 	: out  	std_logic_vector(3 downto 0);
		signal tdc_errflag		: in   	std_logic;
		signal tdc_irflag	 	: in   	std_logic;
		signal tdc_lf2		 	: in   	std_logic;
		signal tdc_lf1		 	: in   	std_logic;
		signal tdc_ef2		 	: in   	std_logic;
		signal tdc_ef1		 	: in   	std_logic;

		----------------------
		-- FIFO's interface --
		----------------------
		-- Data Bus
		signal fifo_data_bus 	: out std_logic_vector(31 downto 0);
		
		-- Control signals
		signal fifo_wen	 		: out   std_logic_vector(3 downto 0);	-- Write Enable

		signal fifo_wck			: out	std_logic;	-- Write Clock to all FIFOs (PLL-4 output)
		
		signal fifo_mrs			: out	std_logic;	-- Master Reset
		signal fifo_prs			: out	std_logic;	-- Partial Reset
		signal fifo_fs0			: out	std_logic;	-- Flag Select Bit 0
		signal fifo_fs1			: out	std_logic;	-- Flag Select Bit 1
		signal fifo_ld		 	: out	std_logic;	-- Load
		signal fifo_rt		 	: out	std_logic;	-- Retransmit
		
		-- Flags
		signal fifo1_ff			: in   	std_logic;	-- FULL flag
		signal fifo2_ff			: in   	std_logic;
		signal fifo3_ff			: in   	std_logic;
		signal fifo4_ff			: in   	std_logic;
		
		signal fifo1_ef			: in   	std_logic;	-- EMPTY flag
		signal fifo2_ef			: in   	std_logic;
		signal fifo3_ef			: in   	std_logic;
		signal fifo4_ef			: in   	std_logic;
		
		signal fifo1_hf			: in   	std_logic;	-- HALF-FULL flag
		signal fifo2_hf			: in   	std_logic;
		signal fifo3_hf			: in   	std_logic;
		signal fifo4_hf			: in   	std_logic;
		
		signal fifo_paf	 		: in   	std_logic_vector(3 downto 0);	-- ALMOST-FULL flag
		
		signal fifo1_pae	 	: in   	std_logic;	-- ALMOST-EMPTY flag
		signal fifo2_pae	 	: in   	std_logic;
		signal fifo3_pae	 	: in   	std_logic;
		signal fifo4_pae	 	: in   	std_logic;

		
		--------------------
		-- SRAM interface --
		--------------------
		signal sram_add	 		: out	std_logic_vector(18 downto 0);
		signal sram_data		: inout std_logic_vector(7 downto 0);
		signal sram_we			: out	std_logic;
		signal sram_oe			: out	std_logic;
		signal sram_cs			: out	std_logic;
		
		
		------------------------------
		-- LVDS connector interface --
		------------------------------
		signal lvdsin 		 	:in  	std_logic_vector(15 downto 0);		
		
		---------------
		-- Slave SPI --
		---------------
		signal spiclk			: in	std_logic;
		signal mosi				: in	std_logic;
		signal miso				: out	std_logic;

		--------------------
		-- Trigger inputs --
		--------------------
		signal trigger_a		: in	std_logic;	
		signal trigger_b		: in	std_logic;
		signal trigger_c		: in	std_logic
		
		-----------------------
		-- Temporary signals --
		-----------------------
		--signal mux_sel		: in		std_logic_vector(2 downto 0)
	);
		
end ndaq_core;

architecture rtl of ndaq_core is

	
------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------

	-- Clock Manager
	component core_clkman
	port
	(	
		signal iclk				: in 	std_logic;
		 	
		signal pclk				: out	std_logic;
		signal nclk				: out	std_logic;
		signal mclk				: out	std_logic;
		signal sclk				: out	std_logic;
		signal clk_enable		: out	std_logic;
		signal tclk				: out	std_logic
	);
	end component;
	
	-- Reset Generator
	component rstgen
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		
		signal reset			: in 	std_logic_vector(7 downto 0);
		
		signal rst				: out	std_logic := '1'
	);
	end component;

	-- FIFO Memory Module (1 channel - 1 pre and 1 post)
	component dcfifom
	port
	(	
		signal wrclk			: in 	std_logic; -- write clock
		signal rdclk			: in 	std_logic; -- read clock
		signal rst				: in 	std_logic; -- async reset
		
		signal wr				: in 	std_logic;
		signal d				: in	DATA_T;
		
		signal rd				: in	std_logic;	
		signal q				: out	DATA_T;
		
		signal f				: out	std_logic;	--full flag
		signal e				: out	std_logic;	--empty flag

		signal rdusedw			: out	USEDW_T;	-- used words sync'ed to read clock
		signal wrusedw			: out	USEDW_T	-- used words sync'ed to write clock
	);
	end component;

	-- FIFO Writer
	component writefifo
	port
	(	
		signal clk				: in 	std_logic; 			-- sync if
		signal rst				: in 	std_logic; 			-- async if

		signal enable			: in 	std_logic;
		signal acqin			: out	std_logic := '0';
	
		signal tmode			: in 	std_logic;
		
		signal trig0 			: in	std_logic;
		signal trig1 			: in	std_logic;
		signal trig2			: in	std_logic;
		signal trig3			: in	std_logic;

		signal wr				: out	std_logic := '0';
				
		signal usedw			: in	USEDW_T;
		signal full				: in	std_logic;
		
		-- Parameters
		
		signal wmax				: in	USEDW_T; 			-- same size of 'usedw'
		signal esize			: in	USEDW_T				-- maximum value must be equal fifo word size (max 'usedw')
	);
	end component;

	-- External Trigger Pulse Conditioner
	component tpulse
	port
	(	
		signal rst			  	: in	std_logic;
		signal clk				: in	std_logic;
		signal enable		  	: in	std_logic;		
		signal trig_in		  	: in	std_logic;
		signal trig_out     	: out	std_logic
	);
	end component;

	component itrigger 
	port
	(	signal rst				: in	std_logic;
		signal clk				: in	std_logic;
		-- Trigger
		signal enable			: in	std_logic;
		signal pos_neg			: in	std_logic;								-- To set positive ('0') or negative ('1') trigger
		signal data_in			: in	signed(data_width-1 downto 0);			-- Signal from the ADC
		signal threshold_rise	: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal threshold_fall	: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal trigger_out		: out	std_logic;
		-- Counter
		signal rdclk			: in	std_logic := '0';
		signal rden				: in	std_logic := '0';
		signal fifo_empty		: out	std_logic := '0';
		signal counter_q		: out	std_logic_vector(31 downto 0) := x"00000000";
		-- Debug
		signal state_out		: out	std_logic_vector(3 downto 0)
	);	
	end component;
	
	-- Data Builder
	component databuilder
	port
	(	
		--
		rst							: in	std_logic;
		clk							: in	std_logic;		 

		--
		enable_A					: in	SLOTS_T;
		enable_B					: in	SLOTS_T;
		transfer					: in	TRANSFER_A;
		address						: in	ADDRESS_A;
		mode						: in	SLOTS_T;
		
		--
		rd							: out	SLOTS_T;
		idata						: in	IDATA_A;
		
		--
		wr							: out	ADDRESS_T;
		odata						: out	ODATA_T
	);
	end component;
	
	-- Synchronous Word Copier
	component swc
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in	std_logic; -- async if
		
		--flags
		signal dwait			: in	std_logic;
		signal dataa			: in	std_logic;

		--strobes
		signal wr				: out 	std_logic := '1';
		signal rd				: out 	std_logic := '1'
	);
	end component;

	-- Slave SPI
	component s_spi
	port
	(	
		signal clk				: in	std_logic;						-- sytem clock (@20 MHz)
		signal rst				: in 	std_logic;						-- asynchronous reset
		
		signal mosi				: in	std_logic;						-- master serial out	- slave serial in
		signal miso				: out	std_logic := '0';				-- master serial in	- slave serial out
		signal sclk				: in	std_logic;						-- spi clock out
		
		signal wr				: in	std_logic;						-- write strobe
		signal rd				: in	std_logic;						-- read strobe
		
		signal dwait			: out	std_logic := '0';				-- dwait flag
		signal dataa			: out	std_logic := '0';				-- data avaiable flag
		
		signal idata			: in	std_logic_vector(7 downto 0);	-- data input parallel bus
		signal odata			: out	std_logic_vector(7 downto 0)	-- data output parallel bus	
	);
	end component;
	
	-- Registers
	component core_rconst
	port
	(
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		
		--register/peripherals's multi access input strobes
		signal a_wr				: in	std_logic_vector((num_regs-1) downto 0);
		signal a_rd				: in	std_logic_vector((num_regs-1) downto 0);

		--signal b_wr				: in	std_logic_vector((num_regs-1) downto 0);
		--signal b_rd				: in	std_logic_vector((num_regs-1) downto 0);

		--common i/o
		signal idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out	std_logic_vector(7 downto 0);

		--register's individual i/os
		signal ireg				: in	SYS_REGS;
		signal oreg				: out	SYS_REGS;

		--peripherals outputs strobes
		signal p_wr				: out	std_logic_vector((num_regs-1) downto 0);
		signal p_rd				: out	std_logic_vector((num_regs-1) downto 0)
	);
	end component;
	
	-- Command Decoder
	component core_cmddec
	port
	(
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		-- Arbiter interface
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		--flags
		signal dwait			: in	std_logic;
		signal dataa			: in	std_logic;

		-- FT245BM_if strobes
		signal wr				: out 	std_logic := '1';
		signal rd				: out 	std_logic := '1';

		-- FT245BM_if local bus
		signal idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out	std_logic_vector(7 downto 0);
		
		--register's strobes
		signal reg_wr			: out	std_logic_vector((num_regs-1) downto 0);
		signal reg_rd			: out	std_logic_vector((num_regs-1) downto 0);
		
		--register's i/os
		signal reg_idata		: in	std_logic_vector(7 downto 0);
		signal reg_odata		: out	std_logic_vector(7 downto 0)		
	);
	end component;

---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------
	
	
	--
	
	--
	signal rst						: std_logic;
	signal idt_rst					: std_logic;
	
	--
	signal adcpwdn					: std_logic_vector(3 downto 0);

	signal adc_dco					: std_logic_vector(3 downto 0);
	signal nadc_dco					: std_logic_vector(3 downto 0);
	signal acq_enable				: std_logic;
	
	--
	signal pclk						: std_logic;
	signal dclk						: std_logic;
	signal fclk						: std_logic;

	--
	signal acq_rst					: std_logic_vector((adc_channels-1) downto 0);	
	signal clk						: std_logic_vector((adc_channels-1) downto 0);
	signal rd						: std_logic_vector((adc_channels-1) downto 0);
	signal wr						: std_logic_vector((adc_channels-1) downto 0);
	signal full						: std_logic_vector((adc_channels-1) downto 0);
	signal empty					: std_logic_vector((adc_channels-1) downto 0);
	signal c_trigger_a				: std_logic_vector((adc_channels-1) downto 0);
	signal c_trigger_b				: std_logic_vector((adc_channels-1) downto 0);
	signal c_trigger_c				: std_logic_vector((adc_channels-1) downto 0);
	signal int_trigger				: std_logic_vector((adc_channels-1) downto 0);
	signal acqin					: std_logic_vector((adc_channels-1) downto 0);
	signal wf_en					: std_logic_vector((adc_channels-1) downto 0);


	signal data						: F_DATA_WIDTH_T;	-- FIFOs input DATA bus vector
	signal q						: F_DATA_WIDTH_T;	-- FIFOs output DATA  bus vector 


	signal rdusedw					: F_USEDW_WIDTH_T; -- FIFOs USED WORDS bus vector sync'ed to read clock
	signal wrusedw					: F_USEDW_WIDTH_T; -- FIFOs USED WORDS bus vector sync'ed to write clock

	-- Data Builder
	signal	enable_A				: SLOTS_T;
	signal	enable_B				: SLOTS_T;
	signal	transfer				: TRANSFER_A;
	signal	address					: ADDRESS_A;
	signal	mode					: SLOTS_T;
	
	--
	signal	db_rd					: SLOTS_T;
	signal  idata					: IDATA_A;
	
	--
	signal	db_wr					: ADDRESS_T;
	signal	odata					: ODATA_T;

	--
	signal even_enable				: SLOTS_T;
	signal odd_enable				: SLOTS_T;

	
	-- Command Decoder / Registers Test
	--register's strobes
	signal a_wr			: std_logic_vector((num_regs-1) downto 0);
	signal a_rd			: std_logic_vector((num_regs-1) downto 0);
	
	signal p_wr			: std_logic_vector((num_regs-1) downto 0);
	signal p_rd			: std_logic_vector((num_regs-1) downto 0);

	signal ireg			: SYS_REGS;
	signal oreg			: SYS_REGS;

	signal reg_idata	: std_logic_vector(7 downto 0);
	signal reg_odata	: std_logic_vector(7 downto 0);
	
	signal thtemp		: DATA_T;

	--
	--signal temp						: std_logic;	

	-- Slave SPI Test
	signal s_spi_wr					: std_logic := '1';
	signal s_spi_rd					: std_logic := '1';
	signal s_spi_idata				: std_logic_vector(7 downto 0) := x"00";
	signal s_spi_odata				: std_logic_vector(7 downto 0) := x"00";

	signal s_spi_dwait				: std_logic := '0';
	signal s_spi_dataa				: std_logic := '0';
	
	--	Test Counter
	signal counter					: std_logic_vector(7 downto 0);
	signal counter_d				: std_logic_vector(9 downto 0);
	signal counter_rd				: std_logic;
	signal counter_t				: std_logic;

	
------------------------------------------
------------------------------------------

begin

	--------------------
	-- ADCs interface --
	--------------------
	adc12_pwdn <= not(ADC12_PWR);
	adc34_pwdn <= not(ADC34_PWR);
	adc56_pwdn <= not(ADC56_PWR);
	adc78_pwdn <= not(ADC78_PWR);


	-------------------
	-- TDC interface --
	-------------------
	tdc_stop_dis	<= (others => 'Z');
	tdc_start_dis	<= 'Z';
	tdc_wrn		 	<= 'Z';
	tdc_rdn			<= 'Z';
	tdc_csn			<= 'Z';
	tdc_alutr		<= 'Z';
	tdc_puresn		<= 'Z';
	tdc_oen			<= 'Z';
	tdc_adr			<= (others => 'Z');

	----------------------
	-- FIFO's interface --
	----------------------
	fifo_wck	<= fclk;
	
	fifo_mrs	<= not(idt_rst);
	fifo_prs	<= '1';
	fifo_rt		<= '1';

	-- IDT FIFO: Configuracao da Programmable Almost Full Flag durante o RESET. 
	fifo_fs0	<= '1';			--high for m = 255 -- See IDT FIFO1s manual.
	fifo_fs1	<= '1';			--high for m = 255 -- See IDT FIFO1s manual.
	fifo_ld		<= '1';			--high during reset for m = 255 -- See IDT FIFO's manual.

	
	--------------------
	-- SRAM interface --
	--------------------
	sram_add	<= (others => 'Z');
	sram_data	<= (others => 'Z');
	sram_we		<= '1';
	sram_oe		<= '1';
	sram_cs		<= '1';
	

------------------------
--********************--
--******* MAPS *******--
--********************--
------------------------
	
-- ************************************ SYSTEM ********************************

	clock_manager: 
	core_clkman port map 
	(
		iclk				=> clkcore, 
		
		pclk				=> pclk, -- @ 40 MHz - 0 deg.
		nclk				=> dclk, -- @ 30 Mhz - 0 deg.
		mclk				=> fclk, -- @ 30 MHz - 90 deg.
		sclk				=> open, -- @ 60 MHz - 0 deg.
		clk_enable			=> open,
		tclk				=> open
	);
	
	
	rst_gen:
	rstgen port map
	(	
		clk				=> pclk,
		
		reset			=> oreg(0),
		
		rst				=> rst
	);
	

	idt_rst				<= oreg(3)(0);							

	
-- ************************************ SLAVE SPI ******************************
	-- *** Utilizado para configuracao de registradores que ainda so funciona no
	-- *** modo USB

	Slave_SPI: 
	s_spi
	port map
	(	
		clk			=> pclk,		-- sytem clock
		rst			=> rst,			-- asynchronous reset
		
		mosi		=> mosi,		-- master serial out	- slave serial in
		miso		=> miso,		-- master serial in		- slave serial out
		sclk		=> spiclk,		-- spi clock out
		
		wr			=> s_spi_wr,	-- write strobe
		rd			=> s_spi_rd,	-- read strobe
		
		dwait		=> s_spi_dwait,	-- busy flag
		dataa		=> s_spi_dataa,	-- data avaiable flag
		
		idata		=> s_spi_idata,	-- data input parallel bus
		odata		=> s_spi_odata		-- data output parallel bus	
	);

-- ****************************** LOOPBACK TEST ********************************

	-- Slave SPI Loopback
	-- s_spi_idata	<= s_spi_odata;

	-- s_spi_loopback:
	-- swc port map
	-- (	
		-- clk			=> pclk,
		-- rst			=> rst,
		
		-- --flags
		-- dwait			=> s_spi_dwait,	--to
		-- dataa			=> s_spi_dataa,	--from

		-- --strobes
		-- wr				=> s_spi_wr,	--to
		-- rd				=> s_spi_rd		--from
	-- );


-- ******************************* CMDDEC-REGS *********************************
	
	-- *** ESCREVER/LER em registrador so funciona no modo USB. Ainda depende de
	-- *** testes e progressos no FPGA VME.

	registers:
	core_rconst port map
	(
		clk			=> pclk,
		rst			=> rst,

		--register's strobes
		a_wr		=> a_wr,
		a_rd		=> a_rd,
		
		idata		=> reg_odata,
		odata		=> reg_idata,
		
		--register's individual i/os
		ireg		=> ireg,
		oreg		=> oreg,

		--peripherals outputs strobes
		p_wr		=> p_wr,
		p_rd		=> p_rd
	);
	
	-- Command Decoder

	command_decoder:
	core_cmddec port map
	(
		clk			=> pclk,
		rst			=> rst,
		
		--arbiter
		enable		=> '1',		--It's the only device attached to the Slave SPI. So, it is always able to write.
		isidle		=> open,	--Thus, no arbiter is needed.
		
		--flags
		dwait		=> s_spi_dwait,
		dataa		=> s_spi_dataa,

		--FT245BM_if strobes
		wr			=> s_spi_wr,
		rd			=> s_spi_rd,
		
		--FT245BM_if local bus
		idata		=> s_spi_odata,
		odata		=> s_spi_idata,

		--register's strobes
		reg_wr		=> a_wr,
		reg_rd		=> a_rd,
		
		--register's strobes
		reg_idata	=> reg_idata,
		reg_odata	=> reg_odata
	);

-- ******************************* TEST COUNTER ********************************
	
	test_counter:
	process (adc12_dco, rst)
	begin
		if (rst = '1') then
			counter		<= x"FF";
			counter_t	<= '0';
			--counter_d	<= (others => '0');
		elsif (rising_edge(adc12_dco)) then
			if (counter_rd = '1') then	-- IDT's RD is active low.
				if (counter = x"FF") then
					counter		<= x"01";
					counter_t	<= '0';
				else
					counter		<= counter + 2;
					counter_t	<= '1';
				end if;
			end if;
		end if;
	end process;
	
	counter_rd					<= '1';
	counter_d(9 downto 8)	<= "00";
	counter_d(7 downto 0)	<= counter;
	
	
-- ******************************* ACQ - CHANNELS *****************************

	clk(0)		<= adc12_dco;
	clk(1)		<= not(adc12_dco);
	clk(2)		<= adc34_dco;
	clk(3)		<= not(adc34_dco);
	clk(4)		<= adc56_dco;
	clk(5)		<= not(adc56_dco);
	clk(6)		<= adc78_dco;
	clk(7)		<= not(adc78_dco);

	data(0)		<= adc12_data;
	data(1)		<= adc12_data;
	data(2)		<= adc34_data;
	data(3)		<= adc34_data;
	data(4)		<= adc56_data;
	data(5)		<= adc56_data;
	data(6)		<= adc78_data;
	data(7)		<= adc78_data;
	
	wf_en(0)	<= '1';
	wf_en(1)	<= '1';
	wf_en(2)	<= '1'; --acqin(0);	-- 0 and 2 interleaved mode.
	wf_en(3)	<= '1';
	wf_en(4)	<= '1';
	wf_en(5)	<= '1';
	wf_en(6)	<= '1';
	wf_en(7)	<= '1';

	acq_enable	<= oreg(4)(0);			--Nao e usado no teste VME porque registradores 
										--nao sao escritos
										
	-- Constroi os 8 canais de aquisicao
	adc_data_acq_construct:
	for i in 0 to (adc_channels-1) generate

		acq_rst(i)	<= oreg(3)(0);
		
		-- Gera reset automatico para a Aquisicao.
		acq_rst_gen:
		rstgen port map
		(	
			clk				=> clk(i),
		
			reset			=> x"00",
		
			rst				=> open --acq_rst(i)
		);

		-- Condiciona trigger da entrada 'A'
		a_etrigger_cond:
		tpulse port map
		(	
			rst			=> acq_rst(i),
			clk			=> clk(i),
			enable		=> '1', 			--Sempre ligado para o teste VME  --acq_enable,
			trig_in		=> trigger_a,
			trig_out	=> c_trigger_a(i)
		);

		-- Condiciona trigger da entrada 'B'
		b_etrigger_cond:
		tpulse port map
		(	
			rst			=> acq_rst(i),
			clk			=> clk(i),
			enable		=> '1', 			--Sempre ligado para o teste VME  --acq_enable,
			trig_in		=> trigger_b,
			trig_out	=> c_trigger_b(i)
		);

		-- Condiciona trigger da entrada 'C'
		c_etrigger_cond:
		tpulse port map
		(	
			rst			=> acq_rst(i),
			clk			=> clk(i),
			enable		=> '1', 			--Sempre ligado para o teste VME  --acq_enable,
			trig_in		=> trigger_c,
			trig_out	=> c_trigger_c(i)
		);

		-- Gera Trigger Interno e conta a quantidade de triggers
		thtemp(9 downto 8) <= "00";
		thtemp(7 downto 0) <= oreg(5);
		
		internal_trigger:
		itrigger port map
		(	
			rst					=> acq_rst(i),
			clk					=> clk(i),
			-- Trigger
			enable				=> '1',
			pos_neg				=> '1',								--'0' for pos, '1' for neg.
			data_in				=> MY_CONV_SIGNED(data(i)),
			threshold_rise		=> CONV_SIGNED(T_RISE, data_width), --MY_CONV_SIGNED(thtemp),
			threshold_fall		=> CONV_SIGNED(T_FALL, data_width), --MY_CONV_SIGNED(thtemp),
			trigger_out			=> int_trigger(i),
			-- Counter
			rdclk				=> fclk,
			rden				=> '0',
			fifo_empty			=> open,
			counter_q			=> open,
			-- Debug
			state_out			=> open
		);	

		-- Controla a escrita nas POST FIFOs a partir de um 'trigger' condicionado
		stream_IN:
		writefifo port map
		(	
			clk			=> clk(i),
			rst			=> acq_rst(i),
		
			enable		=> wf_en(i),
			acqin		=> acqin(i),
			
			tmode		=> oreg(4)(7),	-- '0' for External, '1' for Interal
			
			--OR'ed conditioned trigger inputs, active when 'tmode = '0''
			trig0 		=> c_trigger_a(i),
			trig1 		=> c_trigger_b(i),
			trig2		=> c_trigger_c(i),

			-- conditioned trigger input, active when 'tmode = '1''
			trig3		=> int_trigger(0),
			
			wr			=> wr(i),
				
			usedw		=> wrusedw(i),
			full		=> full(i),
		
			wmax		=> CONV_STD_LOGIC_VECTOR(MAX_WORDS, usedw_width),
			esize		=> CONV_STD_LOGIC_VECTOR(EVENT_SIZE, usedw_width)
		);

		
		-- Modulo de FIFO: PRE+POST
		fifo_module:
		dcfifom port map
		(	
			wrclk		=> clk(i),
			rdclk		=> dclk,
			rst			=> acq_rst(i),
		
			wr			=> wr(i),
			d			=> data(i),
		
			rd			=> rd(i),
			q			=> q(i),
		
			f			=> full(i),
			e			=> empty(i),

			rdusedw		=> rdusedw(i),
			wrusedw		=> wrusedw(i)
		);
	
	end generate adc_data_acq_construct;

-- ************************************ IDT COPIER ********************************

	-- Copia das FIFOs internas para as IDT FIFOs
	-- idt_writer:
	-- idtfifo_top port map
	-- (	-- CONTROL/STATUS signals
		-- rst					=> rst,
		-- clk					=> dclk,						-- Read clock das FIFOs internas		
		-- start_transfer		=> '1',
		-- enable_fifo			=> "1111",						-- A copia para as 4 FIFOs esta habilitada "1111";

		-- idt_full(1)			=> fifo1_paf, --fifo1_ff,		-- Nao da pra usar a full flag para fazer uma copia em bloco.
		-- idt_full(2)			=> fifo2_paf,				 	-- Agora a programmable almost full flag esta sendo usada
		-- idt_full(3)			=> fifo3_paf,					-- E esta configurada para ficar ativa quando a FIFO tiver apenas
		-- idt_full(4)			=> fifo4_paf,					-- 255 palavras livres. Como se quer copiar 128 palavras, devera 
															-- -- funcionar.
																	
		-- idt_wren(1)			=> fifo1_wen,
		-- idt_wren(2)			=> fifo2_wen,
		-- idt_wren(3)			=> fifo3_wen,
		-- idt_wren(4)			=> fifo4_wen,

		-- idt_data			=> fifo_data_bus,
		
		-- fifo_used_A			=> rdusedw(0),					-- Mudar para barramento no futuro
		-- fifo_used_B			=> rdusedw(1),
		-- fifo_used_C			=> rdusedw(2),
		-- fifo_used_D			=> rdusedw(3),
		-- fifo_used_E			=> rdusedw(4),
		-- fifo_used_F			=> rdusedw(5),
		-- fifo_used_G			=> rdusedw(6),
		-- fifo_used_H			=> rdusedw(7),

		-- fifo_empty(1)		=> empty(0),
		-- fifo_empty(2)		=> empty(1),
		-- fifo_empty(3)		=> empty(2),
		-- fifo_empty(4)		=> empty(3),
		-- fifo_empty(5)		=> empty(4),
		-- fifo_empty(6)		=> empty(5),
		-- fifo_empty(7)		=> empty(6),
		-- fifo_empty(8)		=> empty(7),

		-- fifo_rden(1)		=> rd(0),						-- Mudar para barramento quando possivel
		-- fifo_rden(2)		=> rd(1),
		-- fifo_rden(3)		=> rd(2),
		-- fifo_rden(4)		=> rd(3),
		-- fifo_rden(5)		=> rd(4),
		-- fifo_rden(6)		=> rd(5),
		-- fifo_rden(7)		=> rd(6),
		-- fifo_rden(8)		=> rd(7),
		
		-- fifo_qA   			=> q(0),
		-- fifo_qB				=> q(1),
		-- fifo_qC				=> q(2),
		-- fifo_qD				=> q(3),
		-- fifo_qE				=> q(4),
		-- fifo_qF				=> q(5),
		-- fifo_qG				=> q(6),
		-- fifo_qH				=> q(7)
		
	-- );

-- ******************************* DATA BUILDER *******************************


--
-- Data Builder Slots Construct
--

	data_builder: 
	databuilder port map 
	(
		--
		rst							=> rst,
		clk							=> dclk,

		--
		enable_A					=> enable_A,
		enable_B					=> enable_B,
		transfer					=> transfer,
		address						=> address,
		mode						=> mode,
		
		--
		rd							=> db_rd,
		idata						=> idata,
		
		--
		wr							=> db_wr,
		odata						=> odata
	);

slots_construct:
for i in 0 to (slots - 1) generate
	
	--
	-- Internal FIFOs enough data test
	--
	
	even_read_test:
	process(rdusedw, empty)
	begin
		-- Means that the FIFO is FULL of data.
		if (rdusedw(i*2) > CONV_STD_LOGIC_VECTOR(EVENT_SIZE, usedw_width)) and (empty(i*2) = '0') then
			even_enable(i) <= '1';
		else
			even_enable(i) <= '0';
		end if;
	end process;
	
	odd_read_test:
	process(rdusedw, empty)
	begin
		-- Means that the FIFO is FULL of data.
		if (rdusedw((i*2)+1) > CONV_STD_LOGIC_VECTOR(EVENT_SIZE, usedw_width)) and (empty((i*2)+1) = '0') then
			odd_enable(i) <= '1';
		else
			odd_enable(i) <= '0';
		end if;
	end process;

	--
	-- Slots Definitions
	--
	
	--
	-- Slot Enable: '1' for enable.
	enable_A(i)	<= '1';
	-- Transfer Enable: even channel and odd channel and IDT ALMOST Full Flag must let us go. 
	-- 'fifo_paf' is NOT negated because it is active low.
	enable_B(i)	<= even_enable(i) and odd_enable(i) and fifo_paf(i);
	-- Slot Transfer Size:
	transfer(i)	<= CONV_STD_LOGIC_VECTOR(EVENT_SIZE, NumBits(transfer_max));
	-- Slot Address:
	address(i)	<= CONV_STD_LOGIC_VECTOR(i, NumBits(address_max));
	-- Mode: '0' for non branch and '1' for branch.
	mode(i)		<= '1';

	--
	-- Read Side Construct - Internal FIFOs
	--
	
	-- even channels
	rd(i*2)		<= db_rd(i);	-- 0 <= 0, 2 <= 1, 4 <= 2, 6 <= 3 
	-- odd channels
	rd((i*2)+1)	<= db_rd(i);	-- 1 <= 0, 3 <= 1, 5 <= 2, 7 <= 3 
	
	-- 32 bits construct.
	idata(i)(9 downto 0)	<= q(i*2);				-- 0, 2, 4, 6  --- (1), (3), (5), (7) --- index number --- channel number		
	idata(i)(15 downto 10)	<= (others => '0');
	idata(i)(25 downto 16)	<= q((i*2)+1);			-- 1, 3, 5, 7  --- (2), (4), (6), (8) --- index number --- channel number	
	idata(i)(31 downto 26)	<= (others => '0');

	--
	-- Write Side Construct - IDT (external) FIFOs
	--
	
	-- 'fifo_wen' is active low.
	fifo_wen(i)				<= not(db_wr(i));
	fifo_data_bus			<= odata;

end generate slots_construct;
		

end rtl;
