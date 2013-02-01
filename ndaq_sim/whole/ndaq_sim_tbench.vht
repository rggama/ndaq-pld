--
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.usbcmds_pkg.all;

--library std;                                                            
--use std.textio.all;                                                     

entity ndaq_sim_tbench is
end ndaq_sim_tbench;


architecture testbench of ndaq_sim_tbench is


-- devices under test

	-- CORE FPGA
	component ndaq_core 
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
	end component;
	

	-- VME FPGA
	component ndaq_vme
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
		
		--------------------
		-- Overflow Flags --
		--------------------
		signal overflow_a 	:in		std_logic;
		signal overflow_b	:in		std_logic;
		signal overflow_c	:in		std_logic;
		
		-----------------
		-- Test Points --
		-----------------
		
		signal t1_a			:out	std_logic;
		signal t1_b			:out	std_logic
	);
	end component;

	-- Fake IDT FIFO
	component idt_fifo
	port
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
	end component;
	
-- Signals                                                   

-- Clocks
signal adc_dco	: std_logic;
signal clkcore	: std_logic;
signal clkvme	: std_logic;

-- ADC Data Simulation
signal dcounter		: std_logic_vector(7 downto 0) := x"FF";
signal dcounter_t	: std_logic := '0';
signal dcounter_en	: std_logic := '0';
signal trigger_gen	: std_logic := '0';
signal trigger		: std_logic := '0';
signal adc_data		: std_logic_vector(9 downto 0);

-- FT245BM chip behavior signals
signal txe		: std_logic;
signal rxf		: std_logic;
signal nrd		: std_logic;
signal nwr		: std_logic;
signal data		: std_logic_vector(7 downto 0) := x"00";
signal cmd_cntr	: integer := 0;
signal del_cntr	: integer := 0;
signal delayed	: boolean := false;

-- SPI link
signal spiclk	: std_logic;
signal mosi		: std_logic;
signal miso		: std_logic;
signal cs		: std_logic;

-- IDT FIFO

type IDTQ_T is array (1 to 4) of std_logic_vector(31 downto 0);
type USEDW_T is array (1 to 4) of std_logic_vector(16 downto 0);

signal idt_data		: std_logic_vector(31 downto 0);
signal idt_q		: IDTQ_T;
signal idt_q_bus	: std_logic_vector(31 downto 0);
signal idt_wrclk	: std_logic;
signal idt_rst		: std_logic;
signal idt_oe		: std_logic_vector(1 to 4);
signal idt_rd		: std_logic_vector(1 to 4);
signal idt_wr		: std_logic_vector(1 to 4);
signal idt_empty	: std_logic_vector(1 to 4);
signal idt_full		: std_logic_vector(1 to 4);
signal n_idt_rst	: std_logic;
signal n_idt_rd		: std_logic_vector(1 to 4);
signal n_idt_wr		: std_logic_vector(1 to 4);
signal n_idt_empty	: std_logic_vector(1 to 4);
signal n_idt_full	: std_logic_vector(1 to 4);
signal wrusedw		: USEDW_T;
signal used_comp	: std_logic_vector(16 downto 0);
signal idt_paf		: std_logic_vector(1 to 4);

-- Overflow Flags

signal overflow_a	: std_logic;
signal overflow_b	: std_logic;
signal overflow_c	: std_logic;

--
-- arch begin
begin

-- core fpga map
ndaq_core_fpga : ndaq_core
port map
	(	
		------------------
		-- Clock inputs --
		------------------
		clkcore     => clkcore,	

		--------------------
		-- ADCs interface --
		--------------------
		adc12_data 	=>   	adc_data,
		adc34_data 	=>   	adc_data,
		adc56_data 	=>   	adc_data,
		adc78_data 	=>   	adc_data,
		
		adc12_dco	=>  	adc_dco,			-- ADC 1 Data Clock
		adc34_dco	=>  	adc_dco,			-- ADC 2 Data Clock
		adc56_dco	=>  	adc_dco,			-- ADC 3 Data Clock
		adc78_dco	=>  	adc_dco,			-- ADC 4 Data Clock
		
		adc12_pwdn	=> open,					-- ADC 1 Power Down control
		adc34_pwdn	=> open,					-- ADC 2 Power Down control
		adc56_pwdn	=> open,					-- ADC 3 Power Down control
		adc78_pwdn	=> open,					-- ADC 4 Power Down control

		-------------------
		-- TDC terface --
		-------------------
		tdc_data		=>  open,
		tdc_stop_dis	=>  open,
		tdc_start_dis 	=>  open,	
		tdc_wrn		    =>  open,	
		tdc_rdn		    =>  open,	
		tdc_csn		    =>  open,	
		tdc_alutr	    =>  open,  
		tdc_puresn	   	=>  open,  
		tdc_oen		    =>  open,  
		tdc_adr		    =>  open,
		tdc_errflag	  	=>     'Z',
		tdc_irflag	   	=>     'Z',
		tdc_lf2		    =>     'Z',
		tdc_lf1		    =>     'Z',
		tdc_ef2		    =>     'Z',
		tdc_ef1		    =>     'Z',

		----------------------
		-- FIFO's interface --
		----------------------
		-- Data Bus
		fifo_data_bus =>  idt_data,
		
		-- Control signals
		fifo_wen(0) 	=>  idt_wr(1), 		-- Write Enable
		fifo_wen(1) 	=>  idt_wr(2),   	
		fifo_wen(2) 	=>  idt_wr(3),   	
		fifo_wen(3) 	=>  idt_wr(4),   	
		fifo_wck		=>  idt_wrclk,		-- Write Clock to all FIFOs (PLL-4 open,put)
		
		fifo_mrs		=>  idt_rst,		-- Master Reset
		fifo_prs		=>  open,			-- Partial Reset
		fifo_fs0		=>  open,			-- Flag Select Bit 0
		fifo_fs1		=>  open,			-- Flag Select Bit 1
		fifo_ld		 	=>  open,			-- Load
		fifo_rt		  	=>  open,			-- Retransmit
		
		-- Flags
		fifo1_ff		=> n_idt_full(1),	-- FULL flag
		fifo2_ff		=> n_idt_full(2),
		fifo3_ff		=> n_idt_full(3),
		fifo4_ff		=> n_idt_full(4),
		
		fifo_ef			=> (others => 'Z'),	-- EMPTY flag
		
		fifo1_hf		=>     	'Z',		-- HALF-FULL flag
		fifo2_hf		=>     	'Z',
		fifo3_hf		=>     	'Z',
		fifo4_hf		=>     	'Z',
		
		fifo_paf(0) 	=> idt_paf(1),		-- ALMOST-FULL flag
		fifo_paf(1)		=> idt_paf(2),
		fifo_paf(2)		=> idt_paf(3),
		fifo_paf(3) 	=> idt_paf(4),		
		
		fifo1_pae	 	=>     	'Z',		-- ALMOST-EMPTY flag
		fifo2_pae	 	=>     	'Z',
		fifo3_pae	 	=>     	'Z',
		fifo4_pae	 	=>     	'Z',

		
		--------------------
		-- SRAM interface --
		--------------------
		sram_add	  =>  open,  	
		sram_data	  =>  open, 	
		sram_we		  =>  open,		
		sram_oe		  =>  open,		
		sram_cs		  =>  open,		
		
		
		------------------------------
		-- LVDS connector interface --
		------------------------------
		lvdsin 		 =>	(others => 'Z'),		
		
		---------------
		-- Slave SPI --
		---------------
		spiclk		=> spiclk,
		mosi		=> mosi,
		miso		=> miso,
		cs			=> '1',

		--------------------
		-- Trigger inputs --
		--------------------
		trigger_a	=> trigger,
		trigger_b	=> 'Z',
		trigger_c 	=> 'Z',

		----------------------------------
		-- Overflow Signals to FPGA VME --
		----------------------------------
		overflow_a	=> overflow_a,
		overflow_b	=> overflow_b,
		overflow_c	=> overflow_c
	);
		

-- vme fpga map
ndaq_vme_fpga : ndaq_vme
port map
  (	
    ------------
		-- AD9510  --
		------------
		stsclk      => 'Z',
		
		-------------
		-- VME bus --
		-------------
		vme_add     => (others => 'Z'),
		vme_oea     => open,
				
		vme_data    => idt_q_bus,
		vme_oed     => open,
		vme_dird    => open,
		
		vme_gap     => 'Z',
		vme_ga      => (others => 'Z'),
		
		vme_dtack   => open,
		vme_oetack  => open,
		vme_vack    => 'Z',
		
		vme_as      => 'Z',
		vme_lw      => 'Z',
		vme_wr      => 'Z',
		vme_ds0     => 'Z',
		vme_ds1     => 'Z',
		vme_am      => (others => 'Z'),
		vme_sysrst  => 'Z',
		vme_sysclk  => 'Z',
		
		vme_iack    => 'Z',
		vme_iackin  => 'Z',
		vme_iackout => open,
		vme_irq     => open,
		
		vme_berr    => open,
		vme_verr    => 'Z',
		
		-------------------
		-- USB interface --
		-------------------
		usb_Write   => nwr,
		usb_Read    => nrd,
		usb_RXF     => rxf,
		usb_TXE     => txe,
		usb_Data    => data,
				
		----------------
		-- CLK system --
		----------------
		clk50M      => clkvme,

		---------------------
		-- FIFOs interface --
		---------------------
		fifo_oe(0)	=> idt_oe(1),
		fifo_oe(1)	=> idt_oe(2),
		fifo_oe(2)	=> idt_oe(3),
		fifo_oe(3)	=> idt_oe(4),
		fifo_ren(0)	=> idt_rd(1),
		fifo_ren(1)	=> idt_rd(2),
		fifo_ren(2)	=> idt_rd(3),
		fifo_ren(3)	=> idt_rd(4),
		fifo_ef(0)	=> n_idt_empty(1),
		fifo_ef(1)	=> n_idt_empty(2),
		fifo_ef(2)	=> n_idt_empty(3),
		fifo_ef(3)	=> n_idt_empty(4),
		-- FIFO's programmable almost empty flag. These signals come from Core FPGA.
		fifo_pae	=> (others => 'Z'),
		
		----------------
		-- Master SPI --
		----------------
		spiclk		=> spiclk,
		mosi		=> mosi,
		miso		=> miso,
		cs			=> cs,
		
		-------------------
		-- CAN interface --
		-------------------
		can_pgc     => open,
		can_pgd     => open,
		can_pgm     => open,

		--------------------
		-- Overflow Flags --
		--------------------
		overflow_a 	=> overflow_a,
		overflow_b	=> overflow_b,
		overflow_c	=> overflow_c,
		
		-----------------
		-- Test Points --
		-----------------
		t1_a		=> open,
		t1_b		=> open
	);

-- Fake IDT FIFOs

-- Negating signal as real IDT FIFO works this way
n_idt_rst	<= not(idt_rst);

fake_idt_construct:
for i in 1 to 4 generate

	fake_idt_fifo:
	idt_fifo port map
	(
		aclr		=> n_idt_rst,
		data		=> idt_data,
		rdclk		=> clkvme,
		rdreq		=> n_idt_rd(i),
		wrclk		=> idt_wrclk,
		wrreq		=> n_idt_wr(i),
		q			=> idt_q(i),
		rdempty		=> idt_empty(i),
		wrfull		=> idt_full(i),
		wrusedw		=> wrusedw(i)
	);

	-- Tri-state outputs
	idt_q_bus	<= idt_q(i) when (idt_oe(i) = '0') else (others => 'Z');
	
	-- FIFO PAF
	--idt_paf(i)	<= not(wrusedw(i)(7));
	
	used_comp <= "1" & x"FDAA";
	
	process (wrusedw)
	begin
		if (wrusedw(i) = used_comp) then
			idt_paf(i) <= '0'; --active
		else
			idt_paf(i) <= '1';
		end if;
	end process;

	-- Negating signals as real IDT FIFO works this way
	n_idt_rd(i)		<= not(idt_rd(i));
	n_idt_wr(i)		<= not(idt_wr(i));
	n_idt_empty(i)	<= not(idt_empty(i));
	n_idt_full(i)	<= not(idt_full(i));

end generate fake_idt_construct;

	-- Stimulus!

--********************************** Clocks ************************************

-- adc_dco @ 124 MHz as 'adc_dco'
adc12_dco_gen: process
begin
loop
	adc_dco <= '1';
	wait for 4000 ps;
	adc_dco <= '0';
	wait for 4000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process adc12_dco_gen;

-- clkcore @ 125 MHz for CORE FPGA
clkcore_gen: process
begin
loop
	clkcore <= '1';
	wait for 4000 ps;
	clkcore <= '0';
	wait for 4000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process clkcore_gen;

-- clk @ 50 MHz for VME FPGA
clkvme_gen: process
begin
loop
	clkvme <= '0';
	wait for 10000 ps;
	clkvme <= '1';
	wait for 10000 ps;
	-- if (now >= 1000000 ps) then wait; end if;
end loop;
end process clkvme_gen;

trigger_process: process
begin
	trigger_gen <= '0';
	wait for 300 ns;
loop
	trigger_gen <= '1';
	wait for 16 ns;
	trigger_gen <= '0';
	wait for 230 ns;
	trigger_gen <= '1';
	wait for 16 ns;
	trigger_gen <= '0';
	wait for 500 ns;
end loop;
end process trigger_process;

trigger <= trigger_gen;

-- -- Reset 
-- rst_gen: process
-- begin
	-- rst <= '1';
	-- wait for 150 ns;
	-- rst <= '0';
	-- wait;
-- end process rst_gen;

--**************************** ADC DATA SIMULATION *****************************
	
	dcounter_en	<= '1';
	
	adc_data_sim:
	process (adc_dco)
	begin
		--if (rst = '1') then
		--	dcounter	<= x"FF";
		--	dcounter_t	<= '0';
		--elsif (rising_edge(adc_dco)) then
		if (rising_edge(adc_dco)) then
			if (dcounter_en = '1') then	-- IDT's RD is active low.
				if (dcounter = x"FF") then
					dcounter	<= x"01";
					dcounter_t	<= '0';
				else
					dcounter	<= dcounter + 2;
					dcounter_t	<= '1';
				end if;
			end if;
		end if;
	end process;

	adc_data(7 downto 0)	<= dcounter;
	adc_data(9 downto 8)	<= "00";
	--trigger					<= dcounter_t;
	
--***************************** FT245BM Behavior *******************************

-- rxf
rxf_gen: process
begin
  
	--initil transceiver condition
	rxf  <= '1';
	data <= "ZZZZZZZZ";
	--wait for 10 ns;
  
loop
  --wait for 300 ns;
  --let's indicate that there is data avaiable
	rxf  <= '0';

  --now, we're gonna wait for the counterpart's read strobe
	wait until (nrd = '0');
	
	-- Transceiver's RD strobe to valid data output latency
	wait for 50 ns; -- T3: 20 to 50ns
	
	-- Data Input
	if (delayed = false) then
		data	<= COMMAND(cmd_cntr);
	else
		data	<= D_COMMAND(del_cntr);
	end if;
	
	--now, we're gonna wait for the counterpart to end the cycle
	wait until (nrd = '1');
  
	-- Transceiver's Valid Data Hold Time from RD Strobe inactive
	wait for 0 ns; -- T4: 0ns
	
	data <= "ZZZZZZZZ";

	-- RD inactive to RXF = '1'
	wait for 25 ns; -- T5: 0 to 25 ns;
  
	rxf <= '1';
  
	-- RXF inactive after cycle
	wait for 80 ns; -- T6: 80 ns; 
	
	-- Command counting and loop waiting
	-- if (delayed = false) then
		-- if (cmd_cntr = (total_cmds-1)) then
			-- wait for 777 us;
			-- delayed		<= true;
		-- else
			-- cmd_cntr	<= cmd_cntr+1;
			-- delayed		<= false;
		-- end if;
	-- else
		-- -- Delayed command counting and loop ending
		-- if (del_cntr = (del_cmds-1)) then
			-- wait;
		-- else
			-- del_cntr	<= del_cntr+1;
		-- end if;
	-- end if;
	wait;
end loop; 
end process rxf_gen;

-- txe
txe_gen: process
begin 
  --initil transceiver condition
	txe  <= '1';
  --wait for 28572 us;
  
loop
  --wait for 300 ns;
	txe  <= '0'; --'0';
 
  --now, we're gonna wait for the counterpart to end the cycle
  wait until (nwr = '0');
  
  wait for 0 ns; -- T10: 0ns
 
  -- WR inactive to TXF = '1'
  wait for 25 ns; -- T11: 5 to 25 ns;
  
  txe <= '1';
  
  -- TXF inactive after cycle
  wait for 80 ns; -- T12: 80 ns; 
end loop; 
end process txe_gen;


end testbench;
