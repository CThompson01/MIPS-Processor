library IEEE;
use IEEE.std_logic_1164.all;

entity controllogic is 
port(   opcode: in std_logic_vector(5 downto 0);
	functcode: in std_logic_vector(5 downto 0);
	ALUsrc: out std_logic;
	ALUcontrol: out std_logic_vector(5 downto 0);
	MemtoReg: out std_logic;
	Branch: out std_logic;
	Jump: out std_logic;
	MemWrite: out std_logic;
	RegWrite: out std_logic;
	RegDst: out std_logic;
	extendersel: out std_logic; 
	datasel: out std_logic; 
	btype: out std_logic); 
end controllogic;

architecture casestatement of controllogic is 

begin

P_case:process(opcode, functcode)
begin
case opcode is
	when "000000" =>
		case functcode is
			when "100000" => --ADD
				ALUsrc <= '0';
				ALUcontrol <= "000011";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "100001" => --ADDU
				ALUsrc <= '0';
				ALUcontrol <= "000011";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '1';
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "100100" => --AND 
				ALUsrc <= '0';
				ALUcontrol <= "101011";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';				
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "100111" => --NOR
				ALUsrc <= '0';
				ALUcontrol <= "110011";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "100110" => --XOR
				ALUsrc <= '0';
				ALUcontrol <= "110111";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "100101" => --OR
				ALUsrc <= '0';
				ALUcontrol <= "101111";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "101010" => --SLT
				ALUsrc <= '0';
				ALUcontrol <= "100111";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "000000" => --SLL
				ALUsrc <= '0';
				ALUcontrol <= "111001";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "000010" => --SRL
				ALUsrc <= '0';
				ALUcontrol <= "111000";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "000011" => --SRA
				ALUsrc <= '0';
				ALUcontrol <= "111010";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <='0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "100010" => --SUB
				ALUsrc <= '0';
				ALUcontrol <= "100011";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when "100011" => --SUBU
				ALUsrc <= '0';
				ALUcontrol <= "100011";
				MemtoReg <= '0';
				Branch <= '0';
				Jump <= '0';
				MemWrite <= '0';
				RegWrite <= '1';
				RegDst <= '0';	
				extendersel <= '0';
				datasel <= '0';
				btype <= '0';
			when others =>
				
		end case;
	
	when "001000" => --ADDI
		ALUsrc <= '1';
		ALUcontrol <= "000011";
		MemtoReg <= '0';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '1';
		extendersel <= '1';
		datasel <= '0';
		btype <= '0';
	when "001001" => --ADDIU
		ALUsrc <= '1';
		ALUcontrol <= "000011";
		MemtoReg <= '0';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '1';
		extendersel <= '1';
		datasel <= '0';
		btype <= '0';
	when "001100" => --ANDI
		ALUsrc <= '1';
		ALUcontrol <= "101011";
		MemtoReg <= '0';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '1';	
		extendersel <= '1';
		datasel <= '0';
		btype <= '0';
	when "001111" => --LUI		
		ALUsrc <= '1';
		ALUcontrol <= "011111";
		MemtoReg <= '1';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '0';
		extendersel <= '0';
		datasel <= '0';
		btype <= '0';
	when "100011" => --LW
		ALUsrc <= '1';
		ALUcontrol <= "000011";
		MemtoReg <= '1';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '0';
		extendersel <= '1';
		datasel <= '1';
		btype <= '0';
	when "001110" => --XORI
		ALUsrc <= '1';
		ALUcontrol <= "110111";
		MemtoReg <= '0';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '1';
		extendersel <= '0';
		datasel <= '0';
		btype <= '0';
	when "001101" => --ORI 
		ALUsrc <= '1';
		ALUcontrol <= "101111";
		MemtoReg <= '0';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '1';
		extendersel <= '1';
		datasel <= '0';
		btype <= '0';
	when "001010" => --SLTI
		ALUsrc <= '1';
		ALUcontrol <= "100111";
		MemtoReg <= '0';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '1';
		RegDst <= '1';
		extendersel <= '1';
		datasel <= '0';
		btype <= '0';
	when "101011" => --sw
		ALUsrc <= '0';
		ALUcontrol <= "000011";
		MemtoReg <= '0';
		Branch <= '0';
		Jump <= '0';
		MemWrite <= '1';
		RegWrite <= '0';
		RegDst <= '0';
		extendersel <= '1';
		datasel <= '0';
		btype <= '0';
	when "000100" => --BEQ
		ALUsrc <= '0';
		ALUcontrol <= "100011";
		MemtoReg <= '0';
		Branch <= '1';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '0';
		RegDst <= '0';
		extendersel <= '0';
		datasel <= '0';
		btype <= '1';
	when "000101" => --BNE
		ALUsrc <= '0';
		ALUcontrol <= "100011";
		MemtoReg <= '0';
		Branch <= '1';
		Jump <= '0';
		MemWrite <= '0';
		RegWrite <= '0';
		RegDst <= '0';
		extendersel <= '0';
		datasel <= '0';
		btype <= '0';
	when "000010" => --J
		ALUsrc <= '0';
		ALUcontrol <= "111111";
		MemtoReg <= '0';
		Branch <= '1';
		Jump <= '1';
		MemWrite <= '0';
		RegWrite <= '0';
		RegDst <= '0';
		extendersel <= '0';
		datasel <= '0';
		btype <= '0';
	when "000011" => --JAL
		ALUsrc <= '0';
		ALUcontrol <= "111111";
		MemtoReg <= '0';
		Branch <= '1';
		Jump <= '1';
		MemWrite <= '0';
		RegWrite <= '0';
		RegDst <= '0';
		extendersel <= '0';
		datasel <= '0';
		btype <= '0';
	when others =>

end case;		
end process;
end casestatement;
