library IEEE;
use IEEE.std_logic_1164.all;

entity barrelShifter is
port(i_StartVal	   : in std_logic_vector(31 downto 0); --Extra bit for border value
     i_ShiftSel    : in std_logic_vector(4 downto 0); -- 5 bits 0 to 4 correspond to the 5 layers of MUX
     i_ShiftMd     : in std_logic; --0 is logical, 1 is arithmetic
     i_ShiftDir    : in std_logic; --0 is right, 1 is left
     o_Shifted     : out std_logic_vector(31 downto 0));
end barrelShifter;

architecture structural of barrelShifter is
  
--Components--

component mux2t1
port(i_D0	: in std_logic;
     i_D1	: in std_logic;
     i_S	: in std_logic;
     o_O	: out std_logic);
end component;

component org2
port(i_A          : in std_logic;
     i_B          : in std_logic;
     o_F          : out std_logic);
end component;

component bitReverser
port(revIn	: in std_logic_vector(31 downto 0);
     revSel	: in std_logic;
     revOut     : out std_logic_vector(31 downto 0));
end component;


--Signals--
signal s_Rev1   : std_logic_vector(31 downto 0); --Reversed Bits if left shift
signal s_sV1	: std_logic_vector(31 downto 0); --First MUX Output
signal s_sV2	: std_logic_vector(31 downto 0); --Second MUX Output
signal s_sV3	: std_logic_vector(31 downto 0); --Third MUX Output
signal s_sV4	: std_logic_vector(31 downto 0); --Fourth MUX Output
signal s_sV5    : std_logic_vector(31 downto 0); --Fifth MUX Output
signal s_Arith  : std_logic_vector(31 downto 0); --In-Between Arithmetic Shift Check & Output
signal s_zerologic  : std_logic; --zero logic for arithmetic shift


--Mapping--

begin

--Starting Check for Left Shift and bit reversal if needed
topbit: mux2t1
port map(
	i_D0 => i_StartVal(31),
	i_D1 => '0',
	i_S => i_ShiftMd,
	o_O => s_zerologic);

G_BitRev1: bitReverser
port map(revIn   => i_StartVal,
         revSel  => i_ShiftDir,
         revOut  => s_Rev1);

--Shift the first 31 bits right 1
G_MuxR1: for i in 0 to 30 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_Rev1(i),
	 i_D1   => s_Rev1(i+1),
         i_S    => i_ShiftSel(0),
         o_O    => s_sV1(i));
end generate G_MuxR1;

--Shift in the zero
G_Mux1: mux2t1
port map(i_D0	=> s_Rev1(31),
	 i_D1   => s_zerologic,
         i_S    => i_ShiftSel(0),
         o_O    => s_sV1(31));


--Shift the first 30 bits right 2
G_MuxR2: for i in 0 to 29 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV1(i),
	 i_D1   => s_sV1(i+2),
         i_S    => i_ShiftSel(1),
         o_O    => s_sV2(i));
end generate G_MuxR2;

--Shift in the zeros
G_MuxR2z: for i in 30 to 31 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV1(i),
	 i_D1   => s_zerologic,
         i_S    => i_ShiftSel(1),
         o_O    => s_sV2(i));
end generate G_MuxR2z;

--Shift first 28 bits right 4
G_MuxR3: for i in 0 to 27 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV2(i),
	 i_D1   => s_sV2(i+4),
         i_S    => i_ShiftSel(2),
         o_O    => s_sV3(i));
end generate G_MuxR3;

--Shift in the zeros
G_MuxR3z: for i in 28 to 31 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV2(i),
	 i_D1   => s_zerologic,
         i_S    => i_ShiftSel(2),
         o_O    => s_sV3(i));
end generate G_MuxR3z;

--Shift first 24 bits right 8
G_MuxR4: for i in 0 to 23 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV3(i),
	 i_D1   => s_sV3(i+8),
         i_S    => i_ShiftSel(3),
         o_O    => s_sV4(i));
end generate G_MuxR4;

--Shift in the zeros
G_MuxR4z: for i in 24 to 31 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV3(i),
	 i_D1   => s_zerologic,
         i_S    => i_ShiftSel(3),
         o_O    => s_sV4(i));
end generate G_MuxR4z;

--Shift first 16 bits right 16
G_MuxR5: for i in 0 to 15 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV4(i),
	 i_D1   => s_sV4(i+16),
         i_S    => i_ShiftSel(4),
         o_O    => s_sV5(i));
end generate G_MuxR5;

--Shift in the zeros
G_MuxR5z: for i in 16 to 31 generate
  MuxR: mux2t1 port map(
         i_D0	=> s_sV4(i),
	 i_D1   => s_zerologic,
         i_S    => i_ShiftSel(4),
         o_O    => s_sV5(i));
end generate G_MuxR5z;


--Reverse bits back if left shift
G_BitRev2: bitReverser
port map(revIn   => s_sV5,
         revSel  => i_ShiftDir,
         revOut  => s_Arith);

--Preserves leftmost bit for arithmetic shift
G_MuxMode: mux2t1
port map(i_D0    => s_Arith(31),
         i_D1    => i_StartVal(31),
         i_S     => i_ShiftMd,
         o_O     => o_Shifted(31));

--Maps rest of bits to output (Just used as buffer)
G_MuxMode2: for i in 0 to 30 generate
 OrG: org2
port map(i_A     => s_Arith(i),
         i_B     => '0',
         o_F     => o_Shifted(i));
end generate G_MuxMode2;

end structural;




