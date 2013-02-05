---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Design: C:\Projects\VmeInterface\vmeif_usr.vhd
-- Author: Ralf Spiwoks,   original version
-- Company: CERN
-- Description: VME Interface of the ATLAS Level-1 Central Trigger Processor
--              package file for user definitions
-- Notes:
--
-- History:
-- 21 JAN 2004: Created seperate package file.
---------------------------------------------------------------------------------------------------
  library IEEE;
  use IEEE.Std_logic_1164.all;
  use IEEE.Numeric_std.all;
  use work.vmeif_pkg.all;

  package vmeif_usr is
--
-- user configuration ROM
--
    constant usr_cr_data	: MEM_32_BYTE :=
									((x"00"),		-- check sum
									 (x"FF"),		-- length of rom
									 (x"03"),		-- length or rom
									 (x"00"),		-- length of rom
									 (x"81"),		-- CR data width
									 (x"81"),		-- CSR data width
									 (x"02"),		-- CR/CSR specification identifier
									 (x"43"),		-- ASCII "C"
									 (x"52"),		-- ASCII "R"
									 (x"08"),		-- manufacturer identifier
									 (x"00"),		-- manufacturer identifier
									 (x"30"),		-- manufacturer identifier
									 (x"00"),		-- board identifier
									 (x"00"),		-- board identifier
									 (x"01"),		-- board identifier
									 (x"4D"),		-- board identifier
									 (x"00"),		-- revision identifier
									 (x"00"),		-- revision identifier
									 (x"00"),		-- revision identifier
									 (x"03"),		-- revision identifier
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00"),		-- unused
									 (x"00")		-- unused
									);
--
-- user address decoder mask
--								
		constant usr_adem				: MEM_4_BYTE := ((x"FF"),(x"F0"),(x"00"),(x"00"));
--
-- user address map
--	
    constant usr_addr_map			: USR_MAP_VECTOR	:=


--
--    base            = base address of mapping;
--    mask            = mask of mapping, 0 => mapping not used
--    AM_SGL, AM_BLT  = two address modifiers to be decoded
--    DTACK           = 0..15 => generate DTACK #BCs after user_read/write, -1 => wait for user_dtack
--    external        = true  => mapping used with user bus, false => used in same device (user_data_in/out)
--							 = TRADUCAO: tem que ser 'true' para que um dispositivo externo possa usar o barramento de dados
--												VME diretamente, sem os dados passarem por dentro desta FPGA.
-- LF: Shift all address one number to the right (00300 -> 00030) to test inside the NuDAQ


--    base address, window size (mask), AM_SGL,AM_BLT,DTACK (positive number means number of BCs to generate DTACK)

		((x"00010000", x"000F0000", x"09", x"0B", 0, true),  -- 00 - FIFO 1 -> LF change 11/2012 // USED TO u_read(0) or u_write(0)
		 (x"00020000", x"000F0000", x"09", x"0B", 0, true),  -- 01 - FIFO 2 -> LF change 11/2012 // USED TO u_read(1) or u_write(1)
		 (x"00030000", x"000F0000", x"09", x"0B", 0, true),  -- 02 - FIFO 3 -> LF change 11/2012 // USED TO u_read(2) or u_write(2)
		 (x"00040000", x"000F0000", x"09", x"0B", 0, true),  -- 03 - FIFO 4 -> LF change 11/2012 // USED TO u_read(3) or u_write(3)
			
		 (x"00050000", x"000F0000", x"09", x"0B", 0, false), -- 04 - FIFO Flags	  		// USED TO u_read(4) or u_write(4)

		 (x"00060000", x"000F0000", x"09", x"0B", 0, false), -- 05 - SPI Data	  		// USED TO u_read(5) or u_write(5)
		 (x"00070000", x"000F0000", x"09", x"0B", 0, false), -- 06 - SPI Status	  		// USED TO u_read(6) or u_write(6)

		 (x"00080000", x"000F0000", x"09", x"0B", 0, false), -- 07 - R/W Test	  		// USED TO u_read(7) or u_write(7)

		 (x"00090000", x"000F0000", x"09", x"0B", 0, false), -- 08 - Firmware Version	// USED TO u_read(8) or u_write(8)

		 (x"000A0000", x"000F0000", x"09", x"0B", 0, false), -- 09 - Reset Register		// USED TO u_read(9) or u_write(9)

		 (x"000B0000", x"000F0000", x"09", x"0B", 0, false), -- 10 - Reset Register		// USED TO u_read(10) or u_write(10)
																			
		 (x"00000000", x"00000000", x"09", x"0B", -1, true),  -- NOT USED 
		 (x"00000000", x"00000000", x"09", x"0B", -1, true),  -- NOT USED 
		 (x"00000000", x"00000000", x"09", x"0B", -1, true),  -- NOT USED 
		 (x"00000000", x"00000000", x"09", x"0B", -1, true),  -- NOT USED 
		 (x"00000000", x"00000000", x"09", x"0B", -1, true)	  -- mask to zeros mean not implememented.
		);
	

--
-- user clock selection
--
	constant usr_clock				: USR_CLOCK_OPTION	:= external;
--
-- user address latch enable: internal or external
--
	constant usr_addrle				: USR_ADDRLE_OPTION	:= internal;
	
--
-- user data acknowledge: floating or rescinding
--

	constant usr_dtack				: USR_DTACK_OPTION	:= rescinding;

--
-- user busses: external (tri-state) or internal (bi_state)
--	
	--constant usr_bus				  : USR_BUS_OPTION	:= external;	-- COMENTADO POR HERMAN 29/07/10
	
	constant usr_bus				  : USR_BUS_OPTION	:= internal;		-- INSERIDO POR HERMAN 29/07/10

-- user address REGISTERS, added by Herman in 08/09/10
-- the lowest 4 bits below are mapped in the VME address lines 19..16
-- and the address values MUST BE always even numbers
    constant usr_reg_addr	: MEM_32_BYTE :=
									((x"01"),		-- USED register
									 (x"02"),		-- USED register
									 (x"03"),		-- USED register
									 (x"04"),		-- USED register
									 (x"05"),		-- USED register
									 (x"06"),		-- USED register
									 (x"07"),		-- USED register
									 (x"08"),		-- USED register
									 (x"09"),		-- USED register
									 (x"0A"),		-- USED register
									 (x"0B"),		-- unused
									 (x"0C"),		-- unused
									 (x"0D"),		-- unused
									 (x"0E"),		-- unused
									 (x"0F"),		-- unused
									 (x"10"),		-- unused
									 (x"11"),		-- unused
									 (x"12"),		-- unused
									 (x"13"),		-- unused
									 (x"14"),		-- unused
									 (x"15"),		-- unused
									 (x"16"),		-- unused
									 (x"17"),		-- unused
									 (x"18"),		-- unused
									 (x"19"),		-- unused
									 (x"1A"),		-- unused
									 (x"1B"),		-- unused
									 (x"1C"),		-- unused
									 (x"1D"),		-- unused
									 (x"1E"),		-- unused
									 (x"1F"),		-- unused
									 (x"20")		-- unused
									);

	
  end package vmeif_usr;

  package body vmeif_usr is
  end package body vmeif_usr;
