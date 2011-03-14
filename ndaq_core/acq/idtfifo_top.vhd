----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- Author: Herman Lima Jr
-- Company: CBPF
-- Description: Top-level control of write operations in the external IDT FIFOs.
-- Notes:
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
--
entity idtfifo_top is
port(	-- CONTROL/STATUS signals
		rst						    : in std_logic;
		clk						    : in std_logic;		 -- Receives the inverted output (nclk) from 'core_clkman' component
		start_transfer				 : in std_logic;		 -- Control signal to start the readout (command register)
		enable_adc				 	 : in std_logic_vector(1 to 4); -- Indicates if the ADC is enabled ('1') 
		transfer_running			 : out std_logic;		 -- Indicates transfer from FPGA to FIFOs is running ('1')
		transfer_counter			 : out std_logic_vector(7 downto 0);
		idt_full					 	 : in std_logic_vector(1 to 4);
		idt_wren					 	 : buffer std_logic_vector(1 to 4);
		idt_data						 : out std_logic_vector(31 downto 0);
		fifo_empty					 : in std_logic_vector(1 to 8);
		fifo_used_A					 : in std_logic_vector(9 downto 0);
		fifo_used_B					 : in std_logic_vector(9 downto 0);
		fifo_used_C					 : in std_logic_vector(9 downto 0);
		fifo_used_D					 : in std_logic_vector(9 downto 0);
		fifo_used_E					 : in std_logic_vector(9 downto 0);
		fifo_used_F					 : in std_logic_vector(9 downto 0);
		fifo_used_G					 : in std_logic_vector(9 downto 0);
		fifo_used_H					 : in std_logic_vector(9 downto 0);
		fifo_rden					 : out std_logic_vector(1 to 8);
		fifo_qA						 : in std_logic_vector(9 downto 0);
		fifo_qB						 : in std_logic_vector(9 downto 0);
		fifo_qC						 : in std_logic_vector(9 downto 0);
		fifo_qD						 : in std_logic_vector(9 downto 0);
		fifo_qE						 : in std_logic_vector(9 downto 0);
		fifo_qF						 : in std_logic_vector(9 downto 0);
		fifo_qG						 : in std_logic_vector(9 downto 0);
		fifo_qH						 : in std_logic_vector(9 downto 0);
		-- TEST signals
		state_out_A					 : out std_logic_vector(3 downto 0);	-- Only for TESTS
		state_out_B					 : out std_logic_vector(3 downto 0);	-- Only for TESTS
		state_out_top			     : out std_logic_vector(7 downto 0));	-- Only for TESTS
end idtfifo_top;
--
architecture one_idtfifo_top of idtfifo_top is
--
	type state_values is (idle, test_ch1_start, test_ch1_flag, test_ch1_running,
								test_ch2_start, test_ch2_flag, test_ch2_running,
								test_ch3_start, test_ch3_flag, test_ch3_running,
								test_ch4_start, test_ch4_flag, test_ch4_running,
								test_ch5_start, test_ch5_flag, test_ch5_running,
								test_ch6_start, test_ch6_flag, test_ch6_running,
								test_ch7_start, test_ch7_flag, test_ch7_running,
								test_ch8_start, test_ch8_flag, test_ch8_running);
	signal stateval,next_stateval				: state_values;
	
	signal i_start_transfer, start_transfer_reg : std_logic_vector(1 to 8);
	signal i_state_out_top						: std_logic_vector(7 downto 0);	-- Only for TESTS
	signal noflagin					 			: std_logic_vector(1 to 8);
	signal i_transfer_running			 		: std_logic;					-- Indicates transfer from FPGA to FIFO is running ('1')
--	
	-- IDT FIFO control
	component idtfifo_ctr
	port
	(	
		rst						     : in std_logic;
		clk						     : in std_logic;
		start_transfer				 : in std_logic;
		noflag						 : out std_logic;
		idt_full					 : in std_logic;
		idt_wren					 : out std_logic;
		fifo_empty					 : in std_logic;
		fifo_used				 	 : in std_logic_vector(9 downto 0);
		rden_A						 : out std_logic;						-- READ enable
		rden_B						 : out std_logic;						-- READ enable
		transfer_counter			 : out std_logic_vector(7 downto 0);
		state_out				     : out std_logic_vector(3 downto 0)
	);
	end component;
--
begin
--
-- Asynchronous assignments of 'next_stateval'
NEXT_STATE_COMB: process(stateval, start_transfer, enable_adc, noflagin, idt_wren)
begin
	case stateval is
		when idle =>							-- IDLE state
			if start_transfer = '0' then
				next_stateval <= idle;
			else
				next_stateval <= test_ch1_start;
			end if;
		-----------------
		-- Channel 1-2 --
		-----------------		
		when test_ch1_start =>					
			if enable_adc(1) = '1' then
				next_stateval <= test_ch1_flag;
			else
				next_stateval <= test_ch3_start;	-- Channel not enabled
			end if;
		when test_ch1_flag =>
			if noflagin(1) = '1' then
				next_stateval <= test_ch3_start;	-- Channel not allowed by flag
			elsif idt_wren(1) = '0' then
				next_stateval <= test_ch1_running;
			else
				next_stateval <= test_ch1_flag;
			end if;
		when test_ch1_running =>
			if idt_wren(1) = '1' then
				next_stateval <= test_ch3_start;	-- End of channel transfer
			else
				next_stateval <= test_ch1_running;
			end if;

		-----------------
		-- Channel 3-4 --
		-----------------
		when test_ch3_start =>
			if enable_adc(2) = '1' then
				next_stateval <= test_ch3_flag;
			else
				next_stateval <= test_ch5_start;	-- Channel not enabled
			end if;
		when test_ch3_flag =>
			if noflagin(3) = '1' then
				next_stateval <= test_ch5_start;	-- Channel not allowed by flag
			elsif idt_wren(2) = '0' then
				next_stateval <= test_ch3_running;
			else
				next_stateval <= test_ch3_flag;
			end if;
		when test_ch3_running =>
			if idt_wren(2) = '1' then
				next_stateval <= test_ch5_start;	-- End of channel transfer
			else
				next_stateval <= test_ch3_running;
			end if;

		-----------------
		-- Channel 5-6 --
		-----------------
		when test_ch5_start =>
			if enable_adc(3) = '1' then
				next_stateval <= test_ch5_flag;
			else
				next_stateval <= test_ch7_start;	-- Channel not enabled
			end if;
		when test_ch5_flag =>
			if noflagin(5) = '1' then
				next_stateval <= test_ch7_start;	-- Channel not allowed by flag
			elsif idt_wren(3) = '0' then
				next_stateval <= test_ch5_running;
			else
				next_stateval <= test_ch5_flag;
			end if;
		when test_ch5_running =>
			if idt_wren(3) = '1' then
				next_stateval <= test_ch7_start;	-- End of channel transfer
			else
				next_stateval <= test_ch5_running;
			end if;			
			
		-----------------
		-- Channel 7-8 --
		-----------------
		when test_ch7_start =>
			if enable_adc(4) = '1' then
				next_stateval <= test_ch7_flag;
			else
				next_stateval <= idle;	-- Channel not enabled
			end if;
		when test_ch7_flag =>
			if noflagin(7) = '1' then
				next_stateval <= idle;	-- Channel not allowed by flag
			elsif idt_wren(4) = '0' then
				next_stateval <= test_ch7_running;
			else
				next_stateval <= test_ch7_flag;
			end if;
		when test_ch7_running =>
			if idt_wren(4) = '1' then
				next_stateval <= idle;	-- End of channel transfer
			else
				next_stateval <= test_ch7_running;
			end if;				
			
		when others =>
			next_stateval <= idle;
			
	end case;
end process;
--
-- Asynchronous assignments of internal signals
OUTPUT_COMB: process(next_stateval)
begin
	case next_stateval is
		when idle =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"00";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch1_start =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"01";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch1_flag =>
			i_start_transfer <= "10000000";
			i_state_out_top <= x"02";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch1_running =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"03";
			i_transfer_running <= '1';
			idt_data <= "000000" & fifo_qB & "000000" & fifo_qA;
		when test_ch3_start =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"07";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch3_flag =>
			i_start_transfer <= "00100000";
			i_state_out_top <= x"08";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch3_running =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"09";
			i_transfer_running <= '1';
			idt_data <= "000000" & fifo_qD & "000000" & fifo_qC;
		when test_ch5_start =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"0D";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch5_flag =>
			i_start_transfer <= "00001000";
			i_state_out_top <= x"0E";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch5_running =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"0F";
			i_transfer_running <= '1';
			idt_data <= "000000" & fifo_qF & "000000" & fifo_qE;
		when test_ch7_start =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"13";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch7_flag =>
			i_start_transfer <= "00000010";
			i_state_out_top <= x"14";
			i_transfer_running <= '0';
			idt_data <= (others => 'Z');
		when test_ch7_running =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"15";
			i_transfer_running <= '1';
			idt_data <= "000000" & fifo_qH & "000000" & fifo_qG;
		when others =>
			i_start_transfer <= "00000000";
			i_state_out_top <= x"00";
			i_transfer_running <= '0';
	end case;
end process;
--
-- Registered states
STATE_FLOPS: process(clk,rst)
begin
if rst = '1' then
	stateval <= idle;
elsif rising_edge(clk) then
	stateval <= next_stateval;
end if;
end process;
--
-- Registered output assignments
OUTPUT_FLOPS: process(rst,clk)
begin
	if rst ='1' then
		start_transfer_reg <= "00000000";
		state_out_top <= x"00";
		transfer_running <= '0';
	elsif rising_edge(clk) then
		start_transfer_reg <= i_start_transfer;
		state_out_top <= i_state_out_top;
		transfer_running <= i_transfer_running;
	end if;
end process;
--
-- FIFO control instantiation
CH1CH2_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> start_transfer_reg(1),
		noflag				=> noflagin(1),
		idt_full			   => idt_full(1),
		idt_wren				=> idt_wren(1),
		fifo_empty			=> fifo_empty(1),
		fifo_used			=> fifo_used_A,
		rden_A				=> fifo_rden(1),
		rden_B				=> fifo_rden(2),
		transfer_counter 	=> transfer_counter,
		state_out			=> state_out_A
	);


CH3CH4_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> start_transfer_reg(3),
		noflag				=> noflagin(3),
		idt_full				=> idt_full(2),
		idt_wren				=> idt_wren(2),
		fifo_empty			=> fifo_empty(3),
		fifo_used			=> fifo_used_C,
		rden_A				=> fifo_rden(3),
		rden_B				=> fifo_rden(4)
	);


CH5CH6_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> start_transfer_reg(5),
		noflag				=> noflagin(5),
		idt_full				=> idt_full(3),
		idt_wren				=> idt_wren(3),
		fifo_empty			=> fifo_empty(5),
		fifo_used			=> fifo_used_E,
		rden_A				=> fifo_rden(5),
		rden_B				=> fifo_rden(6)
	);


CH7CH8_idtfifo_ctr:
	idtfifo_ctr port map
	(	
		rst					=> rst,
		clk					=> clk,
		start_transfer		=> start_transfer_reg(7),
		noflag				=> noflagin(7),
		idt_full				=> idt_full(4),
		idt_wren				=> idt_wren(4),
		fifo_empty			=> fifo_empty(7),
		fifo_used			=> fifo_used_G,
		rden_A				=> fifo_rden(7),
		rden_B				=> fifo_rden(8)
	);

--
end one_idtfifo_top;