LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY int_ctrl IS
  port (
   rstn       : IN std_logic;
   clk        : IN std_logic;
   
   int_ena    : IN std_logic;
   ena        : IN std_logic; -- axi hp block enabled
   cap_err    : IN std_logic;
   hp_busy    : IN std_logic; -- when goes from 1 to 0 it 
   sts_fin_clr: IN std_logic; -- clear status and interrupt
   sts_err_clr: IN std_logic; -- clear status and interrupt
   sts_fin    : OUT std_logic; -- sts finished
   sts_err    : OUT std_logic; -- status error
   
   int        : OUT std_logic

  ); 
END ENTITY int_ctrl;

ARCHITECTURE rtl OF int_ctrl IS
  -- signals
  
  -- registers
  SIGNAL sts_fin_c, sts_fin_s         : std_logic;
  SIGNAL sts_err_c, sts_err_s         : std_logic;
  SIGNAL int_c, int_s                 : std_logic;
  SIGNAL cap_err_dly_c, cap_err_dly_s : std_logic;
  SIGNAL hp_busy_dly_c, hp_busy_dly_s : std_logic;
   
BEGIN
-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------    
  state_reg : PROCESS (clk, rstn)
   BEGIN
    IF rstn = '0' THEN
      sts_fin_s     <= '0';
      sts_err_s     <= '0';
      int_s         <= '0';
      cap_err_dly_s <= '0';
      hp_busy_dly_s <= '0';
    ELSIF clk = '1' AND clk'EVENT THEN
      sts_fin_s     <= sts_fin_c;
      sts_err_s     <= sts_err_c;
      int_s         <= int_c;
      cap_err_dly_s <= cap_err_dly_c;
      hp_busy_dly_s <= hp_busy_dly_c;
    END IF;       
  END PROCESS state_reg;

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
  -- when interupt is enabled save cap_err and hp_busy
  cap_err_dly_c <= cap_err WHEN int_ena = '1' ELSE 
                   '0';
                   
  hp_busy_dly_c <= hp_busy WHEN int_ena = '1' ELSE 
                   '0';
  
  -- interrupt when transfer finished
  sts_finish: PROCESS (int_ena, hp_busy, hp_busy_dly_s, ena, sts_fin_clr, sts_fin_s)
  BEGIN
    sts_fin_c <= sts_fin_s;
    IF int_ena = '1' THEN
      IF hp_busy = '0' AND hp_busy_dly_s = '1' AND ena = '1' AND sts_fin_clr = '0' THEN 
        sts_fin_c <= '1';
      ELSIF sts_fin_clr = '1' THEN 
        sts_fin_c <= '0';
      END IF;
    ELSE 
      sts_fin_c <= '0';
    END IF;
  END PROCESS sts_finish;
  
  -- interrupt in case error
  sts_error: PROCESS (int_ena, cap_err, cap_err_dly_s, ena, sts_err_clr, sts_err_s)
  BEGIN
    sts_err_c <= sts_err_s;
    IF int_ena = '1' THEN
      IF cap_err = '1' AND cap_err_dly_s = '0' AND ena = '1' AND sts_err_clr = '0' THEN 
        sts_err_c <= '1';
      ELSIF sts_err_clr = '1' THEN 
        sts_err_c <= '0';
      END IF;
    ELSE 
      sts_err_c <= '0';
    END IF;
  END PROCESS sts_error;  
  
  -- final interrupt
  int_c <= sts_fin_c OR sts_err_c;
   
-------------------------------------------------------------------------------
-- output assigment
-------------------------------------------------------------------------------
   sts_fin    <= sts_fin_s;
   sts_err    <= sts_err_s;
   
   int        <= int_s;
END ARCHITECTURE rtl;
 
