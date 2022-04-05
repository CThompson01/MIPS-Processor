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


end process;
end testing;