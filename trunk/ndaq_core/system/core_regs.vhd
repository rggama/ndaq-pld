--
--

library ieee;
use ieee.std_logic_1164.all;


package core_regs is

	-- total system registers
	constant num_regs			: integer := 71;

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
		-- Reset
		(x"AA",	true,	true,	false,	x"00"),	-- 00 - Reset.
		
		-- ACQ
		(x"80",	true,	true,	false,	x"00"),	-- 01 - ACQ Enables. 
		(x"81",	true,	true,	false,	x"1D"),	-- 02 - ADC Event Size Per Trigger.
		(x"87",	true,	true,	false,	x"00"),	-- 03 - ADC Power (Powered down by default).
		(x"89",	true,	true,	false,	x"00"),	-- 04 - ACQ Reset (Also Internal/External FIFOs Reset).

		-- Trigger
		(x"70",	true,	true,	false,	x"00"),	-- 05 - Internal Trigger Output Selector.
		(x"71",	true,	true,	false,	x"00"),	-- 06 - Trigger Configuration: Internal/External.
		(x"77",	true,	true,	false,	x"00"),	-- 07 - Internal Trigger Th 1L.
		(x"78",	true,	true,	false,	x"00"),	-- 08 - Internal Trigger Th 1H.
		(x"79",	true,	true,	false,	x"9C"),	-- 09 - Internal Trigger Th 2L.
		(x"7A",	true,	true,	false,	x"03"),	-- 10 - Internal Trigger Th 2H.
		(x"7B",	true,	true,	false,	x"00"),	-- 11 - Internal Trigger Trigger Slope: Falling/Rising.

		-- TDC
		(x"C0",	true,	true,	false,	x"00"),	-- 12 - TDC Register 0 - A.
		(x"C1",	true,	true,	false,	x"00"),	-- 13 - TDC Register 0 - B.
		(x"C2",	true,	true,	false,	x"00"),	-- 14 - TDC Register 0 - C.
		(x"C3",	true,	true,	false,	x"00"),	-- 15 - TDC Register 0 - D.

		(x"C4",	true,	true,	false,	x"00"),	-- 16 - TDC Register 1 - A.
		(x"C5",	true,	true,	false,	x"00"),	-- 17 - TDC Register 1 - B.
		(x"C6",	true,	true,	false,	x"00"),	-- 18 - TDC Register 1 - C.
		(x"C7",	true,	true,	false,	x"00"),	-- 19 - TDC Register 1 - D.

		(x"C8",	true,	true,	false,	x"00"),	-- 20 - TDC Register 2 - A.
		(x"C9",	true,	true,	false,	x"00"),	-- 21 - TDC Register 2 - B.
		(x"CA",	true,	true,	false,	x"00"),	-- 22 - TDC Register 2 - C.
		(x"CB",	true,	true,	false,	x"00"),	-- 23 - TDC Register 2 - D.

		(x"CC",	true,	true,	false,	x"00"),	-- 24 - TDC Register 3 - A.
		(x"CD",	true,	true,	false,	x"00"),	-- 25 - TDC Register 3 - B.
		(x"CE",	true,	true,	false,	x"00"),	-- 26 - TDC Register 3 - C.
		(x"CF",	true,	true,	false,	x"00"),	-- 27 - TDC Register 3 - D.

		(x"D0",	true,	true,	false,	x"00"),	-- 28 - TDC Register 4 - A.
		(x"D1",	true,	true,	false,	x"00"),	-- 29 - TDC Register 4 - B.
		(x"D2",	true,	true,	false,	x"00"),	-- 30 - TDC Register 4 - C.
		(x"D3",	true,	true,	false,	x"00"),	-- 31 - TDC Register 4 - D.

		(x"D4",	true,	true,	false,	x"00"),	-- 32 - TDC Register 5 - A.
		(x"D5",	true,	true,	false,	x"00"),	-- 33 - TDC Register 5 - B.
		(x"D6",	true,	true,	false,	x"00"),	-- 34 - TDC Register 5 - C.
		(x"D7",	true,	true,	false,	x"00"),	-- 35 - TDC Register 5 - D.

		(x"D8",	true,	true,	false,	x"00"),	-- 36 - TDC Register 6 - A.
		(x"D9",	true,	true,	false,	x"00"),	-- 37 - TDC Register 6 - B.
		(x"DA",	true,	true,	false,	x"00"),	-- 38 - TDC Register 6 - C.
		(x"DB",	true,	true,	false,	x"00"),	-- 39 - TDC Register 6 - D.

		(x"DC",	true,	true,	false,	x"00"),	-- 40 - TDC Register 7 - A.
		(x"DD",	true,	true,	false,	x"00"),	-- 41 - TDC Register 7 - B.
		(x"DE",	true,	true,	false,	x"00"),	-- 42 - TDC Register 7 - C.
		(x"DF",	true,	true,	false,	x"00"),	-- 43 - TDC Register 7 - D.

		(x"E0",	true,	true,	false,	x"00"),	-- 44 - TDC Register 11 - A.
		(x"E1",	true,	true,	false,	x"00"),	-- 45 - TDC Register 11 - B.
		(x"E2",	true,	true,	false,	x"00"),	-- 46 - TDC Register 11 - C.
		(x"E3",	true,	true,	false,	x"00"),	-- 47 - TDC Register 11 - D.

		(x"E4",	true,	true,	false,	x"00"),	-- 48 - TDC Register 12 - A.
		(x"E5",	true,	true,	false,	x"00"),	-- 49 - TDC Register 12 - B.
		(x"E6",	true,	true,	false,	x"00"),	-- 50 - TDC Register 12 - C.
		(x"E7",	true,	true,	false,	x"00"),	-- 51 - TDC Register 12 - D.

		(x"E8",	true,	true,	false,	x"00"),	-- 52 - TDC Register 14 - A.
		(x"E9",	true,	true,	false,	x"00"),	-- 53 - TDC Register 14 - B.
		(x"EA",	true,	true,	false,	x"00"),	-- 54 - TDC Register 14 - C.
		(x"EB",	true,	true,	false,	x"00"),	-- 55 - TDC Register 14 - D.

		(x"EC",	true,	true,	false,	x"00"),	-- 56 - TDC Master Reset - A.
		(x"ED",	true,	true,	false,	x"00"),	-- 57 - TDC Master Reset - B.
		(x"EE",	true,	true,	false,	x"00"),	-- 58 - TDC Master Reset - C.
		(x"EF",	true,	true,	false,	x"00"),	-- 59 - TDC Master Reset - D.

		(x"F0",	true,	true,	false,	x"00"),	-- 60 - TDC Configuration Latch.
		(x"F1",	true,	true,	true,	x"00"),	-- 61 - TDC Configuration Latch Status.
		(x"F2",	true,	true,	false,	x"00"),	-- 62 - TDC STOPs disable and Start Disable.
		(x"F3",	true,	true,	false,	x"00"),	-- 63 - TDC Reset.

		-- Databuilder
		(x"40",	true,	true,	false,	x"00"),	-- 64 - DataBuilder's enable.
		(x"41",	true,	true,	false,	x"00"),	-- 65 - DataBuilder's FIFO 1 Block Configuration.
		(x"42",	true,	true,	false,	x"00"),	-- 66 - DataBuilder's FIFO 2 Block Configuration.
		(x"43",	true,	true,	false,	x"00"),	-- 67 - DataBuilder's FIFO 3 Block Configuration.
		(x"44",	true,	true,	false,	x"00"),	-- 68 - DataBuilder's FIFO 4 Block Configuration.

		--
		(x"27",	true,	true,	false,	x"00"),	-- 69 - R/W Test Register.
		(x"28",	true,	true,	false,	x"48")	-- 70 - Firmware Version.
	);

-------------------------------------------------------------------------------

	type	SYS_REGS			is array (0 to (num_regs-1)) of std_logic_vector(7 downto 0);
	
end package core_regs;

package body core_regs is
end package body core_regs;
