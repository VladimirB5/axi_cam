LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

-- next two line uncoment in vivado
--Library UNISIM;
--use UNISIM.vcomponents.all;


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

ARCHITECTURE rtl OF clk_mux IS

BEGIN

 xclk   <= clk;
 
 mux_gen_0: if G_MUX = true generate
   -- BUFGMUX_CTRL: 2-to-1 Global Clock MUX Buffer
   --               Artix-7
   -- Xilinx HDL Language Template, version 2018.2
   
   BUFGMUX_CTRL_inst : BUFGMUX_CTRL
   port map (
     O => clk_25,   -- 1-bit output: Clock output
     I0 => clk, -- 1-bit input: Clock input (S=0)
     I1 => pclk, -- 1-bit input: Clock input (S=1)
     S => mux    -- 1-bit input: Clock select
   );

   -- End of BUFGMUX_CTRL_inst instantiation
 end generate mux_gen_0;
 
 mux_gen_1: if G_MUX = false generate
  clk_25 <= pclk;
 end generate mux_gen_1;
 
END ARCHITECTURE rtl;
