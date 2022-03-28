library IEEE;
use IEEE.std_logic_1164.all;

entity alu_mux is 
	generic(N : integer := 32);
	port(	addsub: in std_logic_vector(N-1 downto 0);
		slt: in std_logic_vector(N-1 downto 0);
		andg: in std_logic_vector(N-1 downto 0);
		org: in std_logic_vector(N-1 downto 0);
		norg: in std_logic_vector(N-1 downto 0);
		xorg: in std_logic_vector(N-1 downto 0);
		barrel: in std_logic_vector(N-1 downto 0);
		sel: in std_logic_vector(2 downto 0);
		output: out std_logic_vector(N-1 downto 0));
end alu_mux;

architecture struct of alu_mux is 
begin 
	case_statement:process(sel)
	begin
		case sel is 
			when "000" =>
				output <= addsub;
			when "001" =>
				output <= slt;
			when "010" => 
				output <= andg;
			when "011" => 
				output <= org;
			when "100" => 
				output <= norg;
			when "101" => 
				output <= xorg;
			when "110" => 
				output <= barrel;
			when others => 
		end case;
	end process;
end struct;
