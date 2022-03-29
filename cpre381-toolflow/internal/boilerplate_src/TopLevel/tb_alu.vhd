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



end tb_alu;
