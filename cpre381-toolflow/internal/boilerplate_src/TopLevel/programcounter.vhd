library IEEE;
use IEEE.std_logic_1164.all;

entity programcounter is 
port(   i_InstrAddress: in std_logic_vector(31 downto 0);
	i_clk: in std_logic;
	i_reset: in std_logic;
	out_InstrAddress: out std_logic_vector(31 downto 0));
end programcounter;

architecture structural of programcounter is 

begin

resetcase: process(i_clk)
begin 

if(rising_edge(i_clk)) then
	if(i_reset = '1') then
		out_InstrAddress <= x"00400000";
	else
		out_InstrAddress <= i_InstrAddress;		
	end if;
end if;
end process;
end structural;