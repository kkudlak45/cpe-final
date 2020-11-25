-- Control Unit
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity cu is
	port (
		-- Op code for instructions
		OpCode : in std_logic_vector(2 downto 0);
		
		-- Clock signal
		clk : in std_logic;
		
		-- Load bits to turn components on and off
		ToALoad : out std_logic;
		ToMarLoad : out std_logic;
		ToIrLoad : out std_logic;
		ToMdriLoad : out std_logic;
		ToMdroLoad : out std_logic;
		ToPcIncrement : out std_logic :=  '0';
		ToMarMux : out std_logic;
		ToRamWriteEnable : out std_logic;
		
		-- ALU Op Code
		ToAluOp : out std_logic_vector(2 downto 0)
	);
end;

architecture behavior of cu is
	-- custom data type to define states
	type cu_state_type is (
		load_mar,
		read_mem,
		load_mdri, 
		load_ir, 
		decode,
		
		-- load states
		ldaa_load_mar,
		ldaa_read_mem,
		ldaa_load_mdri,
		ldaa_load_a,
		
		-- add states
		adaa_load_mar,
		adaa_read_mem,
		adaa_load_mdri,
		adaa_store_load_a,
		
		-- store states
		staa_load_mdro,
		staa_load_mar,
		staa_write_mem,
		
		increment_pc
	);
	
	-- signal to hold current state
	signal current_state : cu_state_type;

begin
	-- Defines the transitions in our state machine
	process (clk)
	begin
		if (clk'event and clk='1') then
			case current_state is
				--increment pc and fetch instruction, then load the ir with the fetched instruction
				-- decode the instruction, use the diagram in the handout to determine the next states
				when increment_pc =>
					current_state <= load_mar;
				when load_mar =>
					current_state <= read_mem;
				when read_mem =>
					current_state <= load_mdri;
				when load_mdri =>
					current_state <= load_ir;
				when load_ir =>
					current_state <= decode;
					
					
				-- decode opcode to determine instruction
				-- assign current state based on the opcode
				when decode => 
					if (OpCode = "000") then
						current_state <= ldaa_load_mar;
					elsif (OpCode = "001") then
						current_state <= adaa_load_mar;
					elsif (OpCode = "010") then
						current_state <= staa_load_mdro;
					end if;
					-- instructions, need to determine the next state to implement each instruction
					-- follow the path to perform each instruction as described in the handout and determine
					-- where the state machine needs to go to implement the instruction
					
					-- Load instruction
				when ldaa_load_mar =>
					current_state <= ldaa_read_mem;
				when ldaa_read_mem =>
					current_state <= ldaa_load_mdri;
				when ldaa_load_mdri =>
					current_state <= ldaa_load_a;
				when ldaa_load_a =>
					current_state <= increment_pc;
					
				-- add instruction
				when adaa_load_mar =>
					current_state <= adaa_read_mem;
				when adaa_read_mem =>
					current_state <= adaa_load_mdri;
				when adaa_load_mdri =>
					current_state <= adaa_store_load_a;
				when adaa_store_load_a =>
					current_state <= increment_pc;
					
				-- store instruction
				when staa_load_mdro =>
					current_state <= staa_load_mar;
				when staa_load_mar =>
					current_state <= staa_write_mem;
				when staa_write_mem =>
					current_state <= increment_pc;
						
			end case;
		end if;
	end process;

-- defines what happens at each state, set to '1' if we want that component to be on
-- set op code accordingly based on alu, different from instruction op code, look at the actual alu code
-- keep in mind when tomarmux = 0, mar is loaded from pc address, when tomarmux=1, mar is loaded with ir address

process (current_state)
begin
	ToALoad <= '0';
	ToMdroLoad <= '0';
	ToAluOp <= "000";
	
	case current_state is
		-- turns on the increment pc bit
		when increment_pc =>
			ToALoad <= '0';
			ToPcIncrement <= '1';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- Loads MAR with address from pc
		when load_mar =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0'; -- read from pc
			ToMarLoad <= '1'; -- load in whatever's in the  mux
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- Reads address located in MAR
		when read_mem =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0'; -- we are reading
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- Load memory data register input
		when load_mdri =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '1'; -- loads mdri with what is being read from memory
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
		
		-- Loads the instruction register with instruction fetched from memory
		when load_ir =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '1'; -- loads ir with contents of mdri
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- decodes the  current instruction (everything should be off for this)
		when decode =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- Loads the mar with address stored in ir
		when ldaa_load_mar =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '1'; -- read from ir
			ToMarLoad <= '1'; -- store in mar
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- reads data in memory retrieved from address in mar
		when ldaa_read_mem =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0'; -- reading
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- loads the memory data register input with data read from memory
		when ldaa_load_mdri =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '1'; -- load mdri with what is being read
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- Loads the accumulator with the data held in MDRI
		when ldaa_load_a =>
			ToALoad <= '1'; -- loads accumulator
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "101"; -- op code for "return A" (A is the mdri input), we have to go through alu to get to accumulator
		
		-- Loads the mar with address held in ir
		when adaa_load_mar =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '1'; -- set mux to look at the ir
			ToMarLoad <= '1'; -- load in the data
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- reads memory based on address in MAR
		when adaa_read_mem =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0'; -- reading
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
		-- loads mdri with data just read from memory
		when adaa_load_mdri => 
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '1'; -- bit to load mdri
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
		
		-- loads accumulator with data in mdri
		when adaa_store_load_a =>
			ToALoad <= '1'; -- load accumulator with A + B
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000"; -- code for adding
			
		
		-- loads mdro with data to be written to memory (this data comes from the accumulator)
		when staa_load_mdro =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '1'; -- bit to load mdro
			ToAluOp <= "000";
		
		-- get the address to store data in
		when staa_load_mar =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '1'; -- pull from instruction register
			ToMarLoad <= '1'; -- load into mar
			ToRamWriteEnable <= '0';
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
		
		-- writes to memory the data stored in mdro at address from mar
		when staa_write_mem =>
			ToALoad <= '0';
			ToPcIncrement <= '0';
			ToMarMux <= '0';
			ToMarLoad <= '0';
			ToRamWriteEnable <= '1'; -- hey look, we're writing this time
			ToMdriLoad <= '0';
			ToIrLoad <= '0';
			ToMdroLoad <= '0';
			ToAluOp <= "000";
			
	end case;

end process;

end behavior;
		
		
	
		
					
	
	
	
	
	
	
	