------------------------------------------------------------------------------
-- TOP!
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.vmeif_pkg.all;
use work.vmeif_usr.all;
use work.regs_pkg.all;

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
		
		----------------
		-- Master SPI --
		----------------
		
		signal spiclk		:out	std_logic;
		signal mosi			:out	std_logic;
		signal miso			:in		std_logic;
		
		-------------------
		-- CAN interface --
		-------------------
		signal can_pgc	 	 :out  	std_logic;
		signal can_pgd	 	 :out  	std_logic;
		signal can_pgm	 	 :out  	std_logic);
				
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
	component regs
	port
	(
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		
		--register/peripherals's multi access input strobes
		signal a_wr				: in	std_logic_vector((num_regs-1) downto 0);
		signal a_rd				: in	std_logic_vector((num_regs-1) downto 0);

		--signal b_wr			: in	std_logic_vector((num_regs-1) downto 0);
		--signal b_rd			: in	std_logic_vector((num_regs-1) downto 0);

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
	component cmddec
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
		signal usedw			: in	std_logic_vector(7 downto 0);
		signal rd				: out	std_logic;	
		signal q				: in	std_logic_vector(9 downto 0);
				
		-- FT245BM interface
		signal dwait 			: in	std_logic;
		signal wr				: out	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0);
		
		-- Parameters		
		signal rmin				: in 	std_logic_vector(7 downto 0);
		signal esize			: in	std_logic_vector(7 downto 0)
	);
	end component;

	-- Internal USB mode readout FIFO
	component readout_fifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component;

	-- IDT FIFO to Internal FIFO copier
	component f2f_copier
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
	
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal s_ef				: in	std_logic;
		signal s_rd				: out	std_logic;	
		
		signal ena				: in	std_logic;
		signal enb				: in	std_logic;
		
		signal a_ff				: in	std_logic;
		signal a_wr				: out	std_logic;		

		signal b_ff				: in	std_logic;
		signal b_wr				: out	std_logic;		
		
		signal esize			: in	std_logic_vector(7 downto 0)
	);
	end component;
	
	component priarb8
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		signal en	 			: out	std_logic_vector(7 downto 0) := x"00";

		signal ii				: in	std_logic_vector(7 downto 0);

		signal control        	: in	std_logic_vector(7 downto 0)
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
	signal iuser_data_in		: std_logic_vector(31 downto 0);	-- TEST by HERMAN 29/07/10
	signal iuser_data_out		: std_logic_vector(31 downto 0);	-- TEST by HERMAN 29/07/10
	signal iuser_addr			: std_logic_vector(24 downto 0);	-- Added by Herman in 08/09/10
	signal clk_wr, clk_rd		: std_logic; 						-- TEST by HERMAN 29/07/10
	signal iuser_addr_lat		: std_logic_vector(7 downto 0);		-- Added by Herman in 08/09/10
	
	--
	-- FSM para condicionar o sinal user_read(0)
	type trig is (s_one, s_two, s_three);
	signal state_trig  : trig;
	signal bstate_trig : trig;
	signal cstate_trig : trig;
	signal dstate_trig : trig;

	signal u_fifo1_ren	: std_logic;
	signal u_fifo2_ren	: std_logic;
	signal u_fifo3_ren	: std_logic;
	signal u_fifo4_ren	: std_logic;

	-- FT245bm_if
	signal ft_wr	: std_logic := '1';
	signal ft_rd	: std_logic := '1';
	signal ft_idata	: std_logic_vector(7 downto 0) := x"00";
	signal ft_odata	: std_logic_vector(7 downto 0) := x"00";

	signal ft_dwait	: std_logic := '0';
	signal ft_dataa	: std_logic := '0';
			
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

	signal spi_status	: std_logic_vector(7 downto 0);

	--

	--Temp for tests
	signal temp_wr				: std_logic;
	
	--
	-- USB Readout Channels
	--
	constant usb_channels :	integer := 4;
	
	type rdf_bus_t		is array ((usb_channels-1) downto 0) of std_logic_vector(9 downto 0);
	type rdf_usedw_t	is array ((usb_channels-1) downto 0) of std_logic_vector(7 downto 0);
	
	-- A Readout FIFO signals
	signal a_rdf_data	: rdf_bus_t;
	signal a_rdf_q		: rdf_bus_t;
	signal a_rdf_wr		: std_logic_vector((usb_channels-1) downto 0);
	signal a_rdf_ff		: std_logic_vector((usb_channels-1) downto 0);
	signal a_rdf_rd		: std_logic_vector((usb_channels-1) downto 0);
	signal a_rdf_ef		: std_logic_vector((usb_channels-1) downto 0);
	signal a_rdf_usedw	: rdf_usedw_t;

	-- B Readout FIFO signals
	signal b_rdf_data	: rdf_bus_t;
	signal b_rdf_q		: rdf_bus_t;
	signal b_rdf_wr		: std_logic_vector((usb_channels-1) downto 0);
	signal b_rdf_ff		: std_logic_vector((usb_channels-1) downto 0);
	signal b_rdf_rd		: std_logic_vector((usb_channels-1) downto 0);
	signal b_rdf_ef		: std_logic_vector((usb_channels-1) downto 0);
	signal b_rdf_usedw	: rdf_usedw_t;

	--

	--IDT Arbiter
	signal idt_en		: std_logic_vector(7 downto 0) := x"00";
	signal idt_ii		: std_logic_vector(7 downto 0) := x"FF";

	--USB Readout Arbiter
	signal usb_rdout_en	: std_logic_vector(7 downto 0) := x"00";
	signal usb_rdout_ii	: std_logic_vector(7 downto 0) := x"FF";

	--Main Arbiter
	signal main_en		: std_logic_vector(7 downto 0) := x"00";
	signal main_ii		: std_logic_vector(7 downto 0) := x"FF";

	-- Read enable, Output enable and Flag signals for IDT FIFOs
	signal rdtemp		: std_logic_vector((usb_channels-1) downto 0);
	
------------------------------------------
------------------------------------------


begin
	
	--fifo1_oe	<= '1'; --not(u_read0);
	--fifo2_oe	<= '1'; --not(u_read1);
	--fifo3_oe	<= '1'; --not(u_read2);
	--fifo4_oe	<= '1'; --not(u_read3);
	
	--fifo1_ren	<= '1'; --u_fifo1_ren;
	--fifo2_ren	<= '1'; --u_fifo2_ren;
	--fifo3_ren	<= '1'; --u_fifo3_ren;
	--fifo4_ren	<= '1'; --u_fifo4_ren;
	
	-- can_pgc <=  fifo1_ef;
	-- can_pgd <= 'Z';
	can_pgm <= 'Z';

--	vme_berr		<= 'Z';
	vme_irq		<= (others => 'Z');
--	vme_oetack	<= 'Z';
--	vme_dtack	<= 'Z';
--	vme_dird	<= 'Z';
--	vme_oed		<= 'Z';
--	vme_data	<= (others => 'Z');
	vme_oea		<= 'Z';


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
		f_wr			=> temp_wr, --usb_Write,
		f_rd			=> usb_Read,
		f_iodata		=> usb_Data
	);

	usb_Write	<= temp_wr;

	test_pins:
	can_pgc		<= not(ft_wr);
	can_pgd		<= temp_wr;

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
							--testpin			=> can_pgc,
							user_addr			=> iuser_addr,
							user_data_in		=> iuser_data_in,
							user_data_out		=> iuser_data_out,
							user_read			=> user_read,
							vme_addr			=> vme_add,
							vme_am				=> vme_am,
							vme_data			=> vme_data,
							vme_xbuf_dataoe		=> vme_oed, --
							vme_xbuf_datadir	=> vme_dird, --
							vme_lword			=> vme_lw,
							vme_dtack			=> vme_dtack, --
							vme_xbuf_dtackoe	=> vme_oetack, --
							vme_vack			=> vme_vack,
							vme_as				=> vme_as,
							vme_ds0				=> vme_ds0,
							vme_ds1				=> vme_ds1,
							vme_write			=> vme_wr,
							vme_iack			=> vme_iack,
							vme_iack_in			=> vme_iackin,
							vme_iack_out		=> vme_iackout,
							vme_irq				=> open, --vme_irq,
							vme_berr			=> vme_berr, --
							vme_verr			=> vme_verr,
							vme_sysreset		=> vme_sysrst,
							vme_sysclock		=> vme_sysclk,
							vme_ga				=> vme_ga,
							vme_gap				=> vme_gap,
							clock_40mhz			=> clk50M
					);

							
--*********************************************************************************************************

	registers:
	regs port map
	(
		clk				=> pclk,
		rst				=> mrst,

		--register's strobes
		a_wr			=> a_wr,
		a_rd			=> a_rd,
		
		idata			=> reg_odata,
		odata			=> reg_idata,
		
		--register's individual i/os
		ireg			=> ireg,
		oreg			=> oreg,

		--peripherals outputs strobes
		p_wr			=> p_wr,
		p_rd			=> p_rd
	);
	
	-- Command Decoder

	command_decoder:
	cmddec port map
	(
		clk				=> pclk,
		rst				=> mrst,
		
		--arbiter
		enable			=> main_en(7),
		isidle			=> main_ii(7),
		
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
		
		--register's strobes
		reg_idata		=> reg_idata,
		reg_odata		=> reg_odata
	);

--*********************************************************************************************************
	
	fifo_signals_construct:
	for i in 0 to (usb_channels-1) generate
	
		test_used:
		if (usb_channels > i) generate
			fifo_ren(i)	<= rdtemp(i);
			fifo_oe(i)	<= rdtemp(i);
		end generate test_used;
	
	end generate fifo_signals_construct;
	
--*********************************************************************************************************

	idt_arbiter:
	priarb8 port map
	(	
		clk					=> pclk,
		rst					=> mrst,

		enable				=> '1',
		isidle				=> open,

		en	 				=> idt_en,

		ii					=> idt_ii,

		control(0)			=> (oreg(2)(0) or oreg(2)(1)),	--Channel 1 or Channel 2 must read IDT FIFO 1. 
		control(1)			=> (oreg(2)(2) or oreg(2)(3)),	--Channel 3 or Channel 4 must read IDT FIFO 2. 
		control(2)			=> (oreg(2)(4) or oreg(2)(5)), 	--Channel 5 or Channel 6 must read IDT FIFO 3.
		control(3)			=> (oreg(2)(6) or oreg(2)(7)),	--Channel 7 or Channel 8 must read IDT FIFO 4.
		
		control(7 downto 4) => (others => '0')
	);
	
--*********************************************************************************************************
	
	usb_readout_construct:
	for i in 0 to (usb_channels-1) generate

	a_rdf_data(i)		<= vme_data(9 downto 0);	-- ODD Channels.
	b_rdf_data(i)		<= vme_data(25 downto 16);	-- EVEN Channels.

	
	idt_to_intfifo:
	f2f_copier port map
	(	
		clk			=> pclk,
		rst			=> mrst,
	
		enable		=> idt_en(i),	
		isidle		=> idt_ii(i),	

		--source
		s_ef		=> fifo_ef(i),	--IDT NOT EMPTY.
		s_rd		=> rdtemp(i),

		-- Dest Enable
		ena			=>	oreg(2)(i*2),		--enable for Channels: 1,3,5 and 7.	
		enb			=>	oreg(2)((i*2)+1),	--enable for Channels: 2,4,6 and 8.

		--A Dest
		a_ff		=> a_rdf_ff(i),	--FULL FLAG
		a_wr		=> a_rdf_wr(i),
		
		--B Dest
		b_ff		=> b_rdf_ff(i),	--FULL FLAG
		b_wr		=> b_rdf_wr(i),

		esize		=> CONV_STD_LOGIC_VECTOR(x"7F", 8)		--127		
	);

	A_readout_fifo:
	readout_fifo port map
	(
		aclr		=> mrst,
		clock		=> pclk,
		data		=> a_rdf_data(i),
		rdreq		=> a_rdf_rd(i),
		wrreq		=> a_rdf_wr(i),
		empty		=> a_rdf_ef(i),
		full		=> a_rdf_ff(i),
		q			=> a_rdf_q(i),
		usedw		=> a_rdf_usedw(i)
	);

	B_readout_fifo:
	readout_fifo port map
	(
		aclr		=> mrst,
		clock		=> pclk,
		data		=> b_rdf_data(i),
		rdreq		=> b_rdf_rd(i),
		wrreq		=> b_rdf_wr(i),
		empty		=> b_rdf_ef(i),
		full		=> b_rdf_ff(i),
		q			=> b_rdf_q(i),
		usedw		=> b_rdf_usedw(i)
	);

	A_to_ft_copier:
	f2ft_copier port map
	(	
		clk			=> pclk,
		rst			=> mrst,

		-- Arbiter interface
		enable		=> usb_rdout_en(i*2),
		isidle		=> usb_rdout_ii(i*2),
	
		-- FIFO interface
		ef			=> a_rdf_ef(i),
		usedw		=> a_rdf_usedw(i),
		rd			=> a_rdf_rd(i),
		q			=> a_rdf_q(i),
		
		-- FT245BM interface
		dwait 		=> ft_dwait,
		wr			=> ft_wr,
		odata       => ft_idata,
		
		-- Parameters		
		rmin		=> CONV_STD_LOGIC_VECTOR(x"7F", 8),
		esize		=> CONV_STD_LOGIC_VECTOR(x"7F", 8)		--127
	);

	B_to_ft_copier:
	f2ft_copier port map
	(	
		clk			=> pclk,
		rst			=> mrst,

		-- Arbiter interface
		enable		=> usb_rdout_en((i*2)+1),
		isidle		=> usb_rdout_ii((i*2)+1),
	
		-- FIFO interface
		ef			=> b_rdf_ef(i),
		usedw		=> b_rdf_usedw(i),
		rd			=> b_rdf_rd(i),
		q			=> b_rdf_q(i),
		
		-- FT245BM interface
		dwait 		=> ft_dwait,
		wr			=> ft_wr,
		odata       => ft_idata,
		
		-- Parameters		
		rmin		=> CONV_STD_LOGIC_VECTOR(x"7F", 8),
		esize		=> CONV_STD_LOGIC_VECTOR(x"7F", 8)		--127
	);

	end generate usb_readout_construct;

	
--*********************************************************************************************************

	usb_readout_arbiter:
	priarb8 port map
	(	
		clk			=> pclk,
		rst			=> mrst,

		enable		=> main_en(0),
		isidle		=> main_ii(0),

		en	 		=> usb_rdout_en,

		ii			=> usb_rdout_ii,

		control     => oreg(2)
	);

--*********************************************************************************************************

	main_arbiter:
	priarb8 port map
	(	
		clk			=> pclk,
		rst			=> mrst,

		enable		=> '1',
		isidle		=> open,

		en	 		=> main_en,

		ii			=> main_ii,

		control     => oreg(1)
	);

--*********************************************************************************************************

--
-- Preliminary FSMs for RDENs
-- 

	process (srst,clk50m) begin
		if (srst = '1') then
			state_trig <= s_one;
			u_fifo1_ren <= '1';
		elsif (clk50m'event and clk50m = '1') then
				case state_trig is
						
					when s_one =>
						if (user_read(0) = '1') then
							state_trig <= s_two;
							u_fifo1_ren <= '0';
						else
							state_trig <= s_one;
							u_fifo1_ren <= '1';
						end if;
						
					when s_two =>
						u_fifo1_ren <= '1';
						state_trig <= s_three;
						
					when s_three =>
						u_fifo1_ren <= '1';
						if (user_read(0) = '0') then
							state_trig <= s_one;
						else
							state_trig <= s_three;
						end if;
	
					when others =>
						u_fifo1_ren <= '1';
						state_trig <= s_one;
				
				end case;
		end if;
	end process;

	process (srst,clk50m) begin
		if (srst = '1') then
			bstate_trig <= s_one;
			u_fifo2_ren <= '1';
		elsif (clk50m'event and clk50m = '1') then
				case bstate_trig is
						
					when s_one =>
						if (user_read(1) = '1') then
							bstate_trig <= s_two;
							u_fifo2_ren <= '0';
						else
							bstate_trig <= s_one;
							u_fifo2_ren <= '1';
						end if;
						
					when s_two =>
						u_fifo2_ren <= '1';
						bstate_trig <= s_three;
						
					when s_three =>
						u_fifo2_ren <= '1';
						if (user_read(1) = '0') then
							bstate_trig <= s_one;
						else
							bstate_trig <= s_three;
						end if;
	
					when others =>
						u_fifo2_ren <= '1';
						bstate_trig <= s_one;
				
				end case;
		end if;
	end process;

	process (srst,clk50m) begin
		if (srst = '1') then
			cstate_trig <= s_one;
			u_fifo3_ren <= '1';
		elsif (clk50m'event and clk50m = '1') then
				case cstate_trig is
						
					when s_one =>
						if (user_read(2) = '1') then
							cstate_trig <= s_two;
							u_fifo3_ren <= '0';
						else
							cstate_trig <= s_one;
							u_fifo3_ren <= '1';
						end if;
						
					when s_two =>
						u_fifo3_ren <= '1';
						cstate_trig <= s_three;
						
					when s_three =>
						u_fifo3_ren <= '1';
						if (user_read(2) = '0') then
							cstate_trig <= s_one;
						else
							cstate_trig <= s_three;
						end if;
	
					when others =>
						u_fifo3_ren <= '1';
						cstate_trig <= s_one;
				
				end case;
		end if;
	end process;
	
	process (srst,clk50m) begin
		if (srst = '1') then
			dstate_trig <= s_one;
			u_fifo4_ren <= '1';
		elsif (clk50m'event and clk50m = '1') then
				case dstate_trig is
						
					when s_one =>
						if (user_read(3) = '1') then
							dstate_trig <= s_two;
							u_fifo4_ren <= '0';
						else
							dstate_trig <= s_one;
							u_fifo4_ren <= '1';
						end if;
						
					when s_two =>
						u_fifo4_ren <= '1';
						dstate_trig <= s_three;
						
					when s_three =>
						u_fifo4_ren <= '1';
						if (user_read(3) = '0') then
							dstate_trig <= s_one;
						else
							dstate_trig <= s_three;
						end if;
	
					when others =>
						u_fifo4_ren <= '1';
						dstate_trig <= s_one;
				
				end case;
		end if;
	end process;

--

end rtl;