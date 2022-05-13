library IEEE;
use IEEE.std_logic_1164.all;

entity forwardingUnit is
	generic(N : integer := 32);
	port(EXMEMrd : in std_logic_vector(N-1 downto 0);
		EXMEMregwrite : in std_logic;
		MEMWBrd : in std_logic_vector(N-1 downto 0);
		MEMWBregwrite : in std_logic;
		IDEXrs : in std_logic_vector(N-1 downto 0);
        IDEXrt : in std_logic_vector(N-1 downto 0);
		forwardA : out std_logic_vector(1 downto 0);
        forwardB : out std_logic_vector(1 downto 0));
end forwardingUnit;

architecture structural of forwardingUnit is
    component isEqual is
        generic(N : integer := 32);
        port(A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            output : out std_logic);
    end component;
	component andg2 is
        port(i_A : in std_logic;
            i_B : in std_logic;
            o_F : out std_logic);
    end component;
	component mux2t1_N is
		generic(N : integer := 2);
		port(i_S          : in std_logic;
			i_D0         : in std_logic_vector(N-1 downto 0);
			i_D1         : in std_logic_vector(N-1 downto 0);
			o_O          : out std_logic_vector(N-1 downto 0));
	end component;

	-- forward A
	signal EXMEM_rdrs_equal : std_logic;
	signal EXMEM_regwrite_and_rdrs : std_logic;
	signal EXMEM_mux_a : std_logic_vector(1 downto 0);
	signal MEMWB_rdrs_equal : std_logic;
	signal MEMWB_regwrite_and_rdrs : std_logic;
	signal MEMWB_mux_a : std_logic_vector(1 downto 0);

	-- forward B
	signal EXMEM_rdrt_equal : std_logic;
	signal EXMEM_regwrite_and_rdrt : std_logic;
	signal EXMEM_mux_b : std_logic_vector(1 downto 0);
	signal MEMWB_rdrt_equal : std_logic;
	signal MEMWB_regwrite_and_rdrt : std_logic;
	signal MEMWB_mux_b : std_logic_vector(1 downto 0);
begin
	-- forwardA
	fa0: isEqual port map (EXMEMrd, IDEXrs, EXMEM_rdrs_equal);
	fa1: andg2 port map (EXMEM_rdrs_equal, EXMEMregwrite, EXMEM_regwrite_and_rdrs);
	fa2: mux2t1_N port map (EXMEM_regwrite_and_rdrs, "00", "10", EXMEM_mux_a);
	fa3: isEqual port map (MEMWBrd, IDEXrs, MEMWB_rdrs_equal);
	fa4: andg2 port map (MEMWB_rdrs_equal, MEMWBregwrite, MEMWB_regwrite_and_rdrs);
	fa5: mux2t1_N port map (MEMWB_regwrite_and_rdrs, "00", "10", MEMWB_mux_a);
	fa6: mux2t1_N port map (EXMEMregwrite, MEMWB_mux_a, EXMEM_mux_a, forwardA);

	-- forwardB
	fb0: isEqual port map (EXMEMrd, IDEXrt, EXMEM_rdrt_equal);
	fb1: andg2 port map (EXMEM_rdrt_equal, EXMEMregwrite, EXMEM_regwrite_and_rdrt);
	fb2: mux2t1_N port map (EXMEM_regwrite_and_rdrt, "00", "10", EXMEM_mux_b);
	fb3: isEqual port map (MEMWBrd, IDEXrt, MEMWB_rdrt_equal);
	fb4: andg2 port map (MEMWB_rdrt_equal, MEMWBregwrite, MEMWB_regwrite_and_rdrt);
	fb5: mux2t1_N port map (MEMWB_regwrite_and_rdrt, "00", "10", MEMWB_mux_b);
	fb6: mux2t1_N port map (EXMEMregwrite, MEMWB_mux_b, EXMEM_mux_b, forwardB);
end structural;
