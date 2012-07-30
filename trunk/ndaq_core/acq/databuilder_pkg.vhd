-- $ Data Builder Package
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).

use work.functions_pkg.all;

--

package databuilder_pkg is
	
	--
	--Constants
	--
	
	--
	constant slots			: integer	:= 24;
	
	-- For Simulation
	--constant slots			: integer	:= 4;
	
	--
	constant transfer_max	: integer	:= 128;
	
	--
	constant address_max	: integer	:= 4;

	--
	constant in_width		: integer	:= 32;
	
	--
	constant out_width		: integer	:= 32;
	
	--
	constant total_modes	: integer := 3;
		
--*******************************************************************************************************************************

	--
	--Data Types
	--
	
	subtype	SLOTS_T					is std_logic_vector((slots-1) downto 0);
	subtype	SLOTS_REG_T				is std_logic_vector((NumBits(slots)-1) downto 0);
	subtype	TRANSFER_REG_T			is std_logic_vector((NumBits(transfer_max)-1) downto 0);
	subtype	ADDRESS_T				is std_logic_vector((address_max-1) downto 0);
	subtype	ADDRESS_REG_T			is std_logic_vector((Numbits(address_max)-1) downto 0);
	subtype	IDATA_T					is std_logic_vector((in_width-1) downto 0);
	subtype	ODATA_T					is std_logic_vector((out_width-1) downto 0);
	subtype MODE_T					is std_logic_vector((Numbits(total_modes)-1) downto 0);
	
	type	TRANSFER_A				is array ((slots-1) downto 0) of TRANSFER_REG_T;
	type	IDATA_A					is array ((slots-1) downto 0) of IDATA_T;
	type	ADDRESS_A				is array ((slots-1) downto 0) of ADDRESS_REG_T;
	type	MODE_A					is array ((slots-1) downto 0) of MODE_T;
	
	
--*******************************************************************************************************************************
	
end package databuilder_pkg;

--

package body databuilder_pkg is
end package body databuilder_pkg;
