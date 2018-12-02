LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY cam_test IS
  generic (
   vsync_dly   : natural := 1400;  
   p1_dly      : natural := 1424; 
   href_dly    : natural := 1280;  
   p2_dly      : natural := 144;  
   p3_dly      : natural := 1424;  
   lines_num   : natural := 480
  );
  port (
   clk         : IN    std_logic;
   rstn        : IN    std_logic;
   -- data from camera
   vsync       : IN    std_logic;
   href        : IN    std_logic;
   data        : IN    std_logic_vector(7 downto 0);
   -- data to capture
   vsync_cap   : OUT   std_logic;
   href_cap    : OUT   std_logic;
   data_cap    : OUT   std_logic_vector(7 downto 0);   
   -- control interface
   test_ena    : IN    std_logic;
   new_frame   : OUT   std_logic
  ); 
END ENTITY cam_test; 

ARCHITECTURE rtl OF cam_test IS
  signal cnt1_c        : unsigned(10 downto 0); -- max 1424
  signal cnt1_s        : unsigned(10 downto 0);
  signal cnt2_c        : unsigned(9 downto 0);  -- max 640 
  signal cnt2_s        : unsigned(9 downto 0);
  signal send_frames_c : unsigned(2 downto 0);
  signal send_frames_s : unsigned(2 downto 0);
  signal vsync_cap_c   : std_logic;
  signal vsync_cap_s   : std_logic;
  signal href_cap_c    : std_logic;
  signal href_cap_s    : std_logic;
  signal data_cap_c    : std_logic_vector(7 downto 0);
  signal data_cap_s    : std_logic_vector(7 downto 0);
  signal data_cnt_c    : unsigned(4 downto 0);
  signal data_cnt_s    : unsigned(4 downto 0);
  signal mux_c         : std_logic;
  signal mux_s         : std_logic;
  signal new_frame_c   : std_logic;
  signal new_frame_s   : std_logic;
  -- fsm read declaration
  TYPE t_test_state IS (S_IDLE, S_VSYNC, S_P1, S_HREF, S_P2, S_P3, S_END);
  SIGNAL fsm_test_c, fsm_test_s :t_test_state;  
BEGIN
-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------
  state_reg : PROCESS (clk, rstn)
   BEGIN
    IF rstn = '0' THEN
      fsm_test_s <= S_IDLE;
      cnt1_s        <= (others => '0');
      cnt2_s        <= (others => '0');
      send_frames_s <= (others => '0');
      vsync_cap_s   <= '0';
      href_cap_s    <= '0';
      data_cap_s    <= (others => '0');
      data_cnt_s    <= (others => '0');
      new_frame_s   <= '0';
    ELSIF clk = '1' AND clk'EVENT THEN
      fsm_test_s <= fsm_test_c;
      cnt1_s        <= cnt1_c;
      cnt2_s        <= cnt2_c;
      send_frames_s <= send_frames_c;
      vsync_cap_s   <= vsync_cap_c;
      href_cap_s    <= href_cap_c;
      data_cap_s    <= data_cap_c;     
      data_cnt_s    <= data_cnt_c;
      new_frame_s   <= new_frame_c;
    END IF;       
  END PROCESS state_reg;

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
 next_state_test_logic : PROCESS (fsm_test_s, cnt1_s, cnt2_s, data_cnt_s, send_frames_s, test_ena)
 BEGIN
    fsm_test_c     <= fsm_test_s;
    send_frames_c  <= send_frames_s;
    cnt1_c         <= cnt1_s;
    cnt2_c         <= cnt2_s;
    data_cnt_c     <= data_cnt_s;
    CASE fsm_test_s IS
      WHEN S_IDLE =>
        cnt1_c <= (others => '0');
        cnt2_c <= (others => '0');
        IF test_ena = '1' THEN
          fsm_test_c <= S_VSYNC;
        END IF;  
      
      WHEN S_VSYNC =>
        IF test_ena = '0' THEN
          fsm_test_c <= S_IDLE;
        ELSIF cnt1_s = vsync_dly-1  THEN
          cnt1_c     <= (others => '0');
          fsm_test_c <= S_P1;
        ELSE 
          cnt1_c <= cnt1_s + 1;
        END IF;
      
      WHEN S_P1 =>
        IF test_ena = '0' THEN
          fsm_test_c <= S_IDLE;
        ELSIF cnt1_s = p1_dly-1  THEN
          cnt1_c     <= (others => '0');
          fsm_test_c <= S_HREF;
        ELSE 
          cnt1_c <= cnt1_s + 1;
        END IF;
      
      WHEN S_HREF =>
        IF test_ena = '0' THEN
          fsm_test_c <= S_IDLE;
        ELSIF cnt1_s = href_dly-1  THEN
          cnt1_c     <= (others => '0');
          data_cnt_c <= (others => '0');
          fsm_test_c <= S_P2;
        ELSE 
          cnt1_c     <= cnt1_s + 1;
          data_cnt_c <= data_cnt_s + 1;
        END IF;
        
      WHEN S_P2 =>
        IF test_ena = '0' THEN
          fsm_test_c <= S_IDLE;
        ELSIF cnt1_s = p2_dly-1 AND cnt2_s = lines_num-1 THEN
          cnt1_c     <= (others => '0');
          cnt2_c     <= (others => '0');
          fsm_test_c <= S_P3;          
        ELSIF cnt1_s = p2_dly  THEN
          cnt1_c     <= (others => '0');
          cnt2_c     <= cnt2_s + 1;
          fsm_test_c <= S_HREF;
        ELSE 
          cnt1_c <= cnt1_s + 1;
        END IF;
        
      WHEN S_P3 =>
        IF test_ena = '0' THEN
          fsm_test_c <= S_IDLE;
        ELSIF cnt1_s = p3_dly-1  THEN
          cnt1_c     <= (others => '0');
          send_frames_c <= send_frames_s + 1;
          fsm_test_c <= S_END;
        ELSE 
          cnt1_c <= cnt1_s + 1;
        END IF;   
      
      WHEN S_END =>
        cnt1_c <= (others => '0');
        cnt2_c <= (others => '0');        
        IF test_ena = '0' THEN
          fsm_test_c <= S_IDLE;
        ELSE
          fsm_test_c <= S_VSYNC;
        END IF;
    END CASE;        
 END PROCESS next_state_test_logic;

  output_capture_logic : PROCESS (fsm_test_c, data_cnt_c, data_cap_s, new_frame_s)
 BEGIN    
    href_cap_c  <= '0';
    vsync_cap_c <= '0';
    data_cap_c  <= data_cap_s;
    mux_c       <= '1';
    new_frame_c <= '0';
    CASE fsm_test_c IS
      WHEN S_IDLE =>
        mux_c <= '0';
      
      WHEN S_VSYNC =>
        vsync_cap_c <= '1';
      
      WHEN S_P1 =>

      
      WHEN S_HREF =>
        href_cap_c <= '1';
        IF data_cnt_c < 16 THEN
          data_cap_c <= (others => '1');
        ELSE
          data_cap_c <= (others => '0');
        END IF;  
        
      WHEN S_P2 =>

        
      WHEN S_P3 =>
 
      
      WHEN S_END =>
        new_frame_c <= '1';
    END CASE;        
 END PROCESS output_capture_logic; 

-------------------------------------------------------------------------------
-- output assigment
-------------------------------------------------------------------------------
 vsync_cap <= vsync when mux_s = '0' else vsync_cap_s;
 href_cap  <= href  when mux_s = '0' else href_cap_s;
 data_cap  <= data  when mux_s = '0' else data_cap_s; 
 new_frame <= new_frame_s;
END ARCHITECTURE rtl;