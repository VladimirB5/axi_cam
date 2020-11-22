LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

library work;
use work.axi_cam_pkg.all;

ENTITY cam_capture IS
  generic (
    G_DIAG : boolean -- diagnostig logic added
  );
  port (
   -- camera interaface 
   clk        : IN    std_logic;     
   vsync      : IN    std_logic;
   href       : IN    std_logic;
   data       : IN    std_logic_vector(7 downto 0);
   -- internal signals
   rstn       : IN    std_logic;
   ena        : IN    std_logic; -- block enable
   run        : IN    std_logic; -- run capturing
   busy       : OUT   std_logic; -- capture in progress
   href_busy  : OUT   std_logic; -- href recieved
   frame_mis  : OUT   std_logic_vector(31 downto 0); -- frame missed
   frm_mis_ch : OUT   std_logic; -- frame miss change (used for resynchronization)
   error      : OUT   std_logic;
   -- fifo interface
   data_w     : OUT std_logic_vector(63 downto 0);
   we         : OUT std_logic;
   full_w     : IN  std_logic
  ); 
END ENTITY cam_capture;

ARCHITECTURE rtl OF cam_capture IS
  signal data_c, data_s                 : std_logic_vector(63 downto 0);
  signal cnt_c, cnt_s                   : unsigned(2 downto 0);
  signal href_cnt_c, href_cnt_s         : unsigned(8 downto 0);
  signal we_c, we_s                     : std_logic;
  signal busy_c, busy_s                 : std_logic;
  signal frame_miss_c, frame_miss_s     : unsigned(31 downto 0);
  signal frame_miss_change_c            : std_logic;
  signal frame_miss_change_s            : std_logic;
  signal vsync_s, vsync_c               : std_logic; -- used for frame missed counter
  signal href_busy_c, href_busy_s       : std_logic;
  signal err_c, err_s                   : std_logic;
  -- fsm read declaration
  TYPE t_capture_state IS (S_IDLE, S_FINISH, S_WAIT_VSYNC_HIGH, S_WAIT_VSYNC_LOW, S_WAIT_HREF, S_CAPTURE, S_WRITE, S_ERR);
  SIGNAL fsm_cap_c, fsm_cap_s :t_capture_state;   
   
BEGIN
-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------    
  state_reg : PROCESS (clk, rstn)
   BEGIN
    IF rstn = '0' THEN
      fsm_cap_s      <= S_IDLE;
      cnt_s          <= (others => '0');
      we_s           <= '0';
      data_s         <= (others => '0');
      busy_s         <= '0';
      href_cnt_s     <= (others => '0');
      href_busy_s    <= '0';
      err_s          <= '0';
    ELSIF clk = '1' AND clk'EVENT THEN
      fsm_cap_s      <= fsm_cap_c;
      cnt_s          <= cnt_c;
      we_s           <= we_c;      
      data_s         <= data_c;
      busy_s         <= busy_c;
      href_cnt_s     <= href_cnt_c;
      href_busy_s    <= href_busy_c;
      err_s          <= err_c;
    END IF;       
  END PROCESS state_reg;
  
  frame_missed_yes: IF G_DIAG = true GENERATE
    frm_reg : PROCESS (clk, rstn)
    BEGIN
      IF rstn = '0' THEN
        frame_miss_s        <= (others => '0');
        frame_miss_change_s <= '0';
        vsync_s             <= '0';
      ELSIF clk = '1' AND clk'EVENT THEN
        frame_miss_s        <= frame_miss_c;
        frame_miss_change_s <= frame_miss_change_c;
        vsync_s             <= vsync_c;
      END IF;       
    END PROCESS frm_reg;   
  END GENERATE frame_missed_yes;
  
  frame_missed_no: IF G_DIAG = false GENERATE
    frame_miss_s        <= (others => '0');
    frame_miss_change_s <= '0';  
    frame_miss_c        <= (others => '0');
    frame_miss_change_c <= '0';     
    vsync_s             <= '0';
    vsync_c             <= '0';
  END GENERATE frame_missed_no;  

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
  miss_cnt_gen: IF G_DIAG = true GENERATE
    vsync_c <= vsync; -- one edge delay
    
    frm_miss_cnt: PROCESS(ena, run, vsync, vsync_s, fsm_cap_s, fsm_cap_c) 
    BEGIN 
      frame_miss_change_c <= frame_miss_change_s;
      frame_miss_c        <= frame_miss_s;
      IF ena = '0' THEN
        frame_miss_c        <= (others => '0');
        frame_miss_change_c <= NOT frame_miss_change_s;
      ELSIF vsync_s = '1' AND vsync = '0' AND fsm_cap_s = S_FINISH AND fsm_cap_c = S_FINISH THEN -- falling edge on VSYNC, 
        frame_miss_c        <= frame_miss_s + 1;
        frame_miss_change_c <= NOT frame_miss_change_s;
      END IF;
    END PROCESS frm_miss_cnt;
  END GENERATE miss_cnt_gen;
  

-------------------------------------------------------------------------------
-- FSM
-------------------------------------------------------------------------------
  
 next_state_capture_logic : PROCESS (fsm_cap_s, cnt_s, vsync, href, full_w, run, ena, href_cnt_s)
 BEGIN
    fsm_cap_c <= fsm_cap_s;
    CASE fsm_cap_s IS
      WHEN S_IDLE =>
        IF ena = '1' and run = '1' THEN
          fsm_cap_c <= S_WAIT_VSYNC_HIGH;
        END IF;  
        
      WHEN S_FINISH => 
        IF ena = '0' THEN
          fsm_cap_c <= S_IDLE;
        ELSIF run = '1' AND vsync = '1' THEN
          fsm_cap_c <= S_WAIT_VSYNC_LOW;
        ELSIF run = '1' THEN
          fsm_cap_c <= S_WAIT_VSYNC_HIGH;
        END IF;
      
      WHEN S_WAIT_VSYNC_HIGH =>
        IF ena = '0' THEN
          fsm_cap_c <= S_IDLE;
        ELSIF vsync = '1' THEN
          fsm_cap_c <= S_WAIT_VSYNC_LOW;
        END IF;
        
      WHEN S_WAIT_VSYNC_LOW =>
        IF ena = '0' THEN
          fsm_cap_c <= S_IDLE;
        ELSIF vsync = '0' THEN
          fsm_cap_c <= S_WAIT_HREF;
        END IF;        
      
      WHEN S_WAIT_HREF =>
        IF ena = '0' THEN
          fsm_cap_c <= S_IDLE;      
        ELSIF href = '1' THEN
          fsm_cap_c <= S_CAPTURE;
        ELSIF href_cnt_s = C_NUM_LINES THEN
          fsm_cap_c <= S_FINISH;
        END IF;
      
      WHEN S_CAPTURE =>
        IF ena = '0' THEN
          fsm_cap_c <= S_IDLE;
        ELSIF cnt_s = 7 THEN 
          fsm_cap_c <= S_WRITE;
        END IF;
        
      WHEN S_WRITE =>
        IF full_w = '1' THEN
          fsm_cap_c <= S_ERR;
        ELSIF href = '0' THEN
          fsm_cap_c <= S_WAIT_HREF; 
        ELSE 
          fsm_cap_c <= S_CAPTURE;
        END IF;
        
      WHEN S_ERR => 
        if ena = '0' then
          fsm_cap_c <= S_IDLE;
        end if;
    END CASE;        
 END PROCESS next_state_capture_logic;
 
 output_capture_logic : PROCESS (fsm_cap_c, cnt_s, data_s, data, href_cnt_s, fsm_cap_s, href_cnt_s)
 BEGIN
    we_c <= '0';
    data_c <= data_s;
    cnt_c  <= cnt_s;
    busy_c <= '1';
    href_busy_c <= '0';
    err_c <= '0';
    href_cnt_c <= href_cnt_s;
    CASE fsm_cap_c IS
      WHEN S_IDLE =>
        cnt_c <= (others => '0');
        busy_c <= '0';
        href_cnt_c <= (OTHERS => '0');
        
      WHEN S_FINISH =>
        busy_c <= '0';
        href_cnt_c <= (OTHERS => '0');
        
      WHEN S_WAIT_VSYNC_HIGH =>
      
      WHEN S_WAIT_VSYNC_LOW =>      
        
      WHEN S_WAIT_HREF =>
        href_busy_c <= '1';
        if (fsm_cap_s = S_WRITE) then
          href_cnt_c <= href_cnt_s + 1;
        end if;
        
      WHEN S_CAPTURE =>
        cnt_c <= cnt_s + 1;
        data_c(63 downto 8) <= data_s(55 downto 0);
        data_c(7 downto 0)  <= data;
        href_busy_c <= '1';
        
      WHEN S_WRITE =>
        cnt_c <= cnt_s + 1;
        we_c <= '1';
        data_c(63 downto 8) <= data_s(55 downto 0);
        data_c(7 downto 0)  <= data;
        href_busy_c <= '1';
        
       WHEN S_ERR => 
         err_c <= '1';
    END CASE;        
 END PROCESS output_capture_logic; 
 
 
-------------------------------------------------------------------------------
-- output assigment
-------------------------------------------------------------------------------
data_w     <= data_s;
we         <= we_s;
busy       <= busy_s;
href_busy  <= href_busy_s;
frame_mis  <= std_logic_vector(frame_miss_s);
frm_mis_ch <= frame_miss_change_s;
error      <= err_s;
END ARCHITECTURE rtl;
