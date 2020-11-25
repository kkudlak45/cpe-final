-- mux used to create a shared connection between pc and ir to the mar
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity TwoToOneMux is
	port(
		A : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		address : in std_logic;
		output : out std_logic_vector(7 downto 0)
	);
end;

architecture behavior of TwoToOneMux is
begin
	process(A, B, address)
	begin
		if (address='0') then
			output <= A;
		elsif (address='1') then
			output  <= B;
		end if;
	end process;
end behavior;