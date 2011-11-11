--
--

library ieee;
use ieee.std_logic_1164.all;


package regs_pkg is

	-- total system registers
	constant num_regs			: integer := 7;

	type	SYS_REGS_STRUCT		is record
			addr				: std_logic_vector(7 downto 0);
			writable			: boolean;
			readable			: boolean;
			peripheral		: boolean;
			rstate			: std_logic_vector(7 downto 0);
	end record SYS_REGS_STRUCT;
	 
	type SYS_REGS_VECTOR	is array (0 to (num_regs-1)) of SYS_REGS_STRUCT;

------------------------------------------------------------------------------- 

	--(addr, writable, readable, peripheral)
	constant system_regs_enum	: SYS_REGS_VECTOR :=
	(
		(x"AA",	true,	true,	false, x"00"),	--Reset
		(x"80",	true,	true,	false, x"00"),	--Readout Enable	--IDT Writer is always enabled. No readout control here... Change it!?
		(x"87",	true,	true,	false, x"00"),	--ADC Pwdn
		(x"89",	true,	true,	false, x"00"),	--FIFO Reset
		(x"91",	true,	true,	false, x"00"),	--ACQ Enable
		(x"77",	true,	true,	false, x"55"),	--Th
		--
		(x"27",	true,	true,	false, x"00")	--R/W Test Register
		
	);

-------------------------------------------------------------------------------

	type	SYS_REGS			is array (0 to (num_regs-1)) of std_logic_vector(7 downto 0);
	
end package regs_pkg;

package body regs_pkg is
end package body regs_pkg;
