-- $ Data Builder - NDAQ's Data Builder
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

use work.functions_pkg.all;
use work.databuilder_pkg.all;

--
entity databuilder is
port(	
		--
		rst							: in	std_logic;
		clk							: in	std_logic;		 
		
		--
		enable						: in	std_logic;
		
		--
		enable_A					: in	SLOTS_T;
		enable_B					: in	SLOTS_T;
		enable_C					: in	SLOTS_T;
		transfer					: in	TRANSFER_A;
		address						: in	ADDRESS_A;
		mode						: in	MODE_A;
		
		--
		rd							: out	SLOTS_T;
		idata						: in	IDATA_A;
		ctval						: in	IDATA_A;
		
		--
		wr							: out	ADDRESS_T;
		odata						: out	ODATA_T
	);
end databuilder;

--

architecture rtl of databuilder is

	-- Slot Counter
	signal	s_counter_en			: std_logic := '0';
	signal	s_counter_cl			: std_logic := '0';
	signal	s_counter				: SLOTS_REG_T;
	
	-- Idata Bus
	signal idata_bus				: IDATA_T;
	-- Ctval Bus
	signal ctval_bus				: IDATA_T;
	-- Enable A 
	signal en_a						: std_logic := '0';
	-- Enable B 
	signal en_b						: std_logic := '0';
	-- Enable B 
	signal en_c						: std_logic := '0';
	-- Transfer Size 
	signal t_size					: TRANSFER_REG_T;
	-- Address Bus
	signal addr_bus					: ADDRESS_REG_T;
	-- Mode Selector 
	signal mode_sel					: MODE_T;
	
	-- Read Strobe
	signal rds						: std_logic := '0';
	-- Write Strobe
	signal wrs						: std_logic := '0';
	-- Read Strobe Array
	signal rda						: SLOTS_T;
	-- Write Strobe Array
	signal wra						: ADDRESS_T;

	-- Transfer FSM
	type		state_values is (idle, active_rden, ctval_rden, block_transfer, ctval_bt, last_wren, ctval_wren, inc_slot);
	signal		stateval, next_stateval			: state_values;
	attribute	syn_encoding 					: string;
	attribute	syn_encoding of state_values	: type is "safe, one-hot";

	-- Transfer Counter
	signal	t_counter_en			: std_logic := '0';
	signal	t_counter_cl			: std_logic := '0';
	signal	t_counter				: TRANSFER_REG_T;
	
	-- Constant Value Enable Register
	signal ctval_en					: std_logic := '0';
	signal kctval_en				: std_logic := '0';

--

begin

--
-- Slot Counter
--

-- 
slot_counter:
process(clk, rst)
begin
	if (rst = '1') then
		s_counter	<= (others => '0');
	elsif rising_edge(clk) then
		if (s_counter_cl = '1') then
			s_counter	<= (others => '0');
		elsif (s_counter_en = '1') then
			s_counter	<= s_counter + 1;
		end if;
	end if;
end process;

--
-- Input Muxes
--

-- Idata Mux
idata_mux: idata_bus	<=	idata(conv_integer(s_counter));

-- Enable A Mux
enable_a_mux: en_a		<= enable_A(conv_integer(s_counter));

-- Enable B Mux
enable_b_mux: en_b		<= enable_B(conv_integer(s_counter));

-- Enable B Mux
enable_c_mux: en_c		<= enable_C(conv_integer(s_counter));

-- Transfer Size Mux
transfer_mux: t_size	<= transfer(conv_integer(s_counter));

-- Address Mux
address_mux: addr_bus	<= address(conv_integer(s_counter));

-- Mode Mux
mode_mux: mode_sel		<=	mode(conv_integer(s_counter));

-- Ctval Mux
ctval_mux: ctval_bus	<=	ctval(conv_integer(s_counter));


--
-- Transfer FSM
--

--
-- Asynchronous assignments of 'next_stateval'
next_state_comb:
process(stateval, enable, en_a, en_b, en_c, mode_sel, t_counter, t_size)
begin
	case stateval is			
		when idle =>			
			if (enable = '1') then
				-- If the slot is disabled, increment the slot counter and start again.
				if (en_a = '0') then
					next_stateval <= inc_slot;
				-- If enable_A and enable_B and enable_C are asserted, start transfer.
				elsif ((en_a = '1') and (en_b = '1') and (en_c = '1')) then
					next_stateval <= active_rden;
				-- Else if enable_A and enable_C are asserted, do what mode says...
				elsif ((en_a = '1') and (en_c = '1')) then
					if (mode_sel = "00") then		-- Non Branch mode.
						next_stateval <= idle;
					elsif (mode_sel = "01") then	-- Branch mode.
						next_stateval <= inc_slot;
					elsif (mode_sel = "10") then	-- Constant Value mode.
						next_stateval <= ctval_rden;
					else
						next_stateval <= idle;
					end if;
				else
					next_stateval <= idle;
				end if;
			else
				next_stateval <= idle;
			end if;

		when active_rden =>
			if(t_size < 1) then
			  report "Transfer Size MUST be greater than ZERO!" severity error;
			end if;			
			if (t_size = 1) then
				next_stateval <= last_wren;
			else
				next_stateval <= block_transfer;
			end if;

		when ctval_rden =>
			if(t_size < 1) then
			  report "Transfer Size MUST be greater than ZERO!" severity error;
			end if;			
			if (t_size = 1) then
				next_stateval <= ctval_wren;
			else
				next_stateval <= ctval_bt;
			end if;

		when block_transfer =>
			-- If transfer counter has reached transfer size, finish transferring.
			if (t_counter = t_size) then
				next_stateval <= last_wren;
			-- Else, keep transferring.
			else
				next_stateval <= block_transfer;
			end if;

		when ctval_bt =>
			-- If transfer counter has reached transfer size, finish transferring.
			if (t_counter = t_size) then
				next_stateval <= ctval_wren;
			-- Else, keep transferring.
			else
				next_stateval <= ctval_bt;
			end if;

		when last_wren =>						
			next_stateval <= idle;
				
		when ctval_wren =>						
			next_stateval <= idle;

		when inc_slot =>						
			next_stateval <= idle;

		when others =>
			next_stateval <= idle;
			
	end case;
end process;

--
-- Synchronous assignments of FSM outputs
reg_output_decoder: 
process(clk, rst, next_stateval, s_counter)
begin
	if (rst = '1') then
		--
		s_counter_en	<= '0';
		s_counter_cl	<= '0';
		t_counter_en	<= '0';
		t_counter_cl	<= '0';
		--
		wrs				<= '0';		-- Write must be delayed by one clock cycle, as data is registered too.
		--
		ctval_en		<= '0';

	elsif (rising_edge(clk)) then
		case (next_stateval) is
			when idle =>
				--
				s_counter_en	<= '0';
				s_counter_cl	<= '0';
				t_counter_en	<= '0';
				t_counter_cl	<= '0';
				--
				wrs				<= '0';
				--
				ctval_en		<= '0';

			when active_rden =>
				--
				s_counter_en	<= '0';
				s_counter_cl	<= '0';
				t_counter_en	<= '1';
				t_counter_cl	<= '0';
				--
				wrs				<= '0';

			when ctval_rden =>
				--
				s_counter_en	<= '0';
				s_counter_cl	<= '0';
				t_counter_en	<= '1';
				t_counter_cl	<= '0';
				--
				wrs				<= '0';
				--
				ctval_en		<= '1';

			when block_transfer =>
				--
				s_counter_en	<= '0';
				s_counter_cl	<= '0';
				t_counter_en	<= '1';
				t_counter_cl	<= '0';
				--
				wrs				<= '1';

			when ctval_bt =>
				--
				s_counter_en	<= '0';
				s_counter_cl	<= '0';
				t_counter_en	<= '1';
				t_counter_cl	<= '0';
				--
				wrs				<= '1';
				--
				ctval_en		<= '1';

			when last_wren =>
				-- Slot Counter Clear Logic
				if (s_counter = CONV_STD_LOGIC_VECTOR((slots-1), NumBits(slots))) then
					s_counter_cl	<= '1';
				else
					s_counter_cl	<= '0';
				end if;
				--
				s_counter_en	<= '1';
				t_counter_en	<= '0';
				t_counter_cl	<= '1';
				--
				wrs				<= '1';
			
			when ctval_wren =>
				-- Slot Counter Clear Logic
				if (s_counter = CONV_STD_LOGIC_VECTOR((slots-1), NumBits(slots))) then
					s_counter_cl	<= '1';
				else
					s_counter_cl	<= '0';
				end if;
				--
				s_counter_en	<= '1';
				t_counter_en	<= '0';
				t_counter_cl	<= '1';
				--
				wrs				<= '1';
				--
				ctval_en		<= '1';

			when inc_slot =>
				-- Slot Counter Clear Logic
				if (s_counter = CONV_STD_LOGIC_VECTOR((slots-1), NumBits(slots))) then
					s_counter_cl	<= '1';
				else
					s_counter_cl	<= '0';
				end if;
				--
				s_counter_en	<= '1';
				t_counter_en	<= '0';
				t_counter_cl	<= '0';
				--
				wrs				<= '0';

			when others	=>
				--
				s_counter_en	<= '0';
				s_counter_cl	<= '0';
				t_counter_en	<= '0';
				t_counter_cl	<= '0';
				--
				wrs				<= '0';
				--
				ctval_en		<= '0';

		end case;
	end if;
end process;

--
-- Asynchronous assignments of FSM outputs
comb_output_decoder: 
process(next_stateval)
begin
	case (next_stateval) is
		when idle =>
			--
			rds				<= '0';

		when active_rden =>
			--
			rds				<= '1';

		-- when ctval_rden =>
			-- --
			-- rds				<= '1';	-- read strobe is not enabled during constant value mode.

		when block_transfer =>
			--
			rds				<= '1';

		-- when ctval_bt =>
			-- --
			-- rds				<= '1';	-- read strobe is not enabled during constant value mode.

		when last_wren =>
			--
			rds				<= '0';

		-- when ctval_wren =>
			-- --
			-- rds				<= '0';

		when inc_slot =>
			--
			rds				<= '0';

		when others	=>
			--
			rds				<= '0';

		end case;
end process;

--
-- FSM states register
fsm_ff:
process(clk,rst)
begin
if (rst = '1') then
	stateval <= idle;
elsif (rising_edge(clk)) then
	stateval <= next_stateval;
end if;
end process;

--
-- Transfer Counter
transfer_counter:
process(clk, rst)
begin
	if (rst = '1') then
		t_counter	<= (others => '0');
	elsif (rising_edge(clk)) then
		if (t_counter_cl = '1') then
			t_counter	<= (others => '0');
		elsif (t_counter_en = '1') then
			t_counter	<= t_counter + 1;
		end if;
	end if;
end process;

--
-- Output Demuxes
--

-- Rd Demux
rd_demux:
process(s_counter, rds)
begin
	rda <= (others => '0');
	if (rds = '1') then
		rda(conv_integer(s_counter))	<= '1';
	end if;
end process;

-- Wr Demux
wr_demux: 
process(addr_bus, wrs)
begin
	wra <= (others => '0');
	if (wrs = '1') then
		wra(conv_integer(addr_bus))		<= '1';
	end if;
end process;

--
-- Output Registers
--

--
--
process(clk, rst)
begin
	if (rst = '1') then
		rd		<= (others => '0');
		wr		<= (others => '0');
		odata	<= (others => '0');
	elsif (rising_edge(clk)) then
		rd		<= rda;
		wr		<= wra;
		
		if (ctval_en = '1')  then
			odata <= ctval_bus;
		else
			odata <= idata_bus;
		end if;
		
	end if;
end process;

--

end rtl;
