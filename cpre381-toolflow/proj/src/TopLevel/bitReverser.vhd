library IEEE;
use IEEE.std_logic_1164.all;

entity bitReverser is
port(revIn	: in std_logic_vector(31 downto 0);
     revSel	: in std_logic;
     revOut     : out std_logic_vector(31 downto 0));
end bitReverser;


architecture structural of bitReverser is

component mux2t1
port(i_D0	: in std_logic;
     i_D1	: in std_logic;
     i_S	: in std_logic;
     o_O	: out std_logic);
end component;

begin

G_Muxs: for i in 0 to 31 generate
  MuxR: mux2t1 port map(
         i_D0	=> revIn(i),
	 i_D1   => revIn(31-i),
         i_S    => revSel,
         o_O    => revOut(i));
end generate G_Muxs;

end structural;
