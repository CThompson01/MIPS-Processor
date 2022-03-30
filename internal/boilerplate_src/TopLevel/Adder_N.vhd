library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder_N is
	generic(N : integer := 32); 
	port(i0 : in std_logic_vector(N-1 downto 0);
		i1 : in std_logic_vector(N-1 downto 0);
		cin : in std_logic;
		output : out std_logic_vector(N-1 downto 0);
		cout : out std_logic);
end full_adder_N;

architecture structural of full_adder_N is
	component adder is
		port(i0 : in std_logic;
			i1 : in std_logic;
			cin : in std_logic;
			output : out std_logic;
			cout : out std_logic);
	end component;
	signal carry: std_logic_vector(N downto 0);
begin
	carry(0) <= cin;
	G_NBit_ADDER: for i in 0 to N-1 generate
		adderI: adder port map(
			cin => carry(i), 
			i0 => i0(i),  
			i1 => i1(i),  
			output => output(i), 
			cout => carry(i+1)); 
	end generate G_NBit_ADDER;
	cout <= carry(N);
end structural;

