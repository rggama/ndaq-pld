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

use work.functions_pkg.all;			-- Misc. functions
use work.acq_pkg.all;				-- ACQ definitions
use work.tdc_pkg.all;				-- TDC definitions
use work.core_regs.all;				-- Registers handling definitions
use work.databuilder_pkg.all;		-- Data Builder definitions


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
		signal tdc_stop_dis		: out	std_logic_vector(1 to 4);
		signal tdc_start_dis 	: out	std_logic;
		signal tdc_wrn		 	: out	std_logic;
		signal tdc_rdn		 	: out	std_logic;
		signal tdc_csn		 	: out	std_logic;
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
		signal cs				: in	std_logic;
		
		---------------
		-- FIFO PAE --
		---------------
		signal fifo1_pae_o		: out	std_logic;
		signal fifo2_pae_o		: out	std_logic;
		signal fifo3_pae_o		: out	std_logic;
		signal fifo4_pae_o		: out	std_logic;

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

	--
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
	
	-- TDC Interface
	component tdc
	port
	(	
		signal rst				: in 	std_logic;
		signal clk				: in 	std_logic;	-- 40MHz clock
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
		signal conf_done		: out	std_logic;
		signal start_conf		: in	std_logic;
		signal otdc_data		: out	std_logic_vector(27 downto 0);
		signal channel_ef		: out	CTDC_T;
		signal channel_rd		: in	CTDC_T;
		signal channel_out		: out	OTDC_A
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
		signal cs				: in	std_logic;						-- chip select
		
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

	-- TDC
	signal	tdc_ef					: CTDC_T;
	signal	tdc_rd					: CTDC_T;
	signal	tdc_q					: OTDC_A;

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
	signal even_enable				: std_logic_vector(3 downto 0); --SLOTS_T;
	signal odd_enable				: std_logic_vector(3 downto 0); --SLOTS_T;

	
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
	signal counter					: F_DATA_WIDTH_T;
	--signal counter_t				: std_logic_vector((adc_channels-1) downto 0);
	
------------------------------------------
------------------------------------------

begin

	fifo1_pae_o	<= fifo1_pae;
	fifo2_pae_o	<= fifo2_pae;
	fifo3_pae_o	<= fifo3_pae;
	fifo4_pae_o	<= fifo4_pae;
	
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
	-- tdc_stop_dis	<= (others => 'Z');
	-- tdc_start_dis	<= 'Z';
	-- tdc_wrn		 	<= 'Z';
	-- tdc_rdn			<= 'Z';
	-- tdc_csn			<= 'Z';
	-- tdc_alutr		<= 'Z';
	-- tdc_puresn		<= 'Z';
	-- tdc_oen			<= 'Z';
	-- tdc_adr			<= (others => 'Z');

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
		cs			=> cs,			-- chip select
		
		wr			=> s_spi_wr,	-- write strobe
		rd			=> s_spi_rd,	-- read strobe
		
		dwait		=> s_spi_dwait,	-- busy flag
		dataa		=> s_spi_dataa,	-- data avaiable flag
		
		idata		=> s_spi_idata,	-- data input parallel bus
		odata		=> s_spi_odata		-- data output parallel bus	
	);

	
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
	
	test_counter_construct:
	for i in 0 to (adc_channels-1) generate

		test_counter:
		process (clk, rst)
		begin
			if (rst = '1') then
				counter(i)	<= (others => '0'); --CONV_STD_LOGIC_VECTOR(x"3FF", data_width);
			elsif (rising_edge(clk(i))) then
				if ((c_trigger_a(i) = '1') or (acqin(i) = '1')) then
					counter(i)	<= counter(i) + 1;
				else
					counter(i)	<= (others => '0'); --CONV_STD_LOGIC_VECTOR(x"3FF", data_width);
				end if;
			end if;
		end process;

	end generate test_counter_construct;
	
-- ******************************* ACQ - CHANNELS *****************************

	clk(0)		<= adc12_dco;
	clk(1)		<= not(adc12_dco);
	clk(2)		<= adc34_dco;
	clk(3)		<= not(adc34_dco);
	clk(4)		<= adc56_dco;
	clk(5)		<= not(adc56_dco);
	clk(6)		<= adc78_dco;
	clk(7)		<= not(adc78_dco);

	data(0)		<= adc12_data; --counter(0);
	data(1)		<= adc12_data; --counter(1);
	data(2)		<= adc34_data; --counter(2;
	data(3)		<= adc34_data; --counter(3);
	data(4)		<= adc56_data; --counter(4);
	data(5)		<= adc56_data; --counter(5);
	data(6)		<= adc78_data; --counter(6);
	data(7)		<= adc78_data; --counter(7);
	
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
			
			tmode		=> oreg(4)(7),	-- '0' for External, '1' for Internal
			
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

	
-- ************************************ TDC ***********************************

	tdc_top:
	tdc	port map
	(	
		rst				=> rst,
		clk				=> pclk,
		dclk			=> dclk,
		
		-------------------
		-- TDC interface --
		-------------------
		iotdc_data		=> tdc_data,
		otdc_stopdis	=> tdc_stop_dis,
		tdc_start_dis 	=> tdc_start_dis,
		otdc_rdn		=> tdc_rdn,
		otdc_wrn		=> tdc_wrn,
		otdc_csn	 	=> tdc_csn,
		otdc_alutr	 	=> tdc_alutr,
		otdc_puresn	 	=> tdc_puresn,
		tdc_oen		 	=> tdc_oen,
		otdc_adr		=> tdc_adr,
		itdc_irflag	 	=> tdc_irflag,
		itdc_ef2		=> tdc_ef2,
		itdc_ef1		=> tdc_ef1,

		-----------------
		-- TDC control --
		-----------------
		start_conf		=> oreg(6)(0),			-- Start the configuration machine (active high pulse with 2-periods width)
		conf_done		=> ireg(7)(0),		
		otdc_data		=> open,
		channel_ef		=> tdc_ef,
		channel_rd		=> tdc_rd,
		channel_out		=> tdc_q
	);


-- ******************************* DATA BUILDER *******************************

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

		
adc_flags_construct:
for i in 0 to 3 generate
	
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
	
end generate adc_flags_construct;

--
-- Data Builder Slots Construct
--

	--
	-- Slot Enable: '1' for enable.
	enable_A(0)	<= '0';					-- Header
	enable_A(1)	<= '1';					-- ADC
	enable_A(2)	<= '0';					-- TDC

	enable_A(3)	<= '0';
	enable_A(4)	<= '1';
	enable_A(5)	<= '0';

	enable_A(6)	<= '0';
	enable_A(7)	<= '1';
	enable_A(8)	<= '0';

	enable_A(9)	<= '0';
	enable_A(10)<= '1';
	enable_A(11)<= '0';

	-- Transfer Enable: even channel and odd channel and IDT ALMOST Full Flag must let us go. 
	-- 'fifo_paf' is NOT negated because it is active low.
	enable_B(0)	<= fifo_paf(0) and even_enable(0) and odd_enable(0);
	enable_B(1)	<= fifo_paf(0) and even_enable(0) and odd_enable(0);
	enable_B(2)	<= fifo_paf(0);

	enable_B(3)	<= fifo_paf(1) and even_enable(1) and odd_enable(1);
	enable_B(4)	<= fifo_paf(1) and even_enable(1) and odd_enable(1);
	enable_B(5)	<= fifo_paf(1);

	enable_B(6)	<= fifo_paf(2) and even_enable(2) and odd_enable(2);
	enable_B(7)	<= fifo_paf(2) and even_enable(2) and odd_enable(2);
	enable_B(8)	<= fifo_paf(2);

	enable_B(9)	<= fifo_paf(3) and even_enable(3) and odd_enable(3);
	enable_B(10)<= fifo_paf(3) and even_enable(3) and odd_enable(3); 
	enable_B(11)<= fifo_paf(3);

	-- Slot Transfer Size:
	transfer(0)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(1)	<= CONV_STD_LOGIC_VECTOR(EVENT_SIZE, NumBits(transfer_max));
	transfer(2)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	transfer(3)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(4)	<= CONV_STD_LOGIC_VECTOR(EVENT_SIZE, NumBits(transfer_max));
	transfer(5)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	transfer(6)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(7)	<= CONV_STD_LOGIC_VECTOR(EVENT_SIZE, NumBits(transfer_max));
	transfer(8)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	transfer(9)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(10)<= CONV_STD_LOGIC_VECTOR(EVENT_SIZE, NumBits(transfer_max));
	transfer(11)<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	-- Slot Address:
	address(0)	<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(1)	<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(2)	<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));

	address(3)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(4)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(5)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));

	address(6)	<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(7)	<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(8)	<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));

	address(9)	<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(10)	<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(11)	<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));

	-- 32 bits construct.	
	idata(0)	<= x"AA55AA55";											--01 palavra
	idata(1)	<= "000000" & q(1) & "000000" & q(0);					--30 palavras
	idata(2)	<= tdc_q(4)(15 downto 0) & tdc_q(0)(15 downto 0);		--01 palavra

	idata(3)	<= x"AA55AA55";											--01 palavra
	idata(4)	<= "000000" & q(3) & "000000" & q(2);					--30 palavras
	idata(5)	<= tdc_q(5)(15 downto 0) & tdc_q(1)(15 downto 0);		--01 palavra

	idata(6)	<= x"AA55AA55";											--01 palavra
	idata(7)	<= "000000" & q(5) & "000000" & q(4);					--30 palavras
	idata(8)	<= tdc_q(6)(15 downto 0) & tdc_q(2)(15 downto 0);		--01 palavra

	idata(9)	<= x"AA55AA55";											--01 palavra	
	idata(10)	<= "000000" & q(7) & "000000" & q(6);					--30 palavras
	idata(11)	<= tdc_q(7)(15 downto 0) & tdc_q(3)(15 downto 0);		--01 palavra

	-- Mode: '0' for non branch and '1' for branch.
	mode(0)		<= '0';
	mode(1)		<= '0';
	mode(2)		<= '0';
	
	mode(3)		<= '0';
	mode(4)		<= '0';
	mode(5)		<= '0';
	
	mode(6)		<= '0';
	mode(7)		<= '0';
	mode(8)		<= '0';
	
	mode(9)		<= '0';
	mode(10)	<= '0';
	mode(11)	<= '0';

	--*******************************************************************************
	
	rd(0)		<= db_rd(1);
	rd(1)		<= db_rd(1);
	tdc_rd(0)	<= db_rd(2);
	tdc_rd(4)	<= db_rd(2);

	rd(2)		<= db_rd(4);
	rd(3)		<= db_rd(4);
	tdc_rd(1)	<= db_rd(5);
	tdc_rd(5)	<= db_rd(5);

	rd(4)		<= db_rd(7);
	rd(5)		<= db_rd(7);	
	tdc_rd(2)	<= db_rd(8);
	tdc_rd(6)	<= db_rd(8);

	rd(6)		<= db_rd(10);
	rd(7)		<= db_rd(10);
	tdc_rd(3)	<= db_rd(11);
	tdc_rd(7)	<= db_rd(11);

	--*******************************************************************************

	-- 'fifo_wen' is active low.
	fifo_wen(0)				<= not(db_wr(0));
	fifo_wen(1)				<= not(db_wr(1));
	fifo_wen(2)				<= not(db_wr(2));
	fifo_wen(3)				<= not(db_wr(3));

	fifo_data_bus			<= odata;
		
end rtl;
