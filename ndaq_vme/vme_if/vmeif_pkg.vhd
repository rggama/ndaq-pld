---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Design: C:\Projects\VmeInterface\vmeif_pkg.vhd
-- Author: Ralf Spiwoks,   original version
-- Company: CERN
-- Description: VME Interface of the ATLAS Level-1 Central Trigger Processor
--              package file for common definitions
-- Notes:
--
-- History:
-- 21 JAN 2004: Created seperate package file.
-- 12 JUL 2004: Latest version, new time stamp.

  library IEEE;
  use IEEE.Std_logic_1164.all;
  use IEEE.Numeric_std.all;

  package vmeif_pkg is

	constant NUM_USR_MAP		: integer := 16;
	constant NUM_USR_IRQ		: integer := 4;
	constant NUM_USR_RST		: integer := 2;
	constant NUM_DELAY			: integer := 16;

    type	MEM_32_BYTE is array(0 to 31) of std_logic_vector(7 downto 0);
    type	MEM_4_BYTE is array(0 to 3) of std_logic_vector(7 downto 0);
	type	USR_MAP is record
			addr				: std_logic_vector(31 downto 0);
			mask				: std_logic_vector(31 downto 0);
			sgl					: std_logic_vector(7 downto 0);
			blt					: std_logic_vector(7 downto 0);
			dtack_time			: integer;
			external			: boolean;
	end record USR_MAP;
	type	USR_MAP_VECTOR		is array (0 to (NUM_USR_MAP-1)) of USR_MAP;
	
	type	boolean_vector		is array (NATURAL range <>) of boolean;
	type	integer_vector 		is array (NATURAL range <>) of integer;	
	
	subtype USR_IRQ_IDX 		is integer range 0 to (NUM_USR_IRQ-1);

	type	USR_CLOCK_OPTION	is (system, external);	
	type	USR_ADDRLE_OPTION	is (internal, external);
	type	USR_DTACK_OPTION	is (floating, rescinding);
	type	USR_BUS_OPTION		is (external, internal);
	
  end package vmeif_pkg;

  package body vmeif_pkg is
  end package body vmeif_pkg;