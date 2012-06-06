--
--

library ieee;
use ieee.std_logic_1164.all;


package core_regs is

	-- total system registers
	constant num_regs			: integer := 13;

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
		(x"AA",	true,	true,	false,	x"00"),	-- 00 - Reset
		(x"80",	true,	true,	false,	x"00"),	-- 01 - Readout Enable: Controls DataBuilder's enable.
		(x"87",	true,	true,	false,	x"00"),	-- 02 - ADC Pwdn
		(x"89",	true,	true,	false,	x"00"),	-- 03 - FIFO Reset
		(x"91",	true,	true,	false,	x"00"),	-- 04 - ACQ Enable
		(x"77",	true,	true,	false,	x"00"),	-- 05 - Th 1L
		(x"78",	true,	true,	false,	x"00"),	-- 06 - Th 1H
		(x"79",	true,	true,	false,	x"9C"),	-- 07 - Th 2L 
		(x"7A",	true,	true,	false,	x"03"),	-- 08 - Th 2H
		(x"7B",	true,	true,	false,	x"00"),	-- 09 - Trigger Slope: Falling/Rising
		(x"50",	true,	true,	false,	x"00"),	-- 10 - TDC
		(x"51",	true,	true,	true,	x"00"),	-- 11 - TDC
		--
		(x"27",	true,	true,	false,	x"00")	-- 12 - R/W Test Register		
	);

-------------------------------------------------------------------------------

	type	SYS_REGS			is array (0 to (num_regs-1)) of std_logic_vector(7 downto 0);
	
end package core_regs;

package body core_regs is
end package body core_regs;
