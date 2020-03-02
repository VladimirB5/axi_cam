-------------------------------------------------------------------------------
-- tri state output
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity tri_out is
  port(T    : in  std_logic;
       I    : in  std_logic;
       O    : out std_logic);
end tri_out;

architecture rtl of tri_out is
begin

    O <= I when T = '0' else 'Z';

end rtl; 
