library IEEE;
use IEEE.std_logic_1164.all;

entity slt_N is
	generic(N : integer := 32);
	port(	A : in std_logic_vector(N-1 downto 0);
		B : in std_logic_vector(N-1 downto 0);
		output : out std_logic);
end slt_N;

architecture structural of slt_N is
	component adder_subtractor 
		port(	i_A0 : in std_logic_vector(N-1 downto 0);
			i_B0 : in std_logic_vector(N-1 downto 0);
			i_Cin: in std_logic;
			o_Cout : out std_logic_vector(N-1 downto 0);
			o_t : out std_logic);
	end component;
	signal sub_out : std_logic_vector(N-1 downto 0);
	signal sub_cout : std_logic;
begin
	mapped: adder_subtractor port map (A, B, '1', sub_out, sub_cout);  
	output <= sub_out(N-1); 
end structural;
