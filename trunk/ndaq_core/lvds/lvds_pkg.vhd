-- $ lvds_pkg.vhd 
-- LVDS Receiver Package
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).

use work.functions_pkg.all;

--

package lvds_pkg is
	
	--
	--Constants
	--
	
	--
	-- Trigger Stages
	constant t_stages			: integer	:= 8;	-- Trigger Delay Stages = (t_stages - 1). If value = 1, there is no delay.
	
	--
	-- Data Stages
	constant d_stages			: integer	:= 8; 	-- Data Delay Stages = (d_stages - 1). If value = 1, there is no delay.

	--
	-- LVDS Width
	constant lvds_width			: integer := 16;
			
--*******************************************************************************************************************************

	--
	--Data Types
	--
	subtype LVDS_DATA_T				is std_logic_vector((lvds_width-1) downto 0);
	
	subtype BUFFERED_TRIGGER_T		is std_logic_vector((t_stages-1) downto 0);
	subtype T_SEL_T					is std_logic_vector((NumBits(t_stages)-1) downto 0);
	
	subtype BUFFERED_DATA_T			is std_logic_vector((lvds_width-1) downto 0);
	subtype D_SEL_T					is std_logic_vector((NumBits(d_stages)-1) downto 0);
	type	BUFFERED_DATA_A			is array ((d_stages-1) downto 0) of BUFFERED_DATA_T;
		
--*******************************************************************************************************************************
	
end package lvds_pkg;

--

package body lvds_pkg is
end package body lvds_pkg;
