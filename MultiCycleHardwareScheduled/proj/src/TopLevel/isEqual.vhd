library IEEE;
use IEEE.std_logic_1164.all;

entity isEqual is
	generic(N : integer := 32);
	port(	A : in std_logic_vector(N-1 downto 0);
		B : in std_logic_vector(N-1 downto 0);
		output : out std_logic);
end isEqual;

architecture structural of isEqual is
    component invg is
        port(i_A          : in std_logic;
            o_F          : out std_logic);
    end component;
    component andg2 is
        port(i_A          : in std_logic;
            i_B          : in std_logic;
            o_F          : out std_logic);
    end component;
    component slt_N is
	    generic(N : integer := 32);
	    port(A : in std_logic_vector(N-1 downto 0);
		    B : in std_logic_vector(N-1 downto 0);
		    output : out std_logic);
    end component;
	signal slt_ab_out : std_logic;
	signal slt_ba_out : std_logic;
    signal slt_ab_inv : std_logic;
	signal slt_ba_inv : std_logic;
begin
	slt_ab: slt_N port map (A, B, slt_ab_out);
	slt_ba: slt_N port map (B, A, slt_ba_out);
	inv_slt_ab: invg port map (slt_ab_out, slt_ab_inv);
	inv_slt_ba: invg port map (slt_ba_out, slt_ba_inv);
	output: andg2 port map (slt_ab_inv, slt_ba_inv, output);
end structural;
