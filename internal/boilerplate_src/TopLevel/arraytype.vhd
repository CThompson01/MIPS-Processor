library IEEE;
use IEEE.std_logic_1164.all;

package arraytype is  -- use work.arraytype.reg_out;
type reg_out is array(0 to 31) of std_logic_vector(31 downto 0);
end arraytype;

