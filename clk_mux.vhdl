LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY clk_mux IS
  port (
    clk    : IN std_logic;  -- input clk from clk source
    pclk   : IN std_logic;  -- input clk from camera
    mux    : IN std_logic;
    xclk   : OUT std_logic; -- output to camera
    clk_25 : OUT std_logic  -- output to 25mhz clock domain
    
  ); 
END ENTITY clk_mux; 

ARCHITECTURE rtl OF clk_mux IS

BEGIN

 xclk   <= clk;
 clk_25 <= clk when mux = '0' else pclk;
END ARCHITECTURE rtl;