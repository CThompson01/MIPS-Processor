library IEEE;
use IEEE.std_logic_1164.all;
use work.arraytype.reg_out;

entity registerfile is 
generic(n : integer:= 32);
port(
	clk: in std_logic;--
	reset: in std_logic;--
	we: in std_logic;--
	rs: in std_logic_vector(4 downto 0); -- read data 1
	rt: in std_logic_vector(4 downto 0); --read data 2
	rd: in std_logic_vector(4 downto 0);--
	writeport: in std_logic_vector(31 downto 0);
	readdata1: out std_logic_vector(31 downto 0); --
	readdata2: out std_logic_vector(31 downto 0)); --
end registerfile; 

architecture structural of registerfile is 

--component register,
component decoder5to32 is 
port(
	data_in:in std_logic_vector(4 downto 0);
	en:in std_logic;
	data_out:out std_logic_vector(31 downto 0));
end component;

component mux32to1 is 
port(
     data_in0 :in std_logic_vector(n-1 downto 0);
     data_in1 :in std_logic_vector(n-1 downto 0);
     data_in2 :in std_logic_vector(n-1 downto 0);
     data_in3 :in std_logic_vector(n-1 downto 0);
     data_in4 :in std_logic_vector(n-1 downto 0);
     data_in5 :in std_logic_vector(n-1 downto 0);
     data_in6 :in std_logic_vector(n-1 downto 0);
     data_in7 :in std_logic_vector(n-1 downto 0);  
     data_in8 :in std_logic_vector(n-1 downto 0);
     data_in9 :in std_logic_vector(n-1 downto 0);
     data_in10 :in std_logic_vector(n-1 downto 0);
     data_in11 :in std_logic_vector(n-1 downto 0);
     data_in12 :in std_logic_vector(n-1 downto 0);
     data_in13 :in std_logic_vector(n-1 downto 0);
     data_in14 :in std_logic_vector(n-1 downto 0);
     data_in15 :in std_logic_vector(n-1 downto 0);
     data_in16 :in std_logic_vector(n-1 downto 0);
     data_in17 :in std_logic_vector(n-1 downto 0);
     data_in18 :in std_logic_vector(n-1 downto 0);
     data_in19 :in std_logic_vector(n-1 downto 0);
     data_in20 :in std_logic_vector(n-1 downto 0);
     data_in21 :in std_logic_vector(n-1 downto 0);
     data_in22 :in std_logic_vector(n-1 downto 0);
     data_in23 :in std_logic_vector(n-1 downto 0);
     data_in24 :in std_logic_vector(n-1 downto 0);
     data_in25 :in std_logic_vector(n-1 downto 0);
     data_in26 :in std_logic_vector(n-1 downto 0);
     data_in27 :in std_logic_vector(n-1 downto 0);
     data_in28 :in std_logic_vector(n-1 downto 0);
     data_in29 :in std_logic_vector(n-1 downto 0);
     data_in30 :in std_logic_vector(n-1 downto 0);
     data_in31 :in std_logic_vector(n-1 downto 0);
     data_out :out std_logic_vector(n-1 downto 0);
     select_in :in std_logic_vector(4 downto 0));
end component;

component register1 is 
port(we :in std_logic;
     reset :in std_logic; 
     clk :in std_logic;
     data_in :in std_logic_vector(n-1 downto 0);
     data_out :out std_logic_vector(n-1 downto 0));
end component;

signal reg_we: std_logic_vector(n-1 downto 0);
signal reg_out_arr: reg_out;

begin

decoder: decoder5to32 port map(
data_in => rd,
en => we,
data_out => reg_we); 

register0: register1 port map(
we => reg_we(0),
reset => '1', 
clk => clk, 
data_in => writeport,
data_out => reg_out_arr(0));

reg: for i in 1 to 31 generate
registers: register1 port map(
we => reg_we(i),
reset => reset, 
clk => clk, 
data_in => writeport,
data_out => reg_out_arr(i));
end generate;

mux1: mux32to1 port map(
data_out => readdata1,
select_in => rs,
data_in0 => reg_out_arr(0),
data_in1 => reg_out_arr(1),
data_in2 => reg_out_arr(2),
data_in3 => reg_out_arr(3),
data_in4 => reg_out_arr(4),
data_in5 => reg_out_arr(5),
data_in6 => reg_out_arr(6),
data_in7 => reg_out_arr(7),
data_in8 => reg_out_arr(8),
data_in9 => reg_out_arr(9),
data_in10 => reg_out_arr(10),
data_in11 => reg_out_arr(11),
data_in12 => reg_out_arr(12),
data_in13 => reg_out_arr(13),
data_in14 => reg_out_arr(14),
data_in15 => reg_out_arr(15),
data_in16 => reg_out_arr(16),
data_in17 => reg_out_arr(17),
data_in18 => reg_out_arr(18),
data_in19 => reg_out_arr(19),
data_in20 => reg_out_arr(20),
data_in21 => reg_out_arr(21),
data_in22 => reg_out_arr(22),
data_in23 => reg_out_arr(23),
data_in24 => reg_out_arr(24),
data_in25 => reg_out_arr(25),
data_in26 => reg_out_arr(26),
data_in27 => reg_out_arr(27),
data_in28 => reg_out_arr(28),
data_in29 => reg_out_arr(29),
data_in30 => reg_out_arr(30),
data_in31 => reg_out_arr(31));

mux2: mux32to1 port map(
data_out => readdata2, 
select_in => rt,
data_in0 => reg_out_arr(0),
data_in1 => reg_out_arr(1),
data_in2 => reg_out_arr(2),
data_in3 => reg_out_arr(3),
data_in4 => reg_out_arr(4),
data_in5 => reg_out_arr(5),
data_in6 => reg_out_arr(6),
data_in7 => reg_out_arr(7),
data_in8 => reg_out_arr(8),
data_in9 => reg_out_arr(9),
data_in10 => reg_out_arr(10),
data_in11 => reg_out_arr(11),
data_in12 => reg_out_arr(12),
data_in13 => reg_out_arr(13),
data_in14 => reg_out_arr(14),
data_in15 => reg_out_arr(15),
data_in16 => reg_out_arr(16),
data_in17 => reg_out_arr(17),
data_in18 => reg_out_arr(18),
data_in19 => reg_out_arr(19),
data_in20 => reg_out_arr(20),
data_in21 => reg_out_arr(21),
data_in22 => reg_out_arr(22),
data_in23 => reg_out_arr(23),
data_in24 => reg_out_arr(24),
data_in25 => reg_out_arr(25),
data_in26 => reg_out_arr(26),
data_in27 => reg_out_arr(27),
data_in28 => reg_out_arr(28),
data_in29 => reg_out_arr(29),
data_in30 => reg_out_arr(30),
data_in31 => reg_out_arr(31));


end structural; 