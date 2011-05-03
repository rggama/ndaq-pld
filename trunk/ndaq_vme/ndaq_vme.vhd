------------------------------------------------------------------------------
-- TOP!
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.vmeif_pkg.all;
use work.vmeif_usr.all;

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
		signal fifo1_oe 	:out  	std_logic;
		signal fifo2_oe 	:out  	std_logic;
		signal fifo3_oe 	:out  	std_logic;
		signal fifo4_oe 	:out  	std_logic;
		signal fifo1_ren 	:out  	std_logic;
		signal fifo2_ren 	:out  	std_logic;
		signal fifo3_ren 	:out  	std_logic;
		signal fifo4_ren 	:out  	std_logic;
		signal fifo1_ef 	:in  	std_logic;
		signal fifo2_ef 	:in  	std_logic;
		signal fifo3_ef 	:in  	std_logic;
		signal fifo4_ef 	:in  	std_logic;

		----------------
		-- Master SPI --
		----------------
		
		signal spiclk		:out		std_logic;
		signal mosi			:out		std_logic;
		signal miso			:in			std_logic;
		
		-------------------
		-- CAN interface --
		-------------------
		signal can_pgc	 	 :out  		std_logic;
		signal can_pgd	 	 :out  		std_logic;
		signal can_pgm	 	 :out  		std_logic);
				
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
		signal mclk    			: out 	std_logic;
		signal sclk    			: out 	std_logic;
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

	-- Slave SPI - Here for loopback test.
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

	-- VME controller developed at CERN (Per Gallno -> Herman -> Ralf)
	component vmeif
	port
	( testpin			: out	std_logic;
	  vme_addr			: in	std_logic_vector(31 downto 1);									-- VME address bus
      vme_xbuf_addrle	: out	std_logic;														-- VME address bus latch enable
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

	
---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------

	signal srst, mrst				: std_logic;
	signal pclk, sclk, mclk			: std_logic; 
	signal tclk, clk_en				: std_logic;
	-- signal write_t					: std_logic;
	-- signal test						: std_logic;
	
	signal iuser_data_in			: std_logic_vector(31 downto 0);	-- TEST by HERMAN 29/07/10
	signal iuser_data_out			: std_logic_vector(31 downto 0);	-- TEST by HERMAN 29/07/10
	signal iuser_addr				: std_logic_vector(24 downto 0);	-- Added by Herman in 08/09/10
	signal clk_wr, clk_rd			: std_logic; 						-- TEST by HERMAN 29/07/10
	signal iuser_addr_lat			: std_logic_vector(7 downto 0);		-- Added by Herman in 08/09/10
	--signal r_fifo_flag			: std_logic;
	signal u_read0					: std_logic;
	signal u_read1					: std_logic;
	signal u_read2					: std_logic;
	signal u_read3					: std_logic;
	-- signal clk_rdff					: std_logic;
	-- signal fifocount				: std_logic_vector(31 downto 0);
	
	------------------------------
	-- Signals from 'vmedec.vhd --
	------------------------------
	-- Address for external blocks to vmedec.vhd ([23..20]/=x"0" OR [11..8]=x"1")
	-- constant fifo1_add       : std_logic_vector(3 downto 0)  := x"1";  	-- Mapped in add<23..20>
	-- constant fifo2_add       : std_logic_vector(3 downto 0)  := x"2";  	-- Mapped in add<23..20> 
	-- constant fifo3_add       : std_logic_vector(3 downto 0)  := x"3";  	-- Mapped in add<23..20>
	-- constant fifo4_add       : std_logic_vector(3 downto 0)  := x"4";  	-- Mapped in add<23..20>

	-- Address map of the registers        
	-- constant reg1_add        : std_logic_vector(7 downto 0)  := x"01";	-- Start Readout     (W), mapped in add<23..16>
	-- constant reg2_add        : std_logic_vector(7 downto 0)  := x"02";	-- Readout Status    (R), mapped in add<23..16>
	-- constant reg3_add        : std_logic_vector(7 downto 0)  := x"03";	-- Input Selection   (R/W), mapped in add<23..16>
	-- constant reg4_add        : std_logic_vector(7 downto 0)  := x"04";	-- BC Offset         (R/W), mapped in add<23..16>
	-- constant reg5_add        : std_logic_vector(7 downto 0)  := x"05";	-- Almost Overflow   (R/W), mapped in add<23..16>

	-- Internal control signals
	-- signal   reg1_en            : boolean;
	-- signal   reg2_en            : boolean;
	-- signal   reg3_en            : boolean;
	-- signal   reg4_en            : boolean;
	-- signal   reg5_en            : boolean;
	
	-- signal   fifo1_en           : boolean;
	-- signal   fifo2_en           : boolean;
	-- signal   fifo3_en           : boolean;
	-- signal   fifo4_en           : boolean;

	-- Internal registers (control, commands)
	-- signal   stored_d0r         : std_logic_vector(31 downto 0);
	-- signal   stored_d1r         : std_logic_vector(31 downto 0);
	-- signal   stored_d2r         : std_logic_vector(31 downto 0);
	-- signal   stored_d3r         : std_logic_vector(31 downto 0);
	-- signal   stored_d4r         : std_logic_vector(31 downto 0);
	-- signal   stored_d5r         : std_logic_vector(31 downto 0);
	-- signal   stored_d6r         : std_logic_vector(31 downto 0);
	-- signal   stored_d7r         : std_logic_vector(31 downto 0);
	-- signal   stored_d8r         : std_logic_vector(31 downto 0);
	-- signal   stored_d9r         : std_logic_vector(31 downto 0);

	--
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

	-- FT245bm_if Test
	signal ft_wr		: std_logic := '1';
	signal ft_rd		: std_logic := '1';
	signal ft_idata		: std_logic_vector(7 downto 0) := x"00";
	signal ft_odata		: std_logic_vector(7 downto 0) := x"00";

	signal ft_dwait		: std_logic := '0';
	signal ft_dataa		: std_logic := '0';
	
	-- Master SPI
	signal m_spi_wr		: std_logic := '1';
	signal m_spi_rd		: std_logic := '1';
	signal m_spi_idata	: std_logic_vector(7 downto 0) := x"00";
	signal m_spi_odata	: std_logic_vector(7 downto 0) := x"00";

	signal m_spi_dwait	: std_logic := '0';
	signal m_spi_dataa	: std_logic := '0';
	
	-- Slave SPI
	signal s_spi_wr		: std_logic := '1';
	signal s_spi_rd		: std_logic := '1';
	signal s_spi_idata	: std_logic_vector(7 downto 0) := x"00";
	signal s_spi_odata	: std_logic_vector(7 downto 0) := x"00";

	signal s_spi_dwait	: std_logic := '0';
	signal s_spi_dataa	: std_logic := '0';

	signal i_spiclk		: std_logic;	
	signal i_mosi		: std_logic;
	signal i_miso		: std_logic;
	
------------------------------------------
------------------------------------------


begin
	
	fifo1_oe	<= '1'; --not(u_read0);
	fifo2_oe	<= '1'; --not(u_read1);
	fifo3_oe	<= '1'; --not(u_read2);
	fifo4_oe	<= '1'; --not(u_read3);
	
	fifo1_ren	<= '1'; --u_fifo1_ren;
	fifo2_ren	<= '1'; --u_fifo2_ren;
	fifo3_ren	<= '1'; --u_fifo3_ren;
	fifo4_ren	<= '1'; --u_fifo4_ren;
	
	-- can_pgc <=  fifo1_ef;
	-- can_pgd <= 'Z';
	can_pgm <= 'Z';

--	vme_berr		<= 'Z';
	vme_irq		<= (others => 'Z');
--	vme_oetack	<= 'Z';
--	vme_dtack	<= 'Z';
--	vme_dird		<= 'Z';
--	vme_oed		<= 'Z';
--	vme_data	<= (others => 'Z');
	vme_oea		<= 'Z';


------------------------
--********************--
--******* MAPS *******--
--********************--
------------------------
	
	clock_manager: 
	clkman port map 
	(
		iclk				=> clk50M,
		
		pclk				=> pclk,
		nclk				=> open, --nclk,
		mclk				=> mclk,
		sclk				=> sclk,
		clk_enable			=> open, --clk_en,
		tclk				=> open
	);
	
	
--*********************************************************************************************************	
	
	can_pgc	<= ft_dwait;
	can_pgd	<= usb_TXE;
	
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

	-- FT -> M_SPI Copier
	m_spi_idata	<= ft_odata;
	
	ft_m_spi_copier:
	swc port map
	(	
		clk				=> pclk,
		rst				=> mrst,
		
		--flags
		dwait			=> m_spi_dwait,	--to
		dataa			=> ft_dataa,	--from

		--strobes
		wr				=> m_spi_wr,	--to
		rd				=> ft_rd		--from
	);

	-- M_SPI -> FT Copier
	ft_idata	<= m_spi_odata;
	
	m_spi_ft_copier:
	swc port map
	(	
		clk				=> pclk,
		rst				=> mrst,
		
		--flags
		dwait			=> ft_dwait,	--to
		dataa			=> m_spi_dataa,	--from

		--strobes
		wr				=> ft_wr,		--to
		rd				=> m_spi_rd		--from
	);

--*********************************************************************************************************	

	Master_SPI: 
	m_spi
	port map
	(	
		clk			=> pclk,		-- sytem clock
		rst			=> mrst,		-- asynchronous reset
		
		mosi		=> mosi,		-- master serial out	- slave serial in
		miso		=> miso,		-- master serial in		- slave serial out
		sclk		=> spiclk,	-- spi clock out
		
		wr			=> m_spi_wr,	-- write strobe
		rd			=> m_spi_rd,	-- read strobe
		
		dwait		=> m_spi_dwait,	-- busy flag
		dataa		=> m_spi_dataa,	-- data avaiable flag
		
		idata		=> m_spi_idata,	-- data input parallel bus
		odata		=> m_spi_odata	-- data output parallel bus	
	);

	Slave_SPI: 
	s_spi
	port map
	(	
		clk			=> pclk,		-- sytem clock
		rst			=> mrst,		-- asynchronous reset
		
		mosi		=> i_mosi,		-- master serial out	- slave serial in
		miso		=> i_miso,		-- master serial in		- slave serial out
		sclk		=> i_spiclk,	-- spi clock out
		
		wr			=> s_spi_wr,	-- write strobe
		rd			=> s_spi_rd,	-- read strobe
		
		dwait		=> s_spi_dwait,	-- busy flag
		dataa		=> s_spi_dataa,	-- data avaiable flag
		
		idata		=> s_spi_idata,	-- data input parallel bus
		odata		=> s_spi_odata	-- data output parallel bus	
	);

	-- Slave SPI Loopback
	s_spi_idata	<= s_spi_odata;

	s_spi_loopback:
	swc port map
	(	
		clk				=> pclk,
		rst				=> mrst,
		
		--flags
		dwait			=> s_spi_dwait,	--to
		dataa			=> s_spi_dataa,	--from

		--strobes
		wr				=> s_spi_wr,	--to
		rd				=> s_spi_rd		--from
	);

--*********************************************************************************************************	
	
	master_rst_gen:
	rstgen port map
	(	
		clk				=> mclk,
		
		reset			=> x"FF",
		
		rst				=> mrst
	);

	-- slave_rst_gen:
	-- rstgen port map
	-- (	
		-- clk				=> sclk,
		
		-- reset			=> x"FF",
		
		-- rst				=> srst
	-- );

--*********************************************************************************************************

	my_vmeif:
	vmeif port map (  --testpin					=> can_pgc,
							user_addr			=> iuser_addr,
							user_data_in		=> iuser_data_in,
							user_data_out		=> iuser_data_out,
							user_read(0)		=> u_read0,
							user_read(1)		=> u_read1,
							user_read(2)		=> u_read2,
							user_read(3)		=> u_read3,
							user_read(4)		=> open, --vmecore_y, -- porta usada na comunicacao entre fpgas para usb
							user_write(4)		=> open, --vmecore_x, -- porta usada na comunicacao entre fpgas para usb
							vme_addr			=>	vme_add,
							vme_am				=>	vme_am,
							vme_data			=>	vme_data,
							vme_xbuf_dataoe		=>	vme_oed, --
							vme_xbuf_datadir	=>	vme_dird, --
							vme_lword			=>	vme_lw,
							vme_dtack			=>	vme_dtack, --
							vme_xbuf_dtackoe	=>	vme_oetack, --
							vme_vack			=>	vme_vack,
							vme_as				=>	vme_as,
							vme_ds0				=>	vme_ds0,
							vme_ds1				=>	vme_ds1,
							vme_write			=>	vme_wr,
							vme_iack			=>	vme_iack,
							vme_iack_in			=>	vme_iackin,
							vme_iack_out		=>	vme_iackout,
							vme_irq				=>	open, --vme_irq,
							vme_berr			=>	vme_berr, --
							vme_verr			=>	vme_verr,
							vme_sysreset		=>	vme_sysrst,
							vme_sysclock		=>	vme_sysclk,
							vme_ga				=>	vme_ga,
							vme_gap				=>	vme_gap,
							clock_40mhz			=>	clk50M);

							
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
						if (u_read0 = '1') then
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
						if (u_read0 = '0') then
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
						if (u_read1 = '1') then
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
						if (u_read1 = '0') then
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
						if (u_read2 = '1') then
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
						if (u_read2 = '0') then
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
						if (u_read3 = '1') then
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
						if (u_read3 = '0') then
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