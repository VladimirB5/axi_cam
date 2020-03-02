LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity sccb_sender is
    Port ( clk   : in std_logic;
           rst_n : in std_logic;
           data  : in std_logic_vector(23 downto 0);
           start : in std_logic;
           busy  : out std_logic;
           ack   : out std_logic;
           siod_r: in std_logic;
           siod_w: out std_logic;
           sioc  : out std_logic
        );
end entity sccb_sender;

architecture rtl of sccb_sender is
  -- constants 
  -- constant for 100 mhz clock
  constant c_start_setup_hold: unsigned(7 downto 0) := X"64"; -- 100
  constant c_data_setup_hold : unsigned(7 downto 0) := X"4b"; --75
  constant c_clk_high        : unsigned(7 downto 0) := X"64"; --100
  constant c_bus_free        : unsigned(7 downto 0) := X"96"; --150
  
  --signals
  signal mux_data : std_logic;
  
  -- registers
  signal cnt_delay_c, cnt_delay_s : unsigned(7 downto 0); -- register for delay 
  signal cnt_data_c, cnt_data_s   : unsigned(2 downto 0); -- number of sended bits
  signal cnt_word_c, cnt_word_s   : unsigned(1 downto 0);  -- number of sended words
  signal busy_c, busy_s           : std_logic;
  signal siod_c, siod_s           : std_logic;
  signal sioc_c, sioc_s           : std_logic;
  signal ack_c, ack_s             : std_logic;

  -- fsm sccb_sender declaration
  TYPE t_sccb_sender_state IS (S_IDLE, S_START_SETUP, S_START_HOLD, S_CLK_SETUP, S_CLK, S_CLK_HOLD, S_ACK_SETUP, S_ACK, S_ACK_HOLD, S_STOP_DEL, S_STOP_SETUP, S_BUS_FREE);
  SIGNAL fsm_sccb_sender_c, fsm_sccb_sender_s :t_sccb_sender_state;  
begin
-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------
  state_reg : PROCESS (clk, rst_n)
   BEGIN
    IF rst_n = '0' THEN
      fsm_sccb_sender_s <= S_IDLE;
      cnt_delay_s <= (others => '0');
      cnt_data_s  <= (others => '1'); -- sending msb to lsb 7 -> 0
      cnt_word_s  <= (others => '0');
      siod_s      <= '1';
      sioc_s      <= '1';
      busy_s      <= '0';
      ack_s       <= '0';
    ELSIF clk = '1' AND clk'EVENT THEN
      fsm_sccb_sender_s <= fsm_sccb_sender_c;
      cnt_delay_s <= cnt_delay_c;
      cnt_data_s  <= cnt_data_c;
      cnt_word_s  <= cnt_word_c;
      siod_s      <= siod_c;
      sioc_s      <= sioc_c;
      busy_s      <= busy_c;
      ack_s       <= ack_c;
    END IF;       
  END PROCESS state_reg;

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
 next_state_test_logic : PROCESS (fsm_sccb_sender_s, cnt_delay_s, cnt_data_s, start, cnt_word_s, ack_s, siod_r)
 BEGIN
    fsm_sccb_sender_c <= fsm_sccb_sender_s;
    cnt_delay_c       <= cnt_delay_s;
    cnt_data_c        <= cnt_data_s;
    cnt_word_c        <= cnt_word_s;        
    ack_c             <= ack_s;
    CASE fsm_sccb_sender_s IS
      WHEN S_IDLE =>
        cnt_delay_c <= (others => '0');
        cnt_data_c  <= (others => '1');
        cnt_word_c  <= (others => '0');
        IF start = '1' THEN
          fsm_sccb_sender_c <= S_START_SETUP;
        END IF;
   
      WHEN S_START_SETUP =>
        IF cnt_delay_s = c_start_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_START_HOLD;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;
        
      WHEN S_START_HOLD =>
        IF cnt_delay_s =  c_start_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_CLK_SETUP;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;      
      
      WHEN S_CLK_SETUP =>
        IF cnt_delay_s =  c_data_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_CLK;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;       
      
      WHEN S_CLK =>
        IF cnt_delay_s =  c_clk_high-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_CLK_HOLD;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;  
      
      WHEN S_CLK_HOLD =>
        IF cnt_delay_s =  c_data_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          IF cnt_data_s = 0 THEN
            cnt_data_c <= (others => '1');
            fsm_sccb_sender_c <= S_ACK_SETUP;
          ELSE 
            cnt_data_c <= cnt_data_s - 1;
            fsm_sccb_sender_c <= S_CLK_SETUP;            
          END IF;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;      
      
      WHEN S_ACK_SETUP =>
        IF cnt_delay_s =  c_data_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_ACK;
          cnt_word_c <= cnt_word_s + 1;
          ack_c <= ack_s OR siod_r;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;        
      
      WHEN S_ACK =>
        IF cnt_delay_s =  c_clk_high-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_ACK_HOLD;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;       
      
      WHEN S_ACK_HOLD =>
        IF cnt_delay_s =  c_data_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          IF cnt_word_s = 3 THEN
            fsm_sccb_sender_c <= S_STOP_DEL;
          ELSE 
            fsm_sccb_sender_c <= S_CLK_SETUP;            
          END IF;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;        
        
      WHEN S_STOP_DEL => -- this state not defined in spec, hold both data and clock before stop  
        IF cnt_delay_s =  c_data_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_STOP_SETUP;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;       
      
      WHEN S_STOP_SETUP =>
        IF cnt_delay_s =  c_data_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_BUS_FREE;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;         
      
      WHEN S_BUS_FREE =>
        IF cnt_delay_s =  c_data_setup_hold-1 THEN
          cnt_delay_c <= (others => '0');
          fsm_sccb_sender_c <= S_IDLE;
        ELSE 
          cnt_delay_c <= cnt_delay_s + 1;
        END IF;         
    END CASE;        
 END PROCESS next_state_test_logic;

  output_capture_logic : PROCESS (fsm_sccb_sender_c, busy_s, sioc_s, siod_s, mux_data)
 BEGIN    
    busy_c <= '1';
    sioc_c <= '0';
    siod_c <= siod_s;
    CASE fsm_sccb_sender_c IS
      WHEN S_IDLE =>
        busy_c <= '0';
        sioc_c <= '1';
      WHEN S_START_SETUP =>
        sioc_c <= '1';
        siod_c <= '1';
      WHEN S_START_HOLD =>
        sioc_c <= '1';
        siod_c <= '0';
      WHEN S_CLK_SETUP => 
        siod_c <= mux_data;
      WHEN S_CLK =>
        sioc_c <= '1';
      WHEN S_CLK_HOLD =>
      
      WHEN S_ACK_SETUP =>
        siod_c <= '1';
      WHEN S_ACK =>
        sioc_c <= '1';
      WHEN S_ACK_HOLD =>
      
      WHEN S_STOP_DEL =>
        sioc_c <= '0';
        siod_c <= '0';
      WHEN S_STOP_SETUP =>
        sioc_c <= '1';
        siod_c <= '0';
      WHEN S_BUS_FREE =>
        sioc_c <= '1';
        siod_c <= '1';
    END CASE;        
 END PROCESS output_capture_logic; 
 
 mux: PROCESS (data, cnt_data_s, cnt_word_s)
   variable mux_a_out : std_logic_vector(7 downto 0);
 BEGIN
   CASE cnt_word_s IS
     WHEN B"00" =>
       mux_a_out := data(23 downto 16);
     WHEN B"01" =>
       mux_a_out := data(15 downto 8);
     WHEN others => 
       mux_a_out := data(7 downto 0);
   END CASE;
   
   mux_data <= mux_a_out(to_integer(cnt_data_s));   --sending msb to lsb 7 -> 0
 END PROCESS mux;
-------------------------------------------------------------------------------
-- output assigment
------------------------------------------------------------------------------- 
busy   <= busy_s;
sioc   <= sioc_s; 
siod_w <= siod_s; 
ack    <= ack_s;

end rtl;

