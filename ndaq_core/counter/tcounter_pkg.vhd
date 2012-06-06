-- $ Trigger Counter Package
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).

--use work.functions_pkg.all;

--

package tcounter_pkg is
	
	--
	--Constants
	--
	constant tcounter_channels	: integer	:= 8;
			
--*******************************************************************************************************************************

	--
	--Data Types
	--
	subtype	TCOUNTER_DATA_T	is std_logic_vector(31 downto 0);
	type	TCOUNTER_DATA_A	is array ((tcounter_channels-1) downto 0) of TCOUNTER_DATA_T;

	
--*******************************************************************************************************************************
	
end package tcounter_pkg;

--

package body tcounter_pkg is
end package body tcounter_pkg;
