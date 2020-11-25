-- register component for cpu
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity reg is
	port(
		input : in std_logic_vector(7 downto 0);
		output : out std_logic_vector(7 downto 0);
		clk : in std_logic;
		load : in std_logic
	);
end;

architecture behavior of reg is
begin
	process(clk, load)
	begin
		if (clk'event and clk='1' and load='1') then
			output <= input;
		end if;
	end process;
end behavior;