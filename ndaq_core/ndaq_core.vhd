-- $ CORE
-- v: https://ndaq-pld.googlecode.com/svn/trunk
--
-- ****************************************************************************
--
-- Company:			CBPF
-- Author:			Rafael Gama
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
--use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).
--use ieee.std_logic_signed.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as signed integers (used together with std_logic_unsigned is ambiguous).
--use ieee.numeric_std.all;			-- altenative to std_logic_arith, used for maths too (will conflict with std_logic_arith if 'signed' is used in interfaces).

entity ndaq_core is 
	port
	(	
		------------------
		-- Clock inputs --
		------------------
		signal clkcore		:in		std_logic;	-- Same frequency of DCOs (125MHz in first version)
		
		--------------------
		-- ADCs interface --
		--------------------
		signal adc12_data 	:in  	signed(11 downto 2);
		signal adc34_data 	:in  	signed(11 downto 2);
		signal adc56_data 	:in  	signed(11 downto 2);
		signal adc78_data 	:in  	signed(11 downto 2);
		
		signal adc12_dco	:in 	std_logic;				-- ADC 1 Data Clock
		signal adc34_dco	:in 	std_logic;				-- ADC 2 Data Clock
		signal adc56_dco	:in 	std_logic;				-- ADC 3 Data Clock
		signal adc78_dco	:in 	std_logic;				-- ADC 4 Data Clock
		
		signal adc12_pwdn	:out	std_logic;				-- ADC 1 Power Down control
		signal adc34_pwdn	:out	std_logic;				-- ADC 2 Power Down control
		signal adc56_pwdn	:out	std_logic;				-- ADC 3 Power Down control
		signal adc78_pwdn	:out	std_logic;				-- ADC 4 Power Down control

		-------------------
		-- TDC interface --
		-------------------
		signal tdc_data		 : inout	std_logic_vector(27 downto 0); --***WATCH OUT***
		signal tdc_stop_dis	 : out		std_logic_vector(1 to 4);
		signal tdc_start_dis : out		std_logic;
		signal tdc_wrn		 : out		std_logic;
		signal tdc_rdn		 : out		std_logic;
		signal tdc_csn		 : out		std_logic;
		signal tdc_alutr	 : out  	std_logic;
		signal tdc_puresn	 : out  	std_logic;
		signal tdc_oen		 : out  	std_logic;
		signal tdc_adr		 : out  	std_logic_vector(3 downto 0);
		signal tdc_errflag	 : in   	std_logic;
		signal tdc_irflag	 : in   	std_logic;
		signal tdc_lf2		 : in   	std_logic;
		signal tdc_lf1		 : in   	std_logic;
		signal tdc_ef2		 : in   	std_logic;
		signal tdc_ef1		 : in   	std_logic;

		----------------------
		-- FIFO's interface --
		----------------------
		-- Data Bus
		--signal fifo_data_bus : out  	signed(9 downto 0); -- 10 bits !?
		signal fifo_data_bus : out signed(31 downto 0);
		
		-- Control signals
		signal fifo1_wen	 : out   	std_logic;	-- Write Enable
		signal fifo2_wen	 : out   	std_logic;
		signal fifo3_wen	 : out   	std_logic;
		signal fifo4_wen	 : out   	std_logic;
		signal fifo_wck		 : out		std_logic;	-- Write Clock to all FIFOs (PLL-4 output)
		
		signal fifo_mrs		 : out		std_logic;	-- Master Reset
		signal fifo_prs		 : out		std_logic;	-- Partial Reset
		signal fifo_fs0		 : out		std_logic;	-- Flag Select Bit 0
		signal fifo_fs1		 : out		std_logic;	-- Flag Select Bit 1
		signal fifo_ld		 : out		std_logic;	-- Load
		signal fifo_rt		 : out		std_logic;	-- Retransmit
		
		-- Flags
		signal fifo1_ff		 : in   	std_logic;	-- FULL flag
		signal fifo2_ff		 : in   	std_logic;
		signal fifo3_ff		 : in   	std_logic;
		signal fifo4_ff		 : in   	std_logic;
		
		signal fifo1_ef		 : in   	std_logic;	-- EMPTY flag
		signal fifo2_ef		 : in   	std_logic;
		signal fifo3_ef		 : in   	std_logic;
		signal fifo4_ef		 : in   	std_logic;
		
		signal fifo1_hf		 : in   	std_logic;	-- HALF-FULL flag
		signal fifo2_hf		 : in   	std_logic;
		signal fifo3_hf		 : in   	std_logic;
		signal fifo4_hf		 : in   	std_logic;
		
		signal fifo1_paf	 : in   	std_logic;	-- ALMOST-FULL flag
		signal fifo2_paf	 : in   	std_logic;
		signal fifo3_paf	 : in   	std_logic;
		signal fifo4_paf	 : in   	std_logic;		
		
		signal fifo1_pae	 : in   	std_logic;	-- ALMOST-EMPTY flag
		signal fifo2_pae	 : in   	std_logic;
		signal fifo3_pae	 : in   	std_logic;
		signal fifo4_pae	 : in   	std_logic;

		
		--------------------
		-- SRAM interface --
		--------------------
		signal sram_add	 	 : out  	std_logic_vector(18 downto 0);
		signal sram_data	 : inout  	std_logic_vector(7 downto 0);
		signal sram_we		 : out		std_logic;
		signal sram_oe		 : out		std_logic;
		signal sram_cs		 : out		std_logic;
		
		
		------------------------------
		-- LVDS connector interface --
		------------------------------
		signal lvdsin 		 :in  		std_logic_vector(15 downto 0);		
		
		----------------------------
		-- VME FPGA communication --
		----------------------------
		signal bridge_data	 : inout	std_logic_vector(3 downto 0);
		signal bridge_dw 	 : in		std_logic;
		signal bridge_da 	 : in		std_logic;
		signal bridge_wr	 : out		std_logic;
		signal bridge_rd	 : out		std_logic;

		--------------------
		-- Trigger inputs --
		--------------------
		signal trigger_a	: in		std_logic;	
		signal trigger_b	: out		std_logic;
		signal trigger_c	: out		std_logic
		
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

	-- MASTER USB Transceiver Interface
	component m_trif
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rstc				: in	std_logic;
		
		-- params
		signal bcount			: in	std_logic_vector(15 downto 0);

		-- local
		signal dwait			: out	std_logic;
		signal davail			: out	std_logic;
		signal nwr				: in	std_logic;
		signal nrd				: in 	std_logic;
		signal idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out 	std_logic_vector(7 downto 0);

		-- ext
		signal sdwait			: in	std_logic;
		signal sdavail			: in 	std_logic;
		signal snwr				: out	std_logic;
		signal snrd				: out	std_logic;
		signal iodata			: inout	std_logic_vector(3 downto 0)
	);
	end component;
		
	-- Bench 0
	component bench0
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal wro				: out	std_logic;
		signal dwait 			: in	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0)
	);
	end component;

	-- Command Decoder
	component cmddec
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rstc				: in 	std_logic; -- async if

		signal rd				: out	std_logic;
		signal davail 			: in	std_logic;
		signal idata        	: in	std_logic_vector(7 downto 0);

		signal reset			: out	std_logic_vector(7 downto 0);
		signal adcpwdn			: out 	std_logic_vector(3 downto 0) := x"F";
		signal resetc			: out	std_logic_vector(7 downto 0);
		signal control			: out	std_logic_vector(7 downto 0);
		signal rcontrol			: out	std_logic_vector(7 downto 0);
		
		signal bcount			: out	std_logic_vector(15 downto 0);
		signal c8wmax			: out	std_logic_vector(9 downto 0);
		
		signal tdcstart			: out	std_logic
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

	-- Main Arbiter
	component priarb4
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal en0	 			: out	std_logic := '0';
		signal en1	 			: out	std_logic := '0';
		signal en2	 			: out	std_logic := '0';
		signal en3	 			: out	std_logic := '0';

		signal ii0				: in	std_logic;
		signal ii1				: in	std_logic;
		signal ii2				: in	std_logic;
		signal ii3				: in	std_logic;

		signal control        	: in	std_logic_vector(7 downto 0)
	);
	end component;

	-- Readout Arbiter
	component priarb8
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal en0	 			: out	std_logic := '0';
		signal en1	 			: out	std_logic := '0';
		signal en2	 			: out	std_logic := '0';
		signal en3	 			: out	std_logic := '0';
		signal en4	 			: out	std_logic := '0';
		signal en5	 			: out	std_logic := '0';
		signal en6	 			: out	std_logic := '0';
		signal en7	 			: out	std_logic := '0';

		signal ii0				: in	std_logic;
		signal ii1				: in	std_logic;
		signal ii2				: in	std_logic;
		signal ii3				: in	std_logic;
		signal ii4				: in	std_logic;
		signal ii5				: in	std_logic;
		signal ii6				: in	std_logic;
		signal ii7				: in	std_logic;

		signal control        	: in	std_logic_vector(7 downto 0)
	);
	end component;
	
	-- Headers Writer
	component headersw
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal wro				: out	std_logic;
		signal dwait 			: in	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0)
	);
	end component;


	-- FIFO Memory Module (1 channel - 1 pre and 1 post)
	component dcfifom
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rdclk			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rclk				: in	std_logic;
		
		signal wr				: in 	std_logic;
		signal d				: in	std_logic_vector(9 downto 0);
		
		signal rd				: in	std_logic;	
		signal q				: out	std_logic_vector(9 downto 0);
		
		signal f				: out	std_logic;	
		signal e				: out	std_logic;

		signal rdusedw			: out	std_logic_vector(9 downto 0);
		signal wrusedw			: out	std_logic_vector(9 downto 0)
	);
	end component;

	-- FIFO reader and output streamer (tx streamer)
	component readfifo
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
	
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal rd				: out	std_logic;	
		signal q				: in	std_logic_vector(9 downto 0);
				
		signal usedw			: in	std_logic_vector(9 downto 0);
		
		signal wro				: out	std_logic;
		signal dwait 			: in	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0);
		
		-- Parameters
		
		signal rmin				: in 	std_logic_vector(9 downto 0);
		signal esize			: in	std_logic_vector(9 downto 0)		
	);
	end component;

	-- FIFO Writer
	component writefifo
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rclk				: in	std_logic; -- clock from reset generator domain
		
		signal acqin			: out 	std_logic := '0';
	
		signal trig0 			: in	std_logic;
		signal trig1 			: in	std_logic;
		signal trig2			: in	std_logic;

		signal wr				: out	std_logic := '0';
				
		signal usedw			: in	std_logic_vector(9 downto 0);
		
		-- Parameters
		
		signal wmax				: in	std_logic_vector(9 downto 0); 	-- same size of 'usedw'
		signal esize			: in	std_logic_vector(9 downto 0)	-- maximum value must be equal fifo word size (max 'usedw')
	);
	end component;

	-- External Trigger Pulse Conditioner
	component tpulse
	port
	(	
		signal rst			: in std_logic;
		signal clk	        : in std_Logic;
		signal trig_in      : in std_logic;
		signal trig_out     : out std_Logic
	);
	end component;


	component tdc
	port
	(	
		signal rst				: in 		std_logic;
		signal clk				: in 		std_logic;	-- 40MHz clock
		
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
		signal rd_en		 	: in	std_logic_vector(3 downto 0);	-- Read enable to read TDC 8-bit bus data
		signal en_read		 	: in	std_logic;	-- Read enable to read TDC
		signal tdc_out_HB	 	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (HIGHEST Byte)
		signal tdc_out_MH	 	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (MEDIUM HIGH Byte)
		signal tdc_out_ML	 	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (MEDIUM LOW Byte)
		signal tdc_out_LB	 	: out	std_logic_vector(7 downto 0); 	-- TDC Data Bus (HIGHEST Byte)		
		signal otdc_data		: out	std_logic_vector(27 downto 0);
		signal data_valid		: out 	std_logic;
		signal start_conf		: in	std_logic	-- Start the configuration machine (active high pulse with 2-periods width)
	);
	end component;

	component readtdc 
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
	
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal data_valid		: in	std_logic;
		
		signal rd_en			: out 	std_logic ;				
		signal rd_stb			: out 	std_logic_vector(3 downto 0);
		
		signal wro				: out	std_logic;
		signal dwait 			: in	std_logic
	);
	end component;
	
---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------

	signal rst, mrst				: std_logic;
	signal rstc						: std_logic;

	signal adc12_rst				: std_logic;
	
	signal adcpwdn					: std_logic_vector(3 downto 0);

	signal nadc12_dco				: std_logic;
	signal nadc34_dco				: std_logic;
	signal nadc56_dco				: std_logic;
	signal nadc78_dco				: std_logic;

	signal pclk, mclk				: std_logic;

	signal bcount					: std_logic_vector(15 downto 0);
	
	signal wr, dwait				: std_logic;
	signal txbus					: std_logic_vector(7 downto 0);

	signal rd, davail				: std_logic;
	signal rxbus					: std_logic_vector(7 downto 0);
	signal reset					: std_logic_vector(7 downto 0);
	signal resetc					: std_logic_vector(7 downto 0);

	signal en0, en1, en2, en3		: std_logic;
	signal ii0, ii1, ii2, ii3		: std_logic;
	signal control					: std_logic_vector(7 downto 0);

	signal ren1, ren2, ren3, ren4	: std_logic;
	signal ren5, ren6, ren7, ren8	: std_logic;
	signal rii1, rii2, rii3, rii4	: std_logic;
	signal rii5, rii6, rii7, rii8	: std_logic;
	signal rcontrol					: std_logic_vector(7 downto 0);

	signal rd1, rd2, rd3, rd4		: std_logic;
	signal rd5, rd6, rd7, rd8		: std_logic;
	signal q1, q2, q3, q4			: std_logic_vector(9 downto 0);
	signal q5, q6, q7, q8			: std_logic_vector(9 downto 0);

	signal rdusedw1, rdusedw2		: std_logic_vector(9 downto 0);
	signal rdusedw3, rdusedw4		: std_logic_vector(9 downto 0);
	signal rdusedw5, rdusedw6		: std_logic_vector(9 downto 0);
	signal rdusedw7, rdusedw8		: std_logic_vector(9 downto 0);

	signal wrusedw1, wrusedw2		: std_logic_vector(9 downto 0);
	signal wrusedw3, wrusedw4		: std_logic_vector(9 downto 0);
	signal wrusedw5, wrusedw6		: std_logic_vector(9 downto 0);
	signal wrusedw7, wrusedw8		: std_logic_vector(9 downto 0);

	signal wr1, wr2, wr3, wr4		: std_logic;
	signal wr5, wr6, wr7, wr8		: std_logic;

	signal ptrigger12, ntrigger12	: std_logic;
	signal ptrigger34, ntrigger34	: std_logic;
	signal ptrigger56, ntrigger56	: std_logic;
	signal ptrigger78, ntrigger78	: std_logic;
	
	signal c8wmax					: std_logic_vector(9 downto 0);
	
	signal tdc_rden 				: std_logic;
	signal tdc_rdstb				: std_logic_vector(3 downto 0);
	signal data_valid				: std_logic;
	signal tdcstart					: std_logic;

	signal tdc_csn_wire 			: std_logic;
	
------------------------------------------
------------------------------------------

begin

	--------------------
	-- ADCs interface --
	--------------------
	
	adc12_pwdn <= adcpwdn(0);
	adc34_pwdn <= adcpwdn(1);
	adc56_pwdn <= adcpwdn(2);
	adc78_pwdn <= adcpwdn(3);

--	-------------------
--	-- TDC interface --
--	-------------------
--	tdc_stop_dis	<= (others => 'Z');
--	tdc_start_dis	<= 'Z';
--	tdc_wrn		 	<= 'Z';
--	tdc_rdn			<= 'Z';
--	tdc_csn			<= 'Z';
--	tdc_alutr		<= 'Z';
--	tdc_puresn		<= 'Z';
--	tdc_oen			<= 'Z';
--	tdc_adr			<= (others => 'Z');

	----------------------
	-- FIFO's interface --
	----------------------
	-- Data Bus
	fifo_data_bus <= (others => 'Z');
	
	-- Control signals
	fifo1_wen	<= '1';
	fifo2_wen	<= '1';
	fifo3_wen	<= '1';
	fifo4_wen	<= '1';
	fifo_wck	<= '1';
	
	fifo_mrs	<= '1';
	fifo_prs	<= '1';
	fifo_fs0	<= '1';
	fifo_fs1	<= '1';
	fifo_ld		<= '1';
	fifo_rt		<= '1';
	

	
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
		
		pclk				=> pclk,
		nclk				=> open,
		mclk				=> mclk,
		sclk				=> open,
		clk_enable			=> open, --clk_en,
		tclk				=> open
	);
	

	rst_gen:
	rstgen port map
	(	
		clk				=> pclk,
		
		reset			=> reset,
		
		rst				=> rst
	);
	
	
	cmd_decoder:
	cmddec port map
	(	
		clk				=> pclk,
		rst				=> rst,
		rstc			=> rstc,
		
		rd				=> rd,
		davail 			=> davail,
		idata        	=> rxbus,

		reset			=> reset,
		adcpwdn			=> adcpwdn,
		resetc			=> resetc,
		control			=> control,
		rcontrol		=> rcontrol,
		
		bcount			=> bcount,
		c8wmax			=> c8wmax,
		
		tdcstart		=> tdcstart
	);


	main_arbiter:
	priarb4 port map
	(	
		clk				=> pclk,
		rst				=> rst,

		en0	 			=> en0,
		en1	 			=> en1,
		en2	 			=> en2,
		en3	 			=> en3,

		ii0				=> ii0,
		ii1				=> ii1,
		ii2				=> ii2,
		ii3				=> ii3,
		
		control        	=> control
	);


	headers_writer:
	headersw port map
	(	
		clk				=> pclk,
		rst				=> rst,

		enable			=> en0,
		isidle			=> ii0,

		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus
	);


	benchmark_0:
	bench0 port map
	(	
		clk				=> pclk,
		rst				=> rst,

		enable			=> en1,
		isidle			=> ii1,

		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus
	);

	
-- ********************************* ACQ - BASE *******************************

	readout_arbiter:
	priarb8 port map
	(	
		clk				=> pclk,
		rst				=> rst,
		
		enable			=> en2,
		isidle			=> ii2,
		
		en0	 			=> ren1,
		en1	 			=> ren2,
		en2	 			=> ren3,
		en3	 			=> ren4,
		en4	 			=> ren5,
		en5	 			=> ren6,
		en6	 			=> ren7,
		en7	 			=> ren8,
		
		ii0				=> rii1,
		ii1				=> rii2,
		ii2				=> rii3,
		ii3				=> rii4,
		ii4				=> rii5,
		ii5				=> rii6,
		ii6				=> rii7,
		ii7				=> rii8,
		
		control        	=> rcontrol
	);

-- ******************************* ACQ - CHANNEL 1 ****************************


	c1_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> adc12_dco,
		trig_in			=> trigger_a,
		trig_out		=> ptrigger12
	);

	c1_stream_IN:
	writefifo port map
	(	
		clk				=> adc12_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open, --flag,
		
		trig0 			=> ptrigger12,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr1,
				
		usedw			=> wrusedw1,
		
		wmax			=> "1101111110", --0x37E
		esize			=> "0001111111"
	);


	c1_fifo_module:
	dcfifom port map
	(	
		clk				=> adc12_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr1,
		d				=> CONV_STD_LOGIC_VECTOR(adc12_data, 10), --"0101010101", -- 
		
		rd				=> rd1,
		q				=> q1,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw1,
		wrusedw		=> wrusedw1
	);

	c1_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren1,
		isidle			=> rii1,

		rd				=> rd1,
		q				=> q1,
				
		usedw			=> rdusedw1,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ******************************* ACQ - CHANNEL 2 ****************************

	nadc12_dco <= not(adc12_dco);
	
	c2_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> nadc12_dco,
		trig_in			=> trigger_a,
		trig_out		=> ntrigger12
	);

	c2_stream_IN:
	writefifo port map
	(	
		clk				=> nadc12_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open,
		
		trig0 			=> ntrigger12,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr2,
				
		usedw			=> wrusedw2,
		
		wmax			=> "1101111110", --0x37E
		esize			=> "0001111111"
	);


	c2_fifo_module:
	dcfifom port map
	(	
		clk				=> nadc12_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr2,
		d				=> CONV_STD_LOGIC_VECTOR(adc12_data, 10), --"1010101010", -- 
		
		rd				=> rd2,
		q				=> q2,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw2,
		wrusedw		=> wrusedw2
	);

	c2_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren2,
		isidle			=> rii2,

		rd				=> rd2,
		q				=> q2,
				
		usedw			=> rdusedw2,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ******************************* ACQ - CHANNEL 3 ****************************


	c3_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> adc34_dco,
		trig_in			=> trigger_a,
		trig_out		=> ptrigger34
	);

	c3_stream_IN:
	writefifo port map
	(	
		clk				=> adc34_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open, --flag,
		
		trig0 			=> ptrigger34,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr3,
				
		usedw			=> wrusedw3,
		
		wmax			=> "1101111110", --0x37E
		esize			=> "0001111111"
	);


	c3_fifo_module:
	dcfifom port map
	(	
		clk				=> adc34_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr3,
		d				=> CONV_STD_LOGIC_VECTOR(adc34_data, 10), --"0101010101", -- 
		
		rd				=> rd3,
		q				=> q3,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw3,
		wrusedw		=> wrusedw3
	);

	c3_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren3,
		isidle			=> rii3,

		rd				=> rd3,
		q				=> q3,
				
		usedw			=> rdusedw3,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ******************************* ACQ - CHANNEL 4 ****************************

	nadc34_dco <= not(adc34_dco);
	
	c4_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> nadc34_dco,
		trig_in			=> trigger_a,
		trig_out		=> ntrigger34
	);

	c4_stream_IN:
	writefifo port map
	(	
		clk				=> nadc34_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open,
		
		trig0 			=> ntrigger34,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr4,
				
		usedw			=> wrusedw4,
		
		wmax			=> "1101111110", --0x37E
		esize			=> "0001111111"
	);


	c4_fifo_module:
	dcfifom port map
	(	
		clk				=> nadc34_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr4,
		d				=> CONV_STD_LOGIC_VECTOR(adc34_data, 10), --"1010101010", -- 
		
		rd				=> rd4,
		q				=> q4,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw4,
		wrusedw		=> wrusedw4
	);

	c4_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren4,
		isidle			=> rii4,

		rd				=> rd4,
		q				=> q4,
				
		usedw			=> rdusedw4,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ******************************* ACQ - CHANNEL 5 ****************************


	c5_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> adc56_dco,
		trig_in			=> trigger_a,
		trig_out		=> ptrigger56
	);

	c5_stream_IN:
	writefifo port map
	(	
		clk				=> adc56_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open, --flag,
		
		trig0 			=> ptrigger56,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr5,
				
		usedw			=> wrusedw5,
		
		wmax			=> "1101111110", --0x37E
		esize			=> "0001111111"
	);


	c5_fifo_module:
	dcfifom port map
	(	
		clk				=> adc56_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr5,
		d				=> CONV_STD_LOGIC_VECTOR(adc56_data, 10), --"0101010101", -- 
		
		rd				=> rd5,
		q				=> q5,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw5,
		wrusedw		=> wrusedw5
	);

	c5_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren5,
		isidle			=> rii5,

		rd				=> rd5,
		q				=> q5,
				
		usedw			=> rdusedw5,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ******************************* ACQ - CHANNEL 6 ****************************

	nadc56_dco <= not(adc56_dco);
	
	c6_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> nadc56_dco,
		trig_in			=> trigger_a,
		trig_out		=> ntrigger56
	);

	c6_stream_IN:
	writefifo port map
	(	
		clk				=> nadc56_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open,
		
		trig0 			=> ntrigger56,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr6,
				
		usedw			=> wrusedw6,
		
		wmax			=> "1101111110", --0x37E
		esize			=> "0001111111"
	);


	c6_fifo_module:
	dcfifom port map
	(	
		clk				=> nadc56_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr6,
		d				=> CONV_STD_LOGIC_VECTOR(adc56_data, 10), --"1010101010", -- 
		
		rd				=> rd6,
		q				=> q6,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw6,
		wrusedw		=> wrusedw6
	);

	c6_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren6,
		isidle			=> rii6,

		rd				=> rd6,
		q				=> q6,
				
		usedw			=> rdusedw6,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ******************************* ACQ - CHANNEL 7 ****************************


	c7_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> adc78_dco,
		trig_in			=> trigger_a,
		trig_out		=> ptrigger78
	);

	c7_stream_IN:
	writefifo port map
	(	
		clk				=> adc78_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open, --flag,
		
		trig0 			=> ptrigger78,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr7,
				
		usedw			=> wrusedw7,
		
		wmax			=> "1101111110", --0x37E
		esize			=> "0001111111"
	);


	c7_fifo_module:
	dcfifom port map
	(	
		clk				=> adc78_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr7,
		d				=> CONV_STD_LOGIC_VECTOR(adc78_data, 10), --"0101010101", -- 
		
		rd				=> rd7,
		q				=> q7,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw7,
		wrusedw		=> wrusedw7
	);

	c7_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren7,
		isidle			=> rii7,

		rd				=> rd7,
		q				=> q7,
				
		usedw			=> rdusedw7,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ******************************* ACQ - CHANNEL 8 ****************************

	nadc78_dco <= not(adc78_dco);
	
	c8_etrigger_cond:
	tpulse port map
	(	
		rst				=> rst,
		clk				=> nadc78_dco,
		trig_in			=> trigger_a,
		trig_out		=> ntrigger78
	);

	c8_stream_IN:
	writefifo port map
	(	
		clk				=> nadc78_dco,
		rst				=> rst,
		rclk			=> pclk,
		
		acqin			=> open,
		
		trig0 			=> ntrigger78,
		trig1 			=> '0',
		trig2			=> '0',

		wr				=> wr8,
				
		usedw			=> wrusedw8,
		
		wmax			=> c8wmax,	--"1101111110", --0x37E
		esize			=> "0001111111"
	);


	c8_fifo_module:
	dcfifom port map
	(	
		clk				=> nadc78_dco,
		rdclk			=> pclk,
		rst				=> rst,
		rclk			=> pclk,
		
		wr				=> wr8,
		d				=> CONV_STD_LOGIC_VECTOR(adc78_data, 10), --"1010101010", -- 
		
		rd				=> rd8,
		q				=> q8,
		
		f				=> open,
		e				=> open,

		rdusedw		=> rdusedw8,
		wrusedw		=> wrusedw8
	);

	c8_stream_OUT:
	readfifo port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> ren8,
		isidle			=> rii8,

		rd				=> rd8,
		q				=> q8,
				
		usedw			=> rdusedw8,
	
		wro				=> wr,
		dwait 			=> dwait,
		odata        	=> txbus,	

		rmin			=> "0001111111",
		esize			=> "0001111111"
	);


-- ************************************ TDC ***********************************

	tdc_top:
	tdc	port map
	(	
		rst				=> rst,
		clk				=> pclk,	-- clock
		
		-------------------
		-- TDC interface --
		-------------------
		iotdc_data		=> tdc_data,
		otdc_stopdis	=> tdc_stop_dis,
		tdc_start_dis 	=> tdc_start_dis,
		otdc_rdn		=> tdc_rdn,
		otdc_wrn		=> tdc_wrn,
		otdc_csn	 	=> tdc_csn_wire,
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
		conf_done		=> trigger_c,		-- sinal no painel do NDAQ
		rd_en		 	=> tdc_rdstb,	-- barramento 4 bits -- Read enable to read TDC 8-bit bus data
		en_read		 	=> tdc_rden,	-- começa -- Read enable to read TDC
		tdc_out_HB	 	=> txbus, 		-- TDC Data Bus (HIGHEST Byte)
		tdc_out_MH	 	=> txbus, 		-- TDC Data Bus (MEDIUM HIGH Byte)
		tdc_out_ML	 	=> txbus, 		-- TDC Data Bus (MEDIUM LOW Byte)
		tdc_out_LB	 	=> txbus, 		-- TDC Data Bus (HIGHEST Byte)		
		otdc_data		=> open,
		data_valid		=> data_valid,	-- Handshaking.
		start_conf		=> tdcstart		-- Start the configuration machine (active high pulse with 2-periods width)
	);
	
	
	tdc_csn <= tdc_csn_wire;
	trigger_b <= tdc_csn_wire; --tdc_ef1;
	--trigger_c <= tdc_ef2;
	
	tdc_reader:
	readtdc	port map
	(	
		clk				=> pclk,
		rst				=> rst,
	
		enable			=> en3,
		isidle			=> ii3,

		data_valid		=> data_valid,
		
		rd_en			=> tdc_rden,
		rd_stb			=> tdc_rdstb,
		
		wro				=> wr,
		dwait 			=> dwait
	);


-- ************************************ BRIDGE ********************************

	--63488b reset manager
	rstc_gen:
	rstgen port map
	(	
		clk				=> mclk,
		
		reset			=> resetc,
		
		rst				=> rstc
	);

	master_usb_transceiver_if:
	m_trif port map
	(
		clk				=> mclk,		
		clk_en			=> '1', 
		rst				=> rst,
		rstc    		=> rstc,
		
		-- params
		bcount			=> bcount,
		
		-- local
		dwait			=> dwait,
		davail			=> davail,
		nwr				=> wr,
		nrd				=> rd,
		idata			=> txbus,
		odata			=> rxbus,

		-- bridge
		sdwait			=> bridge_dw,
		sdavail			=> bridge_da,
		snwr			=> bridge_wr,
		snrd			=> bridge_rd,
		iodata			=> bridge_data
	);


end rtl;
