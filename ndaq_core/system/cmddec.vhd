-- Command Decoder
-- v: 0.2
-- 
-- 0.1	Changed 'idata' to 'std_logic_vector'.
--
-- 0.2	Added 'rcontrol' register.
--
-- 0.3	Added 'adcpwdn' register.
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity cmddec is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		signal rstc				: in 	std_logic; -- async if

		signal rd				: out	std_logic;
		signal davail 			: in	std_logic;
		signal idata        	: in	std_logic_vector(7 downto 0);

		signal reset			: out	std_logic_vector(7 downto 0);
		signal adcpwdn			: out 	std_logic_vector(3 downto 0) := x"F";
		signal resetc			: out	std_logic_vector(7 downto 0);
		signal control			: out	std_logic_vector(7 downto 0);
		signal rcontrol			: out	std_logic_vector(7 downto 0);
		
		signal bcount			: out	std_logic_vector(15 downto 0);
		signal c8wmax			: out	std_logic_vector(9 downto 0)
	);
end cmddec;

--

architecture rtl of cmddec is
	
------------------------------
-- Registers State Machine	--
------------------------------
	type regs_type is (regs_idle, regs_addr_a, regs_addr_l, regs_wait, regs_data_a, regs_data_l);
	
	signal regs_state 	: regs_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of regs_type : type is "safe";	
		
---------------
-- Registers --
---------------
	signal AddrReg	: std_logic_vector(7 downto 0) := x"FF";
	signal bcountL	: std_logic_vector(7 downto 0);
	signal bcountH	: std_logic_vector(7 downto 0);
	
	signal c8wmaxL	: std_logic_vector(7 downto 0);
	signal c8wmaxH	: std_logic_vector(1 downto 0);
--
	signal davail_r	: std_logic;
	
--

begin
	
	-- 'BCOUNT' 16 bits register
	bcount(7 downto 0)	<= bcountL;
	bcount(15 downto 8)	<= bcountH;
	
	-- 'C8WMAX' 10 bits register
	c8wmax(7 downto 0)	<= c8wmaxL;
	c8wmax(9 downto 8)	<= c8wmaxH;
	

--	process (clk) 
--	begin
--		if (rising_edge(clk)) then
			davail_r <= davail;
--		end if;
--	end process;
	
	registers_machine:
	process (rst, rstc, clk) begin
		if (rst = '1') then
			--AddrReg		<= x"FF";

			-- Register's Reset Values
			reset		<= x"00";
			adcpwdn		<= x"F";		--x"F"	All ADCs powered down.
			resetc		<= x"00";
			control		<= x"00";		--x"02"	Resets enabled for SIMULATION.
			rcontrol	<= x"00";		--x"FF"	Will enable all readout channels.
			--
			bcountL		<= x"00";		-- 63488 is the maximum data block allowed by the USB engine.				
			bcountH		<= x"F8";		-- 63488 is the maximum data block allowed by the USB engine.				
			--
			c8wmaxL		<= x"7E";
			c8wmaxH		<= "11";
			--
			regs_state	<= regs_idle;
			
		------------------------------
		elsif (rstc = '1') then
			resetc		<= x"00";
		------------------------------
		
		elsif (rising_edge(clk)) then
			case regs_state is
				
				when regs_idle =>	
					rd			<= '1'; --'Z';
					AddrReg		<= x"FF";
					--
					if (davail_r = '1') then	-- Data is avaiable at USB Transceiver (FTDI)
						regs_state	<= regs_addr_a;
					else
						regs_state	<= regs_idle;
					end if;
					
				when regs_addr_a =>
					rd			<= '0';		
					--
					if (davail_r = '0') then	-- IF '0', there is data avaible on LOCAL bus, go get it!
						regs_state	<= regs_addr_l;
					else
						regs_state	<= regs_addr_a;
					end if;

				when regs_addr_l =>
					-- getting data...
					AddrReg		<= idata;
					--
					rd			<= '0';	-- ***TROCAR PRA ZERO, mais confiavel ?***
					--
					regs_state	<= regs_wait;

				when regs_wait =>
					rd			<= '1'; --'Z';
					--
					if (davail_r = '1') then	-- Data is avaiable at RX IF
						regs_state	<= regs_data_a;
					else
						regs_state	<= regs_wait;
					end if;
						
				when regs_data_a =>
					rd			<= '0';		
					--
					if (davail_r = '0') then	-- IF '0', there is data avaible on LOCAL bus, go get it!
						regs_state	<= regs_data_l;
					else
						regs_state	<= regs_data_a;
					end if;

				when regs_data_l =>
					rd			<= '0';
					--AddrReg		<= AddrReg;
					
					case AddrReg is
						when x"AA"	=> reset	 	<= idata;				-- Master Reset			at 0xAA
						when x"AB"	=> resetc	 	<= idata;				-- Reset 63488b Counter	at 0xAB
						when x"80"	=> adcpwdn		<= idata(3 downto 0);	-- ADC Power Down Bits	at 0x80
						when x"81"	=> control		<= idata;				-- Main Arbiter Control	at 0x81
						when x"82"	=> rcontrol		<= idata;				-- Readout Control		at 0x82
						--
						when x"90"	=> bcountL		<= idata;				-- MTRIF TX 'BCOUNT' L	at 0x90
						when x"91"	=> bcountH		<= idata;				-- MTRIF TX 'BCOUNT' H	at 0x91
						--
						when x"B0"	=> c8wmaxL		<= idata;				-- WRITEFIFO  'WMAX''L	at 0xB0
						when x"B1"	=> c8wmaxH		<= idata(1 downto 0);	-- WRITEFIFO  'WMAX''H	at 0xB1
						--
						when others	=> AddrReg		<= AddrReg;				-- Something went wrong!
					end case;

					--
					regs_state	<= regs_idle;
		
				when others =>			
					--AddrReg		<= AddrReg;
					--
					regs_state	<= regs_idle;
			
			end case;
		end if;
	end process;
	
--	-- Register FSM -NON BUFFERED- Outputs
--	process (regs_state)
--	begin
--		case regs_state is
--			when regs_idle =>
--				rd <= '0';
--								
--			when regs_addr_a =>
--				rd <= '1';			
--				
--			when regs_addr_d =>
--				rd <= '0';
--
--			when regs_data_a =>
--				rd <= '1';
--						
--		end case;
--	end process;

end rtl;