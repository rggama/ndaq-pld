--
--

library ieee;
use ieee.std_logic_1164.all;


package vme_regs is

	-- total system registers
	constant num_regs			: integer := 7;

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
		(x"AA",	true,	true,	false,	x"00"),	--Reset
		(x"80",	true,	true,	false,	x"00"),	--Control
		(x"81",	true,	true,	false,	x"00"),	--Readout		
		--
		(x"70",	true,	true,	true,	x"00"),	--SPI 
		(x"71",	false,	true,	true,	x"00"),	--SPI Status
		--
		(x"27",	true,	true,	false,	x"00"),	--R/W Test Register				
		(x"82",	true,	true,	false,	x"00")	--Readout Reset		
	);

-------------------------------------------------------------------------------

	type	SYS_REGS			is array (0 to (num_regs-1)) of std_logic_vector(7 downto 0);
	
end package vme_regs;

package body vme_regs is
end package body vme_regs;
