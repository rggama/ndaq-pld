--
--
library ieee;
use ieee.std_logic_1164.all;


package usbcmds_pkg is

	constant total_cmds	: integer := 10;
	constant del_cmds	: integer := 25;
	
	type CMD_T is array (0 to (total_cmds-1)) of std_logic_vector(7 downto 0);
	type DEL_T is array (0 to (del_cmds-1)) of std_logic_vector(7 downto 0);

------------------------------------------------------------------------------- 

	constant COMMAND	: CMD_T :=
	(	
		-- Reset VME FPGA
		-- x"AA",
		-- x"AA",
		-- x"5A",
		-- x"A5",
		-- x"55",
		-- Enable Readout
		x"AA",
		x"A0",
		x"58",
		x"A1",
		x"50",
		-- Select All Channels
		x"AA",
		x"A1",
		x"58",
		x"AF",
		x"5F"
	);

-------------------------------------------------------------------------------
	
	constant D_COMMAND	: DEL_T :=
	(	
		-- Deselect All Channels
		x"AA",
		x"A1",
		x"58",
		x"A0",
		x"50",
		-- Disable Readout
		x"AA",
		x"A0",
		x"58",
		x"A0",
		x"50",
		-- Enable Command Response
		x"AA",
		x"A0",
		x"58",
		x"A0",
		x"58",
		-- Enable Readout
		x"AA",
		x"A0",
		x"58",
		x"A1",
		x"50",
		-- Select All Channels
		x"AA",
		x"A1",
		x"58",
		x"AF",
		x"5F"
		-- -- Deselect All Channels
		-- x"AA",
		-- x"A1",
		-- x"58",
		-- x"A0",
		-- x"50",
		-- -- Disable Readout
		-- x"AA",
		-- x"A0",
		-- x"58",
		-- x"A0",
		-- x"50"
	);

-------------------------------------------------------------------------------

end package usbcmds_pkg;

package body usbcmds_pkg is
end package body usbcmds_pkg;
