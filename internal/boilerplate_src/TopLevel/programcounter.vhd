library IEEE;
use IEEE.std_logic_1164.all;

-- TODO: FIX THIS

entity programcounter is 
port(   i_InstrAddress: in std_logic_vector(31 downto 0);
	i_clk: in std_logic;
	i_reset: in std_logic;
	o_InstrAddress: out std_logic_vector(31 downto 0));
end programcounter;

architecture structural of programcounter is 

component full_adder_N is 
generic(N : integer := 32);
port(	i0 : in std_logic_vector(N-1 downto 0);
	i1 : in std_logic_vector(N-1 downto 0);
	cin : in std_logic;
	output : out std_logic_vector(N-1 downto 0);
	cout : out std_logic);
end component;

signal PCval: std_logic_vector(31 downto 0);

begin

mapping : full_adder_N 
port map(
	i0 => in_InstrAddress,
	i1 => 32x"4",	
	cin => '0',
	output => PCval,
	cout => open);

resetcase: process(clk)
begin 

if(rising_edge(clk)) then
	if(reset = '1') then
		out_InstrAddress <= x"00400000";
	else
		out_InstrAddress <= PCval;		
	end if;
end if;
end process;
end structural;