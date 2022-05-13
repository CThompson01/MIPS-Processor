library IEEE;
use IEEE.std_logic_1164.all;

entity adder is
	port(i0 : in std_logic;
		i1 : in std_logic;
		cin : in std_logic;
		output : out std_logic;
		cout : out std_logic);
end adder;

architecture structural of adder is
	component andg2
		port(i_A, i_B: in std_logic; o_F: out std_logic);
	end component;
	component org2
		port(i_A, i_B: in std_logic; o_F: out std_logic);
	end component;
	component xorg2
		port(i_A, i_B: in std_logic; o_F: out std_logic);
	end component;
	component invg
		port(i_A: in std_logic; o_F: out std_logic);
	end component;
	signal i0_inv : std_logic;
	signal i1_inv : std_logic;
	signal cin_inv : std_logic;

	signal xor_cin : std_logic;
	signal left_or : std_logic;

	signal inv_and : std_logic;
	signal norm_and : std_logic;
	signal norm_inv_or : std_logic;
	signal right_or : std_logic;

	signal cout1 : std_logic;
	signal cout2 : std_logic;
	signal cout3 : std_logic;
begin
	G1: invg port map (i0, i0_inv);
	G2: invg port map (i1, i1_inv);
	G3: invg port map (cin, cin_inv);


	G4: xorg2 port map (i1, cin, xor_cin);
	G5: andg2 port map (i0_inv, xor_cin, left_or);

	G6: andg2 port map (i1_inv, cin_inv, inv_and);
	G7: andg2 port map (i1, cin, norm_and);
	G8: org2 port map (inv_and, norm_and, norm_inv_or);
	G9: andg2 port map (i0, norm_inv_or, right_or);
	
	G10: org2 port map (left_or, right_or, output);

	
	G11: org2 port map (i0, i1, cout1);
	G12: andg2 port map (cin, cout1, cout3);

	G13: andg2 port map (i0, i1, cout2);
	
	G14: org2 port map (cout3, cout2, cout);
end structural;