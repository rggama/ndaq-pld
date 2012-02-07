-- $ Data Builder Package
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
--use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).

use ieee.math_real.log2;
use ieee.math_real.ceil;

--

package functions_pkg is
	
	--
	--Functions
	--
	
	--
	function NumBits(val : integer) return integer;
	
--*******************************************************************************************************************************
	
end package functions_pkg;

--

package body functions_pkg is

-- Calculate the number of bits required to represent a given value
function NumBits(val : integer) return integer is
    variable result : integer;
begin
    if val=0 then
        result := 0;
    else
        result  := natural(ceil(log2(real(val))));
    end if;
    return result;
end;

end package body functions_pkg;
