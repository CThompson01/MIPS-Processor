library IEEE;
use IEEE.std_logic_1164.all;

entity alu_mux is 
	generic(N : integer := 32);
	port(	addsub: in std_logic_vector(N-1 downto 0);
		slt: in std_logic_vector(N-1 downto 0);
		andg: in std_logic_vector(N-1 downto 0);
		org: in std_logic_vector(N-1 downto 0);
		norg: in std_logic_vector(N-1 downto 0);
		xorg: in std_logic_vector(N-1 downto 0);
		barrel: in std_logic_vector(N-1 downto 0);
		lui: in std_logic_vector(N-1 downto 0);
		sel: in std_logic_vector(2 downto 0);
		output: out std_logic_vector(N-1 downto 0));
end alu_mux;

architecture struct of alu_mux is 
begin 
	with sel select
	output <= addsub when "000",
		  slt when "001",
		  andg when "010",
		  org when "011",
		  norg when "100",
		  xorg when "101",
		  barrel when "110",
		  lui when "111",
		  x"00000000" when others;	
end struct;
