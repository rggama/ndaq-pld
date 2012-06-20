-- $ f2ft_copier.vhd - FIFO to FT245BM interface copier.
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--

entity f2ft_copier is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		-- Arbiter interface
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if
	
		-- FIFO interface
		signal ef				: in	std_logic;
		signal usedw			: in	std_logic_vector(9 downto 0);
		signal rd				: out	std_logic;	
		signal q				: in	std_logic_vector(7 downto 0);
				
		-- FT245BM interface
		signal dwait 			: in	std_logic;
		signal wr				: out	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0)
	);
end f2ft_copier;

--

architecture rtl of f2ft_copier is
	
	constant BYPASS_OPNDRN			:	boolean := false;
	
	constant SOURCE_RD_ASSERT		:	std_logic := '1';	-- Altera's SC FIFO.
	constant SOURCE_RD_DEASSERT		:	std_logic := '0';	-- Altera's SC FIFO.

	-- Components
	component opndrn
    port 
    (
		a_in : in std_logic;
		a_out : out std_logic 
    );
	end component;

	--	
	-- Build an enumerated type for the state machine
	type state_type is (idle, read_st, write_st);

	-- Register to hold the current state
	signal state	: state_type := idle;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";

	
	--	
	signal i_rd			: std_logic := SOURCE_RD_DEASSERT;
	signal i_wr			: std_logic := 'Z';
	signal i_isidle		: std_logic := '1';
	signal i_odata		: std_logic_vector(7 downto 0) := x"00";
	signal oe			: std_logic := '0';
	
--

begin

	transfer_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			state <= idle;
			
		elsif (rising_edge(clk)) then
			case (state) is
				
				when idle	=>
					if ((enable = '1') and (dwait = '0')  
						and (ef = '0')) then
						state	<= read_st;
					else
						state	<= idle;
					end if;

				when read_st	=>
					state	<= write_st;
					
--********************************************************************************

				when write_st	=>
					state <= idle; --go_idle;			--When ending, we must 'go_idle'.

--********************************************************************************
				
				-- when go_idle	=>
					-- state		<= idle;

				when others	=>
					state		<= idle;
					
			end case;
		end if;
	end process;

	odata_assignment:
	i_odata	<= q;

	transfer_fsm_ops:
	process (state)
	begin
		case (state) is
			
			when idle	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '1';						
				--
				i_isidle	<= '1';
				--
				oe			<= '0';
				
			when read_st	=>
				i_rd		<= SOURCE_RD_ASSERT;
				i_wr		<= '1';						
				--
				i_isidle	<= '0';
				--
				oe			<= '0';
		
--********************************************************************************

			when write_st	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '0';						-- Write Assert.
				--
				i_isidle	<= '0';
				--
				oe			<= '1';
							
--********************************************************************************

			-- when go_idle	=>
				-- i_rd		<= SOURCE_RD_DEASSERT;
				-- i_wr		<= '1';						
				-- --
				-- i_isidle	<= '1';
				-- --
				-- oe			<= '0';

			when others	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '1';						
				--
				i_isidle	<= '1';
				--
				oe			<= '0';
				
		end case;
	end process;
	
--*****************************************************************************

	test_opndrn:
	if (BYPASS_OPNDRN = false) generate

		open_drain:
		opndrn port map 
		(
			a_in	=>	i_wr,
			a_out 	=>	wr
		);
	
		hi_z_odata:
		odata	<= i_odata when (oe = '1') else (others => 'Z');
		
	end generate test_opndrn;

	test_bypass_opndrn:
	if (BYPASS_OPNDRN = true) generate

		direct_wr:
		wr		<= i_wr;
	
		direct_odata:
		odata	<= i_odata;
		
	end generate test_bypass_opndrn;

--*****************************************************************************
	
	direct_ops:	
	rd		<= i_rd;
	isidle	<= i_isidle;
	
end rtl;