library IEEE;
use IEEE.std_logic_1164.all;

entity alu_mux_simple is 
	port(	
        addsub: in std_logic;
		slt: in std_logic;
		andg: in std_logic;
		org: in std_logic;
		norg: in std_logic;
		xorg: in std_logic;
		barrel: in std_logic;
		lui: in std_logic;
		sel: in std_logic_vector(2 downto 0);
		output: out std_logic);
end alu_mux_simple;

architecture struct of alu_mux_simple is 
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
		  '0' when others;	
end struct;
