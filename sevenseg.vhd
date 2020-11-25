-- seven segment display, output is 8 bits to match
-- the cpu component outputs, when connecting the pins, ignore the msb of o or o(7)

library ieee;
use ieee.std_logic_1164.all;

entity sevenseg is
	port(
		i : in std_logic_vector(3 downto 0);
		o : out std_logic_vector(0 to 7)
	);
end sevenseg;

architecture logic of sevenseg is
begin  
	o <=  "00000001" when i="0000" else
			"01001111" when i="0001" else
			"00010010" when i="0010" else
			"00000110" when i="0011" else
			"01001100" when i="0100" else
			"00100100" when i="0101" else
			"00100000" when i="0110" else
			"00001111" when i="0111" else
			"00000000" when i="1000" else
			"00000100" when i="1001" else
			"00001000" when i="1010" else
			"01100000" when i="1011" else
			"00110001" when i="1100" else
			"01000010" when i="1101" else
			"00110000" when i="1110" else
			"00111000" when i="1111";
end;