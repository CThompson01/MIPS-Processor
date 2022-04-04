library IEEE;
use IEEE.std_logic_1164.all;

entity tb_alu is 
generic(gCLK_HPER   : time := 10 ns;
	N: integer := 32);   
end tb_alu;

architecture mixes of tb_alu is 

component ALU is 
	port(	read_data_1: in std_logic_vector(N-1 downto 0);
		read_data_2: in std_logic_vector(N-1 downto 0);
		alu_control: in std_logic_vector(5 downto 0);
		shampt: in std_logic_vector(4 downto 0);
		output: out std_logic_vector(N-1 downto 0); 
		overflow: out std_logic; 
		carryout: out std_logic; 
		zero: out std_logic); 
end component; 

signal s_rd1, s_rd2, s_output: std_logic_vector(N-1 downto 0);
signal s_control: std_logic_vector(5 downto 0);
signal s_shampt: std_logic_vector(4 downto 0); 
signal s_overflow, s_carryout, s_zero: std_logic;

begin 

mapp:ALU
port map(
	read_data_1 => s_rd1,
	read_data_2 => s_rd2,
	alu_control => s_control,
	shampt => s_shampt,
	output => s_output,
	overflow => s_overflow,
	carryout => s_carryout,
	zero => s_zero
);

testing:process
begin 

wait for gCLK_HPER/2;

--carryout
s_rd1 <= 
s_rd2 <= 
s_control <= 
s_shampt <= x"00000";
--expected output = 
wait for gCLK_HPER/2;

--overflow
s_rd1 <= 
s_rd2 <= 
s_control <= 
s_shampt <= x"00000";
--expected output = 
wait for gCLK_HPER/2;

--zero
s_rd1 <= 
s_rd2 <= 
s_control <= x"100011";
s_shampt <= x"00000";
--expected output zero = 1 (subtract operation) 
wait for gCLK_HPER/2;

--add
s_rd1 <= x"00000002";
s_rd2 <= x"00000002";
s_control <= x"000011";
s_shampt <= x"00000";
--expected output = x00000004
wait for gCLK_HPER/2;

--sub
s_rd1 <= x"00000002";
s_rd2 <= x"00000001";
s_control <= x"100011";
s_shampt <= x"00000";
--expected output = x00000001
wait for gCLK_HPER/2;

--slt
s_rd1 <= 
s_rd2 <= 
s_control <= x"100111";
s_shampt <= x"00000";
--expected output = 
wait for gCLK_HPER/2;

--and
s_rd1 <= x"0000000A";
s_rd2 <= x"00000003";
s_control <= x"101011";
s_shampt <= x"00000";
--expected output = x00000010
wait for gCLK_HPER/2;

--or
s_rd1 <= x"0000000a";
s_rd2 <= x"00000003";
s_control <= x"101111";
s_shampt <= x"00000";
--expected output = x00001011
wait for gCLK_HPER/2;

--nor
s_rd1 <= 
s_rd2 <= 
s_control <= x"110011";
s_shampt <= x"00000";
--expected output = 
wait for gCLK_HPER/2;

--xor
s_rd1 <= x"0000000a";
s_rd2 <= x"00000003";
s_control <= x"110111";
s_shampt <= x"00000";
--expected output = x00001001
wait for gCLK_HPER/2;

--sll
s_rd1 <= 
s_rd2 <= 
s_control <= x"111001";
s_shampt <= 
--expected output = 
wait for gCLK_HPER/2;

--srl
s_rd1 <= 
s_rd2 <= 
s_control <= x"111000";
s_shampt <= 
--expected output = 
wait for gCLK_HPER/2;

--sra
s_rd1 <= 
s_rd2 <= 
s_control <= x"111010";
s_shampt <= 
--expected output = 
wait for gCLK_HPER/2;

--lui
s_rd1 <= 
s_rd2 <= 
s_control <= x"011111";
s_shampt <= x"00000";
--expected output = 
wait for gCLK_HPER/2;

end process;
end mixes;
