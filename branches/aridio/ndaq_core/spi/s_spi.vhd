-- $Slave SPI Interface
-- v: svn controlled.
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--

entity s_spi is
	port
	(	
		signal clk				: in	std_logic;						-- sytem clock (@20 MHz)
		signal rst				: in 	std_logic;						-- asynchronous reset
		
		signal mosi				: in	std_logic;						-- master serial out	- slave serial in
		signal miso				: out	std_logic := '0';				-- master serial in	- slave serial out
		signal sclk				: in	std_logic;						-- spi clock out
		
		signal wr				: in	std_logic;						-- write strobe
		signal rd				: in	std_logic;						-- read strobe
		
		signal dwait			: out	std_logic := '0';				-- dwait flag
		signal dataa			: out	std_logic := '0';				-- data avaiable flag
		
		signal idata			: in	std_logic_vector(7 downto 0);	-- data input parallel bus
		signal odata			: out	std_logic_vector(7 downto 0)	-- data output parallel bus	
	);
end s_spi;

--

architecture rtl of s_spi is
	--
	-- Signals
	--
	
	-- CLK Enable Logic
	-- signal clk_en		: std_logic := '0';
	-- signal clk_st		: std_logic := '0';
	
	
	-- Transfer finite state machine
	type state_type		is (idle, rx_dataa, rx_sync); 
	type txstate_type	is (idle, tx_load, tx_sync); 

	-- Register to hold the current state
	signal state	: state_type := idle;
	signal txstate	: txstate_type := idle;
	
	-- FSM attributes
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe, one-hot";
	attribute syn_encoding of txstate_type : type is "safe, one-hot";
	
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
--	signal r_sclk	: std_logic := '0';

	-- Buffers
	signal rxtmp	: std_logic_vector(7 downto 0) := x"00";
	signal txtmp	: std_logic_vector(7 downto 0) := x"AA";
	signal ibuf		: std_logic_vector(7 downto 0) := x"00";
	signal obuf		: std_logic_vector(7 downto 0) := x"00";
	signal txload	: std_logic	:= '0';
	
	-- Transfer Counter
	signal t_cntr	: std_logic_vector(3 downto 0) := x"0";
	signal cntr_end	: std_logic := '0';
	signal cntr_zro	: std_logic := '0';
	
	-- RX buffering
	signal r_cntr_end	: std_logic := '0';
	--signal r_cntr_zro	: std_logic := '1';
	
	-- System clock's registers
	signal s_cntr_end	: std_logic := '0';
	--signal s_cntr_zro	: std_logic := '1';
	signal s_rxtmp		: std_logic_vector(7 downto 0) := x"00";
	
--

begin

--***************************************************************************************************************
	-- Buffering SPI signals with system clock's registers
	
	sysclk_buffering:
	process (clk, rst)      
	begin
	if (rst = '1') then
		s_cntr_end	<= '0';
		--s_cntr_zro	<= '1';
		--dwait			<= '0';
		
	elsif (rising_edge(clk)) then          
		s_cntr_end	<= r_cntr_end;
		--s_cntr_zro	<= r_cntr_zro;
		--dwait			<= not(cntr_zro);

	end if;
	end process;    

--***************************************************************************************************************

	--TX Write FSM
	txwrite_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then	
			--
			txstate	<= idle;
			ibuf	<= x"00";
			
		elsif (rising_edge(clk)) then
			case txstate is
				when idle	=>
					if (wr = '0') then
						txstate	<= tx_load;
						ibuf	<= idata;
					else
						txstate	<= idle;
					end if;
						
				when tx_load	=>
					if(txload = '1') then
						txstate <= tx_sync; --idle;
					else
						txstate	<= tx_load;
					end if;

				when tx_sync	=>
					if((txload = '0') and (s_cntr_end = '1')) then
						txstate	<= idle;
					else
						txstate <= tx_sync;
					end if;
					
				when others		=>
					txstate	<= idle;

			end case;
		end if;
	end process;

	-- TX Write FSM *NON BUFFERED* Outputs
	txwrite_fsm_ops:
	process (txstate)
	begin
		case (txstate) is 
			when idle		=> 
				dwait	<= '0';

			when tx_load	=>
				dwait	<= '1';

			when tx_sync	=>
				dwait	<= '1';

			when others 	=>
				dwait	<= '0';

		end case;
	end process;

--***************************************************************************************************************

	--RX Read FSM
	rxread_fsm:
	process (clk, rst)
	begin
		if (rst = '1') then	
			--
			state	<= idle;
			--dataa	<= '0';
			odata	<= x"00";
			
		elsif (rising_edge(clk)) then
			case state is
				when idle	=>
					if (s_cntr_end = '1') then
						state	<= rx_dataa;
						--dataa	<= '1';
					else
						state	<= idle;
						--dataa	<= '0';
					end if;
						
				when rx_dataa	=>
					if (rd = '0') then
						state	<= rx_sync;
						--dataa	<= '0';
						odata	<= obuf;
					else
						state	<= rx_dataa;
					end if;
										
				when rx_sync	=>
					if (s_cntr_end = '0') then	-- Rx started again...
						state	<= idle;
						--dataa	<= '0';
					else
						state	<= rx_sync;
					end if;
				
				when others		=>
					--dataa	<= '0';
					state	<= idle;

			end case;
		end if;
	end process;
	
	-- RX Read FSM *NON BUFFERED* Outputs
	rxread_fsm_ops:
	process (state)
	begin
		case (state) is 
			when idle		=> 
				dataa	<= '0';

			when rx_dataa	=>
				dataa	<= '1';

			when rx_sync	=>
				dataa	<= '0';

			when others 	=>
				dataa	<= '0';

		end case;
	end process;

	-- Transfer FSM *NON BUFFERED* Outputs
	-- process (state)
	-- begin
		-- case state is 
			-- when idle		=> 
				-- i_load		<= '0';	-- parallel SR load strobe
				-- i_transfer	<= '0';	-- enable transfer pulse
				-- i_sclk		<= '0'; -- enable serial clock pulse
				-- i_cntr_en	<= '0';	-- counter enable			
				-- i_cntr_cl	<= '0';	-- counter synchronous clear
				-- i_dwait		<= '0';	-- dwait flag
				-- i_read		<= '0';	-- read issued flag
				-- i_rbuf		<= '0';	-- parallel read buffer strobe

			-- when transfer	=>
				-- i_load		<= '0';
				-- i_transfer	<= '0';
				-- i_sclk		<= '1';
				-- i_cntr_en	<= '0';
				-- i_cntr_cl	<= '0';
				-- i_dwait		<= '1';
				-- i_read		<= '0';
				-- i_rbuf		<= '0';

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
	
	-- dwait <= i_dwait;
	

--***************************************************************************************************************
	
	-- Serial Engine

	rx_shift_register:
	process (sclk, rst)      
	begin
	if (rst = '1') then
		rxtmp <= (others => '0');
		
	elsif (rising_edge(sclk)) then          

		rxtmp	<= rxtmp(6 downto 0) & mosi;          
	
	end if;
	end process;    

	rx_buffering:
	process (sclk, rst, cntr_end)      
	begin
	if (rst = '1') then
		obuf		<= x"00";
		r_cntr_end	<= '0';
		--r_cntr_zro	<= '1';
		
	elsif (falling_edge(sclk)) then          
		if (cntr_end = '1') then
			obuf	<= rxtmp;
		end if;
		
		r_cntr_end	<= cntr_end;
		--r_cntr_zro	<= cntr_zro;
		
	end if;
	end process;    
	
	tx_shift_register:
	process (sclk, rst, t_cntr, txstate)      
	begin
	if (rst = '1') then
		txtmp <= x"AA"; --(others => '0');
		txload	<= '0';
		
	elsif (rising_edge(sclk)) then          
	
		if (txstate = tx_load) then
			txtmp	<= ibuf;
			txload	<= '1';
		elsif (t_cntr = x"0") then
			txtmp	<= x"AA";
			txload	<= '0';			
		else
			txtmp	<= txtmp(6 downto 0) & '0'; --mosi;          
			txload	<= '0';			
		end if;        
	
	end if;
	end process;    

	miso	<= txtmp(7);
	
--***************************************************************************************************************

	-- Transfer Counter
	transfer_counter:
	process(sclk, rst)
	begin
	if (rst = '1') then
		t_cntr <= x"0";
	elsif (falling_edge(sclk)) then
		if (cntr_end = '1') then
			t_cntr <= x"0";
		else
			t_cntr <= t_cntr + 1;
--		else
--			t_cntr <= t_cntr;
		end if;
	end if;
	end process;	 

	-- Counter Tests
	counter_seven:
	process(t_cntr)
	begin
		if (t_cntr = x"7") then
			cntr_end <= '1';
		else
			cntr_end <= '0';
		end if;
		
	end process;

	-- counter_zero:
	-- process(t_cntr)
	-- begin
		-- if (t_cntr = x"0") then
			-- cntr_zro <= '1';
		-- else
			-- cntr_zro <= '0';
		-- end if;		
	-- end process;
	
--***************************************************************************************************************

	--Parallel Output Buffering
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