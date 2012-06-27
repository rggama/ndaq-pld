--
--

library ieee;
use ieee.std_logic_1164.all;
use work.core_regs.all;
use ieee.numeric_std.all;

entity core_cmddec is

	port
	(
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if

		-- Arbiter interface
		signal enable			: in	std_logic; -- arbiter if
		signal isidle			: out	std_logic; -- arbiter if

		--flags
		signal dwait			: in	std_logic;
		signal dataa			: in	std_logic;

		-- FT245BM_if strobes
		signal wr				: out 	std_logic := '1';
		signal rd				: out 	std_logic := '1';

		-- FT245BM_if local bus
		signal idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out	std_logic_vector(7 downto 0);
		
		--register's strobes
		signal reg_wr			: out	std_logic_vector((num_regs-1) downto 0);
		signal reg_rd			: out	std_logic_vector((num_regs-1) downto 0);
		
		--register's i/os
		signal reg_idata		: in	std_logic_vector(7 downto 0);
		signal reg_odata		: out	std_logic_vector(7 downto 0)		
	);

end entity;

architecture rtl of core_cmddec is

	-- Constants
	
	constant WRITE_CMD	:	std_logic_vector(7 downto 0) := x"AA";
	constant READ_CMD	:	std_logic_vector(7 downto 0) := x"2A";

	constant PH1_TOKEN	:	std_logic_vector(3 downto 0) := x"A";
	constant PH2_TOKEN	:	std_logic_vector(3 downto 0) := x"5";


	-- Components

	-- Synchronous Word Copier
	component swc
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in	std_logic; -- async if
		
		--flags
		signal dwait			: in	std_logic;
		signal dataa			: in	std_logic;

		--strobes
		signal wr				: out 	std_logic := '1';
		signal rd				: out 	std_logic := '1'
	);
	end component;

	-- Opendrain
	component opndrn
    port 
    (
		a_in : in std_logic;
		a_out : out std_logic 
    );
	end component;
	

	-- FSMs

	-- Command Decoder finite state machine
	type cmddec_st_type		is (idle, get_cmd, addr, data, access_reg, read_wait); 
	--type cmddec_st_type		is (idle, get_cmd, addr_ph1, addr_ph2, data_ph1, data_ph2, access_reg, read_wait); 

	-- Response finite state machine
	type response_st_type	is (idle, write_resp, read_resp, read_wait, latch_data, write_st); 

	-- Command Decoder FSM's Registers to hold the current state
	signal cmddec_st	: cmddec_st_type := idle;

	-- Response FSM's Registers to hold the current state
	signal response_st	: response_st_type := idle;
	
	-- FSM attributes
	attribute syn_encoding : string;
	
	-- Command Decoder FSM
	attribute syn_encoding of cmddec_st_type : type is "safe, one-hot";
	
	-- Response FSM
	attribute syn_encoding of response_st_type : type is "safe, one-hot";
	

	-- Signals
	
	signal cmd_wr		: std_logic := '1';	-- Active Low
	signal cmd_dwait	: std_logic := '0';
	
	signal rw_flag		: std_logic := '0';
	signal response_wr	: std_logic := '0';
	signal response_rd	: std_logic	:= '0';

	signal cmd_tmp		: std_logic_vector(7 downto 0) := x"00";
	signal addr_reg		: std_logic_vector(7 downto 0) := x"00";
	signal addr_stb		: std_logic_vector((num_regs-1) downto 0);
	signal i_reg_wr		: std_logic_vector((num_regs-1) downto 0);
	signal i_reg_rd		: std_logic_vector((num_regs-1) downto 0);
	signal data_reg		: std_logic_vector(7 downto 0) := x"00";
	
	signal wr_stb		: std_logic := '0';
	signal rd_stb		: std_logic := '0';
	
	signal tmp			: std_logic_vector(7 downto 0) := x"00";

	signal i_wr			: std_logic := '1';
	
begin

--*****************************************************************************

	ft245bm_to_cmddec_writer:
	swc port map
	(	
		clk				=> clk,
		rst				=> rst,
		
		--flags
		dwait			=> cmd_dwait,	--to
		dataa			=> dataa,		--from

		--strobes
		wr				=> cmd_wr,		--to
		rd				=> rd			--from
	);

--*****************************************************************************

command_decoder_fsm: 
process(rst, clk)
begin
	if (rst = '1') then
		cmddec_st	<= idle;
		--
		cmd_tmp		<= x"00";
		rw_flag		<= '0';
		--
		addr_reg	<= x"00";
		data_reg	<= x"00";
		
	elsif (rising_edge(clk)) then
		case (cmddec_st) is
		
			when idle	=>	
				if (cmd_wr = '0') then
					cmddec_st	<= get_cmd;
					--
					cmd_tmp		<= idata;		-- Latching written data.
					
				else
					cmddec_st	<= idle;

				end if;
				
			when get_cmd	=>
				if (cmd_tmp = WRITE_CMD) then
					rw_flag	<= '1';				-- rw_flag is '1' for WRITE
					--
					if (cmd_wr = '0') then
						cmddec_st	<= addr; --addr_ph1;
						--
						cmd_tmp		<= idata;
					else
						cmddec_st	<= get_cmd;
					end if;
				
				elsif (cmd_tmp = READ_CMD) then
					rw_flag	<= '0';				-- rw_flag is '0' for READ
					--
					if (cmd_wr = '0') then
						cmddec_st	<= addr; --addr_ph1;
						--
						cmd_tmp		<= idata;
					else
						cmddec_st	<= get_cmd;
					end if;
					
				else
					cmddec_st	<= idle;
				end if;
								
			-- when addr_ph1	=>
				-- if (cmd_tmp(7 downto 4) = PH1_TOKEN) then
					
					-- addr_reg(3 downto 0)	<= cmd_tmp(3 downto 0);		-- addr ls nibble.
					-- --
					-- if (cmd_wr = '0') then
						-- cmddec_st	<= addr_ph2;
						-- --
						-- cmd_tmp		<= idata;
					-- else
						-- cmddec_st	<= addr_ph1;
					-- end if;

				-- else
					-- cmddec_st	<= idle;
				-- end if;

			--when addr_ph2	=>
			when addr	=>
				--if (cmd_tmp(7 downto 4) = PH2_TOKEN) then
					
					addr_reg	<= cmd_tmp;		-- addr.
					--addr_reg(7 downto 4)	<= cmd_tmp(3 downto 0);		-- addr ms nibble.
					--
					if (rw_flag = '1') then								-- If write, branch to 'access reg'.
						if (cmd_wr = '0') then
						
							cmddec_st	<= data; --data_ph1;
							--
							cmd_tmp		<= idata;
						else
							cmddec_st	<= addr; --addr_ph2;
						end if;
					
					else
						cmddec_st	<= access_reg;
					end if;
					
				--else
					--cmddec_st	<= idle;
				--end if;

			-- when data_ph1	=>
				-- if (cmd_tmp(7 downto 4) = PH1_TOKEN) then
					
					-- data_reg(3 downto 0)	<= cmd_tmp(3 downto 0);		-- data ls nibble.
					-- --
					-- if (cmd_wr = '0') then
						-- cmddec_st	<= data_ph2;
						-- --
						-- cmd_tmp		<= idata;
					-- else
						-- cmddec_st	<= data_ph1;
					-- end if;

				-- else
					-- cmddec_st	<= idle;
				-- end if;

			-- This state CAN NOT receive data. Thus, 'dwait' must be '1'.
			--when data_ph2	=>
			when data	=>
				--if (cmd_tmp(7 downto 4) = PH2_TOKEN) then
					
					data_reg	<= cmd_tmp;		-- data.
					--data_reg(7 downto 4)	<= cmd_tmp(3 downto 0);		-- data ms nibble.
					--
					
					cmddec_st	<= access_reg;

				--else
					--cmddec_st	<= idle;
				--end if;

			-- This state CAN NOT receive data. Thus, 'dwait' must be '1'.
			when access_reg	=>
				if (rw_flag = '1') then
					cmddec_st	<= idle;
				else
					cmddec_st	<= read_wait;	-- Read must be performed in 2 cycles.
				end if;
				
			when read_wait	=>
				cmddec_st	<= idle;
				
			when others		=>
				cmddec_st	<= idle;

		end case;	
	end if;
end process command_decoder_fsm;

cmddec_fsm_ops:
process (cmddec_st, rw_flag)
begin
	case (cmddec_st) is
		-- when idle			=>		
		-- when get_cmd			=>
		-- when addr_ph1		=>
		-- when data_ph1		=>

		--when addr_ph2		=>		
		when addr		=>		
			if (rw_flag = '0') then		-- If read, stop accepting data.
				cmd_dwait	<= '1';
			else
				cmd_dwait	<= '0';
			end if;

			wr_stb		<= '0';
			rd_stb		<= '0';
			response_wr	<= '0';
			response_rd	<= '0';
			
		--when data_ph2	=>
		when data		=>
			cmd_dwait	<= '1';
			wr_stb		<= '0';
			rd_stb		<= '0';
			response_wr	<= '0';
			response_rd	<= '0';
			
		when access_reg	=>
			cmd_dwait	<= '1';

			if (rw_flag = '1') then
				wr_stb		<= '1';
				rd_stb		<= '0';
				--
				response_wr	<= '1';
				response_rd	<= '0';
				
			else
				wr_stb		<= '0';
				rd_stb		<= '1';			
				--
				response_wr	<= '0';
				response_rd	<= '1';
			end if;
		
		when read_wait	=>
			cmd_dwait	<= '1';

			if (rw_flag = '1') then
				wr_stb		<= '1';
				rd_stb		<= '0';
				--
				response_wr	<= '1';
				response_rd	<= '0';
				
			else
				wr_stb		<= '0';
				rd_stb		<= '1';			
				--
				response_wr	<= '0';
				response_rd	<= '1';
			end if;

		when others		=>
			cmd_dwait	<= '0';
			wr_stb		<= '0';
			rd_stb		<= '0';
			response_wr	<= '0';
			response_rd	<= '0';
			
	end case;
end process;

--*****************************************************************************
	
addr_decoder:
for i in 0 to (num_regs - 1) generate
	
	addr_stb(i)	<= '1' when	(addr_reg = system_regs_enum(i).addr) else '0';
	i_reg_wr(i)	<= '1' when ((addr_stb(i) = '1') and (wr_stb = '1')) else '0';
	i_reg_rd(i)	<= '1' when ((addr_stb(i) = '1') and (rd_stb = '1')) else '0';
		
	stbs_op_regs:
	process (clk, rst)
	begin
		if (rst = '1') then
			reg_wr(i)	<= '0';
			reg_rd(i)	<= '0';
		elsif (rising_edge(clk)) then
			reg_wr(i)	<= i_reg_wr(i);
			reg_rd(i)	<= i_reg_rd(i);
		end if;
	end process;
	
end generate addr_decoder;
		
--*****************************************************************************

reg_data_output:
process(rst, clk)
begin
	if (rst = '1') then
		reg_odata	<= x"00";
	
	elsif (rising_edge(clk)) then
		
		if (wr_stb = '1') then
			reg_odata	<= data_reg;
		end if;

	end if;
end process;

--*****************************************************************************

response_fsm:
process(rst, clk)
begin
	if (rst = '1') then
		response_st	<= idle;
		--
		i_wr	<= '1';				
		--
		odata	<= (others => 'Z'); --x"00";
		--
		tmp		<= x"00";
		--
		isidle		<= '1';
		
	elsif (rising_edge(clk)) then
		case (response_st) is
		
			when idle	=>	
				if (response_wr = '1') then
					response_st	<= write_resp;

				elsif (response_rd = '1') then
					response_st	<= read_resp;
				
				else
					response_st	<= idle;
				end if;
				
			when write_resp	=>
				if ((enable = '1') and (dwait = '0')) then
					response_st	<= write_st;
					--
					i_wr		<= '0';				
					--
					odata	<= x"EB";
					--
					isidle		<= '0';
				else
					response_st	<= write_resp;
				end if;

			when read_resp	=>
				response_st	<= read_wait; --latch_data;
				--
				--tmp			<= reg_idata;
				
			when read_wait	=>
				response_st	<= latch_data;
				--
				tmp			<= reg_idata;
				
			when latch_data	=>
				if ((enable = '1') and (dwait = '0')) then
					response_st	<= write_st;
					--
					i_wr		<= '0';				
					--
					odata	<= tmp;
					--
					isidle		<= '0';
				else
					response_st	<= latch_data;
				end if;

			when write_st	=>
				response_st	<= idle;
				--
				i_wr		<= '1';				
				--
				odata	<= (others => 'Z');
				--
				isidle		<= '1';
				
			when others	=>
				response_st	<= idle;

		end case;	
	end if;
end process response_fsm;

--*****************************************************************************

    open_drain:
	opndrn port map 
    (
		a_in	=>	i_wr,
		a_out =>	wr
    );

end rtl;
