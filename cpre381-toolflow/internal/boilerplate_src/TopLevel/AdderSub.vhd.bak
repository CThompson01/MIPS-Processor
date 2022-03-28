library IEEE;
use IEEE.std_logic_1164.all;

entity AdderSub is 
generic(n : integer := 32);
port(   i_A0 : in std_logic_vector(n-1 downto 0);
	i_B0 : in std_logic_vector(n-1 downto 0);
	i_Cin : in std_logic;
	o_Cout : out std_logic_vector(n-1 downto 0);
	o_t : out std_logic);
end AdderSub;


architecture structural of AdderSub is 

signal s_iB : std_logic_vector(n-1 downto 0);
signal s_Imux : std_logic_vector(n-1 downto 0);

component full_adder_N is
port(   i0 : in std_logic_vector(N-1 downto 0);
		i1 : in std_logic_vector(N-1 downto 0);
		cin : in std_logic;
		output : out std_logic_vector(N-1 downto 0);
		cout : out std_logic);
end component;

component onescomp is 
generic(N: integer := 16);
port(   a: in std_logic_vector(n-1 downto 0);
	y: out std_logic_vector(n-1 downto 0));
end component;

component mux2t1_N is 
port(   i_S : in std_logic;
	i_D0 : in std_logic_vector(n-1 downto 0);
	i_D1 : in std_logic_vector(n-1 downto 0);
	o_O : out std_logic_vector(n-1 downto 0));
end component;

begin

invert: onescomp
generic map(N => n)
port Map(a => i_B0,
	y => s_iB);

mux: mux2t1_N
port Map(i_S => i_Cin,
	i_D0 => i_B0,
	i_D1 => s_iB,
	o_O => s_Imux);

add: full_adder_N
port Map(i0 => i_A0,
	i1 => s_Imux,
	cin => i_Cin,
	output => o_Cout,
	cout => o_t);

end structural;
