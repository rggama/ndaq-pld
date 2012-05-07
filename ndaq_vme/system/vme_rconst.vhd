--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vme_regs.all;

entity vme_rconst is

	port
	(
		signal clk				: in 	std_logic; -- sync if
		signal rst				: in 	std_logic; -- async if
		
		--register/peripherals's multi access input strobes
		signal a_wr				: in	std_logic_vector((num_regs-1) downto 0);
		signal a_rd				: in	std_logic_vector((num_regs-1) downto 0);

		signal b_wr				: in	std_logic_vector((num_regs-1) downto 0);
		signal b_rd				: in	std_logic_vector((num_regs-1) downto 0);

		--common i/o
		signal a_idata			: in	std_logic_vector(7 downto 0);
		signal b_idata			: in	std_logic_vector(7 downto 0);
		signal odata			: out	std_logic_vector(7 downto 0);

		--register's individual i/os
		signal ireg				: in	SYS_REGS;
		signal oreg				: out	SYS_REGS;

		--peripherals outputs strobes
		signal p_wr				: out	std_logic_vector((num_regs-1) downto 0);
		signal p_rd				: out	std_logic_vector((num_regs-1) downto 0)
	);

end entity;

architecture rtl of vme_rconst is

	signal		regs	:	SYS_REGS;
	signal 		locked	:	std_logic_vector((num_regs-1) downto 0);


begin
	
	regs_construct:
	for i in 0 to (num_regs - 1) generate

		test_register:
		if (system_regs_enum(i).peripheral = false) generate	
															
			r_test_writable:
			if (system_regs_enum(i).writable = true) generate

				regs_hold_ffs:
				process(clk, rst)							
				begin
					if (rst = '1') then
						regs(i)		<= system_regs_enum(i).rstate;
						locked(i)	<= '0';
						
					elsif(rising_edge(clk)) then
						if ((a_wr(i) = '1') and (locked(i) = '0')) then	-- 'locked' ensures one write per rising edge of 'a_wr'.
							regs(i)		<= a_idata;
							locked(i)	<= '1';
						elsif ((b_wr(i) = '1') and (locked(i) = '0')) then	-- 'locked' ensures one write per rising edge of 'a_wr'.
							regs(i)		<= b_idata;
							locked(i)	<= '1';
						elsif ((a_wr(i) = '0') and (b_wr(i) = '0')) then
							locked(i)	<= '0';
						end if;

					end if;
				end process;
			end generate r_test_writable;
			
			r_test_readable:
			if (system_regs_enum(i).readable = true) generate

				regs_tri_st_ops:
				process(a_rd(i), b_rd(i), regs(i))
				begin
					if ((a_rd(i) xor b_rd(i)) = '1') then
						odata	<= regs(i);
					else
						odata	<= (others => 'Z');
					end if;
				end process;
			end generate r_test_readable;
			
			register_output:
			oreg(i)	<= regs(i);
			
		end generate test_register;
	end generate regs_construct;

	peripheral_construct:
	for i in 0 to (num_regs - 1) generate

		test_peripheral:
		if (system_regs_enum(i).peripheral = true) generate	
															
			p_test_writable:
			if (system_regs_enum(i).writable = true) generate
				
				input_to_peripheral:
				oreg(i)	<= a_idata when (a_wr(i) = '1') else b_idata;
				
				wr_stb_to_periph:
				p_wr(i)	<= a_wr(i) xnor b_wr(i);	--periphereal's wr strobe is inverted
				
			end generate p_test_writable;
			
			p_test_readable:
			if (system_regs_enum(i).readable = true) generate

				rd_stb_to_periph:
				p_rd(i)	<= a_wr(i) xnor b_wr(i);	--peripheral's rd strobe is inverted
				
				periph_tri_st_ops:
				process(a_rd(i), b_rd(i), ireg(i))
				begin
					if ((a_rd(i) xor b_rd(i)) = '1') then
						odata	<= ireg(i);
					else
						odata	<= (others => 'Z');
					end if;
				end process;
			end generate p_test_readable;
						
		end generate test_peripheral;
	end generate peripheral_construct;
	
	
end rtl;
