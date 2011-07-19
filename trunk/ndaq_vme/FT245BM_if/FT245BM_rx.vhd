-- FT245BM TX Interface
-- v: svn controlled
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

entity ft245bm_rx is
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal ftclk			: in	std_logic;
		signal clk_en			: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		signal enable			: in	std_logic;			-- arbiter if
		signal isidle			: out	std_logic := '1';	-- arbiter if

		signal rd				: in	std_logic;
		signal dataa 			: out	std_logic := '0';
		signal odata			: out 	std_logic_vector(7 downto 0);

		signal f_rxf			: in 	std_logic;
		signal f_rd				: out	std_logic := '1';
		signal f_idata        	: in	std_logic_vector(7 downto 0)
	);
end ft245bm_rx;

--

architecture rtl of ft245bm_rx is
	
	-- Build an enumerated type for the state machine
	type state_type		is (idle,  
							FTDI_rd_a, FTDI_waitst, FTDI_ldata, FTDI_rd_d); 

	type rxlocalst_type	is (idle, 
							FT_request, localbuf, localread);
							
	-- Register to hold the current state
	signal state		: state_type;
	
	signal rxlocalst	: rxlocalst_type;
	
	-- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type		: type is "safe, one-hot";

	attribute syn_encoding of rxlocalst_type	: type is "safe, one-hot";

	-- Buffer
	signal buf		: std_logic_vector(7 downto 0) := x"00";
	
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

	rx_ft_fsm:
	process (ftclk, clk_en, rst)
	begin
		if (rst = '1') then	
			state	<= idle;
			--

		elsif (rising_edge(ftclk) and (clk_en = '1')) then
			case (state) is
				when idle	=>
					--
					if (ft_req = '1') then		-- Local reader request? Go get data.
						state	<= FTDI_rd_a;
						--						
					else
						state	<= idle;
					end if;
				  					
				when FTDI_rd_a	=>
					state	<= FTDI_waitst;
				
				when FTDI_waitst =>
					state	<= FTDI_ldata; 
					--							-- Data is ready at the FT bus.
												-- Tell it to the local reader.

				when FTDI_ldata	=>
					if (ft_req = '0') then		-- If local read has finished we're
						state	<= FTDI_rd_d;	-- free to go.
						--
												-- Handshake.
					else
						state	<= FTDI_ldata;	-- Wait for the local reader.
					end if;						
					
				-- Pre-Charge Time T6(80ns), will be achieved with the next states.	
				--
				when FTDI_rd_d	=>				-- Wastes 50ns with f_rd deasserted
						state	<= idle;		-- plus 50ns with the next state (idle)
						--						-- achieving 100ns of precharge time.
						
			end case;
		end if;
	end process;

	process (state)
	begin
		case (state) is
		
			when idle			=>
				i_ft_done	<= '0';
				f_rd   		<= '1';
			
			when FTDI_rd_a		=>
				i_ft_done	<= '0';
				f_rd   		<= '0';
			
			when FTDI_waitst	=>
				i_ft_done	<= '0';
				f_rd   		<= '0';
			
			when FTDI_ldata		=>
				i_ft_done	<= '1';
				f_rd   		<= '0';
			
			when FTDI_rd_d		=>
				i_ft_done	<= '0';
				f_rd   		<= '1';
			
			when others	=>
				i_ft_done	<= '0';
				f_rd   		<= '1';
		
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

	rx_local_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then
			rxlocalst	<= idle;
			--
			odata		<= x"00";
			buf			<= x"00";
			
		elsif (rising_edge(clk)) then
			case(rxlocalst) is
			
				when idle	=> 
					if (r_enable = '1') then
						rxlocalst	<= FT_request;
						--
					else
						rxlocalst	<= idle;
					end if;
						
				when FT_request	=>
					if (ft_done = '1') then
						rxlocalst	<= localbuf;
						--
						buf			<= f_idata;
					else
						rxlocalst	<= FT_request;
					end if;
					
				when localbuf	=> 
					if (ft_done = '0') then			-- Handshaking.
						rxlocalst	<= localread;
						--
					else
						rxlocalst	<= localbuf;	-- Wait for FT machine to complete its cycle.
					end if;

				when localread	=>
					if (rd = '0') then
						rxlocalst	<= idle;
						--
						odata		<= buf;
					else
						rxlocalst	<= localread;
					end if;
					
				when others =>
					rxlocalst	<= idle;
					
			end case;
		end if;
	end process;
	
	rx_local_fsm_ops:
	process (rxlocalst)
	begin
		case (rxlocalst) is
			
			when idle		=>
				dataa		<= '0';
				i_ft_req	<= '0';
				isidle		<= '1';
			
			when FT_request	=>
				dataa		<= '0';
				i_ft_req	<= '1';
				isidle		<= '0';
			
			when localbuf	=>
				dataa		<= '0';
				i_ft_req	<= '0';
				isidle		<= '0';
			
			when localread	=>
				dataa		<= '1';
				i_ft_req	<= '0';
				isidle		<= '1';
			
			when others		=>
				dataa		<= '0';
				i_ft_req	<= '0';
				isidle		<= '1';
			
		end case;
	end process;
	
end rtl;
