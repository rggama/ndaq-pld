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

package mcounter_pkg is
	
	--
	--Constants
	--
	constant mcounter_channels	: integer	:= 8;
			
--*******************************************************************************************************************************

	--
	--Data Types
	--
	subtype	MCOUNTER_DATA_T	is std_logic_vector(35 downto 0);
	type	MCOUNTER_DATA_A	is array ((mcounter_channels-1) downto 0) of MCOUNTER_DATA_T;

	
--*******************************************************************************************************************************
	
end package mcounter_pkg;

--

package body mcounter_pkg is
end package body mcounter_pkg;
