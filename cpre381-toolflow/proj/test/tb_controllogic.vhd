library IEEE;
use IEEE.std_logic_1164.all;

entity tb_controllogic is
end tb_controllogic;

architecture testing of tb_controllogic is 

component controllogic is
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
	halt: out std_logic; 
	btype: out std_logic); 
end component; 

signal s_opcode, s_functcode, s_alucontrol: std_logic_vector(5 downto 0);
signal s_alusrc, s_memtoreg, s_branch, s_jump, s_memwrite: std_logic;
signal s_regwrite, s_datasel, s_regdst, s_extendersel, s_halt, s_btype: std_logic;

begin 

mapp:controllogic
port map(
   	opcode => s_opcode, 
	functcode => s_functcode, 
	ALUsrc => s_alusrc,
	ALUcontrol => s_alucontrol,
	MemtoReg => s_memtoreg,
	Branch => s_branch,
	Jump => s_jump,
	MemWrite => s_memwrite,
	RegWrite => s_regwrite,
	RegDst => s_regdst,
	extendersel => s_extendersel,
	datasel => s_datasel,
	halt => s_halt,
	btype => s_btype
);

testing:process
begin

wait for 50 ns;

s_opcode <= "000000";
s_functcode <= "100000"; --add

wait for 50 ns;

s_functcode <= "100001"; --addu 

wait for 50 ns;

s_functcode <= "100100"; --and

wait for 50 ns;

s_functcode <= "100111"; --nor 

wait for 50 ns;

s_functcode <= "100110"; --xor 

wait for 50 ns;

s_functcode <= "100101"; --or

wait for 50 ns;

s_functcode <= "101010"; --slt

wait for 50 ns;

s_functcode <= "000000"; --sll

wait for 50 ns;

s_functcode <= "000010"; --srl

wait for 50 ns;

s_functcode <= "000011"; --sra

wait for 50 ns;

s_functcode <= "100010"; --sub

wait for 50 ns;

s_functcode <= "100011"; --subu

wait for 50 ns;

s_opcode <= "001000"; --addi

wait for 50 ns;

s_opcode <= "001001"; --addiu

wait for 50 ns;

s_opcode <= "001100"; --andi

wait for 50 ns;

s_opcode <= "001111"; --lui

wait for 50 ns;

s_opcode <= "100011"; --lw

wait for 50 ns;

s_opcode <= "001110"; --xori

wait for 50 ns;

s_opcode <= "001101"; --ori

wait for 50 ns;

s_opcode <= "001010"; --slti

wait for 50 ns;

s_opcode <= "101011"; --sw

wait for 50 ns;

s_opcode <= "000100"; --beq

wait for 50 ns;

s_opcode <= "000101"; --bne

wait for 50 ns;

s_opcode <= "000010"; --j

wait for 50 ns;

s_opcode <= "000011"; --jal

wait for 50 ns;

s_opcode <= "010100"; --halt

end process;
end testing;