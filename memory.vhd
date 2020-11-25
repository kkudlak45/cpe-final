-- 8x32 memory array
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity memory is
	port(
		clk : in std_logic;
		Write_enable : in std_logic;
		read_addr : in std_logic_vector(4 downto 0);
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0)
	);
end memory;

architecture behavior of memory is
	type ram_type is array(0 to 31) of std_logic_vector(7 downto 0);
	
	--instructions / data go into memory here
	signal z : ram_type := (
		"00000101", "00100110", "01000111", "00000111",
		"00101000", "00001010", "00010100", "01010101",
		"00000001", "10110100", "10001010", "10101010",
		"10101001", "00000000", "10100101", "01010101",
		"10101110", "10110100", "10001010", "10101010",
		"10101001", "00000000", "10100101", "01010101",
		"10101110", "10110100", "10001010", "10101010",
		"10101001", "00000000", "10100101", "01010101"
	);
begin
	process(clk, read_addr, data_in, write_enable)
	begin
		-- read from memory
		if (clk'event and clk='1' and write_enable='0') then
			data_out <= z(conv_integer(read_addr));
		-- write to memory
		elsif (clk'event and clk='1' and write_enable='1') then
			z(conv_integer(read_addr)) <= data_in;
		end if;		
	end process;
end;