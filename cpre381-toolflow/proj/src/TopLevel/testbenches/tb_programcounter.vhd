library IEEE;
use IEEE.std_logic_1164.all;

entity tb_programcounter is 
generic(N : integer := 32;
	gCLK_HPER   : time := 10 ns);
end tb_programcounter;

architecture mixed of tb_programcounter is 

component programcounter is 
port(   i_InstrAddress: in std_logic_vector(31 downto 0);
	i_clk: in std_logic;
	i_reset: in std_logic;
	out_InstrAddress: out std_logic_vector(31 downto 0));
end component;

signal clk, rst: std_logic; 
signal i_input, o_output: std_logic_vector(31 downto 0);

begin 

DUT0: programcounter 
port map(
	i_InstrAddress => i_input,
	i_clk => clk,
	i_reset => rst,
	out_InstrAddress => o_output
);

P_CLK: process
  begin
    clk <= '1';        
    wait for gCLK_HPER; 
    clk <= '0';         
    wait for gCLK_HPER; 
  end process;

ptestcases: process
begin

i_input <= x"00400185";

wait for gCLK_HPER*2;

rst <= '1';

wait for gCLK_HPER*2;

rst <= '0';

wait for gCLK_HPER*2;

i_input <= x"00400234";

wait for gCLK_HPER*2;

end process;
end mixed;

