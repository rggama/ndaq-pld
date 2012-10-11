--
--

library ieee;
use ieee.std_logic_1164.all;


package vme_regs is

	-- total system registers
	constant num_regs			: integer := 11;

	type	SYS_REGS_STRUCT		is record
			addr				: std_logic_vector(7 downto 0);
			writable			: boolean;
			readable			: boolean;
			peripheral			: boolean;
			rstate				: std_logic_vector(7 downto 0);
	end record SYS_REGS_STRUCT;
	 
	type SYS_REGS_VECTOR	is array (0 to (num_regs-1)) of SYS_REGS_STRUCT;

------------------------------------------------------------------------------- 

	--(addr, writable, readable, peripheral, reset state)
	constant system_regs_enum	: SYS_REGS_VECTOR :=
	(
		(x"AA",	true,	true,	false,	x"00"),	-- 00 - Reset 	-	-	-	-	-	VME: Base+0xA00000.
		(x"80",	true,	true,	false,	x"80"),	-- 01 - USB	Control	-	-	-	-	Not assigned to VME.
		(x"81",	true,	true,	false,	x"00"),	-- 02 - USB Readout	-	-	-	-	Not assigned to VME.
		--
		(x"70",	true,	true,	true,	x"00"),	-- 03 - SPI 	-	-	-	-	-	VME: Base+0x600000.
		(x"71",	false,	true,	true,	x"00"),	-- 04 - SPI Status	-	-	-	-	VME: Base+0x700000.
		--
		(x"27",	true,	true,	true,	x"00"),	-- 05 - Status Register	-	-	-	VME: Base+0x500000.			
		(x"82",	true,	true,	false,	x"00"),	-- 06 - USB Readout Reset	-	-	Not assigned to VME.
		(x"33",	true,	true,	false,	x"00"),	-- 07 - R/W Test Register	-	-	VME: Base+0x800000.
		(x"83",	true,	true,	false,	x"00"), -- 08 - Data Builder Block Size	-	Not assigned to VME.

		(x"28",	true,	true,	false,	x"44"),	-- 09 - Firmware Version	-	-	VME: Base+0x900000.
		
		(x"29",	true,	true,	false,	x"16")	-- 10 - NDAQ Number	-	-	-	-	VME: Base+0xB00000.
		
	);

-------------------------------------------------------------------------------

	type	SYS_REGS			is array (0 to (num_regs-1)) of std_logic_vector(7 downto 0);
	
end package vme_regs;

package body vme_regs is
end package body vme_regs;
