library IEEE;
use IEEE.std_logic_1164.all;

entity extender is
generic(n : integer := 32);
port(   Imm: in std_logic_vector(15 downto 0);
	s: in std_logic;
	out_Imm: out std_logic_vector(n - 1 downto 0));
end extender;

architecture data of extender is 

signal s_I1, s_I2: std_logic_vector(15 downto 0);
signal s_q: std_logic;

begin 
	s_q <= Imm(15);
	with s_q select
	s_I2 <= 
		x"FFFF" when '1',
		x"0000" when '0',
		x"0101" when others;

	s_I1 <= (15 downto 0 => '0');

	with s select 
	out_Imm <= 
		s_I1 & Imm when '0',
		s_I2 & Imm when '1',
		x"00000000" when others;

end data;

