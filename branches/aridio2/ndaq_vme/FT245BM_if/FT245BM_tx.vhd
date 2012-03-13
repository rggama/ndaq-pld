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
	signal ft_req		: std_logic := '0';
	signal ft_done		: std_logic := '0';
	signal i_ft_req		: std_logic := '0';
	signal i_ft_done	: std_logic := '0';
	signal r_enable		: std_logic := '0';

--

begin	

	from_local_reg:
	process (ftclk, clk_en, rst)
	begin
		if (rst = '1') then
			ft_req	<= '0';
			
		elsif (rising_edge(ftclk) and (clk_en = '1')) then
			ft_req	<= i_ft_req;
		end if;
	end process;

	tx_ft_fsm:
	process (ftclk, clk_en, rst)
	begin
		if (rst = '1') then	
			state	<= idle;
			
		elsif (rising_edge(ftclk) and (clk_en = '1')) then
			case state is
				when idle	=>

					if (ft_req = '1') then		-- Waiting for the local writer request.
						state	<= FTDI_wr_a;
						--						
					else
						state <= idle;
					end if;

				when FTDI_wr_a	=>
					state	<= FTDI_wr_d;
					--				
	
				-- Pre-Charge
				when FTDI_wr_d	=>
					if (ft_req = '0') then		-- Handshake.
						state	<= idle;
						--
					else
						state	<= FTDI_wr_d;
					end if;
				
				when others	=>
					state	<= idle;
					 
			end case;
		end if;
	end process;
	
	tx_ft_fsm_ops:
	process (state)
	begin
		case(state) is
		
			when idle		=>
				f_wr		<= '0';
				i_ft_done	<= '0';
			
			when FTDI_wr_a	=>
				f_wr		<= '1';
				i_ft_done	<= '1';
			
			when FTDI_wr_d	=>
				f_wr		<= '0';
				i_ft_done	<= '1';
			
			when others		=>
				f_wr		<= '0';
				i_ft_done	<= '0';
		
		end case;
	end process;

--***************************************************************************************************************  						

	from_ft_reg:
	process (clk, rst)
	begin
		if (rst = '1') then
			ft_done		<= '0';
			r_enable	<= '0';
			
		elsif (rising_edge(clk)) then
			ft_done		<= i_ft_done;
			r_enable	<= enable;
		end if;
	end process;

	tx_local_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			txlocalst	<= idle;
			--
			buf			<= x"00";
			--f_odata		<= (others => 'Z');
			
		elsif (rising_edge(clk)) then
			case(txlocalst) is
			
				when idle	=> 
					if (wr = '0') then			-- Wait for local write request.
						txlocalst	<= localwrite;
						--
						buf			<= idata;
					else
						txlocalst	<= idle;	
					end if;
				
				when localwrite	=>
					if (r_enable = '1') then	 	-- If the arbiter let us go...
						txlocalst	<= ftwrite;
						--
						--f_odata		<= buf;
					
					else
						txlocalst	<= localwrite;
					end if;
						
				when ftwrite	=>
					if (ft_done = '1') then
						txlocalst	<= handshake;
						--						
					else
						txlocalst	<= ftwrite;
					end if;
				
				when handshake	=>
					if (ft_done = '0') then
						txlocalst	<= idle;
						--
						--f_odata		<= (others => 'Z');											
					else
						txlocalst	<= handshake;
					end if;
					
				when others =>
					txlocalst	<= idle;
					
			end case;
		end if;
	end process;

	tx_local_fsm_ops:
	process (txlocalst, buf)
	begin
		case(txlocalst) is
			when idle		=>
				dwait		<= '0';
				i_ft_req	<= '0';
				isidle		<= '1';
				--
				f_odata		<= (others => 'Z');	
				
			when localwrite	=>
				dwait		<= '1';
				i_ft_req	<= '0';
				isidle		<= '1';
				--
				f_odata		<= (others => 'Z');	
			
			when ftwrite	=>
				dwait		<= '1';
				i_ft_req	<= '1';
				isidle		<= '0';
				--
				f_odata		<= buf;			

			when handshake	=>
				dwait		<= '1';
				i_ft_req	<= '0';
				isidle		<= '0';
				--
				f_odata		<= buf;			
			
			when others =>
				dwait		<= '0';
				i_ft_req	<= '0';
				isidle		<= '1';
				--
				f_odata		<= (others => 'Z');	

		end case;
	end process;

--***************************************************************************************************************  						
	
	-- input_register:
	-- process (clk, rst)
	-- begin
		-- if (rst = '1') then
			-- buf	<= x"00";
			
		-- elsif (rising_edge(clk)) then
			-- if (wr = '0') then			-- Wait for local write request.
				-- buf	<= idata;
			-- end if;	
		-- end if;
	-- end process;

end rtl;
