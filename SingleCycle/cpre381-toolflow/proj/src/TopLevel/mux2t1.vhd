library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is
port(
i_D0,i_D1 : in STD_LOGIC;
i_S : in STD_LOGIC;
o_O : out STD_LOGIC
);
end mux2t1;

architecture structural of mux2t1 is 
component org2
	port(i_A, i_B: in STD_LOGIC; o_F: out STD_LOGIC);
end component;
component andg2
	port(i_A, i_B: in STD_LOGIC; o_F: out STD_LOGIC);
end component;
component invg
	port(i_A: in STD_LOGIC; o_F: out STD_LOGIC);
end component;
signal S_inv: STD_LOGIC;
signal I1_inv: STD_LOGIC;
signal I2_S: STD_LOGIC;

begin 
G1: invg port map (i_S, S_inv);
G2: andg2 port map (i_D0, S_inv, I1_inv);
G3: andg2 port map (i_D1, i_S, I2_S);
G4: org2 port map (I1_inv, I2_S, o_O);

end structural;
