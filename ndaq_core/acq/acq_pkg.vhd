-- $ ACQ Package - ACQ definitions
-- v: svn controlled.
--
--

library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).

use work.functions_pkg.all;


package acq_pkg is

	--Quantidade de canais de ADC
	constant adc_channels				: integer	:= 8;
	
	
	--Tamanho da palavra do ADC em bits
	--*** ALTERAR ESTE VALOR CAUSARA PROBLEMAS NO COMPONENTE 'idt_writer' ***
	constant data_width					: integer	:= 10;		


	-- Freq.
	constant freq_width					: integer	:= 32;
	
	--usedw_width = (log(2) W) + 1, onde W e o tamanho maximo da POST FIFO
	--ou quantos bits sao necessarios para representar o valor maximo de 
	--palavras na POST FIFO. Ex: Se o max da POST FIFO = 1024 palavras
	--serao necessarios 11 bits. Repare: e necessario representar o valor e 
	--nao somente o intervalo, que no caso do exemplo seria satisfeito com
	--10 bits.
	constant	usedw_width				: integer	:= 11;		


	-- MAX de palavras na POST FIFO																		
	constant	FIFO_MAX				: natural	:= (2**(usedw_width-1));	
	
																		
	--Evento = 512 palavras, 4096 ns
	--EVENT_SIZE = (M - 1), onde M = tamanho do evento ou quantidade de palavras
	--que devem ser gravadas por 'trigger'. [EM PALAVRAS DE FIFO]
	constant	EVENT_SIZE				: unsigned	:= x"7F";	
																			
	constant 	t						: unsigned 	:= x"00";
	
	--Este valor deve ser o tamanho maximo da POST FIFO subtraido do tamanho	
	--do evento (parametro acima). Para POST FIFO (max) = 1024 e tamanho do 
	--evento = 128, este valor deveria ser 1024 - 128 = 896 em decimal e
	--0x380 em hexadecimal. Porem, um 'bug' me fez escolher o valor correto
	--subtraido de dois, para o exemplo: 0x37E. [EM PALAVRAS DE FIFO]																																					
	--constant	MAX_WORDS				: unsigned	:= ((FIFO_MAX - (EVENT_SIZE + 1)) - 2);
	constant	MAX_WORDS				: unsigned	:= x"380"; --(FIFO_MAX - t);
																			
	--MAX_WORDS e o maximo de palavras que a POST FIFO pode conter para que
	--um novo evento seja gravado. Ou seja, a POST FIFO deve ter espaco 
	--suficiente para guardar um evento completo.
		

	--Power para o ADC - '1' -> ADC LIGADO e '0' -> ADC DESLIGADO		
	constant 	ADC12_PWR				: std_logic	:= '1';		
	
	--Power para o ADC - '1' -> ADC LIGADO e '0' -> ADC DESLIGADO	
	constant 	ADC34_PWR				: std_logic	:= '1';		
	
	--Power para o ADC - '1' -> ADC LIGADO e '0' -> ADC DESLIGADO	
	
	constant	ADC56_PWR				: std_logic	:= '1';		
	
	--Power para o ADC - '1' -> ADC LIGADO e '0' -> ADC DESLIGADO
	constant 	ADC78_PWR				: std_logic	:= '1';		
	
																			
--*******************************************************************************************************************************

	constant	T_FALL					: signed	:= x"3F6"; --x"0A";	
	constant	T_RISE					: signed	:= x"3F6"; --x"0A";	

--*******************************************************************************************************************************

	--Data Types
	subtype	DATA_T						is std_logic_vector((data_width-1) downto 0);
	subtype	USEDW_T						is std_logic_vector((usedw_width-1) downto 0);
	subtype	FREQ_T						is std_logic_vector((freq_width-1) downto 0);

	type	F_DATA_WIDTH_T				is array ((adc_channels-1) downto 0) of DATA_T;
	type	F_USEDW_WIDTH_T				is array ((adc_channels-1) downto 0) of USEDW_T;
	type	FREQ_WIDTH_A				is array ((adc_channels-1) downto 0) of FREQ_T;
	
--*******************************************************************************************************************************

end package acq_pkg;


package body acq_pkg is
end package body acq_pkg;
