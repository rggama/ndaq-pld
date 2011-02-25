------------------------------------------------------------------------------
-- TOP!
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ndaq_vme is 
	port
	(	
		------------
		-- AD9510  --
		------------
		signal stsclk		:in		std_logic; -- AD9510 Status
		
		-------------
		-- VME bus --
		-------------
		signal vme_add 		:in  	std_logic_vector(31 downto 1);-- 'vmeif' OK :VME Address Bus
		signal vme_oea		:out  	std_logic;-- 'vmeif' OK ('vme_xbuf_addrle') :VME Address Bus Enable
				
		signal vme_data		:inout 	std_logic_vector(31 downto 0);-- 'vmeif' OK :VME Data Bus
		signal vme_oed		:out  	std_logic;-- 'vmeif' OK ('vme_xbuf_dataoe') :VME Data Bus Enable
		signal vme_dird		:out  	std_logic;-- 'vmeif' OK ('vme_xbuf_datadir'):VME Data Bus Direction
		
		signal vme_gap 		:in  	std_logic;-- 'vmeif' OK						:VME Geographical Address Parity
		signal vme_ga 		:in  	std_logic_vector(4 downto 0);-- 'vmeif' OK	:VME Geographical Address
		
		signal vme_dtack	:out  	std_logic;-- 'vmeif' OK						: VME Data Transfer Acknowledge
		signal vme_oetack	:out  	std_logic;-- 'vmeif' OK ('vme_xbuf_dtackoe'): VME Data Transfer Acknowledge Output Enable
		signal vme_vack		:in  	std_logic;-- 'vmeif' OK						: VME Data Transfer Acknowledge Read Value
		
		signal vme_as 		:in  	std_logic;-- 'vmeif' OK						: VME Address Strobe
		signal vme_lw 		:in  	std_logic;-- 'vmeif' OK ('vme_lword')		: VME Long Word
		signal vme_wr 		:in  	std_logic;-- 'vmeif' OK ('vme_write')		: VME Read/Write
		signal vme_ds0 		:in  	std_logic;-- 'vmeif' OK						: VME Data Strobe 0
		signal vme_ds1 		:in  	std_logic;-- 'vmeif' OK						: VME Data Strobe 1
		signal vme_am 		:in  	std_logic_vector(5 downto 0);-- 'vmeif' OK	: VME Address Modifier
		signal vme_sysrst	:in  	std_logic;-- 'vmeif' OK ('vme_sysreset')	: VME System Reset
		signal vme_sysclk	:in  	std_logic;-- 'vmeif' OK ('vme_sysclock')	: VME System Clock
		
		signal vme_iack		:in  	std_logic;-- 'vmeif' OK						: VME Interrupt Acknowledge
		signal vme_iackin	:in  	std_logic;-- 'vmeif' OK ('vme_iack_in')		: VME Interrupt Acknowledge Daisy-Chain Input
		signal vme_iackout	:out	std_logic;-- 'vmeif' OK ('vme_iack_out')	: VME Interrupt Acknoweldge Daisy-Chain Output
		signal vme_irq		:out	std_logic_vector(7 downto 1);-- 'vmeif' OK	: VME Interrupt Request
		
		signal vme_berr		:out  	std_logic;-- 'vmeif' OK						: VME Bus Error
		signal vme_verr		:in  	std_logic;-- 'vmeif' OK						: VME Bus Error Read Value
		

		-----------------------
		-- MPD USB INTERFACE --
		-----------------------
--		signal oUSBWrite   : out std_logic;
--		signal oUSBRead    : out std_logic;
--		signal iUSBRXF     : in std_logic;
--		signal iUSBTXE     : in std_logic;
--		signal ioUSBData   : inout signed(7 downto 0);

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

		---------------
		-- FPGA bridge --
		---------------
		signal bridge_wr	 :in  		std_logic;
		signal bridge_rd	 :in  		std_logic;
		signal bridge_dw	 :out  		std_logic;
		signal bridge_da	 :out  		std_logic;
		signal bridge_data	 :inout  	std_logic_vector(3 downto 0);
		
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
		signal mclk    : out std_logic;
		signal sclk    : out std_logic;
		signal clk_enable		: out	std_logic;
		signal tclk				: out	std_logic
	);
	end component;

	-- SLAVE USB Transceiver Interface
	component s_trif
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; -- just enable comb logic

		-- ext bus
		signal sdwait			: out	std_logic;
		signal sdavail			: out	std_logic;
		signal snwr				: in 	std_logic;
		signal snrd				: in 	std_logic;
		signal mdata			: inout	std_logic_vector(3 downto 0);

		-- ftdi bus
		signal txf				: in	std_logic;
		signal rxf				: in 	std_logic;
		signal txwr				: out	std_logic;
		signal rxrd				: out	std_logic;
		signal iodata			: inout	std_logic_vector(7 downto 0)
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


---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------

	signal srst						: std_logic;
	signal sclk						: std_logic; 
	signal tclk, clk_en				: std_logic;
	signal write_t					: std_logic;
	signal test						: std_logic;
	
	
------------------------------------------
------------------------------------------

begin
	
-- Let's create a peaceful environment.

	fifo1_oe	<= '1';
	fifo2_oe	<= '1';
	fifo3_oe	<= '1';
	fifo4_oe	<= '1';

	fifo1_ren	<= '1';
	fifo2_ren	<= '1';
	fifo3_ren	<= '1';
	fifo4_ren	<= '1';
		
	can_pgc <= 'Z';	--bridge_wr; --usb_TXE; --'Z';
	can_pgd <= 'Z'; --bridge_rd; --write_t; --'Z';
	can_pgm <= 'Z';

	vme_berr	<= 'Z';
	vme_irq		<= (others => 'Z');
	vme_oetack	<= 'Z';
	vme_dtack	<= 'Z';
	vme_dird	<= 'Z';
	vme_oed		<= 'Z';
	vme_data	<= (others => 'Z');
	vme_oea		<= 'Z';
	vme_iackout	<= 'Z';

------------------------
--********************--
--******* MAPS *******--
--********************--
------------------------
	
	clock_manager: 
	clkman port map 
	(
		iclk				=> clk50M, --iclk60M,
		
		pclk				=> open,
		nclk				=> open, --nclk,
		mclk				=> open,
		sclk				=> sclk,
		clk_enable			=> open, --clk_en,
		tclk				=> test
	);
	
	--bridge_dw	<= test;
	--bridge_da	<= test;
	
	
	slave_usb_transceiver_if:
	s_trif port map
	(	
		clk				=> sclk,
		clk_en			=> '1', --clk_en,
		rst      		=> srst,
    
		enable			=> '1',

		sdwait			=> bridge_dw,
		sdavail			=> bridge_da,
		snwr			=> bridge_wr,
		snrd			=> bridge_rd,
		mdata			=> bridge_data,

		txf				=> usb_TXE,
		rxf				=> usb_RXF,
		txwr			=> write_t,	--usb_Write, --,
		rxrd			=> usb_Read,
		iodata			=> usb_Data
	);

	usb_Write <= write_t;
	
	
	slave_rst_gen:
	rstgen port map
	(	
		clk				=> sclk,
		
		reset			=> x"FF",
		
		rst				=> srst
	);

end rtl;