---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Design: C:\Projects\VmeInterface\vmeif.vhd
-- Author: Per Gallno,     original version
--         Herman Lima Jr, 26 JUN 2003
--         Ralf Spiwoks,   11 NOV 2003
-- Company: CERN
-- Description: VME Interface of the ATLAS Level-1 Central Trigger Processor
-- Notes:
-- 1) All internal control signals (i_xx) are active high.
-- 2) State machine outputs are registered.
--
-- History:
-- 11 NOV 2003: Created new project VmeInterface.
-- 02 DEC 2003: Continued cleaning up and implementation of generic VmeInterface.
-- 09 DEC 2003: Added CR/CSR and user space.
-- 11 DEC 2003: Added package for user-specific constants.
-- 21 DEC 2003: Seperated common and user package from main design file.
-- 21 JAN 2004: Splitted the state machine: single cylce, block transfer, interrupt acknowledge.
-- 23 JAN 2004: Corrected block transfer state machine.
-- 26 JAN 2004: Corrected interrupt acknowledge state machine.
-- 27 JAN 2004: Introduced user interrupt request state machine.
-- 01 FEB 2004: Global reset.
-- 04 FEB 2004: Retargeted for 40MHz, revised registered outputs: timing problems!
-- 09 FEB 2004: Hand-coded state machines & took out netlist optimization.
-- 10 FEB 2004: Retimed dtack and delay.
-- 17 FEB 2004: Modified user-side signal timing.
-- 19 FEB 2004: Modified interrupt acknowledge cycle timing.
-- 20 FEB 2004: New state machine for data transfer: single, block and address pipelining.
-- 27 FEB 2004: Modified state machine behaviour.
-- 02 MAR 2004: Extended internal delay, and synchronized VMEbus read/write signal.
-- 08 MAR 2004: Clean-up of end of cycle: go through state DTB5!
-- 12 MAR 2004: Grand unification: one state machine for SGL, BLT and IAK.
-- 15 MAR 2004: Added possibility to read/write busses within the same device.
-- 17 MAR 2004: Cleaned up, modified state names, ISTAT endianness, and CSR reset.
-- 25 MAR 2004: Corrected signal polarities and rescinidng DTACK.
-- 17 JUN 2004: Corrected read bits of ICSR and RCSR;
--              changed polarity of powerup_reset and vme_sysreset enable in RCSR.
-- 28 JUN 2004: Modified state machines: one process, output encoded in state variable.
-- 29 JUN 2004: Changed USER_CSR write handling (all bits => less resources!);
--              changed byte-swapping of ADEM, ADER and ISTAT (big-endian!).
-- 12 JUL 2004: Corrected handling of interrupt acknowledge cycle.
--
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--
  library IEEE;
  use IEEE.Std_logic_1164.all;
  use IEEE.Numeric_std.all;
  use work.vmeif_pkg.all;
  use work.vmeif_usr.all;
--
  entity vmeif is	
    port(
		testpin			: out std_logic;	-- HERMAN 07/10/10
	 --
-- VMEbus-side signals
--
	  vme_addr			: in	std_logic_vector(31 downto 1);	-- VME address bus
      vme_xbuf_addrle	: out	std_logic;						-- VME address bus latch enable
      vme_am			: in    std_logic_vector(5 downto 0);  	-- VME address modifier code
	  vme_data			: inout	std_logic_vector(31 downto 0);	-- VME data bus
	  vme_xbuf_dataoe	: out	std_logic;						-- VME data bus output enable
	  vme_xbuf_datadir	: out	std_logic;						-- VME data bus direction
	  vme_lword			: in	std_logic;						-- VME long word
	  vme_dtack			: out	std_logic;						-- VME data transfer acknowledge
	  vme_xbuf_dtackoe	: out	std_logic;						-- VME data transfer acknowledge output enable
	  vme_vack			: in	std_logic;						-- VME data transfer acknowledge read value
	  vme_as			: in	std_logic;						-- VME address strobe
	  vme_ds0			: in	std_logic;						-- VME data strobe #0
	  vme_ds1			: in	std_logic;						-- VME data strobe #1
	  vme_write			: in	std_logic;						-- VME read/write
	  vme_iack			: in	std_logic;						-- VME interrupt acknowledge
	  vme_iack_in		: in	std_logic;						-- VME interrupt acknowledge daisy-chain input
	  vme_iack_out		: out	std_logic;						-- VME interrupt acknoweldge daisy-chain output
	  vme_irq			: out	std_logic_vector(7 downto 1);	-- VME interrupt request
	  vme_berr			: out	std_logic;						-- VME bus error
	  vme_verr			: in	std_logic;						-- VME bus error read value
	  vme_sysreset		: in	std_logic;						-- VME system reset
	  vme_sysclock		: in	std_logic;						-- VME system clock
	  vme_retry			: out	std_logic;						-- VME retry
	  vme_xbuf_retryoe	: out	std_logic;						-- VME retry output enable
	  vme_ga			: in	std_logic_vector(4 downto 0);	-- VME geographical address
	  vme_gap			: in	std_logic;						-- VME geographical address parity
	--
	-- Common signals
	--
	  powerup_reset	: in	std_logic;						-- COM power-up reset
	  clock_40mhz		: in	std_logic;						-- COM 40 MHz clock
	--
	-- User-side signals
	--
	  user_addr			: out	std_logic_vector(24 downto 0);	-- USR latched address bus (32-bit words)
	  user_am			: out	std_logic_vector(5 downto 0);	-- USR addres modifier
	  user_data			: inout	std_logic_vector(31 downto 0);	-- USR data bus
	  user_read			: out	std_logic_vector((NUM_USR_MAP-1) downto 0);	-- USR read strobe
	  user_write		: out	std_logic_vector((NUM_USR_MAP-1) downto 0);	-- USR vme_writeite strobe
	  user_dtack		: in	std_logic_vector((NUM_USR_MAP-1) downto 0);	-- USR data transfer acknowledge
	  user_error		: in	std_logic_vector((NUM_USR_MAP-1) downto 0);	-- USR error
	  user_ireq			: in	std_logic_vector((NUM_USR_IRQ-1) downto 0);	-- USR interrupt request
	  user_iack			: out	std_logic_vector((NUM_USR_IRQ-1) downto 0);	-- USR interrupt acknowledge
	  user_reset		: out	std_logic_vector((NUM_USR_RST-1) downto 0);	-- USR reset	
	  -- for device-internal use
	  user_addr_out		: out	std_logic_vector(24 downto 0);	-- USR latched address bus (32-bit words)
	  user_am_out		: out	std_logic_vector(5 downto 0);	-- USR addres modifier
	  user_data_out		: out	std_logic_vector(31 downto 0);	-- USR data bus
	  user_valid		: out	std_logic;						-- USR addr/am/data valid
	  user_data_in		: in	std_logic_vector(31 downto 0)	-- USR data bus
	);
	
  end vmeif;

--
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--
  architecture vmeif_one of vmeif is
--
-- Define CR addresses
--
	constant CR_MASK			: std_logic_vector(19 downto 0) := x"7F000";	-- VME64x defined CR
	constant CR_ADDR			: std_logic_vector(19 downto 0)	:= x"00000";	-- VME64x defined CR
	
	constant CR_VME64_MASK		: std_logic_vector(11 downto 0) := x"F80";		-- VME64 defined CR
	constant CR_VME64_ADDR		: std_logic_vector(11 downto 0)	:= x"000";		-- VME64 defined CR

	constant ADEM_MASK			: std_logic_vector(11 downto 0)	:= x"FF0";		-- Address decoder mask
	constant ADEM_ADDR			: std_logic_vector(11 downto 0)	:= x"623";		-- Address decoder mask	

	constant ADEM				: std_logic_vector(31 downto 0) := usr_adem(0) & usr_adem(1) & usr_adem(2) & x"00";
--
-- Define CSR addresses
--
	constant CSR_MASK			: std_logic_vector(19 downto 0) := x"7F000";	-- Complete CSR
	constant CSR_ADDR			: std_logic_vector(19 downto 0)	:= x"7FFFF";	-- Complete CSR
	
	constant CSR_VME64X_MASK	: std_logic_vector(11 downto 0)	:= x"F00";		-- VME64x defined CSR
	constant CSR_VME64X_ADDR	: std_logic_vector(11 downto 0)	:= x"FFF";		-- VME64x defined CSR
	
	constant BAR_MASK			: std_logic_vector(11 downto 0)	:= x"0FC";		-- Base address
	constant BAR_ADDR			: std_logic_vector(11 downto 0)	:= x"FFF";		-- Base address
	
	constant ADER_MASK			: std_logic_vector(11 downto 0)	:= x"0F0";		-- Address decoder compare register
	constant ADER_ADDR			: std_logic_vector(11 downto 0)	:= x"F63";		-- Address decoder compare register
	
	constant CSR_USER_MASK		: std_logic_vector(11 downto 0)	:= x"F80";		-- User CSR
	constant CSR_USER_ADDR		: std_logic_vector(11 downto 0)	:= x"B83";		-- User CSR
--
-- Define function for address comparison with mask
--	
	function ADDRCOMP (x, mask, addr : std_logic_vector) return boolean is
	  variable result : boolean;
	begin
	  result := ((x and mask) = (addr and mask));
	  return result;
	end function ADDRCOMP;
--
-- Define indices for user CSR
--		
	constant RCSR_1_IDX			: integer	:= 29;
	constant RCSR_0_IDX			: integer	:= 28;
	constant ICSR_3B_IDX		: integer	:= 27;
	constant ICSR_3A_IDX		: integer	:= 26;
	constant ICSR_2B_IDX		: integer	:= 25;
	constant ICSR_2A_IDX		: integer	:= 24;
	constant ICSR_1B_IDX		: integer	:= 23;
	constant ICSR_1A_IDX		: integer	:= 22;
	constant ICSR_0B_IDX		: integer	:= 21;
	constant ICSR_0A_IDX		: integer	:= 20;
	constant ISTAT_3D_IDX		: integer	:= 19;
	constant ISTAT_3C_IDX		: integer	:= 18;
	constant ISTAT_3B_IDX		: integer	:= 17;
	constant ISTAT_3A_IDX		: integer	:= 16;
	constant ISTAT_2D_IDX		: integer	:= 15;
	constant ISTAT_2C_IDX		: integer	:= 14;
	constant ISTAT_2B_IDX		: integer	:= 13;
	constant ISTAT_2A_IDX		: integer	:= 12;
	constant ISTAT_1D_IDX		: integer	:= 11;
	constant ISTAT_1C_IDX		: integer	:= 10;
	constant ISTAT_1B_IDX		: integer	:=  9;
	constant ISTAT_1A_IDX		: integer	:=  8;
	constant ISTAT_0D_IDX		: integer	:=  7;
	constant ISTAT_0C_IDX		: integer	:=  6;
	constant ISTAT_0B_IDX		: integer	:=  5;
	constant ISTAT_0A_IDX		: integer	:=  4;

	-- To conveniently access the registers ...
	constant ICSR_IDX			: integer_vector(NUM_USR_IRQ-1 downto 0) :=
											( ICSR_3A_IDX, ICSR_2A_IDX, ICSR_1A_IDX, ICSR_0A_IDX );
	constant ISTATA_IDX			: integer_vector(NUM_USR_IRQ-1 downto 0) :=
											( ISTAT_3A_IDX, ISTAT_2A_IDX, ISTAT_1A_IDX, ISTAT_0A_IDX);
	constant ISTATB_IDX			: integer_vector(NUM_USR_IRQ-1 downto 0) :=
											( ISTAT_3B_IDX, ISTAT_2B_IDX, ISTAT_1B_IDX, ISTAT_0B_IDX);
	constant ISTATC_IDX			: integer_vector(NUM_USR_IRQ-1 downto 0) :=
											( ISTAT_3C_IDX, ISTAT_2C_IDX, ISTAT_1C_IDX, ISTAT_0C_IDX);
	constant ISTATD_IDX			: integer_vector(NUM_USR_IRQ-1 downto 0) :=
											( ISTAT_3D_IDX, ISTAT_2D_IDX, ISTAT_1D_IDX, ISTAT_0D_IDX);
	constant RCSR_IDX			: integer_vector(NUM_USR_RST-1 downto 0) :=
											( RCSR_1_IDX, RCSR_0_IDX );
					
--
-- Define CSR registers
--
	signal	ga_par				: std_logic;
    signal	BAR					: std_logic_vector(4 downto 0);		-- Base address register
	signal	ADER				: MEM_4_BYTE;						-- Address decoder compare register
	signal	CSR_USER			: MEM_32_BYTE;						-- User CSR registers
	
	signal	csr_irst_status		: std_logic_vector(1 downto 0);
	signal	csr_ireq_status		: std_logic_vector(3 downto 0);
	signal	csr_iack_status		: std_logic_vector(3 downto 0);	
--
--	Registers for temporary CR/CSR values
--
    signal	cr_reg				: std_logic_vector(7 downto 0);
    signal	csr_reg				: std_logic_vector(7 downto 0);
--
-- Signals for VMEbus
--
	signal	i_clock				: std_logic;
    signal	i_vme_as      		: boolean;
    signal	i_vme_ds			: std_logic;
    signal	i_vme_lword			: std_logic;
    signal	i_vme_read			: boolean;
	signal	i_vme_write			: boolean;
	signal	i_vme_as_ok			: boolean;
	signal	i_vme_iack			: std_logic;
	signal	i_reset				: boolean;

    signal	i_vme_addr			: std_logic_vector(31 downto 0);  	-- VME address
    signal	i_vme_am			: std_logic_vector(5 downto 0);  	-- VME address modifier
	signal	i_vme_data			: std_logic_vector(31 downto 0);	-- VME data (input)
    signal	o_vme_addr			: std_logic_vector(24 downto 0);  	-- VME address
    signal	o_vme_am			: std_logic_vector(5 downto 0);  	-- VME address modifier
	signal	o_vme_data			: std_logic_vector(31 downto 0);	-- VME data (output)
--
-- Signals for CR
--
    signal	cr_am_single		: boolean;
    signal	cr_addr_match		: boolean;
    signal	cr_select			: boolean;
--
-- Signals for CSR
--
    signal	csr_am_single		: boolean;
    signal	csr_addr_match		: boolean;
    signal	csr_select			: boolean;
--
-- Signals for user mappings
--
	signal	usr_am_single		: boolean_vector((NUM_USR_MAP-1) downto 0);
	signal	usr_am_block		: boolean_vector((NUM_USR_MAP-1) downto 0);
	signal	usr_addr_match		: boolean_vector((NUM_USR_MAP-1) downto 0);
	signal	usr_select			: boolean_vector((NUM_USR_MAP-1) downto 0);
	signal	any_usr_select		: boolean;
	signal	any_usr_select_ext	: boolean;
	signal	any_usr_select_int	: boolean;
--
-- Signal for selection of whole module
--
	signal	module_select		: boolean;
--
-- State machines
--
	type	STATE_TYPE_DTB is	array (6 downto 0) of std_logic;
	constant DTB_IDLE			: STATE_TYPE_DTB := "0000000";
	constant DTB_ACTIVE			: STATE_TYPE_DTB := "0001001";
	constant DTB_DTACK			: STATE_TYPE_DTB := "0001011";
	constant DTB_BLKWAIT		: STATE_TYPE_DTB := "0001000";
	constant DTB_BLKINC			: STATE_TYPE_DTB := "0011000";
	constant DTB_PIPELINE		: STATE_TYPE_DTB := "1001011";
	constant DTB_FINISH			: STATE_TYPE_DTB := "0100000";
	constant DTB_ERROR			: STATE_TYPE_DTB := "0001100";
    signal	 state_dtb			: STATE_TYPE_DTB;

	type	STATE_TYPE_IRQ is array(1 downto 0) of std_logic;
	constant IRQ_IDLE			: STATE_TYPE_IRQ := "00";
	constant IRQ_ACCEPT			: STATE_TYPE_IRQ := "10";
	constant IRQ_ACTIVE			: STATE_TYPE_IRQ := "11";
    signal	 state_irq			: STATE_TYPE_IRQ;
--
-- Control signals
--
    signal	ctrl_dtb_vmeok		: boolean;
    signal	ctrl_dtb_dtack		: boolean;
    signal	ctrl_dtb_error		: boolean;
	signal	ctrl_dtb_addrlck	: boolean;
	signal	ctrl_dtb_addrinc	: boolean;
	signal	ctrl_dtb_iackend	: boolean;
	
	signal	ctrl_irq_active		: boolean;
    signal	ctrl_iack_finish	: boolean;
--
-- User data bus
--
	signal	i_user_data			: std_logic_vector(31 downto 0);
	signal	o_user_data			: std_logic_vector(31 downto 0);
--
-- Signals for interrupt request
--
	signal	ireq_select			: USR_IRQ_IDX;
	signal	i_ireq_select		: USR_IRQ_IDX;
	signal	any_ireq_select		: boolean;
	
	signal	ireq_level			: std_logic_vector(2 downto 0);		-- level from register
    signal	ireq_output			: std_logic_vector(7 downto 1);		-- output to drive
	signal	o_user_iack			: std_logic_vector((NUM_USR_IRQ-1) downto 0);
--
-- Signals for interrupt acknowledge
--
	signal	ilev_select			: boolean;							-- interrupt level selected       (first condition)
	signal	iack_select			: boolean;							-- interrupt acknowledge selected (iack strobe and token active)
	signal	iack_select_save	: boolean;							-- interrupt acknowledge selected (saved for later test)
	signal	iack_level			: std_logic_vector(2 downto 0);		-- level from VMEbus
	signal	iack_status			: std_logic_vector(31 downto 0);	-- STATUS/ID vector
--
-- Signals for data acknowledge or user error
--
    signal	i_delay				: std_logic_vector(0 to (NUM_DELAY-1));	-- internal delay for acknowledge
	signal	i_usr_dtack			: std_logic_vector(15 downto 0);
	signal	i_usr_error			: std_logic_vector(15 downto 0);
	signal	any_usr_dtack		: std_logic;
	signal	any_usr_error		: std_logic;
    signal	i_dtack				: boolean;							-- internal acknowledge
	signal	i_error				: boolean;							-- internal error
    signal	o_dtack				: std_logic;						-- output to drive
    signal	o_error				: std_logic;						-- output to drive
	signal	ctrl_dtack_save		: boolean;							-- rescinding dtack
--
-- Signal for resets
--
	signal	o_user_reset		: std_logic_vector((NUM_USR_RST-1) downto 0);
	
  begin
--
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Monitor Control Signals
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--
-- Clock
--
	USR_CLOCK_SYSTEM : if (usr_clock = system) generate
	  i_clock		<= vme_sysclock;
	end generate USR_CLOCK_SYSTEM;
	USR_CLOCK_EXTERNAL : if (usr_clock = external) generate
	  i_clock		<= clock_40mhz;
	end generate USR_CLOCK_EXTERNAL;	
--
-- Asynchronous control signals
--
	i_vme_iack		<= vme_iack;
	i_reset			<= (powerup_reset = '1' or vme_sysreset = '0');
--
-- Synchronous control signals
--
    synchronize_control : process(i_clock, vme_as, vme_ds1, vme_ds0)
    begin
      if RISING_EDGE(i_clock) then
        i_vme_as		<= (vme_as = '0');						-- VME address strobe
        i_vme_ds		<= (not(vme_ds0) or not(vme_ds1));		-- VME data strobes
		if not(ctrl_dtb_vmeok) then
		  i_vme_read	<= (vme_write = '1');					-- VME read (synchronized)
		  i_vme_write	<= (vme_write = '0');					-- VME write (synchronized)
		end if;
      end if;
    end process synchronize_control;
--
-- Check for data acknowledge and bus error before starting transfer cycles
--
	i_vme_as_ok	<= (i_vme_as) and (vme_vack = '1') and (vme_verr = '1');

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Decode Addresses
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--
-- Latch address, long word and address modifier (for address pipelining)
--	
	USR_ADDRLE_INTERNAL : if (usr_addrle = internal) generate
	  latch_address : process(i_clock)
	  begin
		if RISING_EDGE(i_clock) then
		  if not(ctrl_dtb_vmeok) then
			i_vme_addr	<= vme_addr & not(vme_lword);	-- VME address
			i_vme_am	<= vme_am;						-- VME address modifier
			i_vme_lword	<= not(vme_lword);				-- VME long word
		  end if;
    	end if;
      end process latch_address;
	  vme_xbuf_addrle <= '1';
	end generate USR_ADDRLE_INTERNAL;
	USR_ADDRLE_EXTERNAL : if (usr_addrle = external) generate
	  i_vme_addr	<= vme_addr & not(vme_lword);		-- VME address
	  i_vme_am		<= vme_am;							-- VME address modifier
	  i_vme_lword	<= not(vme_lword);					-- VME long word
	  vme_xbuf_addrle <= '1' when ctrl_dtb_vmeok else '0';
	end generate USR_ADDRLE_EXTERNAL;
--
-- Decode configuration ROM
--
	cr_addr_match	<= (i_vme_addr(23 downto 19) = BAR)
				   and (ADDRCOMP(i_vme_addr(19 downto 0),CR_MASK,CR_ADDR));
    cr_am_single	<= ("00" & i_vme_am(5 downto 0) = x"2F");	-- CR/CSR cycle
    cr_select		<= cr_addr_match and cr_am_single;
--
-- Decode control and status RAM
--
    csr_addr_match	<= (i_vme_addr(23 downto 19) = BAR)
				   and (ADDRCOMP(i_vme_addr(19 downto 0),CSR_MASK,CSR_ADDR));
    csr_am_single	<= ("00" & i_vme_am(5 downto 0) = x"2F");	-- CR/CSR cycle
    csr_select		<= csr_addr_match and csr_am_single;
--
-- Decode user spaces
--

	USR_DECODE_MAP : for i in 0 to (NUM_USR_MAP - 1) generate
	  USR_ENABLE_MAP : if (usr_addr_map(i).mask /= x"00000000") generate
		usr_addr_match(i)	<= (ADDRCOMP(i_vme_addr,ADEM,(ADER(0)&ADER(1)&ADER(2)&x"00")))			-- BASE address comparison
						   and (ADDRCOMP(i_vme_addr,usr_addr_map(i).mask,usr_addr_map(i).addr));	-- DEVICE address comparison
	  	usr_am_single(i)	<= ("00" & i_vme_am(5 downto 0) = usr_addr_map(i).sgl);
		usr_am_block(i)	<= ("00" & i_vme_am(5 downto 0) = usr_addr_map(i).blt);
		usr_select(i)		<= usr_addr_match(i) and (usr_am_single(i) or usr_am_block(i));
	  end generate USR_ENABLE_MAP;
	  USR_DISABLE_MAP : if (usr_addr_map(i).mask = x"00000000") generate
		usr_select(i)		<= false;
	  end generate USR_DISABLE_MAP;
	end generate USR_DECODE_MAP;
	
	testpin <= '1' when i_vme_as_ok else '0';	-- HERMAN - to test base address decoding 28/02/11 
	
	or_usr_select : process(usr_select)
	  variable select_help		: boolean;
	  variable select_help_ext	: boolean;
	  variable select_help_int	: boolean;
	begin
	  select_help			:= false;
	  select_help_ext		:= false;
	  select_help_int		:= false;
	  for i in 0 to (NUM_USR_MAP - 1) loop
		select_help			:= select_help or usr_select(i);
		if usr_addr_map(i).external then
		  select_help_ext	:= select_help_ext or usr_select(i);
		else
		  select_help_int	:= select_help_int or usr_select(i);
		end if;		
	  end loop;
	  any_usr_select		<= select_help;
	  any_usr_select_ext	<= select_help_ext;
	  any_usr_select_int	<= select_help_int;
	end process or_usr_select;	
--
-- Select module
--
    module_select	<= (cr_select or csr_select or any_usr_select) and (i_vme_iack = '1');
--
-- Decode IRQ level during interrupt acknowledge
--
	ilev_select <= (ireq_level = i_vme_addr(3 downto 1)) and ctrl_irq_active;
	iack_select <= ilev_select and (i_vme_iack = '0') and (vme_iack_in = '0');
	
	latch_iack_select : process (i_clock, i_reset)
	begin
	  if i_reset then
		iack_select_save <= false;
	  elsif RISING_EDGE(i_clock) then
		if ctrl_dtb_vmeok and not(ctrl_dtb_dtack) then
		  iack_select_save <= iack_select;
		end if;
	  end if;	
	end process latch_iack_select;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Control state machines: separate state machines 
-- for single transfer, block transfer and interrupt request and acknowledge
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Data transfer R/W cycle (single and block)
---------------------------------------------------------------------------------------------------
	state_machine_dtb: process(i_reset, i_clock, state_dtb, i_vme_as_ok, module_select,
	  i_vme_as, i_vme_ds, iack_select, i_error, i_dtack, i_delay)
	begin
	  if(i_reset) then
		state_dtb <= DTB_Idle;
	  elsif RISING_EDGE(i_clock) then
		case state_dtb is
		
		  when DTB_IDLE =>					-- Check as, dtack, berr, iack and module selection
			if i_vme_as_ok and (module_select or iack_select) and i_vme_ds = '1' then
			  state_dtb <= DTB_ACTIVE;		-- Data transfer cycle
			else
			  state_dtb <= DTB_IDLE;		-- Wait
			end if;
			
		  when DTB_ACTIVE =>				-- Check internal dtack
			if (i_error) or (not(i_dtack) and (i_delay(NUM_DELAY-1) = '1')) then
			  state_dtb <= DTB_ERROR;		-- Goto error state
			elsif i_dtack then
			  state_dtb <= DTB_DTACK;		-- Generate dtack
			else
			  state_dtb <= DTB_ACTIVE;		-- Wait
        	end if;

		  when DTB_DTACK =>					-- Check address and data strobes
			if (   i_vme_ds = '0' and     i_vme_as) then
			  state_dtb <= DTB_BLKINC;		-- Continue data transfer
			elsif (i_vme_ds = '0' and not(i_vme_as)) then
			  state_dtb <= DTB_FINISH;		-- Terminate data transfer
			elsif (i_vme_ds = '1' and not(i_vme_as)) then
			  state_dtb <= DTB_PIPELINE;	-- Address Pipelining 
			else
			  state_dtb <= DTB_DTACK;		-- Wait
			end if;
			
		  when DTB_BLKINC =>				-- Address increment state: goto selected state
        	if (not(i_vme_as)) then
			  state_dtb <= DTB_FINISH;		-- Finish cycle
			elsif i_vme_ds = '1' then
			  state_dtb <= DTB_ACTIVE;		-- Continue data transfer
			else
			  state_dtb <= DTB_BLKWAIT;		-- Wait for next data transfer
		    end if;
		
		  when DTB_BLKWAIT =>				-- Check address and data strobes
			if (not(i_vme_as)) then
			  state_dtb <= DTB_FINISH;		-- Finish cycle
			elsif (i_vme_ds = '1') then
			  state_dtb <= DTB_ACTIVE;		-- Address and data cycle
			else
			  state_dtb <= DTB_BLKWAIT;		-- Wait
			end if;
			
		  when DTB_PIPELINE =>				-- Check data strobe
			if(i_vme_ds = '0') then
			  state_dtb <= DTB_FINISH;		-- Goto terminate state
			else
			  state_dtb <= DTB_PIPELINE;	-- Wait
			end if;
			
		  when DTB_FINISH =>				-- Terminate state: unconditionally goto idle state
			state_dtb <= DTB_IDLE;
			
		  when DTB_ERROR =>					-- Error state: wait for address and data strobes
			if (i_vme_ds = '0' and not(i_vme_as)) then
			  state_dtb <= DTB_IDLE;
			else
			  state_dtb <= DTB_ERROR;		-- Wait
			end if;
			
		  when others =>					-- Exception catcher: unconditonally goto idle state
			state_dtb <= DTB_IDLE;
			
		end case;
	  end if;	
    end process state_machine_dtb;

---------------------------------------------------------------------------------------------------
-- Interrupt request cycle: driven from user side!
---------------------------------------------------------------------------------------------------
	state_machine_irq: process(i_reset, i_clock, state_irq, any_ireq_select,
	  ctrl_dtb_iackend, iack_select_save)
	begin
	  if(i_reset) then
		state_irq <= IRQ_Idle;
	  elsif RISING_EDGE(i_clock) then
		case state_irq is
		
		  when IRQ_IDLE =>
			if (any_ireq_select) then
			  state_irq <= IRQ_ACCEPT;		-- User interrupt request
			else
			  state_irq <= IRQ_IDLE;		-- Wait
			end if;
			
		when IRQ_ACCEPT =>
		  state_irq <= IRQ_ACTIVE;			-- Intermediate state: unconditionally progress to active
		
		when IRQ_ACTIVE =>
		  if (ctrl_dtb_iackend and iack_select_save) then
			state_irq <= IRQ_IDLE;			-- Finish user interrupt
		  else
			state_irq <= IRQ_ACTIVE;		-- Wait
		  end if;
		
		when others =>
		  state_irq <= IRQ_IDLE;
		
		end case;
	  end if;
	end process state_machine_irq;
--
-- Calculate output associated to state machines
--				
	ctrl_dtb_vmeok		<= (state_dtb(0) = '1');
	ctrl_dtb_dtack		<= (state_dtb(1) = '1');
	ctrl_dtb_error		<= (state_dtb(2) = '1');
	ctrl_dtb_addrlck	<= (state_dtb(3) = '1');
	ctrl_dtb_addrinc	<= (state_dtb(4) = '1');
	ctrl_dtb_iackend	<= (state_dtb(5) = '1');
	
	ctrl_irq_active		<= (state_irq(0) = '1');
	
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Generate data acknowledge and bus error
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--
-- Process to generate delay based on a shift register
--
    delay_gen : process(i_clock, ctrl_dtb_vmeok)
    begin
      if RISING_EDGE(i_clock) then
		if not(ctrl_dtb_vmeok) then
		  i_delay <= (others => '0');
		else
		  i_delay(0) <= '1';
		  for i in 1 to (NUM_DELAY-1) loop
			i_delay(i) <= i_delay(i-1);
		  end loop;
		end if;
	  end if;
    end process delay_gen;
--
-- Generate data acknowledge and user error
--
	USR_DTACK_MAP : for i in 0 to (NUM_USR_MAP - 1) generate
	  USR_DTACK_ENABLE		: if (usr_addr_map(i).mask /= x"00000000") generate 
	    USR_DTACK_INTERNAL	: if ((usr_addr_map(i).dtack_time > 0) and 
								  (usr_addr_map(i).dtack_time <= NUM_DELAY)) generate
		  i_usr_dtack(i)	<= i_delay(usr_addr_map(i).dtack_time - 1);
	    end generate USR_DTACK_INTERNAL;
	    USR_DTACK_ZERO		: if ((usr_addr_map(i).dtack_time = 0)) generate
		  i_usr_dtack(i)	<= '1' when ctrl_dtb_vmeok else '0';
	    end generate USR_DTACK_ZERO;
	    USR_DTACK_EXTERNAL	: if ((usr_addr_map(i).dtack_time < 0) or
								  (usr_addr_map(i).dtack_time > NUM_DELAY)) generate
		  i_usr_dtack(i)	<= user_dtack(i);
	    end generate USR_DTACK_EXTERNAL;
		i_usr_error(i)		<= user_error(i);
	  end generate USR_DTACK_ENABLE;
	  USR_DTACK_DISABLE		: if (usr_addr_map(i).mask = x"00000000") generate
		i_usr_dtack(i) 	<= '0';
		i_usr_error(i)		<= '0';
	  end generate USR_DTACK_DISABLE;
	end generate USR_DTACK_MAP;

	or_usr_dtack : process(i_usr_dtack, usr_select, ctrl_dtb_vmeok)
	  variable dtack_help : std_logic;
	begin
	  dtack_help		:= '0';
	  for i in 0 to (NUM_USR_MAP-1) loop
		if (usr_select(i) and ctrl_dtb_vmeok) then
		  dtack_help	:= dtack_help or i_usr_dtack(i);
		end if;
	  end loop;
	  any_usr_dtack	<= dtack_help;
	end process or_usr_dtack;

	i_dtack <= true when (cr_select and ctrl_dtb_vmeok)
	                  or (csr_select and ctrl_dtb_vmeok)
					  or (iack_select and ctrl_dtb_vmeok)
	                  or (any_usr_select and (any_usr_dtack = '1'))
		  else false;
					
	or_usr_error : process(i_usr_error, usr_select, ctrl_dtb_vmeok)
	  variable error_help : std_logic;
	begin
	  error_help		:= '0';
	  for i in 0 to (NUM_USR_MAP-1) loop
		if (usr_select(i) and ctrl_dtb_vmeok) then
		  error_help	:= error_help or i_usr_error(i);
		end if;
	  end loop;
	  any_usr_error	<= error_help;
	end process or_usr_error;
	
	i_error <= true when (any_usr_error = '1')
		  else false;
--
-- Generate data acknowledge, bus error and retry
--
	USR_DTACK_FLOATING : if (usr_dtack = floating) generate
	  vme_dtack			<= '0';
	  vme_xbuf_dtackoe	<= '1' when (ctrl_dtb_dtack)
					  else '0';
	end generate USR_DTACK_FLOATING;
	USR_DTACK_RESCINDING : if (usr_dtack = rescinding) generate
	  latch_ctrl_dtack : process(i_clock)
	  begin
		if RISING_EDGE(i_clock) then
		  ctrl_dtack_save <= ctrl_dtb_dtack;
		end if;
	  end process latch_ctrl_dtack;	
	  o_dtack			<= '0' when (ctrl_dtb_dtack)
					  else '1';	
	  vme_dtack			<= o_dtack;
	  vme_xbuf_dtackoe	<= '1' when (ctrl_dtb_dtack or ctrl_dtack_save)
					  else '0';
	end generate USR_DTACK_RESCINDING;

	o_error				<= '1' when (ctrl_dtb_error)
					  else '0';
	vme_berr			<= o_error;

	vme_retry			<= 'Z';		-- Do not use retry!
	vme_xbuf_retryoe	<= '0';		-- Do not use retry!
	
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Output user addresses, am and read/write strobes
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------	
--
-- Store and increment address
--
	output_address : process (i_clock)
	begin
	  if RISING_EDGE(i_clock) then
	    if (not ctrl_dtb_addrlck) then
		  o_vme_addr	<= vme_addr(26 downto 2);				
		elsif (ctrl_dtb_addrinc) then
		  o_vme_addr	<= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(o_vme_addr))+1,25));
		end if;
	  end if;
	end process output_address;
--
-- User-side address, address modifier and data
--		
	-- write to user bus address
	user_addr		<= o_vme_addr		when (any_usr_select_ext and ctrl_dtb_vmeok)
				 else (others => 'Z');
	user_addr_out	<= o_vme_addr;
	
	-- write to user bus address modifier		
	o_vme_am		<= i_vme_am;	
	user_am			<= o_vme_am			when (any_usr_select_ext and ctrl_dtb_vmeok)
				 else (others => 'Z');
	user_am_out		<= o_vme_am;
			
	-- write to user bus data
	o_user_data		<= i_vme_data;	
	user_data		<= o_user_data		when (any_usr_select_ext and i_vme_write and ctrl_dtb_vmeok)
				 else (others => 'Z');
	user_data_out	<= o_user_data;

	-- validate addr/am/data (write) for internal use
	user_valid		<= '1' when (any_usr_select_int and ctrl_dtb_vmeok) else '0';
	
	-- read from user bus data
	i_user_data		<= user_data_in		when (any_usr_select_int)
				  else user_data;
--
-- User-side read and write strobes
--	
	USR_SIGNALS : for i in 0 to (NUM_USR_MAP - 1) generate
	  USR_STROBES : if (usr_addr_map(i).mask /= x"00000000") generate
		user_read(i)	<= '1' when (usr_select(i) and i_vme_read and ctrl_dtb_vmeok)
					  else '0';
		user_write(i)	<= '1' when (usr_select(i) and i_vme_write and ctrl_dtb_vmeok)
					  else '0';
	  end generate USR_STROBES;
	end generate USR_SIGNALS;
--
-- VMEbus-side data
--	 
	-- read from VMEbus
	i_vme_data <= vme_data;
	
	-- write to VMEbus
    o_vme_data	<= x"000000" & cr_reg		when cr_select
			  else x"000000" & csr_reg 		when csr_select
			  else i_user_data				when any_usr_select
			  else iack_status				when iack_select or iack_select_save
              else x"00000000";

	-- external VMEbus signals
	vme_data	<= o_vme_data				when (i_vme_read and ctrl_dtb_vmeok and i_vme_ds = '1')
																			and not(any_usr_select_ext)				-- CTPMON uses external data lines
              else (others => 'Z');

	vme_xbuf_dataoe <= '0' 					when (               ctrl_dtb_vmeok and i_vme_ds = '1')
				  else '1';
				
	vme_xbuf_datadir <= '1' 				when (i_vme_read and ctrl_dtb_vmeok and i_vme_ds = '1')
				   else '0';

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- CR/CSR
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--
-- Read from configuration ROM
--
    read_cr : process(i_clock, i_reset)
      variable index : integer;
    begin
      if (i_reset) then
        cr_reg <= x"00";
      elsif RISING_EDGE(i_clock) then
		if (cr_select and i_vme_read) then
		  if (ADDRCOMP(i_vme_addr(11 downto 0),CR_VME64_MASK,CR_VME64_ADDR)) then
		  	index := TO_INTEGER(UNSIGNED(i_vme_addr(6 downto 2)));
		  	cr_reg <= usr_cr_data(index);
		  elsif (ADDRCOMP(i_vme_addr(11 downto 0),ADEM_MASK,ADEM_ADDR)) then
		  	index := TO_INTEGER(UNSIGNED(i_vme_addr(3 downto 2)));
		  	cr_reg <= usr_adem(index);
		  else
			cr_reg <= x"00";
		  end if;
        end if;
      end if;
    end process read_cr;
--
-- Read from control and status register RAM
--
    read_csr : process(i_clock, i_reset)
      variable index : integer;
    begin
      if (i_reset) then
        csr_reg <= x"00";
      elsif RISING_EDGE(i_clock) then
		if (csr_select and i_vme_read) then
		  if (ADDRCOMP(i_vme_addr(11 downto 0),CSR_VME64X_MASK,CSR_VME64X_ADDR)) then
			if (ADDRCOMP(i_vme_addr(11 downto 0),BAR_MASK,BAR_ADDR)) then
				csr_reg <= BAR & "000";
			elsif (ADDRCOMP(i_vme_addr(11 downto 0),ADER_MASK,ADER_ADDR)) then
			  index := TO_INTEGER(UNSIGNED(i_vme_addr(3 downto 2)));
			  csr_reg <= ADER(index);
			else
			  csr_reg <= x"00";
			end if;
		  elsif (ADDRCOMP(i_vme_addr(11 downto 0),CSR_USER_MASK,CSR_USER_ADDR)) then
		  	index := TO_INTEGER(UNSIGNED(i_vme_addr(6 downto 2)));
			case index is
			when RCSR_1_IDX =>
			  csr_reg <= "0000" & csr_irst_status(1) & CSR_USER(index)(2 downto 0);
			when RCSR_0_IDX =>
			  csr_reg <= "0000" & csr_irst_status(0) & CSR_USER(index)(2 downto 0);
			when ICSR_3B_IDX =>
			  csr_reg <= "0000000" & csr_iack_status(3);
			when ICSR_3A_IDX =>
			  csr_reg <= csr_ireq_status(3) & CSR_USER(index)(6 downto 0);
			when ICSR_2B_IDX =>
			  csr_reg <= "0000000" & csr_iack_status(2);
			when ICSR_2A_IDX =>
			  csr_reg <= csr_ireq_status(2) & CSR_USER(index)(6 downto 0);
			when ICSR_1B_IDX =>
			  csr_reg <= "0000000" & csr_iack_status(1);
			when ICSR_1A_IDX =>
			  csr_reg <= csr_ireq_status(1) & CSR_USER(index)(6 downto 0);
			when ICSR_0B_IDX =>
			  csr_reg <= "0000000" & csr_iack_status(0);
			when ICSR_0A_IDX =>
			  csr_reg <= csr_ireq_status(0) & CSR_USER(index)(6 downto 0);
			when others =>
			  csr_reg <= CSR_USER(index);
			end case;
		  else
			csr_reg <= x"00";
		  end if;
        end if;
      end if;
    end process read_csr;
--
-- Base address register, geographical address and its parity
--
	ga_parity : process(vme_ga)
	  variable gap_help : std_logic;
	begin
	  gap_help := '0';
	  for i in 4 downto 0 loop
		if(vme_ga(i) = '0') then
		  gap_help := not(gap_help);
		end if;
	  end loop;
	  ga_par <= gap_help;
	end process ga_parity;
	
	bar_register : process(i_clock, vme_ga, vme_gap, ga_par)
	begin
	  if RISING_EDGE(i_clock) then
		if (vme_gap = ga_par) then
		  BAR <= not(vme_ga);
		else
		  BAR <= "11110";
		end if;
	  end if;
	end process bar_register;	
--
-- write to control and status register RAM
--

--	ADER(0)	<= BAR & "000";		-- HERMAN INSERE EM 29/07/10: ASSIM NAO PRECISA DE RESET PARA CARREGAR ADER (abaixo)
--	ADER(1)	<= x"00";			-- HERMAN INSERE EM 08/09/10: ASSIM NAO PRECISA DE RESET PARA CARREGAR ADER
--	ADER(2)	<= x"00";			-- HERMAN INSERE EM 08/09/10: ASSIM NAO PRECISA DE RESET PARA CARREGAR ADER
--	ADER(3)	<= x"00";			-- HERMAN INSERE EM 08/09/10: ASSIM NAO PRECISA DE RESET PARA CARREGAR ADER

-- Changed on 11/2012 to run with the NuDAQ
		ADER(0)	<= x"02";		
		ADER(1)	<= BAR(3 downto 0) & "0000";	
		ADER(2)	<= x"00";		
		ADER(3)	<= x"00";		

		
	write_csr : process(i_clock, i_reset, BAR, i_vme_data)
      variable index : integer;
    begin
	 
      if (i_reset) then
		
		 --ADER(3)	<= x"00";
		 --ADER(2)	<= x"00";
		 --ADER(1)	<= x"00";
		 --ADER(0)	<= BAR & "000";						-- ADER intialised from BAR (= GA)		-- COMENTADO POR HERMAN EM 29/07/10		
		---------------------------------------------- CSR_USR is not reset
      elsif RISING_EDGE(i_clock) then
		if (csr_select and i_vme_write and ctrl_dtb_vmeok and not(ctrl_dtb_dtack)) then
		  if (ADDRCOMP(i_vme_addr(11 downto 0),CSR_VME64X_MASK,CSR_VME64X_ADDR)) then
		    if (ADDRCOMP(i_vme_addr(11 downto 0),ADER_MASK,ADER_ADDR)) then
			  index := TO_INTEGER(UNSIGNED(i_vme_addr(3 downto 2)));
			  --ADER(index) <= i_vme_data(7 downto 0);													-- COMENTADO POR HERMAN EM 29/07/10
			end if;
		  elsif (ADDRCOMP(i_vme_addr(11 downto 0),CSR_USER_MASK,CSR_USER_ADDR)) then
		  	index := TO_INTEGER(UNSIGNED(i_vme_addr(6 downto 2)));
			CSR_USER(index) <= i_vme_data(7 downto 0);
		  end if;
		else 
		  if (ctrl_irq_active) then
		    index := ICSR_IDX(ireq_select);
		    CSR_USER(index)(0) <= '0';
		  end if;
		end if;
	  end if;
    end process write_csr;

    status_csr : process(i_clock) 
    begin
      if RISING_EDGE(i_clock) then
		csr_irst_status(1) <= o_user_reset(1);
		csr_irst_status(0) <= o_user_reset(0);
		csr_iack_status(3) <= o_user_iack(3);
		csr_ireq_status(3) <= user_ireq(3);
		csr_iack_status(2) <= o_user_iack(2);
		csr_ireq_status(2) <= user_ireq(2);
		csr_iack_status(1) <= o_user_iack(1);
		csr_ireq_status(1) <= user_ireq(1);
		csr_iack_status(0) <= o_user_iack(0);
		csr_ireq_status(0) <= user_ireq(0);
	  end if;
	end process status_csr;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Interrupts
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--
-- Monitor user interrupt requests and select with priority (0 -> 1 -> 2 -> etc.)
--
	uirq_select : process(user_ireq, CSR_USER)
	  variable	h_ireq_request	: boolean_vector(NUM_USR_IRQ-1 downto 0);
	  variable	h_ireq_any		: boolean;
	begin
	  h_ireq_any := false;
	  i_ireq_select <= (NUM_USR_IRQ-1);
	  for i in (NUM_USR_IRQ-1) downto 0 loop
		h_ireq_request(i) := ((CSR_USER(ICSR_IDX(i))(0) = '1') and (user_ireq(i) = '1'));
		if h_ireq_request(i) then
		  i_ireq_select <= i;
		end if;
		h_ireq_any := h_ireq_any or h_ireq_request(i);
	  end loop;
	  any_ireq_select <= h_ireq_any;
	end process uirq_select;
	
	latch_user_ireq : process (i_clock)
	begin
	  if RISING_EDGE(i_clock) then
		if not(ctrl_irq_active) then
		  ireq_select <= i_ireq_select;
		end if;
	  end if;
	end process latch_user_ireq;	
--
-- Select interrupt level and drive interrupt request lines
--
	ireq_level <= CSR_USER(ICSR_IDX(ireq_select))(3 downto 1);
    with ireq_level select ireq_output <= "0000001" when o"1",
										  "0000010" when o"2",
										  "0000100" when o"3",
 										  "0001000" when o"4",
										  "0010000" when o"5",
 										  "0100000" when o"6",
										  "1000000" when o"7",
										  "0000000" when others;

    vme_irq   <= ireq_output	when (ctrl_irq_active)
			else "0000000";
--
-- Drive interrupt daisy chain
--
    vme_iack_out <= '0' when (vme_iack_in = '0') and not(ilev_select) and vme_as = '0'
			   else '1';
--
-- Generate STATUS/ID vector
--
    iack_status_generate : process(i_clock, ireq_select)
	begin
	  if RISING_EDGE(i_clock) then
		if (ctrl_irq_active) then
			  iack_status(31 downto 24) <= CSR_USER(ISTATA_IDX(ireq_select));
			  iack_status(23 downto 16)	<= CSR_USER(ISTATB_IDX(ireq_select));
			  iack_status(15 downto  8)	<= CSR_USER(ISTATC_IDX(ireq_select));
			  iack_status( 7 downto  0)	<= CSR_USER(ISTATD_IDX(ireq_select));
		end if;
	  end if;
	end process iack_status_generate;	
--
-- Handle user interrupt acknowledge
--
    uiak_generate : process(i_clock, i_reset)
    begin
      if (i_reset) then
		o_user_iack <= (others => '0');
      elsif RISING_EDGE(i_clock) then
		o_user_iack <= (others => '0');
		if (iack_select_save and ctrl_dtb_dtack) then
		  o_user_iack(ireq_select) <= '1';
		end if;
      end if;
    end process uiak_generate;

	user_iack <= o_user_iack;
	
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- User resets
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

	USR_RESET : for i in 0 to (NUM_USR_RST - 1) generate
	  o_user_reset(i) <= '1' when ((CSR_USER(RCSR_IDX(i))(0) = '0' and powerup_reset = '1') 
							    or (CSR_USER(RCSR_IDX(i))(1) = '0' and vme_sysreset = '0')
							    or (CSR_USER(RCSR_IDX(i))(2) = '1'))
				    else '0';
	  user_reset(i)	<= o_user_reset(i);
	end generate USR_RESET;
	
  end vmeif_one;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
