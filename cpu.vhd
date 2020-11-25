-- cpu, top level entity
library ieee;
use ieee.std_logic_1164.all;

entity cpu is 
	-- these are the outputs that can be displayed on the fpga
	-- more port statements may be necessary depending how each signal is displayed
	port(
		clk          : in std_logic;
		pcOut        : out std_logic_vector(7 downto 0);
		marOut       : out std_logic_vector(7 downto 0);
		irOutput     : out std_logic_vector(7 downto 0);
		mdriOutput   : out std_logic_vector(7 downto 0);
		mdroOutput   : out std_logic_vector(7 downto 0);
		aOut         : out std_logic_vector(7 downto 0);
		incrementOut : out std_logic
	);
end;

architecture behavior of cpu is

	-- initialize memory component
	component memory
	port(
		clk : in std_logic;
		write_enable : in std_logic;
		read_addr : in std_logic_vector(4 downto 0);
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7  downto 0)
	);
	end component;
	
	-- initialize the alu
	component alu
	port(
		A : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		AluOp : in std_logic_vector(2 downto 0);
		output : out std_logic_vector(7 downto 0)
	);
	end component;
	
	-- initialize the registers
	component reg
	port(
		input : in std_logic_vector(7 downto 0);
		output: out std_logic_vector(7 downto 0);
		clk : in std_logic;
		load : in std_logic
	);
	end component;
	
	-- initialize the program counter
	component pc 
	port(
		increment : in std_logic;
		clk : in std_logic;
		output : out std_logic_vector(7 downto 0)
	);
	end component;
	
	-- initialize the mux
	component TwoToOneMux
	port(
		A : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		address : in std_logic;
		output : out std_logic_vector(7 downto 0)
	);
	end component;
	
	-- initialize the seven segment decoder
	component sevenseg
	port(
		i : in std_logic_vector(3 downto 0);
		o : out std_logic_vector(0 to 7)
	);
	end component;
	
	component cu is
	port (
		OpCode : in std_logic_vector(2 downto 0);
		clk : in std_logic;
		ToALoad : out std_logic;
		ToMarLoad : out std_logic;
		ToIrLoad : out std_logic;
		ToMdriLoad : out std_logic;
		ToMdroLoad : out std_logic;
		ToPcIncrement : out std_logic;
		ToMarMux : out std_logic;
		ToRamWriteEnable : out std_logic;
		ToAluOp : out std_logic_vector(2 downto 0)
	);
	end component;
	
	
	-- the following signals will be used in your port map statements, don't use the port variables in your port maps
	
	-- connections : need to be sorted
	signal ramDataOutToMdri : std_logic_vector(7 downto 0);
	
	-- MAR multiplexer connections
	signal pcToMarMux : std_logic_vector(7 downto 0);
	signal muxToMar : std_logic_vector(7 downto 0);
	
	-- RAM connections
	signal marToRamReadAddr : std_logic_vector(4 downto 0);
	signal mdroToRamDataIn : std_logic_vector(7 downto 0);
	
	-- MDRI connections
	signal mdriOut : std_logic_vector(7 downto 0);
	
	-- IR connection
	signal irOut : std_logic_vector(7 downto 0);
	
	-- ALU / Accumulator connections
	signal aluOut : std_logic_vector(7 downto 0);
	signal aToAluB : std_logic_vector(7 downto 0);
	
	-- Control Unit Connections
	signal cuToALoad : std_logic;
	signal cuToMarLoad : std_logic;
	signal cuToIrLoad : std_logic;
	signal cuToMdriLoad : std_logic;
	signal cuToMdroLoad : std_logic;
	signal cuToPcIncrement : std_logic;
	signal cuToMarMux : std_logic;
	signal cuToRamWriteEnable : std_logic;
	signal cuToAluOp : std_logic_vector(2 downto 0);
	
begin
	
	-- port map statements go here
	-- create port map statements for each component in the cpu and map them to teh appropriate signal defined above
	
	-- RAM
	RAM : memory port map 
				(
					clk          => clk, 
					write_enable => cuToRamWriteEnable, 
					read_addr    => marToRamReadAddr, 
					data_in      => mdroToRamDataIn, 
					data_out     => ramDataOutToMdri
				);
	
	-- Accumulator
	ACC : reg    port map 
				(
					clk          => clk, 
					input        => aluOut, 
					output       => aToAluB, 
					load         => cuToALoad
				);
	
	-- ALU
	ALUX: alu    port map 
				(
					A            => mdriOut, 
					B            => aToAluB, 
					AluOp        => cuToAluOp, 
					output       => aluOut
				);
	
	-- Program Counter
	PCX : pc     port map 
				(
					clk          => clk, 
					increment    => cuToPcIncrement, 
					output       => pcToMarMux
				);
	
	-- Instruction Register
	IR  : reg    port map 
				(
					clk          => clk, 
					input        => mdriOut, 
					output       => irOut, 
					load         => cuToIrLoad
				);
	
	-- MAR mux
	MUX : TwoToOneMux port map 
				(
					A            => pcToMarMux, 
					B            => irOut, 
					address      => cuToMarMux, 
					output       => muxToMar
				);
	
	-- Memory Access Register
	MAR : reg    port map 
				(
					clk          => clk, 
					input        => muxToMar, 
					output(4)    => marToRamReadAddr(4), 
					output(3)    => marToRamReadAddr(3), 
					output(2)    => marToRamReadAddr(2), 
					output(1)    => marToRamReadAddr(1), 
					output(0)    => marToRamReadAddr(0), 
					load         => cuToMarLoad
				);
	
	-- Memory Data Register Input
	MDRI: reg    port map 
				(
					clk          => clk, 
					input        => ramDataOutToMdri, 
					output       => mdriOut, 
					load         => cuToMdriLoad
				);
	
	-- Memory Data Register Output
	MDRO: reg    port map 
				(
					clk          => clk, 
					input        => aToAluB, 
					output       => mdroToRamDataIn, 
					load         => cuToMdroLoad
				);
	
	-- Control Unit
	CUx : cu    port map 
				(
					OpCode(2)        => irOut(7),
					OpCode(1)        => irOut(6),
					OpCode(0)        => irOut(5),	
					clk              => clk, 
					ToALoad          => cuToALoad, 
					ToMarLoad        => cuToMarLoad,
					ToIrLoad         => cuToIrLoad, 
					ToMdriLoad       => cuToMdriLoad,
					ToMdroLoad       => cuToMdroLoad, 
					ToPcIncrement    => cuToPcIncrement,
					ToMarMux         => cuToMarMux, 
					ToRamWriteEnable => cuToRamWriteEnable,
					ToAluOp          => cuToAluOp
				);
	
	-- REMAINING CODE GOES ERE
	-- here is where you connect the port statement to the matching signal to display it on the fpga
	-- if you want to display the signal on leds, just set it to teh port statement port<=signal
	-- if you want to send the signal to the seven segment display, initialize an instance ofthe sevenseg
	-- then map i=>signal, o=>port, keep in mind i needs to be 4 bits and o 8 bits
	-- pcOut <= pcToMarMux;
	
	pcOut        <= pcToMarMux;
	marOut       <= "000"&marToRamReadAddr;
	irOutput     <= irOut;
	mdriOutput   <= mdriOut;
	mdroOutput   <= mdroToRamDataIn;
	aOut         <= aToAluB;
	incrementOut <= cuToPcIncrement;
	
end behavior;
	
	
	
	
	
	
	
	
	
	
	
	