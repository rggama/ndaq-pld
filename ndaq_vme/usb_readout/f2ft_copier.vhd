-- $ f2ft_copier.vhd - FIFO to FT245BM interface copier.
-- v: svn controlled.
--
--		Parameters:
--
--			@ 'RMIN'	: Read is prohibited if 'usedw' < 'RMIN'
--			@ 'ESIZE'	: Number of samples (words) to build an event. 
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
		signal odata        	: out	std_logic_vector(7 downto 0);
		
		-- Parameters		
		signal rmin				: in 	std_logic_vector(7 downto 0);
		signal esize			: in	std_logic_vector(8 downto 0)
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
	type state_type is (idle, read_st, write_st_LOW, test_st_LOW, write_st_HIGH, test_st_HIGH, go_idle);

	-- Register to hold the current state
	signal state	: state_type := idle;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";

	--

	signal scounter	: std_logic_vector(7 downto 0);
	signal tmp		: std_logic_vector(9 downto 0); --:= x"00";
	
	--
	
	signal i_rd			: std_logic := SOURCE_RD_DEASSERT;
	signal i_wr			: std_logic := 'Z';
	signal i_isidle		: std_logic := '1';
	signal i_odata		: std_logic_vector(7 downto 0) := x"00";
	signal oe			: std_logic := '0';
	signal mode			: std_logic	:= '1';
	
--

begin

	transfer_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			state <= idle;
			--	
			scounter	<= (others => '0');		-- Event size counter.
			
		elsif (rising_edge(clk)) then
			case (state) is
				
				when idle	=>
					if ((enable = '1') and (dwait = '0')  
						and (ef = '0') and ((usedw > esize) or (usedw = x"00"))) then
						state	<= read_st;
					else
						state	<= idle;
					end if;

				when read_st	=>
					if (mode = '0') then
						state	<= write_st_LOW;
					else
						state	<= write_st_HIGH;
					end if;
					
						
--********************************************************************************

				when write_st_LOW	=>
			
					state <= test_st_LOW;						
				
				when test_st_LOW	=>
					if (enable = '1') then
						if (dwait = '0') then
							state	<= write_st_HIGH;
						else
							state	<= test_st_LOW;
						end if;
					else
						state 	<= idle; --go_idle;
						--
						scounter	<= (others => '0');
					end if;

--********************************************************************************

				when write_st_HIGH	=>
					scounter <= scounter + 1;
					--
					if (scounter = esize) then
						state <= go_idle;			--When ending, we must 'go_idle'.
						--
						scounter	<= (others => '0');
					else
						state <= test_st_HIGH;						
					end if;
				
				when test_st_HIGH	=>
					if (enable = '1') then
						if (dwait = '0') then
							state	<= read_st;
						else
							state	<= test_st_HIGH;
						end if;
					else
						state 	<= idle; --go_idle;
						--
						scounter	<= (others => '0');
					end if;

--********************************************************************************
				
				when go_idle	=>
					state		<= idle;

				when others	=>
					state		<= idle;
					--	
					scounter	<= (others => '0');
					
			end case;
		end if;
	end process;

	odata_assignment:
	tmp <= q & "00";

	transfer_fsm_ops:
	process (state, tmp)
	begin
		case (state) is
			
			when idle	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '1';						-- Tri-state output.
				--
				i_isidle	<= '1';
				--
				i_odata		<= tmp(9 downto 2);			--(others => 'Z');
				--
				oe			<= '0';
				
			when read_st	=>
				i_rd		<= SOURCE_RD_ASSERT;
				i_wr		<= '1';						-- Tri-state output.
				--
				i_isidle	<= '0';
				--
				i_odata		<= tmp(9 downto 2);			--(others => 'Z');
				--
				oe			<= '0';
		
--********************************************************************************

			when write_st_LOW	=>
				i_rd				<= SOURCE_RD_DEASSERT;
				i_wr				<= '0';						-- Write Assert.
				--
				i_isidle			<= '0';
				--
				i_odata(7 downto 2)	<= (others => '0');
				i_odata(1 downto 0)	<= tmp(1 downto 0);
				--
				oe					<= '1';
				
			when test_st_LOW	=>
				i_rd				<= SOURCE_RD_DEASSERT;
				i_wr				<= '1';						-- Tri-state output.
				--
				i_isidle			<= '0';
				--
				i_odata(7 downto 2)	<= (others => '0');
				i_odata(1 downto 0)	<= tmp(1 downto 0);
				--
				oe					<= '1';

--********************************************************************************

			when write_st_HIGH	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '0';						-- Write Assert.
				--
				i_isidle	<= '0';
				--
				i_odata		<= tmp(9 downto 2);
				--
				oe			<= '1';
				
			when test_st_HIGH	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '1';						-- Tri-state output.
				--
				i_isidle	<= '0';
				--
				i_odata		<= tmp(9 downto 2);
				--
				oe			<= '1';
			
--********************************************************************************

			when go_idle	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '1';						-- Tri-state output.
				--
				i_isidle	<= '1';
				--
				i_odata		<= tmp(9 downto 2);			--(others => 'Z');
				--
				oe			<= '0';

			when others	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '1';						-- Tri-state output.
				--
				i_isidle	<= '1';
				--
				i_odata		<= tmp(9 downto 2);			--(others => 'Z');
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