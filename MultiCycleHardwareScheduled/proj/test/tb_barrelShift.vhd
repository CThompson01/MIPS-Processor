library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  
library std;
use std.env.all;               
use std.textio.all;             


entity tb_barrelShift is
  generic(gCLK_HPER   : time := 10 ns);   
end tb_barrelShift;

architecture mixed of tb_barrelShift is


constant cCLK_PER  : time := gCLK_HPER * 2;

component barrelShifter is
    port(i_StartVal    :in std_logic_vector(31 downto 0);
	 i_ShiftSel    :in std_logic_vector(4 downto 0);
         i_ShiftMd     :in std_logic;
         i_ShiftDir    :in std_logic;
	 o_Shifted     :out std_logic_vector(31 downto 0));

end component;

signal CLK, reset : std_logic := '0';

signal s_Start       : std_logic_vector(31 downto 0);
signal s_Sel         : std_logic_vector(4 downto 0);
signal s_Mode        : std_logic;
signal s_Direction   : std_logic;
signal s_Output      : std_logic_vector(31 downto 0);

begin

  DUT0: barrelShifter
  port map(
      i_StartVal  =>  s_Start,
      i_ShiftSel  =>  s_Sel,
      i_ShiftMd   =>  s_Mode,
      i_ShiftDir  =>  s_Direction,
      o_Shifted   =>  s_Output);
  

  P_CLK: process
  begin
    CLK <= '1';        
    wait for gCLK_HPER; 
    CLK <= '0';         
    wait for gCLK_HPER; 
  end process;

  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  
  

  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; 
   
   --Test srl--
   s_Start      <= x"00001234";
   s_Sel        <= "00110";
   s_Mode       <= '1';
   s_Direction  <= '0';

   wait for gCLK_HPER*2;
   wait for gCLK_HPER*2;

   --Test sll--
   s_Start      <= x"00001234";
   s_Sel        <= "01011";
   s_Mode       <= '1';
   s_Direction  <= '1';

   wait for gCLK_HPER*2;
   wait for gCLK_HPER*2;

   --Test sra--
   s_Start      <= x"00001234";
   s_Sel        <= "00101";
   s_Mode       <= '0';
   s_Direction  <= '0';

   wait for gCLK_HPER*2;
   wait for gCLK_HPER*2;

   --Test sra with negative--
   s_Start      <= x"FFFFFB2E";
   s_Sel        <= "00101";
   s_Mode       <= '0';
   s_Direction  <= '0';

   wait for gCLK_HPER*2;
   wait for gCLK_HPER*2;



  end process;

end mixed;
