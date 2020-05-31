LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--use IEEE.numeric_std.all;

library work;
-- Package Declaration Section
package axi_cam_pkg is
  
  CONSTANT C_NUM_LINES     : natural := 480;  --2; --480;
  -- hp full frame : (( 640 * 2 - 2 bytes per pixel ) * 480 (num lines) / 128(transfer in one hp transfer)-1 = 4799
  -- 1 hp transfer takes 16 * 64bits = 128 bytes
  CONSTANT C_HP_FULL_FRAME : natural := 4799; --19; --4799 
   
  -- cam test
  CONSTANT C_VSYNC_DLY : natural := 1400;  
  CONSTANT C_P1_DLY    : natural := 1424; 
  CONSTANT C_HREF_DLY  : natural := 1280;  -- 640 * 2
  CONSTANT C_P2_DLY    : natural := 144;  
  CONSTANT C_P3_DLY    : natural := 1424; 
      
end package axi_cam_pkg;
 
