------------------------------------------------------------------------------
-- TOP!
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.vmeif_pkg.all;
use work.vmeif_usr.all;
use work.vme_regs.all;

use work.functions_pkg.all;			-- Misc. functions
use work.databuilder_pkg.all;		-- Data Builder definitions

entity ndaq_vme is 
	port
	(	
		------------
		-- AD9510  --
		------------
		signal stsclk		:in			std_logic; -- AD9510 Status
		
		-------------
		-- VME bus --
		-------------
		signal vme_add 		:in  		std_logic_vector(31 downto 1);-- 'vmeif' OK :VME Address Bus
		signal vme_oea		:out  		std_logic;-- 'vmeif' OK ('vme_xbuf_addrle') :VME Address Bus Enable
				
		signal vme_data		:inout 		std_logic_vector(31 downto 0);-- 'vmeif' OK :VME Data Bus
		signal vme_oed		:out  		std_logic;-- 'vmeif' OK ('vme_xbuf_dataoe') :VME Data Bus Enable
		signal vme_dird		:out  		std_logic;-- 'vmeif' OK ('vme_xbuf_datadir'):VME Data Bus Direction
		
		signal vme_gap 		:in  		std_logic;-- 'vmeif' OK						:VME Geographical Address Parity
		signal vme_ga 		:in  		std_logic_vector(4 downto 0);-- 'vmeif' OK	:VME Geographical Address
		
		signal vme_dtack	:out 		std_logic;-- 'vmeif' OK						: VME Data Transfer Acknowledge
		signal vme_oetack	:out 		std_logic;-- 'vmeif' OK ('vme_xbuf_dtackoe'): VME Data Transfer Acknowledge Output Enable
		signal vme_vack		:in  		std_logic;-- 'vmeif' OK						: VME Data Transfer Acknowledge Read Value
		
		signal vme_as 		:in  		std_logic;-- 'vmeif' OK						: VME Address Strobe
		signal vme_lw 		:in  		std_logic;-- 'vmeif' OK ('vme_lword')		: VME Long Word
		signal vme_wr 		:in  		std_logic;-- 'vmeif' OK ('vme_write')		: VME Read/Write
		signal vme_ds0 		:in  		std_logic;-- 'vmeif' OK						: VME Data Strobe 0
		signal vme_ds1 		:in  		std_logic;-- 'vmeif' OK						: VME Data Strobe 1
		signal vme_am 		:in  		std_logic_vector(5 downto 0);-- 'vmeif' OK	: VME Address Modifier
		signal vme_sysrst	:in  		std_logic;-- 'vmeif' OK ('vme_sysreset')	: VME System Reset
		signal vme_sysclk	:in  		std_logic;-- 'vmeif' OK ('vme_sysclock')	: VME System Clock
		
		signal vme_iack		:in  		std_logic;-- 'vmeif' OK						: VME Interrupt Acknowledge
		signal vme_iackin	:in  		std_logic;-- 'vmeif' OK ('vme_iack_in')		: VME Interrupt Acknowledge Daisy-Chain Input
		signal vme_iackout	:out		std_logic;-- 'vmeif' OK ('vme_iack_out')	: VME Interrupt Acknoweldge Daisy-Chain Output
		signal vme_irq		:out		std_logic_vector(7 downto 1);-- 'vmeif' OK	: VME Interrupt Request
		
		signal vme_berr		:out  		std_logic;-- 'vmeif' OK						: VME Bus Error
		signal vme_verr		:in  		std_logic;-- 'vmeif' OK						: VME Bus Error Read Value
		

		-------------------
		-- USB interface --
		-------------------
		signal usb_Write   : out	std_Logic;
		signal usb_Read    : out	std_Logic;
		signal usb_RXF     : in     std_logic;
		signal usb_TXE     : in     std_Logic;
		signal usb_Data    : inout  std_logic_vector(7 downto 0);
				
		----------------
		-- CLK system --
		----------------
		signal clk50M 		:in  	std_logic;

		---------------------
		-- FIFOs interface --
		---------------------
		--signal fifo1_oe 	:out  	std_logic;
		--signal fifo2_oe 	:out  	std_logic;
		--signal fifo3_oe 	:out  	std_logic;
		--signal fifo4_oe 	:out  	std_logic;
		
		signal fifo_oe		:out	std_logic_vector(3 downto 0) := x"F";
		
		--signal fifo1_ren 	:out  	std_logic;
		--signal fifo2_ren 	:out  	std_logic;
		--signal fifo3_ren 	:out  	std_logic;
		--signal fifo4_ren 	:out  	std_logic;
		
		signal fifo_ren		:out	std_logic_vector(3 downto 0) := x"F";
		
		--signal fifo1_ef 	:in  	std_logic;
		--signal fifo2_ef 	:in  	std_logic;
		--signal fifo3_ef 	:in  	std_logic;
		--signal fifo4_ef 	:in  	std_logic;

		signal fifo_ef		:in		std_logic_vector(3 downto 0);

		-- FIFO's programmable almost empty flag. These signals come from Core FPGA.
		signal fifo_pae		:in		std_logic_vector(3 downto 0);
		
		----------------
		-- Master SPI --
		----------------
		
		signal spiclk		:out	std_logic;
		signal mosi			:out	std_logic;
		signal miso			:in		std_logic;
		signal cs			:out	std_logic;
		
		-------------------
		-- CAN interface --
		-------------------
		signal can_pgc	 	 :out  	std_logic;
		signal can_pgd	 	 :out  	std_logic;
		signal can_pgm	 	 :out  	std_logic;
		
		-----------------
		-- Test Points --
		-----------------
		
		signal t1_a			:out	std_logic;
		signal t1_b			:out	std_logic
	);
end ndaq_vme;

architecture rtl of ndaq_vme is

------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------

	-- Clock Manager
	component clkman
	port
	(	
		signal iclk				: in 	std_logic;
		 	
		signal pclk				: out	std_logic;
		signal nclk				: out	std_logic;
		signal mclk    			: out	std_logic;
		signal sclk    			: out	std_logic;
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

	-- FT245BM Interface
	component ft245bm_if
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal ftclk			: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; 

		-- local bus
		signal dwait			: out	std_logic;
		signal dataa			: out	std_logic;
		signal wr				: in 	std_logic;
		signal rd				: in 	std_logic;
		signal idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out	std_logic_vector(7 downto 0);

		-- ftdi bus
		signal f_txf			: in	std_logic;
		signal f_rxf			: in 	std_logic;
		signal f_wr				: out	std_logic;
		signal f_rd				: out	std_logic;
		signal f_iodata			: inout	std_logic_vector(7 downto 0)
	);
	end component;

	-- Master SPI
	component m_spi
	port
	(	
		signal clk				: in	std_logic;						-- sytem clock (@20 MHz)
		signal rst				: in 	std_logic;						-- asynchronous reset
		
		signal mosi				: out	std_logic := '0';				-- master serial out	- slave serial in
		signal miso				: in	std_logic;						-- master serial in	- slave serial out
		signal sclk				: out	std_logic := '0';				-- spi clock out
		signal cs				:out	std_logic := '0';				-- chip select
		
		signal wr				: in	std_logic;						-- write strobe
		signal rd				: in	std_logic;						-- read strobe
		
		signal dwait			: out	std_logic := '0';				-- dwait flag
		signal dataa			: out	std_logic := '0';				-- data avaiable flag
		
		signal idata			: in	std_logic_vector(7 downto 0);	-- data input parallel bus
		signal odata			: out	std_logic_vector(7 downto 0)	-- data output parallel bus	
	);
	end component;

	-- VME controller developed at CERN (Per Gallno -> Herman -> Ralf)
	component vmeif
	port
	( testpin			: out	std_logic;
	  vme_addr			: in	std_logic_vector(31 downto 1);									-- VME address bus
	  vme_xbuf_addrle 	: out	std_logic;														-- VME address bus latch enable
      vme_am			: in	std_logic_vector(5 downto 0);  									-- VME address modifier code
	  vme_data			: inout	std_logic_vector(31 downto 0);									-- VME data bus
	  vme_xbuf_dataoe	: out	std_logic;														-- VME data bus output enable
	  vme_xbuf_datadir	: out	std_logic;														-- VME data bus direction
	  vme_lword			: in	std_logic;														-- VME long word
	  vme_dtack			: out	std_logic;														-- VME data transfer acknowledge
	  vme_xbuf_dtackoe	: out	std_logic;														-- VME data transfer acknowledge output enable
	  vme_vack			: in	std_logic;														-- VME data transfer acknowledge read value
	  vme_as			: in	std_logic;														-- VME address strobe
	  vme_ds0			: in	std_logic;														-- VME data strobe #0
	  vme_ds1			: in	std_logic;														-- VME data strobe #1
	  vme_write			: in	std_logic;														-- VME read/write
	  vme_iack			: in	std_logic;														-- VME interrupt acknowledge
	  vme_iack_in		: in	std_logic;														-- VME interrupt acknowledge daisy-chain input
	  vme_iack_out		: out	std_logic;														-- VME interrupt acknoweldge daisy-chain output
	  vme_irq			: out	std_logic_vector(7 downto 1);									-- VME interrupt request
	  vme_berr			: out	std_logic;														-- VME bus error
	  vme_verr			: in	std_logic;														-- VME bus error read value
	  vme_sysreset		: in	std_logic;														-- VME system reset
	  vme_sysclock		: in	std_logic;														-- VME system clock
	  vme_retry			: out	std_logic;														-- VME retry
	  vme_xbuf_retryoe	: out	std_logic;														-- VME retry output enable
	  vme_ga			: in	std_logic_vector(4 downto 0);									-- VME geographical address
	  vme_gap			: in	std_logic;														-- VME geographical address parity
	  powerup_reset		: in	std_logic := '0';												-- COM power-up reset
	  clock_40mhz		: in	std_logic;														-- COM 40 MHz clock
	  user_addr			: out	std_logic_vector(24 downto 0);									-- USR latched address bus (32-bit words)
	  user_am			: out	std_logic_vector(5 downto 0);									-- USR addres modifier
	  user_data			: inout	std_logic_vector(31 downto 0);									-- USR data bus
	  user_read			: out	std_logic_vector((NUM_USR_MAP-1) downto 0);						-- USR read strobe
	  user_write		: out	std_logic_vector((NUM_USR_MAP-1) downto 0);						-- USR vme_writeite strobe
	  user_dtack		: in	std_logic_vector((NUM_USR_MAP-1) downto 0) := (others => '0');	-- USR data transfer acknowledge
	  user_error		: in	std_logic_vector((NUM_USR_MAP-1) downto 0) := (others => '0');	-- USR error
	  user_ireq			: in	std_logic_vector((NUM_USR_IRQ-1) downto 0) := (others => '0');	-- USR interrupt request
	  user_iack			: out	std_logic_vector((NUM_USR_IRQ-1) downto 0);						-- USR interrupt acknowledge
	  user_reset		: out	std_logic_vector((NUM_USR_RST-1) downto 0);						-- USR reset	
	  user_addr_out		: out	std_logic_vector(24 downto 0);									-- USR latched address bus (32-bit words)
	  user_am_out		: out	std_logic_vector(5 downto 0);									-- USR addres modifier
	  user_data_out		: out	std_logic_vector(31 downto 0);									-- USR data bus
	  user_valid		: out	std_logic;														-- USR addr/am/data valid
	  user_data_in		: in	std_logic_vector(31 downto 0) := (others => '0'));				-- USR data bus
	end component;

	-- Registers
	component vme_rconst
	port
	(
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		
		--register/peripherals's multi access input strobes
		signal a_wr				: in	std_logic_vector((num_regs-1) downto 0);
		signal a_rd				: in	std_logic_vector((num_regs-1) downto 0);

		signal b_wr				: in	std_logic_vector((num_regs-1) downto 0);
		signal b_rd				: in	std_logic_vector((num_regs-1) downto 0);

		--common i/o
		signal a_idata			: in	std_logic_vector(7 downto 0);
		signal b_idata			: in	std_logic_vector(7 downto 0);
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
	component vme_cmddec
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

	-- Internal USB mode readout FIFO
	component readout_fifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdfull		: OUT STD_LOGIC ;
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		wrfull		: OUT STD_LOGIC ;
		wrempty		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component;

	-- FIFO to FT245BM interface copier
	component f2ft_copier is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		-- Arbiter interface
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if
	
		-- FIFO interface
		signal ef				: in	std_logic;
		signal usedw			: in	std_logic_vector(9 downto 0);
		signal rd				: out	std_logic;	
		signal q				: in	std_logic_vector(7 downto 0);
				
		-- FT245BM interface
		signal dwait 			: in	std_logic;
		signal wr				: out	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0)
	);
	end component;

	
---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------

	signal srst, mrst			: std_logic;
	signal pclk, sclk, mclk		: std_logic; 
	signal tclk, clk_en			: std_logic;
	
	signal user_read			: std_logic_vector((NUM_USR_MAP-1) downto 0);
	signal user_write			: std_logic_vector((NUM_USR_MAP-1) downto 0);

	signal user_data_in			: std_logic_vector(31 downto 0);
	signal user_data_out		: std_logic_vector(31 downto 0);
	signal user_addr			: std_logic_vector(24 downto 0);
	-- signal clk_wr, clk_rd		: std_logic; 						-- TEST by HERMAN 29/07/10
	-- signal iuser_addr_lat		: std_logic_vector(7 downto 0);		-- Added by Herman in 08/09/10
	
	--
	-- FSM para condicionar os sinais user_read(0), user_read(1), user_read(3) e user_read(4). 
	type trig is (s_one, s_two, s_three);
	signal state_trig  : trig;
	signal bstate_trig : trig;
	signal cstate_trig : trig;
	signal dstate_trig : trig;

	signal u_fifo_ren	: std_logic_vector(3 downto 0);

	-- FT245bm_if
	signal ft_wr	: std_logic := '1';
	signal ft_rd	: std_logic := '1';
	signal ft_idata	: std_logic_vector(7 downto 0) := x"00";
	signal ft_odata	: std_logic_vector(7 downto 0) := x"00";

	signal ft_dwait	: std_logic := '0';
	signal ft_dataa	: std_logic := '0';
			
	-- Command Decoder / Registers
	signal a_wr			: std_logic_vector((num_regs-1) downto 0);
	signal a_rd			: std_logic_vector((num_regs-1) downto 0);

	signal b_wr			: std_logic_vector((num_regs-1) downto 0);
	signal b_rd			: std_logic_vector((num_regs-1) downto 0);
	
	signal p_wr			: std_logic_vector((num_regs-1) downto 0);
	signal p_rd			: std_logic_vector((num_regs-1) downto 0);

	signal ireg			: SYS_REGS;
	signal oreg			: SYS_REGS;

	signal a_reg_idata	: std_logic_vector(7 downto 0);
	signal b_reg_idata	: std_logic_vector(7 downto 0);
	signal reg_odata	: std_logic_vector(7 downto 0);

	signal spi_status	: std_logic_vector(7 downto 0);

	--
	-- USB Readout Channels
	--
	constant	usb_channels :	integer := 4;
	constant	EVENT_SIZE   : unsigned	:= x"7F";		

	-- USB Readout Reset
	signal rdout_rst		: std_logic;

	-- Data Builder
	signal	enable_A		: SLOTS_T;
	signal	enable_B		: SLOTS_T;
	signal	transfer		: TRANSFER_A;
	signal	address			: ADDRESS_A;
	signal	mode			: SLOTS_T;
	
	--
	signal	db_rd			: SLOTS_T;
	signal  db_idata		: IDATA_A;
	
	--
	signal	db_wr			: ADDRESS_T;
	signal	db_odata		: ODATA_T;
	
	-- USB Readout FIFO
	signal usb_fifo_rd		: std_logic;
	signal usb_fifo_q		: std_logic_vector(7 downto 0);
	signal usb_fifo_rdempty	: std_logic;
	signal usb_fifo_wrempty	: std_logic;
	signal usb_fifo_wrusedw	: std_logic_vector(7 downto 0);
	signal usb_fifo_rdusedw	: std_logic_vector(9 downto 0);
	
------------------------------------------
------------------------------------------


begin
	
	-- Test Points
	t1_a	<= pclk;
	t1_b	<= sclk;
	
	can_pgc <= stsclk;
	can_pgd <= 'Z';
	can_pgm <= 'Z';

--	vme_berr		<= 'Z';
	vme_irq		<= (others => 'Z');
--	vme_oetack	<= 'Z';
--	vme_dtack	<= 'Z';
--	vme_dird	<= 'Z';
--	vme_oed		<= 'Z';
--	vme_data	<= (others => 'Z');
	vme_oea		<= '0'; --'Z';


------------------------
--********************--
--******* MAPS *******--
--********************--
------------------------

	master_rst_gen:
	rstgen port map
	(	
		clk				=> pclk,
		
		reset			=> oreg(0),
		
		rst				=> mrst
	);

	clock_manager: 
	clkman port map 
	(
		iclk				=> clk50M,
		
		pclk				=> pclk,	--50 MHz - 0	degree
		nclk				=> open,	--50 MHz - 180	degrees
		mclk				=> open,    --40 MHz
		sclk				=> sclk,    --20 MHz
		clk_enable			=> open,
		tclk				=> open
	);
	
	--pclk	<= clk50M;
	
--*********************************************************************************************************	
	
	usb_transceiver_if:
	ft245bm_if port map
	(	
		clk				=> pclk,
		ftclk			=> sclk,
		clk_en			=> '1',
		rst				=> mrst,

		enable			=> '1',

		-- local bus
		dwait			=> ft_dwait,
		dataa			=> ft_dataa,
		wr				=> ft_wr,
		rd				=> ft_rd,
		idata			=> ft_idata,
		odata			=> ft_odata,

		-- ftdi bus
		f_txf			=> usb_TXE,
		f_rxf			=> usb_RXF,
		f_wr			=> usb_Write,
		f_rd			=> usb_Read,
		f_iodata		=> usb_Data
	);


--*********************************************************************************************************	

	Master_SPI: 
	m_spi
	port map
	(	
		clk			=> pclk,			-- sytem clock
		rst			=> mrst,			-- asynchronous reset
		
		mosi		=> mosi,			-- master serial out	- slave serial in
		miso		=> miso,			-- master serial in		- slave serial out
		sclk		=> spiclk,			-- spi clock out
		cs			=> cs,				-- chip select
		
		wr			=> p_wr(3),			-- write strobe
		rd			=> p_rd(3),			-- read strobe
		
		dwait		=> spi_status(0),	-- busy flag
		dataa		=> spi_status(1),	-- data avaiable flag
		
		idata		=> oreg(3),			-- data input parallel bus
		odata		=> ireg(3)			-- data output parallel bus	
	);
	
	ireg(4)			<= spi_status;
	
--*********************************************************************************************************

	my_vmeif:
	vmeif port map (		
							user_addr			=> user_addr,
							user_data_in		=> user_data_in,
							user_data_out		=> user_data_out,
							user_read			=> user_read,
							user_write			=> user_write,
							vme_addr			=> vme_add,
							vme_am				=> vme_am,
							vme_data			=> vme_data,
							vme_xbuf_dataoe		=> vme_oed,		--
							vme_xbuf_datadir	=> vme_dird,	--
							vme_lword			=> vme_lw,
							vme_dtack			=> vme_dtack,	--
							vme_xbuf_dtackoe	=> vme_oetack,	--
							vme_vack			=> vme_vack,
							vme_as				=> vme_as,
							vme_ds0				=> vme_ds0,
							vme_ds1				=> vme_ds1,
							vme_write			=> vme_wr,
							vme_iack			=> vme_iack,
							vme_iack_in			=> vme_iackin,
							vme_iack_out		=> vme_iackout,
							vme_irq				=> open,
							vme_berr			=> vme_berr,	--
							vme_verr			=> vme_verr,
							vme_sysreset		=> vme_sysrst,
							vme_sysclock		=> vme_sysclk,
							vme_ga				=> vme_ga,
							vme_gap				=> vme_gap,
							clock_40mhz			=> pclk
					);

							
--*********************************************************************************************************

	registers:
	vme_rconst port map
	(
		clk				=> pclk,
		rst				=> mrst,

		--register's strobes
		a_wr			=> a_wr,
		a_rd			=> a_rd,
		
		--register's strobes
		b_wr			=> b_wr,
		b_rd			=> b_rd,

		a_idata			=> a_reg_idata,
		b_idata			=> b_reg_idata,
		odata			=> reg_odata,
		
		--register's individual i/os
		ireg			=> ireg,
		oreg			=> oreg,

		--peripherals outputs strobes
		p_wr			=> p_wr,
		p_rd			=> p_rd
	);

	-- Status Register assignements
	ireg(5)(0)			<= fifo_pae(0);
	ireg(5)(1)			<= fifo_pae(1);
	ireg(5)(2)			<= fifo_pae(2);
	ireg(5)(3)			<= fifo_pae(3);
	ireg(5)(6 downto 4)	<= (others => '0');
	ireg(5)(7)			<= stsclk;

	-- VME Registers Assignments.	*** MUST MAKE THAT AUTOMATIC ! ***
	b_wr(0)		<= user_write(9);
	b_wr(1)		<= '0';
	b_wr(2)		<= '0';
	b_wr(3)		<= user_write(5);
	b_wr(4)		<= user_write(6);
	b_wr(5)		<= user_write(4);	
	b_wr(6)		<= '0';
	b_wr(7)		<= user_write(7);
	b_wr(8)		<= '0';
	b_wr(9)		<= user_write(8);
	b_wr(10)	<= user_write(10);
	
	b_rd(0)		<= user_read(9);
	b_rd(1)		<= '0';
	b_rd(2)		<= '0';
	b_rd(3)		<= user_read(5);
	b_rd(4)		<= user_read(6);
	b_rd(5)		<= user_read(4);	
	b_rd(6)		<= '0';
	b_rd(7) 	<= user_read(7);
	b_rd(8) 	<= '0';
	b_rd(9) 	<= user_read(8);
	b_rd(10) 	<= user_read(10);
		
	-- VME Interface Data Output to Registers Data Input:
	b_reg_idata					<=	user_data_out(7 downto 0);
	
	-- Registers Data Output to VME Interface Data Input:
	user_data_in(7 downto 0)	<=	reg_odata;
	user_data_in(31 downto 8)	<=	(others => '0');	

--*****************************************************************************

	-- USB Command Decoder
	command_decoder:
	vme_cmddec port map
	(
		clk				=> pclk,
		rst				=> mrst,
		
		--arbiter
		enable			=> oreg(1)(7), -- Command Response Enable - 0x80 @ 0x80.
		isidle			=> open,
		
		--flags
		dwait			=> ft_dwait,
		dataa			=> ft_dataa,

		--FT245BM_if strobes
		wr				=> ft_wr,
		rd				=> ft_rd,
		
		--FT245BM_if local bus
		idata			=> ft_odata,
		odata			=> ft_idata,

		--register's strobes
		reg_wr			=> a_wr,
		reg_rd			=> a_rd,
		
		--register's i/os
		reg_idata		=> reg_odata,
		reg_odata		=> a_reg_idata
	);

--*********************************************************************************************************

	--Readout Reset Assignement
	process(pclk, mrst)
	begin
		if (mrst = '1') then
			rdout_rst <= '1';
		elsif (rising_edge(pclk)) then
			rdout_rst <= oreg(6)(0);
		end if;
	end process;

--*********************************************************************************************************
	
	fifo_signals_construct:
	for i in 0 to (usb_channels-1) generate
	
		fifo_ren(i)	<= 	not(db_rd(i)) xnor u_fifo_ren(i);
		fifo_oe(i)	<= 	not(db_rd(i)) xnor not(user_read(i));
	
	end generate fifo_signals_construct;
	
--*********************************************************************************************************
	
	data_builder: 
	databuilder port map 
	(
		--
		rst							=> rdout_rst, --mrst,
		clk							=> pclk,
		
		--
		enable						=> oreg(1)(0),	-- Readout Enable.
		
		--
		enable_A					=> enable_A,
		enable_B					=> enable_B,
		transfer					=> transfer,
		address						=> address,
		mode						=> mode,
		
		--
		rd							=> db_rd,
		idata						=> db_idata,
		
		--
		wr							=> db_wr,
		odata						=> db_odata
	);

--
-- Data Builder Slots Construct
--

	db_idata(0)		<= vme_data; --x"2000" & x"1000";
	db_idata(1)		<= vme_data; --x"4000" & x"3000";
	db_idata(2)		<= vme_data; --x"6000" & x"5000";
	db_idata(3)		<= vme_data; --x"8000" & x"7000";
	
	enable_A(0)		<= oreg(2)(0);	--Slot Enable.
	enable_A(1)		<= oreg(2)(1);
	enable_A(2)		<= oreg(2)(2);
	enable_A(3)		<= oreg(2)(3);
	
	enable_B(0)		<= fifo_pae(0) and usb_fifo_wrempty;
	enable_B(1)		<= fifo_pae(1) and usb_fifo_wrempty;
	enable_B(2)		<= fifo_pae(2) and usb_fifo_wrempty;
	enable_B(3)		<= fifo_pae(3) and usb_fifo_wrempty;

	transfer(0)		<= oreg(8); --CONV_STD_LOGIC_VECTOR(127, NumBits(transfer_max)); 	-- 3*32bits words	= 12 bytes
	transfer(1)		<= oreg(8); --CONV_STD_LOGIC_VECTOR(127, NumBits(transfer_max)); 	-- 3*32bits words	= 12 bytes
	transfer(2)		<= oreg(8); --CONV_STD_LOGIC_VECTOR(127, NumBits(transfer_max));	-- 3*32bits words	= 12 bytes
	transfer(3)		<= oreg(8); --CONV_STD_LOGIC_VECTOR(127, NumBits(transfer_max));	-- 3*32bits words	= 12 bytes
																						-- (+)Total			= 48 bytes
	address(0)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(1)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(2)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	address(3)		<= CONV_STD_LOGIC_VECTOR(0, NumBits(address_max));
	
	mode(0)			<= '0';
	mode(1)			<= '0';
	mode(2)			<= '0';
	mode(3)			<= '0';
	
--*********************************************************************************************************

	--
	usb_readout_fifo:
	readout_fifo port map
	(
		aclr		=> rdout_rst, --mrst,
		wrclk		=> pclk,
		rdclk		=> pclk,
		data		=> db_odata,
		rdreq		=> usb_fifo_rd,
		wrreq		=> db_wr(0),
		wrempty		=> usb_fifo_wrempty,
		wrfull		=> open,
		rdempty		=> usb_fifo_rdempty,
		rdfull		=> open,
		q			=> usb_fifo_q,
		wrusedw		=> usb_fifo_wrusedw,
		rdusedw		=> usb_fifo_rdusedw
	);

	--
	f_to_ft_copier:
	f2ft_copier port map
	(	
		clk			=> pclk,
		rst			=> rdout_rst, --mrst,

		-- Arbiter interface
		enable		=> not(oreg(1)(7)),  --NOT Command Response Enable.
		isidle		=> open,
	
		-- FIFO interface
		ef			=> usb_fifo_rdempty,
		usedw		=> usb_fifo_rdusedw,
		rd			=> usb_fifo_rd,
		q			=> usb_fifo_q,
		
		-- FT245BM interface
		dwait 		=> ft_dwait,
		wr			=> ft_wr,
		odata       => ft_idata
	);


--*********************************************************************************************************
--
--*********************************************************************************************************

--
-- Preliminary FSMs for RDENs
-- 

	process (mrst,pclk) begin
		if (mrst = '1') then
			state_trig <= s_one;
			u_fifo_ren(0) <= '1';
		elsif (pclk'event and pclk = '1') then
				case state_trig is
						
					when s_one =>
						if (user_read(0) = '1') then
							state_trig <= s_two;
							u_fifo_ren(0) <= '0';
						else
							state_trig <= s_one;
							u_fifo_ren(0) <= '1';
						end if;
						
					when s_two =>
						u_fifo_ren(0) <= '1';
						state_trig <= s_three;
						
					when s_three =>
						u_fifo_ren(0) <= '1';
						if (user_read(0) = '0') then
							state_trig <= s_one;
						else
							state_trig <= s_three;
						end if;
	
					when others =>
						u_fifo_ren(0) <= '1';
						state_trig <= s_one;
				
				end case;
		end if;
	end process;

	process (mrst,pclk) begin
		if (mrst = '1') then
			bstate_trig <= s_one;
			u_fifo_ren(1) <= '1';
		elsif (pclk'event and pclk = '1') then
				case bstate_trig is
						
					when s_one =>
						if (user_read(1) = '1') then
							bstate_trig <= s_two;
							u_fifo_ren(1) <= '0';
						else
							bstate_trig <= s_one;
							u_fifo_ren(1) <= '1';
						end if;
						
					when s_two =>
						u_fifo_ren(1) <= '1';
						bstate_trig <= s_three;
						
					when s_three =>
						u_fifo_ren(1) <= '1';
						if (user_read(1) = '0') then
							bstate_trig <= s_one;
						else
							bstate_trig <= s_three;
						end if;
	
					when others =>
						u_fifo_ren(1) <= '1';
						bstate_trig <= s_one;
				
				end case;
		end if;
	end process;

	process (mrst,pclk) begin
		if (mrst = '1') then
			cstate_trig <= s_one;
			u_fifo_ren(2) <= '1';
		elsif (pclk'event and pclk = '1') then
				case cstate_trig is
						
					when s_one =>
						if (user_read(2) = '1') then
							cstate_trig <= s_two;
							u_fifo_ren(2) <= '0';
						else
							cstate_trig <= s_one;
							u_fifo_ren(2) <= '1';
						end if;
						
					when s_two =>
						u_fifo_ren(2) <= '1';
						cstate_trig <= s_three;
						
					when s_three =>
						u_fifo_ren(2) <= '1';
						if (user_read(2) = '0') then
							cstate_trig <= s_one;
						else
							cstate_trig <= s_three;
						end if;
	
					when others =>
						u_fifo_ren(2) <= '1';
						cstate_trig <= s_one;
				
				end case;
		end if;
	end process;
	
	process (mrst,pclk) begin
		if (mrst = '1') then
			dstate_trig <= s_one;
			u_fifo_ren(3) <= '1';
		elsif (pclk'event and pclk = '1') then
				case dstate_trig is
						
					when s_one =>
						if (user_read(3) = '1') then
							dstate_trig <= s_two;
							u_fifo_ren(3) <= '0';
						else
							dstate_trig <= s_one;
							u_fifo_ren(3) <= '1';
						end if;
						
					when s_two =>
						u_fifo_ren(3) <= '1';
						dstate_trig <= s_three;
						
					when s_three =>
						u_fifo_ren(3) <= '1';
						if (user_read(3) = '0') then
							dstate_trig <= s_one;
						else
							dstate_trig <= s_three;
						end if;
	
					when others =>
						u_fifo_ren(3) <= '1';
						dstate_trig <= s_one;
				
				end case;
		end if;
	end process;

--

end rtl;