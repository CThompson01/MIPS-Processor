library IEEE;
use IEEE.std_logic_1164.all;

entity mux32to1 is 
generic(n : integer :=32);
port(data_in0 :in std_logic_vector(n-1 downto 0);
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

end mux32to1;

architecture behavioral of mux32to1 is 
begin

with select_in select
	data_out <= data_in0 when "00000",
		 data_in1 when "00001",
		 data_in2 when "00010",
		 data_in3 when "00011",
		 data_in4 when "00100",
		 data_in5 when "00101",
		 data_in6 when "00110",
		 data_in7 when "00111",
		 data_in8 when "01000",
		 data_in9 when "01001",
		 data_in10 when "01010",
		 data_in11 when "01011",
		 data_in12 when "01100",
		 data_in13 when "01101",
		 data_in14 when "01110",
		 data_in15 when "01111",
		 data_in16 when "10000",
		 data_in17 when "10001",
		 data_in18 when "10010",
		 data_in19 when "10011",
		 data_in20 when "10100",
		 data_in21 when "10101",
		 data_in22 when "10110",
		 data_in23 when "10111",
		 data_in24 when "11000",
		 data_in25 when "11001",
		 data_in26 when "11010",
		 data_in27 when "11011",
		 data_in28 when "11100",
		 data_in29 when "11101",
		 data_in30 when "11110",
		 data_in31 when "11111",
		 x"20000000" when others;

end behavioral;
