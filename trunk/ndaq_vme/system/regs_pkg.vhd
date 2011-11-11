--
--

library ieee;
use ieee.std_logic_1164.all;


package regs_pkg is

	-- total system registers
	constant num_regs			: integer := 6;

	type	SYS_REGS_STRUCT		is record
			addr				: std_logic_vector(7 downto 0);
			writable			: boolean;
			readable			: boolean;
			peripheral			: boolean;
	end record SYS_REGS_STRUCT;
	 
	type SYS_REGS_VECTOR	is array (0 to (num_regs-1)) of SYS_REGS_STRUCT;

------------------------------------------------------------------------------- 

	--(addr, writable, readable, peripheral)
	constant system_regs_enum	: SYS_REGS_VECTOR :=
	(
		(x"AA",	true,	true,	false),	--Reset
		(x"80",	true,	true,	false),	--Control
		(x"81",	true,	true,	false),	--Readout		
		--
		(x"70",	true,	true,	true),	--SPI 
		(x"71",	false,	true,	true),	--SPI Status
		--
		(x"27", true, true, false)		--R/W Test Register
	);

-------------------------------------------------------------------------------

	type	SYS_REGS			is array (0 to (num_regs-1)) of std_logic_vector(7 downto 0);
	
end package regs_pkg;

package body regs_pkg is
end package body regs_pkg;
