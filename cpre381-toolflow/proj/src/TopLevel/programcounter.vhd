library IEEE;
use IEEE.std_logic_1164.all;

entity programcounter is 
port(   i_InstrAddress: in std_logic_vector(31 downto 0);
	clk: in std_logic;
	reset: in std_logic;
	o_InstrAddress: out std_logic_vector(31 downto 0));
end programcounter;

architecture structural of programcounter is 

begin

resetcase: process(clk)
begin 

if(rising_edge(clk)) then
	if(reset = '1') then
		o_InstrAddress <= x"00400000";
	else
		o_InstrAddress <= i_InstrAddress;		
	end if;
end if;
end process;
end structural;