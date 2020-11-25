-- program counter code
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Increments the program counter by 1 if there is a positive edge clock and increment = 1

entity pc is
port (
	output    : out std_logic_vector(7 downto 0);
	clk       : in std_logic;
	increment : in std_logic
);
end;

architecture behavior of pc is
begin

	process(clk, increment)
		variable counter : integer := 0;
	begin
		-- check for positive edge trigger & if incrememnt is true
		if (clk'event and clk='1' and increment ='1') then
			counter := counter + 1;
			output <= conv_std_logic_vector(counter, 8);
		end if; 
	end process;
	
end behavior;
