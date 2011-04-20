-- FT245BM TX Interface
-- v: svn controlled
--
-- 0.0	First Version
--
-- 0.1	Changed IOs to 'std_logic_vector'
--
--

library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.all;

--

entity ft245bm_tx is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal ftclk			: in 	std_logic; -- sync if
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic; 			-- arbiter if
		signal isidle			: out	std_logic := '1';	-- arbiter if

		signal wr				: in	std_logic;
		signal dwait 			: out	std_logic := '0';
		signal idata			: in 	std_logic_vector(7 downto 0);

		signal f_txf			: in 	std_logic;
		signal f_wr				: out	std_logic := '0';
		signal f_odata        	: out	std_logic_vector(7 downto 0)
	);
end ft245bm_tx;

--

architecture rtl of ft245bm_tx is
	
	-- Build an enumerated type for the state machine
	type state_type		is (idle, FTDI_wr_a, FTDI_wr_d);
	type txlocalst_type	is (idle, localwrite, ftwrite, handshake);

	-- Register to hold the current state
	signal state		: state_type;
	signal txlocalst	: txlocalst_type;

	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type		: type is "safe, one-hot";
	attribute syn_encoding of txlocalst_type	: type is "safe, one-hot";

	-- Buffer
	signal buf	: std_logic_vector(7 downto 0) := x"00";
	
	-- Internal Signals
	signal ft_req	: std_logic := '0';
	signal ft_done	: std_logic := '0';

--

begin	

	tx_ft_fsm:
	process (ftclk, clk_en, rst)
	begin
		if (rst = '1') then	
			state	<= idle;
			f_wr	<= '0';
			ft_done	<= '0';
			
		elsif (rising_edge(ftclk) and (clk_en = '1')) then
			case state is
				when idle	=>

					if (ft_req = '1') then		-- Waiting for the local writer request.
						state	<= FTDI_wr_a;
						--
						f_wr	<= '1';
						ft_done	<= '1';
						
					else
						state <= idle;
					end if;

				when FTDI_wr_a	=>
					state	<= FTDI_wr_d;
					--
					f_wr	<= '0';
					
				
				-- Pre-Charge
				when FTDI_wr_d	=>
					if (ft_req = '0') then		-- Handshake.
						state	<= idle;
						--
						ft_done	<= '0';
					else
						state	<= FTDI_wr_d;
					end if;
				
				when others	=>
					state	<= idle;
					 
			end case;
		end if;
	end process;

--***************************************************************************************************************  						

	tx_local_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			txlocalst	<= idle;
			--
			buf			<= x"00";
			dwait		<= '0';
			ft_req		<= '0';
			isidle		<= '1';
			f_odata		<= (others => 'Z');
			
		elsif (rising_edge(clk)) then
			case(txlocalst) is
			
				when idle	=> 
					if (wr = '0') then			-- Wait for local write request.
						txlocalst	<= localwrite;
						--
						buf			<= idata;
						dwait		<= '1';
					else
						txlocalst	<= idle;	
					end if;
				
				when localwrite	=>
					if (enable = '1') then	 	-- If the arbiter let us go...
						txlocalst	<= ftwrite;
						--
						f_odata		<= buf;
						ft_req		<= '1';
						isidle		<= '0';
					
					else
						txlocalst	<= localwrite;
					end if;
						
				when ftwrite	=>
					if (ft_done = '1') then
						txlocalst	<= handshake;
						--
						ft_req		<= '0';
						
					else
						txlocalst	<= ftwrite;
					end if;
				
				when handshake	=>
					if (ft_done = '0') then
						txlocalst	<= idle;
						--
						dwait		<= '0';
						ft_req		<= '0';
						f_odata		<= (others => 'Z');					
						isidle		<= '1';
						
					else
						txlocalst	<= handshake;
					end if;
					
				when others =>
					txlocalst	<= idle;
					
			end case;
		end if;
	end process;

end rtl;
