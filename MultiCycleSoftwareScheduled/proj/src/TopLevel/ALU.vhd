library IEEE;
use IEEE.std_logic_1164.all;

entity ALU is
	generic(N : integer := 32);
	port(	read_data_1: in std_logic_vector(N-1 downto 0);
		read_data_2: in std_logic_vector(N-1 downto 0);
		alu_control: in std_logic_vector(5 downto 0);
		shampt: in std_logic_vector(4 downto 0);
		output: out std_logic_vector(N-1 downto 0); 
		overflow: out std_logic; 
		carryout: out std_logic; 
		zero: out std_logic); 
end ALU;

architecture struct of ALU is 

component andg_N is 
port(
	i_A: in std_logic_vector(N-1 downto 0);
	i_B: in std_logic_vector(N-1 downto 0);
	o_O: out std_logic_vector(N-1 downto 0));
end component;

component org_N is 
port(
	i_A: in std_logic_vector(N-1 downto 0);
	i_B: in std_logic_vector(N-1 downto 0);
	o_O: out std_logic_vector(N-1 downto 0));
end component;

component xorg_N is 
port(
	i_A: in std_logic_vector(N-1 downto 0);
	i_B: in std_logic_vector(N-1 downto 0);
	o_O: out std_logic_vector(N-1 downto 0));
end component;

component AdderSub is
port(
	i_A0: in std_logic_vector(N-1 downto 0);
	i_B0: in std_logic_vector(N-1 downto 0);
	i_Cin: in std_logic;
	o_Cout: out std_logic_vector(N-1 downto 0);
	o_overflow: out std_logic;
	o_t: out std_logic);
end component;

component slt_N is 
port(
	A: in std_logic_vector(N-1 downto 0);
	B: in std_logic_vector(N-1 downto 0);
	output: out std_logic);
end component;

component barrelShifter is 
port(
	i_StartVal: in std_logic_vector(N-1 downto 0);
	i_ShiftSel: in std_logic_vector(4 downto 0);
	i_ShiftMd: in std_logic;
	i_ShiftDir: in std_logic;
	o_Shifted: out std_logic_vector(N-1 downto 0));
end component;

component alu_mux is
port(
	addsub: in std_logic_vector(N-1 downto 0);
	slt: in std_logic_vector(N-1 downto 0);
	andg: in std_logic_vector(N-1 downto 0);
	org: in std_logic_vector(N-1 downto 0);
	norg: in std_logic_vector(N-1 downto 0);
	xorg: in std_logic_vector(N-1 downto 0);
	barrel: in std_logic_vector(N-1 downto 0);
	lui: in std_logic_vector(N-1 downto 0);
	sel: in std_logic_vector(2 downto 0);
	output: out std_logic_vector(N-1 downto 0));
end component;

component alu_mux_simple is 
	port(	
		addsub: in std_logic;
		slt: in std_logic;
		andg: in std_logic;
		org: in std_logic;
		norg: in std_logic;
		xorg: in std_logic;
		barrel: in std_logic;
		lui: in std_logic;
		sel: in std_logic_vector(2 downto 0);
		output: out std_logic);
end component;

signal s_addsub_mux, s_and_mux, s_lui_mux, s_or_mux, s_xor_mux, s_or_nor_mux: std_logic_vector(N-1 downto 0);
signal s_barrel_mux, s_slt_mux: std_logic_vector(N-1 downto 0);
signal s_addsub_overflowmux: std_logic;

signal s_slt_temp: std_logic;

begin 

AddSub:AdderSub
port map(
	i_A0 => read_data_1,
	i_B0 => read_data_2,
	i_Cin => alu_control(5),
	o_Cout => s_addsub_mux,
	o_overflow => s_addsub_overflowmux,
	o_t => carryout
);

ander:andg_N
port map(
	i_A => read_data_1,
	i_B => read_data_2,
	o_O => s_and_mux
);

orer:org_N
port map(
	i_A => read_data_1,
	i_B => read_data_2,
	o_O => s_or_mux
);

xorer:xorg_N
port map(
	i_A => read_data_1,
	i_B => read_data_2,
	o_O => s_xor_mux
);

bshifter:barrelShifter
port map(
	i_StartVal => read_data_2,
	i_ShiftSel => shampt,
	i_ShiftMd => alu_control(1),
	i_ShiftDir => alu_control(0),
	o_Shifted => s_barrel_mux
);

setlessthan:slt_N
port map(
	A => read_data_1,
	B => read_data_2, 
	output => s_slt_temp
);

multiplexor:alu_mux
port map(
	addsub => s_addsub_mux,
	slt => s_slt_mux,
	andg => s_and_mux,
	org => s_or_mux,
	norg => s_or_nor_mux,
	xorg => s_xor_mux,
	barrel => s_barrel_mux,
	lui => s_lui_mux,
	sel => alu_control(4 downto 2),
	output => output
);

overflowmux:alu_mux_simple
port map(
	addsub => s_addsub_overflowmux,
	slt => '0',
	andg => '0',
	org => '0',
	norg => '0',
	xorg => '0',
	barrel => '0',
	lui => '0',
	sel => alu_control(4 downto 2),
	output => overflow
);

s_or_nor_mux <= not(read_data_1 or read_data_2); 

s_slt_mux <="0000000000000000000000000000000" & s_slt_temp;

s_lui_mux <= read_data_2(15 downto 0) & x"0000"; 

zero <= '1' when s_addsub_mux = x"00000000" else '0';  

end struct; 