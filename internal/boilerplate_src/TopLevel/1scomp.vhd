library IEEE; 
use IEEE.std_logic_1164.all;

entity onescomp is 
generic(N: integer := 16);
port(a: in std_logic_vector(N-1 downto 0);
     y: out std_logic_vector(N-1 downto 0));
end onescomp;

architecture structural of onescomp is 
   component invg is 
     port(i_A: in std_logic;
	  o_F: out std_logic);
end component;

begin 

N_bit_ones_comp: for i in 0 to N-1 generate 
	OneComp: invg port map(
		i_A => a(i),
		o_F => y(i));
end generate N_bit_ones_comp;

end structural;	