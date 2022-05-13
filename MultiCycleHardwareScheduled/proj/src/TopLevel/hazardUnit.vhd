library IEEE;
use IEEE.std_logic_1164.all;

entity hazardUnit is
	generic(N : integer := 32);
	port(IDEXmemread : in std_logic;
        IDEXrt : in std_logic_vector(N-1 downto 0);
		IFIDrs : in std_logic_vector(N-1 downto 0);
        IFIDrt : in std_logic_vector(N-1 downto 0);
		stall : out std_logic);
end hazardUnit;

architecture structural of hazardUnit is
    component isEqual is
        generic(N : integer := 32);
        port(A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            output : out std_logic);
    end component;
    component org2 is
        port(i_A : in std_logic;
			i_B : in std_logic;
            o_F : out std_logic);
    end component;
	component andg2 is
        port(i_A : in std_logic;
            i_B : in std_logic;
            o_F : out std_logic);
    end component;
	signal rtrs : std_logic;
	signal rtrt : std_logic;
	signal same_resource : std_logic;
begin
	rtrs0: isEqual port map (IDEXrt, IFIDrs, rtrs);
	rtrt0: isEqual port map (IDEXrt, IFIDrt, rtrt);
	either: org2 port map (rtrs, rtrt, same_resource);
	checkmem: andg2 port map (same_resource, IDEXmemread, stall);
end structural;
