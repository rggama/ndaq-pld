-- $Master SPI Interface
-- v: svn controlled.
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--

entity m_spi is
	port
	(	
		signal clk				: in	std_logic;						-- sytem clock (@20 MHz)
		signal rst				: in 	std_logic;						-- asynchronous reset
		
		signal mosi				: out	std_logic := '0';				-- master serial out	- slave serial in
		signal miso				: in	std_logic;						-- master serial in	- slave serial out
		signal sclk				: out	std_logic := '0';				-- spi clock out
		
		signal wr				: in	std_logic;						-- write strobe
		signal rd				: in	std_logic;						-- read strobe
		
		signal dwait			: out	std_logic := '0';				-- dwait flag
		signal dataa			: out	std_logic := '0';				-- data avaiable flag
		
		signal idata			: in	std_logic_vector(7 downto 0);	-- data input parallel bus
		signal odata			: out	std_logic_vector(7 downto 0)	-- data output parallel bus	
	);
end m_spi;

--

architecture rtl of m_spi is

	-- CLK Divider/Enable Logic
	signal cg_clk_en	: std_logic := '0';						-- Clock Generator clock enable
	signal se_clk_en	: std_logic := '1';						-- Serial Engine clock enable
	signal cg_clk_div	: std_logic_vector(3 downto 0) := x"0";	--
	
	
	-- Transfer finite state machine
	type state_type		is (idle, tx_load, transfer, rx_latch); 
	type rxstate_type	is (idle, rx_dataa); 

	-- Register to hold the current state
	signal state	: state_type := idle;
	signal rxstate	: rxstate_type := idle;

	-- FSM attributes
	attribute syn_encoding : string;
	attribute syn_encoding of state_type	: type is "safe, one-hot";
	attribute syn_encoding of rxstate_type	: type is "safe, one-hot";
	
	-- Transfer FSM *Non Buffered* Signals
	-- signal i_load		: std_logic := '0';
	-- signal i_transfer	: std_logic	:= '0';
	-- signal i_sclk		: std_logic	:= '0';
	-- signal i_cntr_en		: std_logic := '0';
	-- signal i_cntr_cl		: std_logic := '1';
	-- signal i_dwait		: std_logic := '0';
	-- signal i_read		: std_logic := '0';
	-- signal i_rbuf		: std_logic := '0';
		
	-- Serial Clock
	signal r_sclk	: std_logic := '0';

	-- Buffers
	signal tmp	: std_logic_vector(7 downto 0) := x"00";
	signal ibuf	: std_logic_vector(7 downto 0) := x"00";
	signal obuf	: std_logic_vector(7 downto 0) := x"00";
	
	-- Transfer Counter
	signal t_cntr	: std_logic_vector(3 downto 0) := x"0";
	
--

begin

--***************************************************************************************************************

	-- Clock Generator CLK Divider/Enable Logic
	process (rst, clk) begin
		if (rst = '1') then	
			cg_clk_en	<= '0';
			cg_clk_div	<= x"0";
				
		elsif (rising_edge(clk)) then
			if(cg_clk_div = x"2") then -- divided by 2 
				cg_clk_en	<= '1';
				cg_clk_div	<= x"0";		
			else
				cg_clk_en	<= '0';
				cg_clk_div	<= cg_clk_div + 1;
			end if;
						
		end if;
	end process;

	-- Serial Engine CLK Divider/Enable Logic
	process (rst, clk, cg_clk_en) begin
		if (rst = '1') then	
			se_clk_en	<= '1';
			
		elsif (rising_edge(clk) and (cg_clk_en = '1')) then
			
			if(se_clk_en = '0') then
				se_clk_en	<= '1';
			else
				se_clk_en	<= '0';
			end if;
			
		end if;
	end process;

--***************************************************************************************************************

	-- TX Write FSM
	transfer_fsm:
	process (clk, se_clk_en, rst)
	begin
		if (rst = '1') then	
			--
			state	<= idle;
			ibuf	<= x"00";
			obuf	<= x"00";
			
			
		elsif (rising_edge(clk)) then
			case state is
				when idle		=>
					--
					if (wr = '0') then
						state	<= tx_load;						
						--
						ibuf	<= idata;			-- Buffering Input Data into 'ibuf'.
						
					else
						state <= idle;
					end if;
				
				when tx_load	=>					-- Load 'ibuf' into the SR.	
					if ((se_clk_en = '1') and (cg_clk_en = '1')) then
						state	<= transfer;
					else
						state <= tx_load;
					end if;
					
				when transfer	=>					-- Serial Transfer. 

					if ((t_cntr = x"7") and (se_clk_en = '1') and (cg_clk_en = '1')) then
						
						state	<= rx_latch;
					else
						state <= transfer;
					end if;
													
				when rx_latch		=>					-- Future test implementation.
					state	<= idle;
					--
					obuf	<= tmp;
					
				when others		=>
					state	<= idle;

			end case;
		end if;
	end process;
	
	-- Transfer FSM *NON BUFFERED* Outputs
	transfer_fsm_ops:
	process (state)
	begin
		case (state) is 
			when idle		=> 
				dwait	<= '0';

			when tx_load	=>
				dwait	<= '1';

			when transfer	=>
				dwait	<= '1';

			when rx_latch	=>
				dwait	<= '1';

			when others 	=>
				dwait	<= '0';

		end case;
	end process;

--***************************************************************************************************************
	
	odata	<= obuf;
	
	-- RX Read FSM
	rxread_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then	
			--
			rxstate	<= idle;
			--
			--odata	<= x"00";
			
			
		elsif (rising_edge(clk)) then
			case rxstate is
				when idle	=>
					if (state = rx_latch) then --(t_cntr = x"8")
						rxstate	<= rx_dataa;
						--
						
					else
						rxstate	<= idle;
				end if;
											
				when rx_dataa	=>					
					if (rd = '0') then
						rxstate	<= idle;
						--
						--odata	<= obuf;
					else
						rxstate	<= rx_dataa;
					end if;						
				
					
				when others		=>
					rxstate	<= idle;

			end case;
		end if;
	end process;

	-- RX Read FSM *NON BUFFERED* Outputs
	rxread_fsm_ops:
	process (rxstate)
	begin
		case (rxstate) is 
			when idle		=> 
				dataa	<= '0';

			when rx_dataa	=>
				dataa	<= '1';

			when others 	=>
				dataa	<= '0';

		end case;
	end process;
	
--***************************************************************************************************************

	-- Serial Clock Generator
	serial_clock:
	process (clk, rst, cg_clk_en, state)
	begin
		if (rst = '1') then
			r_sclk	<= '0';
			
		elsif (rising_edge(clk) and (cg_clk_en = '1')) then
			case r_sclk is
				
				when '0'	=>
					if(state = transfer) then
						r_sclk	<= '1';
					else
						r_sclk	<= '0';
					end if;
					
				when '1'	=>		
					r_sclk	<= '0';
				when others =>
					r_sclk	<= '0';
			end case;
		end if;
	end process;
				
	sclk <= r_sclk;

--***************************************************************************************************************
			
	-- Shift Register
	shift_register:
	process (clk, se_clk_en, cg_clk_en, rst, state)      
	begin
	if (rst = '1') then
		tmp <= (others => '0');
		
	elsif (rising_edge(clk) and (se_clk_en = '1') and (cg_clk_en = '1')) then          
		
		if (state = tx_load) then            
			tmp <= ibuf;          
		elsif (state = transfer) then          
			tmp <= tmp(6 downto 0) & miso;          
		end if;        
	
	end if;
	end process;    
	
	mosi		<=	tmp(7);
	
--***************************************************************************************************************

	-- Transfer Counter
	transfer_counter:
	process(clk, se_clk_en, cg_clk_en, rst, state)
	begin
	if (rst = '1') then
		t_cntr <= x"0";
	elsif (rising_edge(clk)) then
		if ((state = transfer) and (se_clk_en = '1') and (cg_clk_en = '1')) then
			t_cntr <= t_cntr + 1;
		elsif (state = idle) then
			t_cntr <= x"0";
--		else
--			t_cntr <= t_cntr;
		end if;
	end if;
	end process;	 

--***************************************************************************************************************

	-- Parallel Output Buffering
	-- output_buffer:
	-- process (clk, rst)
	-- begin
	-- if (rst = '1') then
		-- obuf <= (others => '0');
	
	-- elsif (rising_edge(clk)) then
		
		-- if (i_rbuf = '1') then
			-- obuf	<= tmp;
		-- else
			-- obuf <= obuf;
		-- end if;
	
	-- end if;
	-- end process;
	
	-- odata	<= obuf;
	
--***************************************************************************************************************

end rtl;