library IEEE;
use IEEE.std_logic_1164.all;

entity decoder5to32 is 
generic(n : integer :=32);
port(data_in  : in std_logic_vector(4 downto 0);
     en       : in std_logic; -- WHEN HI: Output 1 hot encoding
                              -- WHEN LO: output 00000000
     data_out : out std_logic_vector(n-1 downto 0));

end decoder5to32;

architecture behavioral of decoder5to32 is 

signal decoder_s : std_logic_vector(31 downto 0);

component andg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;

begin
-- GENERATE 32 AND Gates: data_out<= (decoder_s(i) && en)
andg: for i in 0 to n-1 generate
	andi: andg2 port map(
	i_A => decoder_s(i),
	i_b => en,
	o_F => data_out(i));
	end generate andg;
with data_in select
	decoder_s <= x"00000001" when "00000", -- IN 00000 : OUT Bit 0 HIGH
		    x"00000002" when "00001", -- IN 00001 : OUT Bit 1 HIGH
		    x"00000004" when "00010", -- IN 00010 : OUT Bit 2 HIGH
		    x"00000008" when "00011",

		    x"00000010" when "00100",
		    x"00000020" when "00101",
		    x"00000040" when "00110",
		    x"00000080" when "00111", 

		    x"00000100" when "01000", 
		    x"00000200" when "01001",
		    x"00000400" when "01010",
		    x"00000800" when "01011",

		    x"00001000" when "01100",
		    x"00002000" when "01101",
		    x"00004000" when "01110",
		    x"00008000" when "01111",

		    x"00010000" when "10000",
		    x"00020000" when "10001",
		    x"00040000" when "10010",
		    x"00080000" when "10011",

		    x"00100000" when "10100",
		    x"00200000" when "10101",
		    x"00400000" when "10110",
		    x"00800000" when "10111",

		    x"01000000" when "11000",
		    x"02000000" when "11001",
		    x"04000000" when "11010",
		    x"08000000" when "11011",

		    x"10000000" when "11100",
		    x"20000000" when "11101",
		    x"40000000" when "11110",
		    x"80000000" when "11111",

		    x"00000000" when others;

end behavioral; 