LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

--ADDR: 0 : 
--ADDR: 4 : start_addr
--ADDR: 8 : busy(1), power(0)

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
  power        : OUT std_logic;
  test_ena     : OUT std_logic;
  clock_mux    : OUT std_logic;
  cam_reset    : OUT std_logic;
  cam_pwdn     : OUT std_logic;
  hp_busy      : IN  std_logic; -- axi HP busy
  capture_busy : IN  std_logic;
  curr_addr    : IN  std_logic_vector(31 downto 0);
  num_frames   : IN  std_logic_vector(7 downto 0);
  new_frm      : IN  std_logic   -- new frame sended throught AXI HP
  ); 
END ENTITY axi_lite;
ARCHITECTURE rtl OF axi_lite IS
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
  signal start_addr_c, start_addr_s   : std_logic_vector(31 downto 0);
  signal power_c, power_s : std_logic;
  signal start_sccb_c, start_sccb_s   : std_logic;
  signal clock_mux_c, clock_mux_s     : std_logic;
  signal test_ena_c, test_ena_s       : std_logic;
  signal stop_c, stop_s               : std_logic; -- when stop is set to 1, block is deactivate after frame is finished
  signal new_frame_c, new_frame_s     : std_logic; -- latched value of new frame
  signal addr_lock_c, addr_lock_s     : std_logic; -- signalized that address is locked to in axi_hp, signal is set in transition 0 -> 1 on busy_hp
  signal hp_busy_c, hp_busy_s         : std_logic; -- latched value busy_hp
  signal cam_reset_c, cam_reset_s     : std_logic; 
  signal cam_pwdn_c, cam_pwdn_s       : std_logic;
  
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
      arready_s    <= '0';
      rvalid_s     <= '0';
      awready_s    <= '0';
      wready_s     <= '0';
      bvalid_s     <= '0';
      rresp_s      <= (others => '0');
      bresp_s      <= (others => '0');
      rdata_s      <= (others => '0');
      start_addr_s <= (others => '0');
      power_s      <= '0';
      stop_s       <= '0';
      new_frame_s  <= '0';
      addr_lock_s  <= '0';
      start_sccb_s <= '0';
      clock_mux_s  <= '0';
      test_ena_s   <= '0';
      hp_busy_s    <= '0';
      cam_reset_s  <= '1';
      cam_pwdn_s   <= '1';
      fsm_read_s   <= R_IDLE; -- init state after reset
      fsm_write_s  <= W_IDLE;
    ELSIF ACLK = '1' AND ACLK'EVENT THEN
      arready_s    <= arready_c;
      rvalid_s     <= rvalid_c;
      awready_s    <= awready_c;
      wready_s     <= wready_c;
      bvalid_s     <= bvalid_c;
      rresp_s      <= rresp_c;
      bresp_s      <= bresp_c;
      rdata_s      <= rdata_c;
      start_addr_s <= start_addr_c;
      power_s      <= power_c;
      stop_s       <= stop_c;
      new_frame_s  <= new_frame_c;
      addr_lock_s  <= addr_lock_c;
      start_sccb_s <= start_sccb_c; 
      clock_mux_s  <= clock_mux_c;
      test_ena_s   <= test_ena_c;
      hp_busy_s    <= hp_busy_c;
      cam_reset_s  <= cam_reset_c;
      cam_pwdn_s   <= cam_pwdn_c;
      fsm_read_s   <= fsm_read_c; -- next fsm state
      fsm_write_s  <= fsm_write_c;
    END IF;       
 END PROCESS state_reg;
  
 -- combinational parts 
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
 hp_busy_c <= hp_busy;
 output_read_mux : PROCESS (fsm_read_s, ARVALID, ARADDR(4 downto 2), num_frames, busy_sccb, capture_busy, hp_busy, hp_busy_s, new_frm, new_frame_s, power_s, stop_s, addr_lock_s,
                            start_addr_s, curr_addr, clock_mux_s, test_ena_s, rdata_s, rresp_s, cam_pwdn_s, cam_reset_s, ack_sccb)
 BEGIN
    rdata_c <= (others => '0');
    rresp_c <= OKAY;
    IF new_frm = '1' THEN
      new_frame_c <= '1';
    ELSE
      new_frame_c <= new_frame_s;
    END IF;
    IF hp_busy_s = '0' and hp_busy = '1' THEN
      addr_lock_c <= '1';
    ELSE
      addr_lock_c <= addr_lock_s; 
    END IF;    
    IF ARVALID = '1' AND fsm_read_s = R_AREADY THEN
      CASE ARADDR(4 downto 2) IS 
        WHEN "000" => 
          rdata_c(31 downto 16) <= x"AA55";
          rdata_c(15 downto 8)  <= num_frames;
          rdata_c(7)            <= '0';
          rdata_c(6)            <= '0'; 
          rdata_c(5)            <= addr_lock_s;
          rdata_c(4)            <= hp_busy;          
          rdata_c(3)            <= capture_busy;
          rdata_c(2)            <= new_frame_s;
          rdata_c(1)            <= stop_s;          
          rdata_c(0)            <= power_s;
          new_frame_c           <= '0'; -- clear after read new frame register
          addr_lock_c           <= '0'; -- clear after read address lock register
        WHEN "001" => 
          rdata_c <= start_addr_s;
        WHEN "010" =>   
          rdata_c <= curr_addr;
        WHEN "011" =>   
          rdata_c(7 downto 5)   <= (others => '0');
          rdata_c(5)            <= cam_pwdn_s;
          rdata_c(4)            <= cam_reset_s;
          rdata_c(3)            <= ack_sccb;
          rdata_c(2)            <= busy_sccb;
          rdata_c(1)            <= clock_mux_s;
          rdata_c(0)            <= test_ena_s;
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
  
 output_write_logic : PROCESS (fsm_write_c, AWADDR(4 downto 2), WDATA, power_s, start_addr_s, start_sccb_s, test_ena_s, clock_mux_s, bresp_s, busy_sccb, stop_s, new_frm, cam_reset_s, cam_pwdn_s)
 BEGIN
    awready_c <= '0';
    wready_c  <= '0';
    bvalid_c  <= '0';
    bresp_c   <= bresp_s;
    power_c   <= power_s;
    start_addr_c <= start_addr_s; 
    start_sccb_c <= start_sccb_s;
    test_ena_c   <= test_ena_s;
    clock_mux_c  <= clock_mux_s;
    stop_c       <= stop_s;
    cam_reset_c  <= cam_reset_s;
    cam_pwdn_c   <= cam_pwdn_s;    
    CASE fsm_write_c IS
      WHEN W_IDLE => 
        bresp_c   <= OKAY;
        awready_c <= '0';
        wready_c  <= '0';
        bvalid_c  <= '0';
            
      WHEN W_ADDR_DAT => 
        CASE AWADDR(4 downto 2) IS
          WHEN "000" => 
            power_c <= WDATA(0);
            stop_c  <= WDATA(1);
          WHEN "001" => 
            start_addr_c <= WDATA;
          WHEN "010" =>           
            --power_c <= WDATA(0);
          WHEN "011" =>           
            test_ena_c  <= WDATA(0);      
            clock_mux_c <= WDATA(1);
            IF busy_sccb = '0' THEN
              start_sccb_c <= WDATA(2);
            END IF;
            cam_reset_c <= WDATA(4);
            cam_pwdn_c  <= WDATA(5);
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
    IF stop_s = '1' AND new_frm = '1' THEN
      power_c <= '0';
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
  start_addr  <= start_addr_s;
  power       <= power_s;
  start_sccb  <= start_sccb_s;
  test_ena    <= test_ena_s;
  clock_mux   <= clock_mux_s;
  cam_reset   <= cam_reset_s;
  cam_pwdn    <= cam_pwdn_s;
END ARCHITECTURE RTL;
 
