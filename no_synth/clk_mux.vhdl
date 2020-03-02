-------------------------------------------------------------------------------
-- model for used with GHDL
-- not used for synthesys
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;


ENTITY clk_mux IS
  generic (
    G_MUX : boolean -- if mux is use
  );
  port (
    clk    : IN std_logic;  -- input clk from clk source
    pclk   : IN std_logic;  -- input clk from camera
    mux    : IN std_logic;
    xclk   : OUT std_logic; -- output to camera
    clk_25 : OUT std_logic  -- output to 25mhz clock domain
    
  ); 
END ENTITY clk_mux; 

ARCHITECTURE behavior OF clk_mux IS

BEGIN

 xclk   <= clk;
 
 mux_gen_0: if G_MUX = true generate

   clk_25 <= clk when mux = '0' ELSE 
             pclk;
             
 end generate mux_gen_0;
 
 mux_gen_1: if G_MUX = false generate
  clk_25 <= pclk;
 end generate mux_gen_1;
 
END ARCHITECTURE behavior;
 
