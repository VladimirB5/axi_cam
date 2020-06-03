LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

library work;
use work.axi_cam_pkg.all;

ENTITY axi_hp IS
  port (
  -- AXI signals
  -- Global signals
  ACLK    : IN std_logic;
  ARESETn : IN std_logic;
  -- write adress channel
  AWADDR  : OUT std_logic_vector(31 downto 0);
  AWVALID : OUT std_logic;
  AWREADY : IN  std_logic;
  AWID    : OUT std_logic_vector(5 downto 0);   
  AWLOCK  : OUT std_logic_vector(1 downto 0); 
  AWCACHE : OUT std_logic_vector(3 downto 0); 
  AWPROT  : OUT std_logic_vector(2 downto 0); 
  AWLEN   : OUT std_logic_vector(3 downto 0); 
  AWSIZE  : OUT std_logic_vector(2 downto 0); 
  AWBURST : OUT std_logic_vector(1 downto 0); 
  AWQOS   : OUT std_logic_vector(3 downto 0);  
  -- write data channel  
  WDATA   : OUT std_logic_vector(63 downto 0);
  WVALID  : OUT std_logic;
  WREADY  : IN  std_logic;
  WID     : OUT std_logic_vector(5 downto 0);
  WLAST   : OUT std_logic;
  WSTRB   : OUT std_logic_vector(7 downto 0);
  WCOUNT  : IN  std_logic_vector(7 downto 0);
  WACOUNT : IN  std_logic_vector(5 downto 0);
  WRISSUECAP1EN : OUT std_logic;
  -- write response channel
  BVALID  : IN  std_logic;
  BREADY  : OUT std_logic;
  BID     : IN  std_logic_vector(5 downto 0);
  BRESP   : IN  std_logic_vector(1 downto 0);
  -- read address channel  
  ARADDR  : OUT std_logic_vector(31 downto 0);
  ARVALID : OUT std_logic;
  ARREADY : IN  std_logic;
  ARID    : OUT std_logic_vector(5 downto 0);    
  ARLOCK  : OUT std_logic_vector(1 downto 0);
  ARCACHE : OUT std_logic_vector(3 downto 0);
  ARPROT  : OUT std_logic_vector(2 downto 0);
  ARLEN   : OUT std_logic_vector(3 downto 0);
  ARSIZE  : OUT std_logic_vector(2 downto 0);
  ARBURST : OUT std_logic_vector(1 downto 0);
  ARQOS   : OUT std_logic_vector(3 downto 0);
  -- read data channel  
  RDATA   : IN  std_logic_vector(63 downto 0);
  RVALID  : IN  std_logic;
  RREADY  : OUT std_logic;
  RID     : IN  std_logic_vector(5 downto 0);    
  RLAST   : IN  std_logic;
  RRESP   : IN  std_logic_vector(1 downto 0);
  RCOUNT  : IN  std_logic_vector(7 downto 0);
  RACOUNT : IN  std_logic_vector(2 downto 0);
  RDISSUECAP1EN : OUT std_logic;
  
  -- zynq fifo signals
  re      : OUT std_logic;
  full_r  : IN  std_logic;
  empty   : IN  std_logic;
  data_r  : IN  std_logic_vector(63 downto 0);
  
  -- control signals
  ena      : IN  std_logic;
  run      : IN  std_logic;
  address  : IN  std_logic_vector(31 downto 0);
  addr_we  : IN  std_logic;
  curr_addr: OUT std_logic_vector(31 downto 0);
  num_frm  : OUT std_logic_vector(7 downto 0);
  busy     : OUT std_logic
  ); 
END ENTITY axi_hp; 
 
ARCHITECTURE rtl OF axi_hp IS
  signal curr_address_c : unsigned(31 downto 0); -- current address in axi transaction ass address
  signal curr_address_s : unsigned(31 downto 0);
  signal data_cnt_c     : unsigned(4 downto 0);
  signal data_cnt_s     : unsigned(4 downto 0);
  signal re_c           : std_logic;
  signal re_s           : std_logic;
  signal num_frame_s    : unsigned(7 downto 0);
  signal num_frame_c    : unsigned(7 downto 0);
  signal trn_num_c      : unsigned(12 downto 0); -- transaction number
  signal trn_num_s      : unsigned(12 downto 0);
  signal busy_c         : std_logic;
  signal busy_s         : std_logic;
  -- axi signal regisetrs
  signal awvalid_c      : std_logic;
  signal awvalid_s      : std_logic;
  signal wvalid_c       : std_logic;
  signal wvalid_s       : std_logic;
  signal wlast_c        : std_logic;
  signal wlast_s        : std_logic;
  signal wid_c          : unsigned(5 downto 0);
  signal wid_s          : unsigned(5 downto 0);
  signal bready_c       : std_logic;
  signal bready_s       : std_logic;
  signal wstrb_c        : std_logic_vector(7 downto 0);
  signal wstrb_s        : std_logic_vector(7 downto 0);
  
  -- fsm read declaration
  TYPE t_axi_state IS (S_IDLE, S_FINISH, S_WAIT_FIFO, S_AWVALID, S_WAIT_AWREADY, S_RE, S_SAVE, S_WVALID, S_WLAST, S_RESPONSE, S_END_FRAME);
  SIGNAL fsm_axi_c, fsm_axi_s :t_axi_state;  
BEGIN 
-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------
  state_reg : PROCESS (ACLK, ARESETn)
   BEGIN
    IF ARESETn = '0' THEN
      fsm_axi_s      <= S_IDLE;
      curr_address_s <= (others => '0');
      data_cnt_s     <= (others => '0');
      re_s           <= '0';
      num_frame_s    <= (others => '0');      
      trn_num_s      <= (others => '0');
      busy_s         <= '0';
      -- axi signals
      awvalid_s      <= '0';
      wvalid_s       <= '0';
      wlast_s        <= '0';
      wstrb_s        <= (others => '0');
      wid_s          <= (others => '0');
      bready_s       <= '0';
    ELSIF ACLK = '1' AND ACLK'EVENT THEN
      fsm_axi_s      <= fsm_axi_c;
      curr_address_s <= curr_address_c;
      data_cnt_s     <= data_cnt_c;
      re_s           <= re_c;
      num_frame_s    <= num_frame_c;
      trn_num_s      <= trn_num_c;
      busy_s         <= busy_c;
      -- axi signals
      awvalid_s      <= awvalid_c;
      wvalid_s       <= wvalid_c;
      wlast_s        <= wlast_c;
      wstrb_s        <= wstrb_c;      
      wid_s          <= wid_c;
      bready_s       <= bready_c;
    END IF;       
  END PROCESS state_reg;

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
  
 next_state_axi_hp_logic : PROCESS (fsm_axi_s, empty, ena, data_cnt_s, AWREADY, WREADY, wid_s, curr_address_s, trn_num_s, num_frame_s, 
                                    address, BVALID, run, addr_we)
 BEGIN
    fsm_axi_c      <= fsm_axi_s;
    data_cnt_c     <= data_cnt_s;
    wid_c          <= wid_s;
    curr_address_c <= curr_address_s;
    trn_num_c      <= trn_num_s;
    num_frame_c    <= num_frame_s;
    CASE fsm_axi_s IS
      WHEN S_IDLE =>
        data_cnt_c     <= (others => '0');
        IF addr_we = '1' THEN
          curr_address_c <= unsigned(address);
        END IF;
        trn_num_c      <= (others => '0');
        num_frame_c    <= (others => '0');
        wid_c          <= (others => '0');
        IF ena = '1' THEN
          fsm_axi_c <= S_WAIT_FIFO;
        END IF;  
        
      WHEN S_FINISH => 
        trn_num_c   <= (others => '0');
        wid_c       <= (others => '0');
        IF addr_we = '1' THEN
          curr_address_c <= unsigned(address);
        END IF;  
        IF ena = '0' THEN
          fsm_axi_c <= S_IDLE;
        ELSIF run = '1' THEN
          fsm_axi_c <= S_WAIT_FIFO;
        END IF;
      
      WHEN S_WAIT_FIFO =>
        data_cnt_c <= (others => '0');
        IF ena = '0' THEN
          fsm_axi_c   <= S_IDLE;
        ELSIF empty = '0' THEN
          fsm_axi_c <= S_AWVALID;
        END IF;
      
      WHEN S_AWVALID =>
        IF AWREADY = '1' THEN
          fsm_axi_c  <= S_RE;
        ELSE
          fsm_axi_c  <= S_WAIT_AWREADY;
        END IF;
        
      WHEN S_WAIT_AWREADY =>
        IF AWREADY = '1' THEN
          --data_cnt_c <= data_cnt_s + 1;
          fsm_axi_c <= S_RE;
        END IF;
        
      WHEN S_RE =>
        fsm_axi_c <= S_SAVE;
        
      WHEN S_SAVE =>
        IF data_cnt_s = 15 THEN
          fsm_axi_c <= S_WLAST;
        ELSE 
          fsm_axi_c <= S_WVALID;
        END IF;        
      
      WHEN S_WVALID =>
        IF WREADY = '1' THEN
          data_cnt_c <= data_cnt_s + 1;
          fsm_axi_c <= S_RE;
        END IF;       
      
      WHEN S_WLAST =>
        fsm_axi_c <= S_RESPONSE;
      
      WHEN S_RESPONSE =>
        IF BVALID = '1' THEN
          fsm_axi_c <= S_END_FRAME;
        END IF;
      
      WHEN S_END_FRAME =>
        IF (trn_num_s = C_HP_FULL_FRAME) THEN 
          num_frame_c <= num_frame_s + 1; 
          fsm_axi_c   <= S_FINISH; 
        ELSE
          wid_c <= wid_s + 1;
          curr_address_c <= curr_address_s + 128;
          fsm_axi_c <= S_WAIT_FIFO; 
          trn_num_c <= trn_num_s + 1;
        END IF;
    END CASE; 
 END PROCESS next_state_axi_hp_logic;
 
 output_axi_hp_logic : PROCESS (fsm_axi_c, re_s, awvalid_s, wvalid_s, wlast_s, bready_s, data_r, wstrb_s)
 BEGIN
    re_c           <= '0';
    awvalid_c      <= '0';
    wvalid_c       <= '0';
    wlast_c        <= '0';
    bready_c       <= '0';
    busy_c         <= '1';
    wstrb_c        <= (others => '0');
    CASE fsm_axi_c IS
      WHEN S_IDLE =>
        busy_c <= '0';
        
      WHEN S_FINISH => 
        busy_c <= '0';
        
      WHEN S_WAIT_FIFO =>
      
      WHEN S_AWVALID =>
        awvalid_c <= '1';
        
      WHEN S_WAIT_AWREADY =>
                
      WHEN S_RE =>
        re_c     <= '1';
        --wstrb_c  <= (others => '1');
        
      WHEN S_SAVE =>
        --wstrb_c  <= (others => '1');
      
      WHEN S_WVALID =>             
        wvalid_c <= '1';
        wstrb_c  <= (others => '1');
                
      WHEN S_WLAST =>      
        wvalid_c <= '1';
        wlast_c  <= '1';
        wstrb_c  <= (others => '1');        
      
      WHEN S_RESPONSE =>
        bready_c <= '1';
        
      WHEN S_END_FRAME =>  
      
    END CASE;        
 END PROCESS output_axi_hp_logic; 

-------------------------------------------------------------------------------
-- output assigment
-------------------------------------------------------------------------------
  re            <= re_s;
  num_frm       <= std_logic_vector(num_frame_s);
  busy          <= busy_s;
  curr_addr     <= std_logic_vector(curr_address_s);
  -- axi signals
  AWVALID       <= awvalid_s;
  WVALID        <= wvalid_s;
  WLAST         <= wlast_s;
  WID           <= std_logic_vector(wid_s);
  AWID          <= std_logic_vector(wid_s);
  AWADDR        <= std_logic_vector(curr_address_s);
  BREADY        <= bready_s;
  WDATA         <= data_r;
  WSTRB         <= wstrb_s;  
  -- axi static signals
  -- read signals
  ARADDR        <= (others => '0');
  ARVALID       <= '0';
  ARID          <= (others => '0');  
  ARLOCK        <= (others => '0');
  ARCACHE       <= (others => '0');
  ARPROT        <= (others => '0');
  ARLEN         <= (others => '0');
  ARSIZE        <= (others => '0');
  ARBURST       <= (others => '0');
  ARQOS         <= (others => '0');
  RREADY        <= '0';
  RDISSUECAP1EN <= '0';
  -- write signals
  AWLOCK        <= (others => '0'); 
  AWCACHE       <= (others => '0'); 
  AWPROT        <= (others => '0'); 
  AWLEN         <= "1111"; -- 16
  AWSIZE        <= "011";  -- 8 
  AWBURST       <= "01";   -- INCR  
  AWQOS         <= (others => '0');   
  WRISSUECAP1EN <= '0';  
END ARCHITECTURE rtl;
