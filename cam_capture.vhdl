LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY cam_capture IS
  port (
   -- camera interaface 
   clk        : IN    std_logic;     
   vsync      : IN    std_logic;
   href       : IN    std_logic;
   data       : IN    std_logic_vector(7 downto 0);
   reset      : OUT   std_logic;
   pwdn       : OUT   std_logic;
   -- internal signals
   rstn       : IN    std_logic;
   power      : IN    std_logic;
   new_frame  : OUT   std_logic;
   -- fifo interface
   data_w     : OUT std_logic_vector(63 downto 0);
   we         : OUT std_logic;
   full_w     : IN  std_logic
  ); 
END ENTITY cam_capture;

ARCHITECTURE rtl OF cam_capture IS
  signal data_c : std_logic_vector(63 downto 0);
  signal data_s : std_logic_vector(63 downto 0);
  signal cnt_c  : unsigned(2 downto 0);
  signal cnt_s  : unsigned(2 downto 0);
  signal we_c   : std_logic;
  signal we_s   : std_logic;
  -- fsm read declaration
  TYPE t_capture_state IS (S_IDLE, S_WAIT_VSYNC, S_WAIT_HREF, S_CAPTURE, S_WRITE);
  SIGNAL fsm_cap_c, fsm_cap_s :t_capture_state;   
   
BEGIN
-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------    
  state_reg : PROCESS (clk, rstn)
   BEGIN
    IF rstn = '0' THEN
      fsm_cap_s <= S_IDLE;
      cnt_s     <= (others => '0');
      we_s      <= '0';
      data_s    <= (others => '0');
    ELSIF clk = '1' AND clk'EVENT THEN
      fsm_cap_s <= fsm_cap_c;
      cnt_s     <= cnt_c;
      we_s      <= we_c;      
      data_s    <= data_c;
    END IF;       
  END PROCESS state_reg;

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
  
 next_state_capture_logic : PROCESS (fsm_cap_s, cnt_s, power, vsync, href, full_w)
 BEGIN
    fsm_cap_c <= fsm_cap_s;
    CASE fsm_cap_s IS
      WHEN S_IDLE =>
        IF power = '1' and vsync = '1' THEN
          fsm_cap_c <= S_WAIT_VSYNC;
        END IF;  
      
      WHEN S_WAIT_VSYNC =>
        IF power = '0' THEN
          fsm_cap_c <= S_IDLE;
        ELSIF vsync = '0' THEN
          fsm_cap_c <= S_WAIT_HREF;
        END IF;
      
      WHEN S_WAIT_HREF =>
        IF power = '0' THEN
          fsm_cap_c <= S_IDLE;      
        ELSIF vsync = '1' THEN
          fsm_cap_c <= S_WAIT_VSYNC;
        ELSIF href = '1' and full_w = '0' THEN
          fsm_cap_c <= S_CAPTURE;
        END IF;
      
      WHEN S_CAPTURE =>
        IF power = '0' THEN
          fsm_cap_c <= S_IDLE;
        ELSIF full_w = '1' THEN -- when fifo is full stop write to fifo 
          fsm_cap_c <= S_WAIT_HREF;
        ELSIF cnt_s = 7 THEN 
          fsm_cap_c <= S_WRITE;
        END IF;
        
      WHEN S_WRITE =>
        IF href = '0' OR full_w = '1' THEN
          fsm_cap_c <= S_WAIT_HREF;
        ELSE 
          fsm_cap_c <= S_CAPTURE;
        END IF;
    END CASE;        
 END PROCESS next_state_capture_logic;
 
 output_capture_logic : PROCESS (fsm_cap_c, cnt_s, data_s, data)
 BEGIN
    we_c <= '0';
    data_c <= data_s;
    cnt_c  <= cnt_s;
    CASE fsm_cap_c IS
      WHEN S_IDLE =>
        cnt_c <= (others => '0');
        
      WHEN S_WAIT_VSYNC =>
      
      WHEN S_WAIT_HREF =>
      
      WHEN S_CAPTURE =>
        cnt_c <= cnt_s + 1;
        data_c(63 downto 8) <= data_s(55 downto 0);
        data_c(7 downto 0)  <= data;
        
      WHEN S_WRITE =>
        cnt_c <= cnt_s + 1;
        we_c <= '1';
        data_c(63 downto 8) <= data_s(55 downto 0);
        data_c(7 downto 0)  <= data;       
    END CASE;        
 END PROCESS output_capture_logic; 
 
 
-------------------------------------------------------------------------------
-- output assigment
-------------------------------------------------------------------------------
RESET     <= not rstn;
pwdn      <= power;
new_frame <= vsync;
data_w    <= data_s;
we        <= we_s;
END ARCHITECTURE rtl;
