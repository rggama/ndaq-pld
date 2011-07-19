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
		signal usedw			: in	std_logic_vector(7 downto 0);
		signal rd				: out	std_logic;	
		signal q					: in	std_logic_vector(9 downto 0);
				
		-- FT245BM interface
		signal dwait 			: in	std_logic;
		signal wr				: out	std_logic;
		signal odata        	: out	std_logic_vector(7 downto 0);
		
		-- Parameters		
		signal rmin				: in 	std_logic_vector(7 downto 0);
		signal esize			: in	std_logic_vector(7 downto 0)
	);
end f2ft_copier;

--

architecture rtl of f2ft_copier is
	
	constant SOURCE_RD_ASSERT		:	std_logic := '1';	-- Altera's SC FIFO.
	constant SOURCE_RD_DEASSERT	:	std_logic := '0';	-- Altera's SC FIFO.

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
	type state_type is (idle, read_st, write_st_LOW, test_st_LOW, write_st_HIGH, test_st_HIGH);

	-- Register to hold the current state
	signal state	: state_type := idle;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";

	--

	signal scounter	: std_logic_vector(7 downto 0);
	signal tmp			: std_logic_vector(9 downto 0); --:= x"00";
	
	--
	
	signal i_rd			: std_logic := SOURCE_RD_DEASSERT;
	signal i_wr			: std_logic := 'Z';
	signal i_isidle	: std_logic := '1';
	signal mode			: std_logic	:= '0';
	
--

begin
	--tmp	<= q(7 downto 0);
	--tmp	<= q(9 downto 2);
	tmp <= q(9 downto 0);
	
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
						and (ef = '0') and (usedw = x"00")) then   --and (usedw > rmin)
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
					if ((enable = '1') and (dwait = '0')) then
						state	<= write_st_HIGH;
					else
						state	<= test_st_LOW;
					end if;

--********************************************************************************

				when write_st_HIGH	=>
					scounter <= scounter + 1;
					--
					if (scounter = esize) then
						state <= idle;
						--
						scounter	<= (others => '0');
					else
						state <= test_st_HIGH;						
					end if;
				
				when test_st_HIGH	=>
					if ((enable = '1') and (dwait = '0')) then
						state	<= read_st;
					else
						state	<= test_st_HIGH;
					end if;

--********************************************************************************
				
				when others	=>
					state <= idle;
					--	
					scounter	<= (others => '0');
					
			end case;
		end if;
	end process;

	transfer_fsm_ops:
	process (state, tmp)
	begin
		case (state) is
			
			when idle	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= 'Z';						-- Tri-state output.
				--
				i_isidle	<= '1';
				--
				odata		<= (others => 'Z');
				
			when read_st	=>
				i_rd		<= SOURCE_RD_ASSERT;
				i_wr		<= 'Z';						-- Tri-state output.
				--
				i_isidle	<= '0';
				--
				odata		<= (others => 'Z');
		
--********************************************************************************

			when write_st_LOW	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '0';						-- Write Assert.
				--
				i_isidle	<= '0';
				--
				odata(7 downto 2)	<= (others => '0');
				odata(1 downto 0)	<= tmp(1 downto 0);
				
			when test_st_LOW	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= 'Z';						-- Tri-state output.
				--
				i_isidle	<= '0';
				--
				odata(7 downto 2)	<= (others => '0');
				odata(1 downto 0)	<= tmp(1 downto 0);

--********************************************************************************

			when write_st_HIGH	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= '0';						-- Write Assert.
				--
				i_isidle	<= '0';
				--
				odata		<= tmp(9 downto 2);
				
			when test_st_HIGH	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= 'Z';						-- Tri-state output.
				--
				i_isidle	<= '0';
				--
				odata		<= tmp(9 downto 2);
			
--********************************************************************************

			when others	=>
				i_rd		<= SOURCE_RD_DEASSERT;
				i_wr		<= 'Z';						-- Tri-state output.
				--
				i_isidle	<= '1';
				--
				odata		<= (others => 'Z');
				
		end case;
	end process;
	
--*****************************************************************************

    open_drain:
	opndrn port map 
    (
		a_in	=>	i_wr,
		a_out =>	wr
    );

--*****************************************************************************

	direct_ops:
	rd		<= i_rd;
	--wr		<= i_wr;
	isidle	<= i_isidle;
	
end rtl;