library IEEE;
use IEEE.std_logic_1164.all;
 
entity register1 is 
generic(n : integer :=32);
port(we :in std_logic;
     reset :in std_logic; 
     clk :in std_logic;
     data_in :in std_logic_vector(n-1 downto 0);
     data_out :out std_logic_vector(n-1 downto 0));

end register1; 

architecture structural of register1 is

	component dffg is 
	port(i_CLK :in std_logic;
 	     i_RST :in std_logic;
	     i_WE :in std_logic;
	     i_D :in std_logic;
	     o_Q :out std_logic);
	end component;

begin 

	reg: for i in 0 to n-1 generate
	regi: dffg port map(
	i_CLK => clk, 
	i_RST => reset, 
	i_WE => we, 
	i_D => data_in(i), 
	o_Q => data_out(i));
	end generate reg;
end structural;
