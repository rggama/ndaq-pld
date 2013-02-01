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
use work.core_regs.all;				-- Registers handling definitions
use work.acq_pkg.all;				-- ACQ definitions
use work.tdc_pkg.all;				-- TDC definitions
use work.mcounter_pkg.all;
use work.tcounter_pkg.all;			-- Trigger Counter definitions
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
		
		-- signal fifo1_ef			: in   	std_logic;	-- EMPTY flag
		-- signal fifo2_ef			: in   	std_logic;
		-- signal fifo3_ef			: in   	std_logic;
		-- signal fifo4_ef			: in   	std_logic;
		
		signal fifo_ef			: in	std_logic_vector(3 downto 0);
		
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
		signal trigger_c		: in	std_logic;
		
		----------------------------------
		-- Overflow Signals to FPGA VME --
		----------------------------------
		signal overflow_a		: out	std_logic;
		signal overflow_b		: out	std_logic;	
		signal overflow_c		: out	std_logic
		
	);
		
end ndaq_core;

architecture rtl of ndaq_core is

------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------

	--
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
	
	--
	-- Reset Generator
	component rstgen
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		
		signal reset			: in 	std_logic_vector(7 downto 0);
		
		signal rst				: out	std_logic := '1'
	);
	end component;

	--
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

	component lock
	port
	(	
		signal clk				: in 	std_logic; 			-- sync if
		signal rst				: in 	std_logic; 			-- async if
		
		signal enable			: in 	std_logic;
		signal trig_in			: in	std_logic;
		signal acq_in			: in	std_logic_vector(7 downto 0);
		
		signal sys_lock			: out	std_logic;
		signal adc_lock			: out	std_logic			
	);
	end component;
	
	--
	--	Internal Discriminator/Trigger Generator
	component itrigger 
	port
	(	
		signal rst				: in	std_logic;
		signal clk				: in	std_logic;
		-- Trigger
		signal enable			: in	std_logic;
		signal pos_neg			: in	std_logic;								-- To set positive ('0') or negative ('1') trigger
		signal data_in			: in	signed(data_width-1 downto 0);			-- Signal from the ADC
		signal th1				: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal th2				: in	signed(data_width-1 downto 0);			-- Signal from 'Threshold' register
		signal trigger_out		: out	std_logic
	);	
	end component;
	
	--
	-- Timebase Generator and Timebase Counter
	component timebase
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		--
		signal trigger_in			: in	std_logic;
		-- Timebase Counter
		signal enable				: in	std_logic;
		signal srst					: in	std_logic;
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal counter_q			: out	std_logic_vector(31 downto 0) := x"00000000"
	);	
	end component;	

	--
	-- Trigger Counter
	component mcounter
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- Counter
		signal trigger_in			: in	std_logic;
		signal enable				: in	std_logic;
		signal lock					: in 	std_logic;
		signal srst					: in	std_logic;
		-- Readout FIFO
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal counter_q			: out	MCOUNTER_DATA_T := x"000000000"
	);	
	end component;

	--
	-- Trigger Counter
	component tcounter
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- Counter
		signal trigger_in			: in	std_logic;
		signal timebase_en			: in	std_logic;
		signal enable				: in	std_logic;
		signal srst					: in	std_logic;
		--
		signal fifowen_in			: in	std_logic;
		--
		signal rdclk				: in	std_logic;
		signal rden					: in	std_logic;
		signal fifo_empty			: out	std_logic;
		signal counter_q			: out	TCOUNTER_DATA_T := x"00000000"
	);	
	end component;

	--
	-- ADC FIFO Writer
	component writefifo
	port
	(	
		signal clk				: in 	std_logic; 			-- sync if
		signal rst				: in 	std_logic; 			-- async if

		signal enable			: in 	std_logic;
		signal acq_in			: out	std_logic := '0';
	
		signal tmode			: in 	std_logic;
		
		signal trig0 			: in	std_logic;
		signal trig1 			: in	std_logic;
		signal trig2			: in	std_logic;
		signal trig3			: in	std_logic;

		signal wr				: out	std_logic := '0';
				
		signal usedw			: in	USEDW_T;
		signal full				: in	std_logic;
		signal enough_room_flag : out	std_logic;
		
		-- Parameters
		
		signal wmax				: in	USEDW_T; 			-- same size of 'usedw'
		signal esize			: in	USEDW_T				-- maximum value must be equal fifo word size (max 'usedw')
	);
	end component;

	--
	-- ADC FIFO Memory Module (1 channel - 1 pre and 1 post)
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
		signal wrusedw			: out	USEDW_T		-- used words sync'ed to write clock
	);
	end component;

	--
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
		signal mode				: in	std_logic;	-- Operation Mode: '0' for SINGLE, '1' for CONTINUOUS.
		signal channel_ef		: out	CTDC_T;
		signal channel_rd		: in	CTDC_T;
		signal channel_out		: out	OTDC_A;

		---------------
		-- Registers --
		---------------
		signal reg_array		: in	TDCREG_A	-- Registers's Value Input Array.
	);	
	end component;

	-------------------
	-- Overflow Flag --
	-------------------
	component overflow
	port
	(	
		signal rst					: in	std_logic;
		signal clk					: in	std_logic;
		-- INs
		signal flag_in				: in	std_logic;
		signal srst					: in	std_logic;
		-- OUTs
		signal flag_out				: out	std_logic
	);
	end component;
	
	--
	-- Data Builder
	component databuilder
	port
	(	
		--
		rst							: in	std_logic;
		clk							: in	std_logic;		 
		
		--
		enable						: in	std_logic;
		
		--
		enable_A					: in	SLOTS_T;
		enable_B					: in	SLOTS_T;
		enable_C					: in	SLOTS_T;
		transfer					: in	TRANSFER_A;
		address						: in	ADDRESS_A;
		mode						: in	MODE_A;
		
		--
		rd							: out	SLOTS_T;
		idata						: in	IDATA_A;
		ctval						: in	IDATA_A;
		
		--
		wr							: out	ADDRESS_T;
		odata						: out	ODATA_T
	);
	end component;

	--
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

	--
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
	
	--
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
	
	-- Reset
	signal rst						: std_logic;
	
	-- ADC 
	signal adcpwdn					: std_logic_vector(3 downto 0);

	signal adc_dco					: std_logic_vector(3 downto 0);
	signal nadc_dco					: std_logic_vector(3 downto 0);
	--signal acq_enable				: std_logic;
	
	-- Clocks
	signal pclk						: std_logic;
	signal dclk						: std_logic;
	signal fclk						: std_logic;
	
	-- Lock Gen
	signal sys_lock					: std_logic;
	
	-- Mighty Trigger Counter
	signal mcounter_trigger_in		: std_logic;
	signal mcounter_rd				: std_logic;
	signal mcounter_ef				: std_logic;
	signal mcounter_q				: MCOUNTER_DATA_T; -- 36 bits

	-- Trigger Counter
	signal tcounter_en_comb			: std_logic;
	signal tcounter_trigger_in		: std_logic;
	signal tcounter_rd				: std_logic;
	signal tcounter_ef				: std_logic;
	signal tcounter_q				: TCOUNTER_DATA_T; -- 32 bits
	
	-- Timebase
	signal timebase_en_comb			: std_logic;
	signal time_rd					: std_logic;
	signal time_ef					: std_logic;
	signal time_q					: TCOUNTER_DATA_T; -- 32 bits

	-- ACQ: ADC
	signal par_enough				: std_logic;
	signal timebase_en				: std_logic;
	signal counter_en				: std_logic;
	signal writefifo_en_comb		: std_logic;
	signal etrigger_en				: std_logic;
	signal itrigger_en				: std_logic;
	signal acq_en					: std_logic;
	signal acq_rst					: std_logic;	
	signal clk						: std_logic_vector((adc_channels-1) downto 0);
	signal rd						: std_logic_vector((adc_channels-1) downto 0);
	signal wr						: std_logic_vector((adc_channels-1) downto 0);
	signal full						: std_logic_vector((adc_channels-1) downto 0);
	signal empty					: std_logic_vector((adc_channels-1) downto 0);
	signal c_trigger_a				: std_logic;
	signal c_trigger_b				: std_logic;
	signal c_trigger_c				: std_logic;
	signal thtemp1					: DATA_T;
	signal thtemp2					: DATA_T;
	signal int_trigger				: std_logic_vector((adc_channels-1) downto 0);
	signal itrigger_sel				: std_logic;
	signal acq_in					: std_logic_vector((adc_channels-1) downto 0);
	signal enough_room				: std_logic_vector((adc_channels-1) downto 0);
	signal adc_lock					: std_logic;
	signal usedw_event_size			: USEDW_T;

	signal data						: F_DATA_WIDTH_T;	-- FIFOs input DATA bus vector
	signal q						: F_DATA_WIDTH_T;	-- FIFOs output DATA  bus vector 


	signal rdusedw					: F_USEDW_WIDTH_T; -- FIFOs USED WORDS bus vector sync'ed to read clock
	signal wrusedw					: F_USEDW_WIDTH_T; -- FIFOs USED WORDS bus vector sync'ed to write clock

	-- ACQ: TDC
	signal	tdc_ef					: CTDC_T;
	signal	tdc_rd					: CTDC_T;
	signal	tdc_q					: OTDC_A;
	signal 	tdc_reg_array			: TDCREG_A;
	
	-- Overflow
	signal overflow_rst				: std_logic;
	signal extfifos_overflow		: std_logic;
	signal adc_overflow				: std_logic;
	signal tdc_overflow				: std_logic;
	
	-- Data Builder
	signal 	busy					: std_logic;
	signal	db_behavior				: MODE_T;
	signal	enable_A				: SLOTS_T;
	signal	enable_B				: SLOTS_T;
	signal	enable_C				: SLOTS_T;
	signal	transfer				: TRANSFER_A;
	signal	address					: ADDRESS_A;
	signal	mode					: MODE_A;
	
	--
	signal	db_rd					: SLOTS_T;
	signal  idata					: IDATA_A;
	signal  ctval					: IDATA_A;
	
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
	adc12_pwdn <= not(oreg(3)(0));
	adc34_pwdn <= not(oreg(3)(1));
	adc56_pwdn <= not(oreg(3)(2));
	adc78_pwdn <= not(oreg(3)(3));

	----------------------
	-- FIFO's interface --
	----------------------
	fifo_wck	<= fclk;
	
	fifo_mrs	<= not(acq_rst);	-- It's ACQ Reset and is negated because IDT FIFO's reset signal is active low.
	fifo_prs	<= '1';
	fifo_rt		<= '1';

	-- IDT FIFO: Configuracao da Programmable Almost Full Flag durante o RESET. 
	fifo_fs0	<= '1';				--high for m = 255 -- See IDT FIFO1s manual.
	fifo_fs1	<= '1';				--high for m = 255 -- See IDT FIFO1s manual.
	fifo_ld		<= '1';				--high during reset for m = 255 -- See IDT FIFO's manual.
	
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
		nclk				=> dclk, -- @ 30 MHz - 0 deg.
		mclk				=> fclk, -- @ 30 MHz - 180 deg.
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
	
	
-- ************************************ SLAVE SPI ******************************

	Slave_SPI: 
	s_spi
	port map
	(	
		clk			=> pclk,			-- sytem clock
		rst			=> rst,				-- asynchronous reset
		
		mosi		=> mosi,			-- master serial out	- slave serial in
		miso		=> miso,			-- master serial in		- slave serial out
		sclk		=> spiclk,			-- spi clock out
		cs			=> cs,				-- chip select
		
		wr			=> s_spi_wr,		-- write strobe
		rd			=> s_spi_rd,		-- read strobe
		
		dwait		=> s_spi_dwait,		-- busy flag
		dataa		=> s_spi_dataa,		-- data avaiable flag
		
		idata		=> s_spi_idata,		-- data input parallel bus
		odata		=> s_spi_odata		-- data output parallel bus	
	);

	
-- ******************************* CMDDEC-REGS *********************************
	
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

	--
	-- Works ONLY for external trigger A!
	--
	test_counter_construct:
	for i in 0 to (adc_channels-1) generate

		test_counter:
		process (clk, rst)
		begin
			if (rst = '1') then
				counter(i)	<= (others => '0'); --CONV_STD_LOGIC_VECTOR(x"3FF", data_width);
			elsif (rising_edge(clk(i))) then
				if ((c_trigger_a = '1') or (acq_in(i) = '1')) then
					counter(i)	<= counter(i) + 1;
				else
					counter(i)	<= (others => '0'); --CONV_STD_LOGIC_VECTOR(x"3FF", data_width);
				end if;
			end if;
		end process;

	end generate test_counter_construct;
	
	
-- ******************************* ACQ - CHANNELS *****************************

	--
	-- Enables
	timebase_en		<= oreg(1)(0);	-- Enable the Timebase generator component.
	counter_en		<= oreg(1)(1);	-- Enable the Internal Trigger Counter component.
	etrigger_en		<= oreg(1)(2);	-- Enable the External Trigger component.
	itrigger_en		<= oreg(1)(3);	-- Enable the Internal Trigger component.
	acq_en			<= oreg(1)(4);  -- Enable the 8 ADC interface component.
	
	--
	-- ACQ Reset
	acq_rst			<= oreg(4)(0);
	
	--
	-- ADC DCOs (Data Clock Outputs) assignements.
	clk(0)		<= adc12_dco;
	clk(1)		<= not(adc12_dco);
	clk(2)		<= adc34_dco;
	clk(3)		<= not(adc34_dco);
	clk(4)		<= adc56_dco;
	clk(5)		<= not(adc56_dco);
	clk(6)		<= adc78_dco;
	clk(7)		<= not(adc78_dco);

	--
	-- ADC Data Bus assignements.
	data(0)		<= adc12_data;
	data(1)		<= adc12_data;
	data(2)		<= adc34_data;
	data(3)		<= adc34_data;
	data(4)		<= adc56_data;
	data(5)		<= adc56_data;
	data(6)		<= adc78_data;
	data(7)		<= adc78_data;
	
	--
	-- Paralell ADC Enough Room
	par_enough	<=	enough_room(0) and enough_room(1) and 
					enough_room(2) and enough_room(3) and 
					enough_room(4) and enough_room(5) and 
					enough_room(6) and enough_room(7);

	--
	-- Enable condition for 'write adc fifos components'
	writefifo_en_comb <= acq_en and par_enough and not(adc_lock);

	--
	-- Test Counter Data Bus assignements.
	-- data(0)		<= counter(0);
	-- data(1)		<= counter(1);
	-- data(2)		<= counter(2);
	-- data(3)		<= counter(3);
	-- data(4)		<= counter(4);
	-- data(5)		<= counter(5);
	-- data(6)		<= counter(6);
	-- data(7)		<= counter(7);

	--
	-- ADC Event Size per trigger [in samples] (to be compared with FIFO's used words). 
	usedw_event_size <= "0000" & oreg(2)(6 downto 0);

	--
	-- Internal Trigger Channel Selector (8 to 1 mux)
	itrigger_selector: itrigger_sel	<= int_trigger(conv_integer(oreg(5)(2 downto 0)));
	
	-- Condiciona trigger da entrada 'A'
	a_etrigger_cond:
	tpulse port map
	(	
		rst			=> acq_rst,
		clk			=> clk(0), --clkcore,
		enable		=> etrigger_en,
		trig_in		=> trigger_a,
		trig_out	=> c_trigger_a
	);
	
	-- Condiciona trigger da entrada 'B'
	b_etrigger_cond:
	tpulse port map
	(	
		rst			=> acq_rst,
		clk			=> clk(0), --clkcore,
		enable		=> etrigger_en,
		trig_in		=> trigger_b,
		trig_out	=> c_trigger_b
	);

	-- Condiciona trigger da entrada 'C'
	c_etrigger_cond:
	tpulse port map
	(	
		rst			=> acq_rst,
		clk			=> clk(0), --clkcore,
		enable		=> etrigger_en,
		trig_in		=> trigger_c,
		trig_out	=> c_trigger_c
	);

	lock_gen:
	lock port map
	(	
		clk				=> clk(0),
		rst				=> acq_rst,
		
		enable			=> '1',
		trig_in			=> c_trigger_a,
		acq_in			=> acq_in,
		
		sys_lock		=> sys_lock,
		adc_lock		=> adc_lock			
	);
	
	--
	-- Mighty Trigger Counter (will not be locked during dead time)
	mcounter_trigger_in <= c_trigger_a; --or c_trigger_b(0) or c_trigger_c(0);
	
	mtrigger_counter:
	mcounter port map
	(	
		rst					=> acq_rst,
		clk					=> clk(0),
		-- Counter
		trigger_in			=> mcounter_trigger_in,
		enable				=> counter_en,
		lock				=> sys_lock,
		srst				=> acq_rst,
		-- Readout FIFO
		rdclk				=> dclk,
		rden				=> mcounter_rd,
		fifo_empty			=> mcounter_ef,
		counter_q			=> mcounter_q
	);	

	--
	-- Enable condition for trigger counter (lockable) component.
	tcounter_en_comb <= counter_en and not(adc_lock);

	--
	-- Internal Trigger Counter
	tcounter_trigger_in <= c_trigger_a; --or c_trigger_b(i) or c_trigger_c(i);
			
	trigger_counter:
	tcounter port map
	(	
		rst					=> acq_rst,
		clk					=> clk(0),
		-- Counter
		trigger_in			=> tcounter_trigger_in, --int_trigger(i),
		timebase_en			=> '1',
		enable				=> tcounter_en_comb,
		srst				=> acq_rst,
		--
		fifowen_in			=> '0',
		--
		rdclk				=> dclk,
		rden				=> tcounter_rd,
		fifo_empty			=> tcounter_ef,
		counter_q			=> tcounter_q
	);

	--
	-- Enable condition for timebase generator (lockable) component.
	timebase_en_comb <= timebase_en and not(adc_lock);
	
	--
	-- Timebase Generator	
	timebase_gen:
	timebase port map
	(	
		rst					=> acq_rst,
		clk					=> clk(0),
		--
		trigger_in			=> c_trigger_a,
		-- Timebase Counter
		enable				=> timebase_en_comb,
		srst				=> acq_rst,
		rdclk				=> dclk,
		rden				=> time_rd,
		fifo_empty			=> time_ef,
		counter_q			=> time_q
	);			

	-- Constroi os 8 canais de aquisicao
	adc_data_acq_construct:
	for i in 0 to (adc_channels-1) generate
		
		--
		-- Constructing the 10 bits Threshold registers.
		thtemp1(9 downto 8) <= oreg(8)(1 downto 0);		-- high Th 1 reg
		thtemp1(7 downto 0) <= oreg(7);					-- low Th 1 reg
		thtemp2(9 downto 8) <= oreg(10)(1 downto 0);	-- high Th 2 reg
		thtemp2(7 downto 0) <= oreg(9);					-- low Th 2 reg

		--
		-- Internal Trigger Generator
		internal_trigger:
		itrigger port map
		(	
			rst					=> acq_rst,
			clk					=> clk(i),
			-- Trigger
			enable				=> itrigger_en,
			pos_neg				=> oreg(11)(0),				--'0' for RISING EDGE, '1' for FALLING EDGE.
			data_in				=> MY_CONV_SIGNED(data(i)),
			th1					=> MY_CONV_SIGNED(thtemp1),	--CONV_SIGNED(T_RISE, data_width),
			th2					=> MY_CONV_SIGNED(thtemp2),	--CONV_SIGNED(T_FALL, data_width),
			trigger_out			=> int_trigger(i)
		);		
				
		--
		-- Controla a escrita nas POST FIFOs a partir de um 'trigger' condicionado	
		stream_IN:
		writefifo port map
		(	
			clk					=> clk(i),
			rst					=> acq_rst,
		
			enable				=> writefifo_en_comb,
			acq_in				=> acq_in(i),
			
			tmode				=> oreg(6)(7),	-- '0' for External, '1' for Internal
			
			--OR'ed conditioned trigger inputs, active when 'tmode = '0''
			trig0 				=> c_trigger_a,
			trig1 				=> '0', --c_trigger_b(i),
			trig2				=> '0', --c_trigger_c(i),

			-- conditioned trigger input, active when 'tmode = '1''
			trig3				=> '0', --itrigger_sel,
			
			wr					=> wr(i),
				
			usedw				=> wrusedw(i),
			full				=> full(i),
			enough_room_flag	=> enough_room(i),
		
			wmax				=> CONV_STD_LOGIC_VECTOR(MAX_WORDS, usedw_width),
			esize				=> usedw_event_size --CONV_STD_LOGIC_VECTOR(EVENT_SIZE, usedw_width)
		);

		--
		-- Modulo de FIFO: PRE+POST
		fifo_module:
		dcfifom port map
		(	
			wrclk		=> clk(i),
			rdclk		=> dclk,
			rst			=> acq_rst,
		
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

	--
	-- TDC Interface
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
		otdc_stopdis	=> open,		-- acessado por um registrador.
		tdc_start_dis 	=> open,		-- acessado por um registrador.	
		otdc_rdn		=> tdc_rdn,
		otdc_wrn		=> tdc_wrn,
		otdc_csn	 	=> tdc_csn,
		otdc_alutr	 	=> tdc_alutr,
		otdc_puresn	 	=> open,		-- acessado por um registrador.
		tdc_oen		 	=> tdc_oen,
		otdc_adr		=> tdc_adr,
		itdc_irflag	 	=> tdc_irflag,
		itdc_ef2		=> tdc_ef2,
		itdc_ef1		=> tdc_ef1,

		-----------------
		-- TDC control --
		-----------------
		start_conf		=> oreg(60)(0),			-- Start the configuration machine (active high pulse with 2-periods width)
		conf_done		=> ireg(61)(0),	
		mode			=> oreg(60)(7),
		otdc_data		=> open,
		channel_ef		=> tdc_ef,
		channel_rd		=> tdc_rd,
		channel_out		=> tdc_q,

		---------------
		-- Registers --
		---------------
		reg_array		=> tdc_reg_array
		
	);

	-- TDC Registers's array connections (Phew!)
	tdc_registers_construct:
	for i in 0 to 11 generate
		tdc_reg_array(i) <= oreg(15+i*4)(3 downto 0) & oreg(14+i*4) & oreg(13+i*4) & oreg(12+i*4);
	end generate tdc_registers_construct;
	
	-- TDC STOPs Disable acessado através de um registrador para ser controlado por software:
	tdc_stop_dis(1) <= oreg(62)(0);
	tdc_stop_dis(2) <= oreg(62)(1);
	tdc_stop_dis(3) <= oreg(62)(2);
	tdc_stop_dis(4) <= oreg(62)(3);
	
	-- TDC START Disable acessado através de um registrador para ser controlado por software:
	tdc_start_dis <= oreg(62)(4);
	
	-- TDC Reset acessado através de um registrador para ser controlado por software:
	-- É negado por ser ativo em nível baixo.
	tdc_puresn <= not(oreg(63)(0)); 
	
-- ****************************** OVERFLOW FLAGS ******************************
	--
	-- Overflow Reset
	overflow_rst <= oreg(4)(1);
	--
	-- External FIFOs Overflow
	extfifos_overflow <= not(fifo_paf(0)) or not(fifo_paf(1)) or not(fifo_paf(2)) or not(fifo_paf(3));
	
	extfifos_overflow_comp:
	overflow port map
	(	
		rst						=> acq_rst,
		clk						=> dclk,
		-- INs
		flag_in					=> extfifos_overflow,
		srst					=> overflow_rst,
		-- OUTs
		flag_out				=> overflow_a
	);
	
	--
	-- ADC Overflow
	adc_overflow <= not(enough_room(0)) or not(enough_room(1)) or
					not(enough_room(2)) or not(enough_room(3)) or 
					not(enough_room(4)) or not(enough_room(5)) or 
					not(enough_room(6)) or not(enough_room(7));
	
	adc_overflow_comp:
	overflow port map
	(	
		rst						=> acq_rst,
		clk						=> clkcore,
		-- INs
		flag_in					=> adc_overflow,
		srst					=> overflow_rst,
		-- OUTs
		flag_out				=> overflow_b
	);

	--
	-- TDC Overflow
	tdc_overflow <= '0';
	
	tdc_overflow_comp:
	overflow port map
	(	
		rst						=> acq_rst,
		clk						=> pclk,
		-- INs
		flag_in					=> '0', --tdc_overflow,
		srst					=> overflow_rst,
		-- OUTs
		flag_out				=> overflow_c
	);

-- ******************************* DATA BUILDER *******************************

	--
	-- Core Databuilder
	data_builder: 
	databuilder port map 
	(
		--
		rst							=> acq_rst,
		clk							=> dclk,
		
		--
		enable						=> oreg(64)(0),
		
		--
		enable_A					=> enable_A,
		enable_B					=> enable_B,
		enable_C					=> enable_C,
		transfer					=> transfer,
		address						=> address,
		mode						=> mode,
		
		--
		rd							=> db_rd,
		idata						=> idata,
		ctval						=> ctval,
		
		--
		wr							=> db_wr,
		odata						=> odata
	);

	
	--
	-- ADC's FIFOs FLAGS Comb logic construct
	adc_flags_construct:
	for i in 0 to 3 generate
		
		--
		-- Even Internal FIFO enough data test
		even_read_test:
		process(rdusedw, usedw_event_size, empty)
		begin
			-- Means that the FIFO is FULL of data.
			if (rdusedw(i*2) > usedw_event_size) and (empty(i*2) = '0') then
				even_enable(i) <= '1';
			else
				even_enable(i) <= '0';
			end if;
		end process;
		
		--
		-- Odd Internal FIFO enough data test
		odd_read_test:
		process(rdusedw, usedw_event_size, empty)
		begin
			-- Means that the FIFO is FULL of data.
			if (rdusedw((i*2)+1) > usedw_event_size) and (empty((i*2)+1) = '0') then
				odd_enable(i) <= '1';
			else
				odd_enable(i) <= '0';
			end if;
		end process;
		
	end generate adc_flags_construct;

	
	--
	-- Busy signal indicates that the data block was acquired during ACQ dead time.
	busy <= mcounter_q(35);
	
	--
	-- Busy to Databuilder Behavior DECODER
	process (busy)
	begin
		if (busy = '1') then
			db_behavior <= "10"; -- constant value
		else
			db_behavior <= "00"; -- non branch
		end if;
	end process;
	
	--
	-- Data Builder Slots Construct
	--

	--
	-- Slot Enable: '1' for enable.
	enable_A(0)		<= oreg(65)(0); --'0';					-- Header
	enable_A(1)		<= oreg(65)(1); --'1';					-- Timestamp
	enable_A(2)		<= oreg(65)(2); --'0';					-- ADC
	enable_A(3)		<= oreg(65)(3); --'0';					-- TDC
	enable_A(4)		<= oreg(65)(3); --'0';					-- TDC
	enable_A(5)		<= oreg(65)(4); --'1';					-- Trigger Counter
	enable_A(6)		<= oreg(65)(5); --'1';					-- Trigger Counter

	enable_A(7)		<= oreg(66)(0); --'0';
	enable_A(8)		<= oreg(66)(1); --'1';
	enable_A(9)		<= oreg(66)(2); --'0';
	enable_A(10)	<= oreg(66)(3); --'0';
	enable_A(11)	<= oreg(66)(3); --'0';
	enable_A(12)	<= oreg(66)(4); --'1';
	enable_A(13)	<= oreg(66)(5); --'1';

	enable_A(14)	<= oreg(67)(0); --'0';
	enable_A(15)	<= oreg(67)(1); --'1';
	enable_A(16)	<= oreg(67)(2); --'0';
	enable_A(17)	<= oreg(67)(3); --'0';
	enable_A(18)	<= oreg(67)(3); --'0';
	enable_A(19)	<= oreg(67)(4); --'1';
	enable_A(20)	<= oreg(67)(5); --'1';

	enable_A(21)	<= oreg(68)(0); --'0';
	enable_A(22)	<= oreg(68)(1); --'1';
	enable_A(23)	<= oreg(68)(2); --'0';
	enable_A(24)	<= oreg(68)(3); --'0';
	enable_A(25)	<= oreg(68)(3); --'0';
	enable_A(26)	<= oreg(68)(4); --'1';
	enable_A(27)	<= oreg(68)(5); --'1';
	

	--
	-- Transfer Enable: 
	-- even channel and odd channel let us go for Header and ADC. 
	-- timestamp NOT empty let us go.
	-- tdc NOT empty let us go.
	-- tcounter NOT empty let us go.
	enable_B(0)		<= not(mcounter_ef); 
	enable_B(1)		<= not(time_ef) and not(busy);
	enable_B(2)		<= even_enable(0) and odd_enable(0) and not(busy);
	enable_B(3)		<= not(tdc_ef(0)) and not(busy);
	enable_B(4)		<= not(tdc_ef(4)) and not(busy);
	enable_B(5)		<= not(tcounter_ef) and not(busy);
	enable_B(6)		<= '1'; 

	enable_B(7)		<= '1'; 
	enable_B(8)		<= '1'; 
	enable_B(9)		<= even_enable(1) and odd_enable(1) and not(busy);
	enable_B(10)	<= not(tdc_ef(1)) and not(busy);
	enable_B(11)	<= not(tdc_ef(5)) and not(busy);
	enable_B(12)	<= '1'; 
	enable_B(13)	<= '1'; 

	enable_B(14)	<= '1'; 
	enable_B(15)	<= '1'; 
	enable_B(16)	<= even_enable(2) and odd_enable(2) and not(busy);
	enable_B(17)	<= not(tdc_ef(2)) and not(busy);
	enable_B(18)	<= not(tdc_ef(6)) and not(busy);
	enable_B(19)	<= '1'; 
	enable_B(20)	<= '1'; 

	enable_B(21)	<= '1'; 
	enable_B(22)	<= '1'; 
	enable_B(23)	<= even_enable(3) and odd_enable(3) and not(busy); 
	enable_B(24)	<= not(tdc_ef(3)) and not(busy);
	enable_B(25)	<= not(tdc_ef(7)) and not(busy);
	enable_B(26)	<= '1'; 
	enable_B(27)	<= '1'; 

	-- Destination Enable: 'fifo_paf' is NOT negated because it is active low.
	enable_C(0)		<= fifo_paf(0);
	enable_C(1)		<= fifo_paf(0);
	enable_C(2)		<= fifo_paf(0);
	enable_C(3)		<= fifo_paf(0);
	enable_C(4)		<= fifo_paf(0);
	enable_C(5)		<= fifo_paf(0);
	enable_C(6)		<= fifo_paf(0);

	enable_C(7)		<= fifo_paf(1);
	enable_C(8)		<= fifo_paf(1);
	enable_C(9)		<= fifo_paf(1);
	enable_C(10)	<= fifo_paf(1);
	enable_C(11)	<= fifo_paf(1);
	enable_C(12)	<= fifo_paf(1);
	enable_C(13)	<= fifo_paf(1);

	enable_C(14)	<= fifo_paf(2);
	enable_C(15)	<= fifo_paf(2);
	enable_C(16)	<= fifo_paf(2);
	enable_C(17)	<= fifo_paf(2);
	enable_C(18)	<= fifo_paf(2);
	enable_C(19)	<= fifo_paf(2);
	enable_C(20)	<= fifo_paf(2);

	enable_C(21)	<= fifo_paf(3);
	enable_C(22)	<= fifo_paf(3);
	enable_C(23)	<= fifo_paf(3);
	enable_C(24)	<= fifo_paf(3);
	enable_C(25)	<= fifo_paf(3);
	enable_C(26)	<= fifo_paf(3);
	enable_C(27)	<= fifo_paf(3);

	-- Slot Transfer Size:
	transfer(0)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(1)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(2)		<= oreg(2)(6 downto 0); -- This register is the ADC's Event Size (in samples) per trigger.
	transfer(3)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(4)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(5)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(6)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	transfer(7)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(8)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(9)		<= oreg(2)(6 downto 0); -- This register is the ADC's Event Size (in samples) per trigger.
	transfer(10)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(11)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(12)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(13)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	transfer(14)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(15)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(16)	<= oreg(2)(6 downto 0); -- This register is the ADC's Event Size (in samples) per trigger.
	transfer(17)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(18)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(19)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(20)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	transfer(21)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(22)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(23)	<= oreg(2)(6 downto 0); -- This register is the ADC's Event Size (in samples) per trigger.
	transfer(24)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(25)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(26)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));
	transfer(27)	<= CONV_STD_LOGIC_VECTOR(1, NumBits(transfer_max));

	-- Slot Address (Where the SLOT should be copied to):
	-- '0' -> IDT FIFO 1
	-- '1' -> IDT FIFO 2
	-- '2' -> IDT FIFO 3
	-- '3' -> IDT FIFO 4
	address(0)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(1)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(2)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(3)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(4)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(5)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(6)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));

	address(7)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(8)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(9)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(10)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(11)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(12)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));
	address(13)		<= CONV_STD_LOGIC_VECTOR(1, NumBits(address_max));

	address(14)		<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(15)		<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(16)		<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(17)		<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(18)		<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(19)		<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));
	address(20)		<= CONV_STD_LOGIC_VECTOR(2, NumBits(address_max));

	address(21)		<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(22)		<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(23)		<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(24)		<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(25)		<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(26)		<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));
	address(27)		<= CONV_STD_LOGIC_VECTOR(3, NumBits(address_max));

	-- 32 bits construct.	
	idata(0)		<= mcounter_q(31 downto 0); --x"AA55AA55";											--001 palavra
	idata(1)		<= time_q;												--001 palavra
	idata(2)		<= x"0" & "00" & q(1) & x"0" & "00" & q(0);				--128 palavras
	idata(3)		<= tdc_errflag & "00000" & tdc_q(0);					--001 palavra
	idata(4)		<= tdc_errflag & "00000" & tdc_q(4); 					--001 palavra
	idata(5)		<= tcounter_q;											--001 palavra
	idata(6)		<= x"0000000" & "000" & busy;							--001 palavra

	idata(7)		<= mcounter_q(31 downto 0); --x"AA55AA55";											--001 palavra
	idata(8)		<= time_q;												--001 palavra
	idata(9)		<= x"0" & "00" & q(3) & x"0" & "00" & q(2);				--128 palavras
	idata(10)		<= tdc_errflag & "00000" & tdc_q(1);					--001 palavra
	idata(11)		<= tdc_errflag & "00000" & tdc_q(5);					--001 palavra
	idata(12)		<= tcounter_q;											--001 palavra
	idata(13)		<= x"0000000" & "000" & busy;							--001 palavra

	idata(14)		<= mcounter_q(31 downto 0); --x"AA55AA55";											--001 palavra
	idata(15)		<= time_q;												--001 palavra
	idata(16)		<= x"0" & "00" & q(5) & x"0" & "00" & q(4);				--128 palavras
	idata(17)		<= tdc_errflag & "00000" & tdc_q(2);					--001 palavra
	idata(18)		<= tdc_errflag & "00000" & tdc_q(6);					--001 palavra
	idata(19)		<= tcounter_q;											--001 palavra
	idata(20)		<= x"0000000" & "000" & busy;							--001 palavra

	idata(21)		<= mcounter_q(31 downto 0); --x"AA55AA55";											--001 palavra	
	idata(22)		<= time_q;												--001 palavra
	idata(23)		<= x"0" & "00" & q(7) & x"0" & "00" & q(6);				--128 palavras
	idata(24)		<= tdc_errflag & "00000" & tdc_q(3);					--001 palavra
	idata(25)		<= tdc_errflag & "00000" & tdc_q(7);					--001 palavra
	idata(26)		<= tcounter_q;											--001 palavra
	idata(27)		<= x"0000000" & "000" & busy;							--001 palavra

	-- Mode: '00' for non branch and '01' for branch and '10' for constant value.
	mode(0)			<= "00";												--Header
	mode(1)			<= "10"; --db_behavior;											--Timestamp
	mode(2)			<= db_behavior;											--ADC
	mode(3)			<= "10";												--TDC
	mode(4)			<= "10";												--TDC
	mode(5)			<= "10"; --db_behavior;											--Trigger Counter
	mode(6)			<= "00";												--Trigger Counter
	
	mode(7)			<= "00";
	mode(8)			<= "10"; --db_behavior;
	mode(9)			<= db_behavior;
	mode(10)		<= "10";
	mode(11)		<= "10";
	mode(12)		<= "10"; --db_behavior;
	mode(13)		<= "00";
	
	mode(14)		<= "00";
	mode(15)		<= "10"; --db_behavior;
	mode(16)		<= db_behavior;
	mode(17)		<= "10";
	mode(18)		<= "10";
	mode(19)		<= "10"; --db_behavior;
	mode(20)		<= "00";
	
	mode(21)		<= "00";
	mode(22)		<= "10"; --db_behavior;
	mode(23)		<= db_behavior;
	mode(24)		<= "10";
	mode(25)		<= "10";
	mode(26)		<= "10"; --db_behavior;
	mode(27)		<= "00";

	-- Constant Value definitions.
	ctval(0)		<= x"FFFFFFFF";
	ctval(1)		<= x"FFFFFFFF";
	ctval(2)		<= x"FFFFFFFF";
	ctval(3)		<= x"FFFFFFFF";
	ctval(4)		<= x"FFFFFFFF";
	ctval(5)		<= x"FFFFFFFF";
	ctval(6)		<= x"FFFFFFFF";

	ctval(7)		<= x"FFFFFFFF";
	ctval(8)		<= x"FFFFFFFF";
	ctval(9)		<= x"FFFFFFFF";
	ctval(10)		<= x"FFFFFFFF";
	ctval(11)		<= x"FFFFFFFF";
	ctval(12)		<= x"FFFFFFFF";
	ctval(13)		<= x"FFFFFFFF";

	ctval(14)		<= x"FFFFFFFF";
	ctval(15)		<= x"FFFFFFFF";
	ctval(16)		<= x"FFFFFFFF";
	ctval(17)		<= x"FFFFFFFF";
	ctval(18)		<= x"FFFFFFFF";
	ctval(19)		<= x"FFFFFFFF";
	ctval(20)		<= x"FFFFFFFF";

	ctval(21)		<= x"FFFFFFFF";
	ctval(22)		<= x"FFFFFFFF";
	ctval(23)		<= x"FFFFFFFF";
	ctval(24)		<= x"FFFFFFFF";
	ctval(25)		<= x"FFFFFFFF";
	ctval(26)		<= x"FFFFFFFF";
	ctval(27)		<= x"FFFFFFFF";
	
	--*******************************************************************************
	
	mcounter_rd		<= db_rd(0); -- Header		<= db_rd(0);
	time_rd			<= db_rd(1);
	rd(0)			<= db_rd(2);
	rd(1)			<= db_rd(2);
	tdc_rd(0)		<= db_rd(3);
	tdc_rd(4)		<= db_rd(4);
	tcounter_rd		<= db_rd(5);
	-- busy flag	<= db_rd(6);

	-- Header		<= db_rd(7);
	-- Time			<= db_rd(8);
	rd(2)			<= db_rd(9);
	rd(3)			<= db_rd(9);
	tdc_rd(1)		<= db_rd(10);
	tdc_rd(5)		<= db_rd(11);
	-- tcounter_rd	<= db_rd(12);
	-- busy flag	<= db_rd(13);

	-- Header		<= db_rd(14);
	-- Time			<= db_rd(15);
	rd(4)			<= db_rd(16);
	rd(5)			<= db_rd(16);	
	tdc_rd(2)		<= db_rd(17);
	tdc_rd(6)		<= db_rd(18);
	-- tcounter_rd	<= db_rd(19);
	-- busy flag	<= db_rd(20);
	
	-- Header		<= db_rd(21);
	-- Time			<= db_rd(22);
	rd(6)			<= db_rd(23);
	rd(7)			<= db_rd(23);
	tdc_rd(3)		<= db_rd(24);
	tdc_rd(7)		<= db_rd(25);
	-- tcounter_rd(	<= db_rd(26);
	-- busy flag	<= db_rd(27);
	
	--*******************************************************************************

	-- 'fifo_wen' is active low.
	fifo_wen(0)				<= not(db_wr(0));
	fifo_wen(1)				<= not(db_wr(1));
	fifo_wen(2)				<= not(db_wr(2));
	fifo_wen(3)				<= not(db_wr(3));

	fifo_data_bus			<= odata;
		
end rtl;
