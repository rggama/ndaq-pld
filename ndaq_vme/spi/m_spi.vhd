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
	signal clk_en		: std_logic := '0';
	signal clk_div		: std_logic_vector(3 downto 0) := x"0";
	
	
	-- Transfer finite state machine
	type state_type		is (idle, tx_load, transfer, w_test); 
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

	-- CLK Divider/Enable Logic
	process (rst, clk) begin
		if (rst = '1') then	
				clk_en <= '0';
				clk_div <= x"0";

		elsif (rising_edge(clk)) then
			if(clk_div = x"1") then -- divided by 2 
				clk_en <= '1';
				clk_div <= x"0";
			else
				clk_en <= '0';
				clk_div <= clk_div + 1;
			end if;
		end if;
	end process;

--***************************************************************************************************************

	-- TX Write FSM
	transfer_fsm:
	process (clk, clk_en, rst)
	begin
		if (rst = '1') then	
			--
			state	<= idle;
			ibuf	<= x"00";
			dwait	<= '0';
			
		elsif (rising_edge(clk)) then
			case state is
				when idle		=>
					--
					if (wr = '0') then
						ibuf	<= idata;			-- Buffering Input Data into 'ibuf'.
						state	<= tx_load;						
						dwait	<= '1';
						
					else
						state <= idle;
					end if;
				
				when tx_load	=>					-- Load 'ibuf' into the SR.	
					if (clk_en = '1') then
						state	<= transfer;
					else
						state <= tx_load;
					end if;
					
				when transfer	=>					-- Serial Transfer. 

					if (t_cntr = x"7" and (clk_en = '1')) then
						
						state	<= w_test;
					else
						state <= transfer;
					end if;
								
				when w_test		=>					-- Future test implementation.
					state	<= idle;
					dwait	<= '0';
										
				when others		=>
					state	<= idle;

			end case;
		end if;
	end process;
	
	--RX Read FSM
	rxread_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then	
			--
			rxstate	<= idle;
			dataa	<= '0';
			odata	<= x"00";
			obuf	<= x"00";
			
		elsif (rising_edge(clk)) then
			case rxstate is
				when idle	=>
					if (t_cntr = x"8") then
						rxstate	<= rx_dataa;
						dataa	<= '1';
						obuf	<= tmp;
					else
						rxstate	<= idle;
						dataa	<= '0';
					end if;
						
				when rx_dataa	=>
					if (rd = '0') then
						dataa	<= '0';
						odata	<= obuf;
						rxstate	<= idle;
					else
						rxstate	<= rx_dataa;
					end if;
						
				when others		=>
					dataa	<= '0';
					rxstate	<= idle;

			end case;
		end if;
	end process;

	-- Transfer FSM *NON BUFFERED* Outputs
	-- process (state)
	-- begin
		-- case state is 
			-- when idle		=> 
				-- i_load		<= '0';	-- parallel SR load strobe
				-- i_transfer	<= '0';	-- enable transfer pulse
				-- i_sclk		<= '0';  -- enable serial clock pulse
				-- i_cntr_en	<= '0';	-- counter enable			
				-- i_cntr_cl	<= '1';	-- counter synchronous clear
				-- i_dwait		<= '0';	-- dwait flag
				-- i_read		<= '0';	-- read issued flag
				-- i_rbuf		<= '0';	-- parallel read buffer strobe
			-- when w_issue	=>
				-- i_load		<= '1';
				-- i_transfer	<= '0';
				-- i_sclk		<= '0';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '0';
				-- i_dwait		<= '1';
				-- i_read		<= '0';
				-- i_rbuf		<= '0';
			-- when w	=>
				-- i_load		<= '0';
				-- i_transfer	<= '0';
				-- i_sclk		<= '1';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '0';
				-- i_dwait		<= '0';
				-- i_read		<= '0';
				-- i_rbuf		<= '0';
			-- when r_issue	=>
				-- i_load		<= '0';
				-- i_transfer	<= '0';
				-- i_sclk		<= '0';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '0';
				-- i_dwait		<= '0';
				-- i_read		<= '1';
				-- i_rbuf		<= '0';
			-- when transfer	=>
				-- i_load		<= '0';
				-- i_transfer	<= '1';
				-- i_sclk		<= '1';
				-- i_cntr_en	<= '1';
				-- i_cntr_cl	<= '0';
				-- i_dwait		<= '1';
				-- i_read		<= '0';
				-- i_rbuf		<= '0';
			-- when transferw	=>
				-- i_load		<= '0';
				-- i_transfer	<= '0';
				-- i_sclk		<= '1';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '0';
				-- i_dwait		<= '1';
				-- i_read		<= '0';
				-- i_rbuf		<= '0';
			-- when w_test		=>
				-- i_load		<= '0';
				-- i_transfer	<= '0';
				-- i_sclk		<= '0';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '1';
				-- i_dwait		<= '1';
				-- i_read		<= '0';
				-- i_rbuf		<= '0';
			-- when r_buf		=>
				-- i_load		<= '0';
				-- i_transfer	<= '0';
				-- i_sclk		<= '0';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '1';
				-- i_dwait		<= '0';
				-- i_read		<= '0';
				-- i_rbuf		<= '1';
			-- when others 	=>
				-- i_load		<= '0';
				-- i_transfer	<= '0';
				-- i_sclk		<= '0';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '1';
				-- i_dwait		<= '0';
				-- i_read		<= '0';
				-- i_rbuf		<= '0';

		-- end case;
	-- end process;
	
	
--***************************************************************************************************************

	-- Serial Clock
	serial_clock:
	process (clk, rst, state)
	begin
		if (rst = '1') then
			r_sclk	<= '0';
			
		elsif (rising_edge(clk)) then
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
	process (clk, clk_en, rst, state)      
	begin
	if (rst = '1') then
		tmp <= (others => '0');
		
	elsif (rising_edge(clk) and (clk_en = '1')) then          
		
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
	process(clk, clk_en, rst, state)
	begin
	if (rst = '1') then
		t_cntr <= x"0";
	elsif (rising_edge(clk) and (clk_en = '1')) then
		if (state = transfer) then
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