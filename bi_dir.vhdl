-------------------------------------------------------------------------------
-- bi directional IO
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity bi_dir is
  port(T     : in    std_logic;
       I     : in    std_logic;
       O_NEW : out   std_logic;
       IO    : inout std_logic);
end bi_dir;

architecture rtl of bi_dir is
begin

    IO <= I when T = '0' else 'Z';
    O_NEW <= IO;

end rtl;
