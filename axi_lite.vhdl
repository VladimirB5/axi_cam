LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;


ENTITY axi_lite IS
  port (
  -- Global signals
  ACLK    : IN std_logic;
  ARESETn : IN std_logic;
  -- write adress channel
  AWVALID : IN std_logic;
  AWREADY : OUT std_logic;
  AWADDR  : IN std_logic_vector(31 downto 0);
  AWPROT  : IN std_logic_vector(2 downto 0);
  -- write data channel
  WVALID  : IN std_logic;
  WREADY  : OUT std_logic;
  WDATA   : IN std_logic_vector(31 downto 0);
  WSTRB   : IN std_logic_vector(3 downto 0); -- C_S_AXI_DATA_WIDTH/8)-1 : 0
  -- write response channel
  BVALID  : OUT std_logic;
  BREADY  : IN std_logic;
  BRESP   : OUT std_logic_vector(1 downto 0);
  -- read address channel
  ARVALID : IN  std_logic;
  ARREADY : OUT std_logic;
  ARADDR  : IN std_logic_vector(31 downto 0);
  ARPROT  : IN std_logic_vector(2 downto 0);
  -- read data channel
  RVALID  : OUT std_logic;
  RREADY  : IN std_logic;
  RDATA   : OUT std_logic_vector(31 downto 0);
  RRESP   : OUT std_logic_vector(1 downto 0);
  
  -- sccb interface
  start_sccb : OUT std_logic;
  busy_sccb  : IN  std_logic;
  ack_sccb   : IN  std_logic;
  
  --registers 
  start_addr   : OUT std_logic_vector(31 downto 0);
  addr_we      : OUT std_logic;
  ena          : OUT std_logic;
  cap_run      : OUT std_logic; -- capture reciving data from camera
  hp_run       : OUT std_logic;
  test_ena     : OUT std_logic;
  clock_mux    : OUT std_logic;
  clk_check_ena: OUT std_logic;
  cam_reset    : OUT std_logic;
  cam_pwdn     : OUT std_logic;
  sccb_data    : OUT std_logic_vector(15 downto 0);
  int_ena      : OUT std_logic;
  int_clr_fin  : OUT std_logic;
  int_clr_err  : OUT std_logic;
  hp_busy      : IN  std_logic; -- axi HP busy
  capture_busy : IN  std_logic;
  href_busy    : IN  std_logic; -- capturing href
  capture_err  : IN  std_logic;
  cap_frm_miss : IN  std_logic;
  clk_check_ok : IN  std_logic;
  int_sts_fin  : IN  std_logic;
  int_sts_err  : IN  std_logic;
  curr_addr    : IN  std_logic_vector(31 downto 0);
  num_frames   : IN  std_logic_vector(7 downto 0)
  ); 
END ENTITY axi_lite;
ARCHITECTURE rtl OF axi_lite IS
  -- signals
  signal busy : std_logic;
  -- output registers
  signal  arready_c, arready_s : std_logic; 
  signal  rvalid_c, rvalid_s   : std_logic;
  signal  awready_c, awready_s : std_logic;
  signal  wready_c, wready_s   : std_logic;
  signal  bvalid_c, bvalid_s   : std_logic;
  signal  rresp_c, rresp_s     : std_logic_vector(1 downto 0); -- read response
  signal  bresp_c, bresp_s     : std_logic_vector(1 downto 0); -- write resonse
  signal  rdata_c, rdata_s     : std_logic_vector(31 downto 0);
  -- register form reg. bank
  signal ena_c, ena_s                 : std_logic;
  signal cap_run_c, cap_run_s         : std_logic;
  signal hp_run_c, hp_run_s           : std_logic;
  signal start_sccb_c, start_sccb_s   : std_logic;
  signal clock_mux_c, clock_mux_s     : std_logic;
  signal test_ena_c, test_ena_s       : std_logic;
  signal new_frame_c, new_frame_s     : std_logic; -- latched value of new frame
  signal addr_lock_c, addr_lock_s     : std_logic; -- signalized that address is locked to in axi_hp, signal is set in transition 0 -> 1 on busy_hp
  signal busy_c, busy_s               : std_logic; -- latched value busy_hp
  signal cam_reset_c, cam_reset_s     : std_logic; 
  signal cam_pwdn_c, cam_pwdn_s       : std_logic;
  signal sccb_data_c, sccb_data_s     : std_logic_vector(15 downto 0);
  signal clk_check_ena_c, clk_check_ena_s : std_logic;
  signal int_ena_c, int_ena_s             : std_logic;
  signal finish_c, finish_s               : std_logic;
  signal int_clr_fin_s, int_clr_fin_c     : std_logic;
  signal int_clr_err_s, int_clr_err_c     : std_logic;
  
  -- fsm read declaration
  TYPE t_read_state IS (R_IDLE, R_AREADY, R_VDATA);
  SIGNAL fsm_read_c, fsm_read_s :t_read_state;
  
  -- fsm write declaration
  TYPE t_write_state IS (W_IDLE, W_ADDR_DAT, W_RESP);
  SIGNAL fsm_write_c, fsm_write_s :t_write_state;  
  
  -- responses
  constant OKAY   : std_logic_vector(1 downto 0) := B"00";
  constant EXOKAY : std_logic_vector(1 downto 0) := B"01";
  constant SLVERR : std_logic_vector(1 downto 0) := B"10";
  constant DECERR : std_logic_vector(1 downto 0) := B"11";
  begin
  -- sequential 
 state_reg : PROCESS (ACLK, ARESETn)
   BEGIN
    IF ARESETn = '0' THEN
      arready_s      <= '0';
      rvalid_s       <= '0';
      awready_s      <= '0';
      wready_s       <= '0';
      bvalid_s       <= '0';
      rresp_s        <= (others => '0');
      bresp_s        <= (others => '0');
      rdata_s        <= (others => '0');
      ena_s          <= '0';
      cap_run_s      <= '0';
      hp_run_s       <= '0';
      start_sccb_s   <= '0';
      clock_mux_s    <= '0';
      test_ena_s     <= '0';
      busy_s         <= '0';
      cam_reset_s    <= '1';
      cam_pwdn_s     <= '1';
      sccb_data_s    <= (others => '0');
      clk_check_ena_s<= '0';
      int_ena_s      <= '0';
      finish_s       <= '0';
      int_clr_fin_s  <= '0';
      int_clr_err_s  <= '0';   
      fsm_read_s     <= R_IDLE; -- init state after reset
      fsm_write_s    <= W_IDLE;
    ELSIF ACLK = '1' AND ACLK'EVENT THEN
      arready_s      <= arready_c;
      rvalid_s       <= rvalid_c;
      awready_s      <= awready_c;
      wready_s       <= wready_c;
      bvalid_s       <= bvalid_c;
      rresp_s        <= rresp_c;
      bresp_s        <= bresp_c;
      rdata_s        <= rdata_c;
      ena_s          <= ena_c;
      cap_run_s      <= cap_run_c;
      hp_run_s       <= hp_run_c;
      start_sccb_s   <= start_sccb_c; 
      clock_mux_s    <= clock_mux_c;
      test_ena_s     <= test_ena_c;
      busy_s         <= busy_c;
      cam_reset_s    <= cam_reset_c;
      cam_pwdn_s     <= cam_pwdn_c;
      sccb_data_s    <= sccb_data_c;
      clk_check_ena_s<= clk_check_ena_c;
      int_ena_s      <= int_ena_c;
      finish_s       <= finish_c;
      int_clr_fin_s  <= int_clr_fin_c;
      int_clr_err_s  <= int_clr_err_c;     
      fsm_read_s     <= fsm_read_c; -- next fsm state
      fsm_write_s    <= fsm_write_c;
    END IF;       
 END PROCESS state_reg;
  
 -- combinational parts 
 busy <= capture_busy OR hp_busy;
 
 busy_c <= busy;
 
 finish_c <= '1' WHEN busy_s = '1' AND busy = '0' AND ena_s = '1' ELSE 
             '0' WHEN busy = '1' ELSE
             '0' WHEN busy = '0' AND ena_s = '0' ELSE -- turn off clear
             finish_s;
 
 -- read processes ---------------------------------------------------------------------------
 next_state_read_logic : PROCESS (fsm_read_s, ARVALID, RREADY)
 BEGIN
    fsm_read_c <= fsm_read_s;
    CASE fsm_read_s IS
      WHEN R_IDLE =>
        fsm_read_c <= R_AREADY;
      
      when R_AREADY =>
        IF ARVALID = '1' then 
          fsm_read_c <= R_VDATA;
        ELSE
          fsm_read_c <= R_AREADY;
        END IF;
            
      WHEN R_VDATA =>
        IF RREADY = '1' then
          fsm_read_c <= R_IDLE;
        ELSE
          fsm_read_c <= R_VDATA;
        END IF;
    END CASE;        
 END PROCESS next_state_read_logic;
    
  -- ouput combinational logic
 output_read_logic : PROCESS (fsm_read_c)
 BEGIN
    rvalid_c  <= '0';
    arready_c <= '0'; 
    CASE fsm_read_c IS
      WHEN R_IDLE =>
        arready_c <= '0';
      
      WHEN R_AREADY =>
        arready_c <= '1';
             
      WHEN R_VDATA =>
        rvalid_c <= '1';
    END CASE;
  END PROCESS output_read_logic;
  
 -- output read mux
 output_read_mux : PROCESS (fsm_read_s, ARVALID, ARADDR(4 downto 2), num_frames, busy_sccb, capture_busy, hp_busy, new_frame_s, ena_s, addr_lock_s,
                            curr_addr, clock_mux_s, test_ena_s, rdata_s, rresp_s, cam_pwdn_s, cam_reset_s, ack_sccb, sccb_data_s, cap_frm_miss,
                            href_busy, capture_err, finish_s, busy, clk_check_ena_s, int_ena_s, int_sts_err, int_sts_fin)
 BEGIN
    rdata_c <= (others => '0');
    rresp_c <= OKAY;   
    IF ARVALID = '1' AND fsm_read_s = R_AREADY THEN
      CASE ARADDR(5 downto 2) IS 
        WHEN "0000" => 
          rdata_c(23 downto 16) <= num_frames;
          rdata_c(11)           <= cap_frm_miss;
          rdata_c(10)           <= clk_check_ok; 
          rdata_c(9)            <= hp_busy;
          rdata_c(8)            <= href_busy;          
          rdata_c(3)            <= capture_err;
          rdata_c(1)            <= finish_s;          
          rdata_c(0)            <= busy;
        WHEN "0001" =>
          rdata_c(2) <= clk_check_ena_s;
          rdata_c(1) <= clock_mux_s;
          rdata_c(0) <= test_ena_s;
        WHEN "0010" =>   
          rdata_c <= curr_addr;
        WHEN "0011" =>   
          rdata_c(7 downto 5) <= (others => '0');
          rdata_c(3)          <= cam_pwdn_s;
          rdata_c(2)          <= cam_reset_s;
          rdata_c(1)          <= clock_mux_s;
          rdata_c(0)          <= test_ena_s;
        WHEN "0100" =>
          rdata_c(15 downto 0) <= sccb_data_s;
        WHEN "0101" =>
          rdata_c(1) <= ack_sccb;
          rdata_c(0) <= busy_sccb;
        WHEN "0110" =>
          rdata_c(0) <= int_ena_s;
        WHEN "0111" =>
          rdata_c(1) <= int_sts_err;
          rdata_c(0) <= int_sts_fin;
        WHEN "1000" => 
          rdata_c <= x"AA55AA55";
        WHEN others =>
          rresp_c <= SLVERR;
      END CASE;
    ELSIF fsm_read_s = R_VDATA THEN
      rdata_c <= rdata_s;
      rresp_c <= rresp_s;
    ELSE
      rdata_c <= (others => '0');
    END IF;
  END PROCESS output_read_mux;
  
-- write processes ------------------------------------------------------------------------  
 next_state_write_logic : PROCESS (fsm_write_s, AWVALID, WVALID, BREADY)
 BEGIN
    fsm_write_c <= fsm_write_s;
    CASE fsm_write_s IS
      WHEN W_IDLE =>
        IF AWVALID = '1' AND WVALID = '1' THEN
          fsm_write_c <= W_ADDR_DAT;
        END IF;
            
      WHEN W_ADDR_DAT =>
        fsm_write_c <= W_RESP;
      
      WHEN W_RESP =>
        IF BREADY = '1' THEN 
          fsm_write_c <= W_IDLE;
        END IF;
    END CASE;
 END PROCESS next_state_write_logic;
  
 output_write_logic : PROCESS (fsm_write_c, AWADDR(4 downto 2), WDATA, ena_s, start_sccb_s, test_ena_s, clock_mux_s, bresp_s, busy_sccb, cam_reset_s, cam_pwdn_s, sccb_data_s, cap_run_s,
                               capture_busy, busy, clk_check_ena_s, int_ena_s)
 BEGIN
    awready_c      <= '0';
    wready_c       <= '0';
    bvalid_c       <= '0';
    bresp_c        <= bresp_s;
    ena_c          <= ena_s;
    cap_run_c      <= cap_run_s;
    hp_run_c       <= '0';
    start_sccb_c   <= start_sccb_s;
    test_ena_c     <= test_ena_s;
    clock_mux_c    <= clock_mux_s;
    cam_reset_c    <= cam_reset_s;
    cam_pwdn_c     <= cam_pwdn_s;   
    sccb_data_c    <= sccb_data_s;
    clk_check_ena_c<= clk_check_ena_s;
    int_ena_c      <= int_ena_s;
    int_clr_fin_c  <= '0';    
    int_clr_err_c  <= '0';
    start_addr     <= (others => '0');
    addr_we        <= '0';
    CASE fsm_write_c IS
      WHEN W_IDLE => 
        bresp_c   <= OKAY;
        awready_c <= '0';
        wready_c  <= '0';
        bvalid_c  <= '0';
            
      WHEN W_ADDR_DAT => 
        CASE AWADDR(4 downto 2) IS
          WHEN "000" => 
            if WDATA(0) = '1' AND WDATA(2) = '0' then
              ena_c <= '1';
              IF busy = '0' THEN 
                cap_run_c <= '1';
                hp_run_c  <= '1'; -- one clk pulse lenght
              END IF;
            elsif WDATA(2) = '1' then
              ena_c <= '0';
            end if;           
          WHEN "001" => 
            test_ena_c      <= WDATA(0);
            clock_mux_c     <= WDATA(1);
            clk_check_ena_c <= WDATA(2);
          WHEN "010" =>  
            IF busy = '0' THEN
              start_addr <= WDATA;
              addr_we    <= '1';
            END IF;
          WHEN "011" =>           
            cam_reset_c <= WDATA(0);
            cam_pwdn_c  <= WDATA(1);
          WHEN "100" =>
            sccb_data_c <= WDATA(15 downto 0);
          WHEN "101" =>
            IF busy_sccb = '0' THEN
              start_sccb_c <= WDATA(0);
            END IF;       
          WHEN "110" =>
            int_ena_c <= WDATA(0);
          WHEN "111" =>
            int_clr_fin_c <= WDATA(0);    
            int_clr_err_c <= WDATA(1);
          WHEN others =>
            bresp_c <= SLVERR;
        END CASE;      
        awready_c <= '1';
        wready_c  <= '1';
        bvalid_c  <= '0';      
      
      WHEN W_RESP =>
        awready_c <= '0';
        wready_c  <= '0';
        bvalid_c  <= '1';      
    END CASE;
    IF busy_sccb = '1' THEN
      start_sccb_c <= '0';
    END IF;
    IF capture_busy = '1' THEN
      cap_run_c <= '0';
    END IF;
  END PROCESS output_write_logic; 
  
  -- output assigment
  -- read channels
  ARREADY <= arready_s;
  RVALID  <= rvalid_s;
  RDATA   <= rdata_s;
  RRESP   <= rresp_s;
  -- write channels
  AWREADY <= awready_s;
  WREADY  <= wready_s;
  BVALID  <= bvalid_s;
  BRESP   <= bresp_s;
  -- output from register bank
  ena         <= ena_s;
  cap_run     <= cap_run_s;
  hp_run      <= hp_run_s;
  clk_check_ena <= clk_check_ena_s;
  start_sccb  <= start_sccb_s;
  test_ena    <= test_ena_s;
  clock_mux   <= clock_mux_s;
  cam_reset   <= cam_reset_s;
  cam_pwdn    <= cam_pwdn_s;
  sccb_data   <= sccb_data_s;
  int_ena     <= int_ena_s;
  int_clr_fin <= int_clr_fin_s;
  int_clr_err <= int_clr_err_s;
END ARCHITECTURE RTL;
 
