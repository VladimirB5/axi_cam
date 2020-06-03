LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--use IEEE.numeric_std.all;

library work;
use work.axi_cam_pkg.all;

entity axi_cam IS
  generic (
    G_DIAG : boolean -- diagnostig logic added
  );
  port (
    -- clocks and resets
  clk_100              : IN std_logic;
  rstn_100             : IN std_logic;
  
  clk_25               : IN std_logic;
  
  -- AXI lite 
  AXI_L_ACLK           : IN std_logic;  
  -- write adress channel
  AXI_L_AWVALID        : IN std_logic;
  AXI_L_AWREADY        : OUT std_logic;
  AXI_L_AWADDR         : IN std_logic_vector(31 downto 0);
  AXI_L_AWPROT         : IN std_logic_vector(2 downto 0);
  -- write data channel
  AXI_L_WVALID         : IN std_logic;
  AXI_L_WREADY         : OUT std_logic;
  AXI_L_WDATA          : IN std_logic_vector(31 downto 0);
  AXI_L_WSTRB          : IN std_logic_vector(3 downto 0); -- C_S_AXI_DATA_WIDTH/8)-1 : 0
  -- write response channel
  AXI_L_BVALID         : OUT std_logic;
  AXI_L_BREADY         : IN std_logic;
  AXI_L_BRESP          : OUT std_logic_vector(1 downto 0);
  -- read address channel
  AXI_L_ARVALID        : IN  std_logic;
  AXI_L_ARREADY        : OUT std_logic;
  AXI_L_ARADDR         : IN std_logic_vector(31 downto 0);
  AXI_L_ARPROT         : IN std_logic_vector(2 downto 0);
  -- read data channel
  AXI_L_RVALID         : OUT std_logic;
  AXI_L_RREADY         : IN std_logic;
  AXI_L_RDATA          : OUT std_logic_vector(31 downto 0);
  AXI_L_RRESP          : OUT std_logic_vector(1 downto 0);    
    
  -- AXI HP
  AXI_HP_ACLK          : IN std_logic;
  -- write adress channel
  AXI_HP_AWADDR        : OUT std_logic_vector(31 downto 0);
  AXI_HP_AWVALID       : OUT std_logic;
  AXI_HP_AWREADY       : IN  std_logic;
  AXI_HP_AWID          : OUT std_logic_vector(5 downto 0);   
  AXI_HP_AWLOCK        : OUT std_logic_vector(1 downto 0); 
  AXI_HP_AWCACHE       : OUT std_logic_vector(3 downto 0); 
  AXI_HP_AWPROT        : OUT std_logic_vector(2 downto 0); 
  AXI_HP_AWLEN         : OUT std_logic_vector(3 downto 0); 
  AXI_HP_AWSIZE        : OUT std_logic_vector(2 downto 0); 
  AXI_HP_AWBURST       : OUT std_logic_vector(1 downto 0); 
  AXI_HP_AWQOS         : OUT std_logic_vector(3 downto 0);  
  -- write data channel  
  AXI_HP_WDATA         : OUT std_logic_vector(63 downto 0);
  AXI_HP_WVALID        : OUT std_logic;
  AXI_HP_WREADY        : IN  std_logic;
  AXI_HP_WID           : OUT std_logic_vector(5 downto 0);
  AXI_HP_WLAST         : OUT std_logic;
  AXI_HP_WSTRB         : OUT std_logic_vector(7 downto 0);
  AXI_HP_WCOUNT        : IN  std_logic_vector(7 downto 0);
  AXI_HP_WACOUNT       : IN  std_logic_vector(5 downto 0);
  AXI_HP_WRISSUECAP1EN : OUT std_logic;
  -- write response channel
  AXI_HP_BVALID        : IN  std_logic;
  AXI_HP_BREADY        : OUT std_logic;
  AXI_HP_BID           : IN  std_logic_vector(5 downto 0);
  AXI_HP_BRESP         : IN  std_logic_vector(1 downto 0);
  -- read address channel  
  AXI_HP_ARADDR        : OUT std_logic_vector(31 downto 0);
  AXI_HP_ARVALID       : OUT std_logic;
  AXI_HP_ARREADY       : IN  std_logic;
  AXI_HP_ARID          : OUT std_logic_vector(5 downto 0);    
  AXI_HP_ARLOCK        : OUT std_logic_vector(1 downto 0);
  AXI_HP_ARCACHE       : OUT std_logic_vector(3 downto 0);
  AXI_HP_ARPROT        : OUT std_logic_vector(2 downto 0);
  AXI_HP_ARLEN         : OUT std_logic_vector(3 downto 0);
  AXI_HP_ARSIZE        : OUT std_logic_vector(2 downto 0);
  AXI_HP_ARBURST       : OUT std_logic_vector(1 downto 0);
  AXI_HP_ARQOS         : OUT std_logic_vector(3 downto 0);
  -- read data channel  
  AXI_HP_RDATA         : IN  std_logic_vector(63 downto 0);
  AXI_HP_RVALID        : IN  std_logic;
  AXI_HP_RREADY        : OUT std_logic;
  AXI_HP_RID           : IN  std_logic_vector(5 downto 0);    
  AXI_HP_RLAST         : IN  std_logic;
  AXI_HP_RRESP         : IN  std_logic_vector(1 downto 0);
  AXI_HP_RCOUNT        : IN  std_logic_vector(7 downto 0);
  AXI_HP_RACOUNT       : IN  std_logic_vector(2 downto 0);
  AXI_HP_RDISSUECAP1EN : OUT std_logic;    
    
  -- ov7670 signals
  pclk                 : IN   std_logic;
  xclk                 : OUT  std_logic;
  vsync                : IN   std_logic;
  href                 : IN   std_logic;
  data                 : IN   std_logic_vector(7 downto 0);
  reset                : OUT  std_logic;
  pwdn                 : OUT  std_logic;  
  siod                 : INOUT std_logic;
  sioc                 : OUT  std_logic;
  
  cam_int              : OUT std_logic
  ); 
END ENTITY axi_cam;

ARCHITECTURE rtl OF axi_cam IS

-- component declaration
COMPONENT axi_lite IS
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
end COMPONENT;

COMPONENT axi_hp IS
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
end COMPONENT; 

COMPONENT sccb IS
  port (
    clk       : IN std_logic; -- 100Mhz clk
    rst_n     : IN std_logic; -- active in 0
    start     : IN std_logic;
    sccb_data : IN std_logic_vector(15 downto 0); -- data to be send via sccb
    busy      : OUT std_logic;
    ack       : OUT std_logic;
    -- sccb interface
    siod_r    : in std_logic;
    siod_w    : out std_logic;
    sioc      : out std_logic
  ); 
end COMPONENT;

COMPONENT fifo IS
  port (
    -- 100 mhz port
    clk_100 : IN std_logic; -- 100Mhz clk
    rst_100n: IN std_logic; -- active in 0
    re      : IN std_logic;
    sa_rstn : IN std_logic; -- sw reset a
    full_r  : OUT std_logic;
    empty   : OUT std_logic;
    data_r  : OUT std_logic_vector(63 downto 0);
    -- 25 mhz port
    clk_25  : IN  std_logic;
    rst_25n : IN  std_logic;
    sb_rstn : IN  std_logic; -- sw reset b
    data_w  : IN  std_logic_vector(63 downto 0);
    we      : IN  std_logic;
    full_w  : OUT std_logic
  ); 
END COMPONENT;

COMPONENT cam_capture IS
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
   href_busy  : OUT   std_logic;
   frame_mis  : OUT   std_logic; -- frame missed
   error      : OUT   std_logic;
   -- fifo interface
   data_w     : OUT std_logic_vector(63 downto 0);
   we         : OUT std_logic;
   full_w     : IN  std_logic
  ); 
END COMPONENT;

COMPONENT clk_mux IS
  generic (
    G_MUX : boolean -- if mux is use
  );
  port (
    clk    : IN std_logic;  -- input clk from clk source
    pclk   : IN std_logic;  -- input clk from camera
    mux    : IN std_logic;
    xclk   : OUT std_logic; -- output to camera
    clk_25 : OUT std_logic -- output to 25mhz clock domain
    
  ); 
END COMPONENT; 

COMPONENT cam_test IS
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
   test_ena    : IN    std_logic
  ); 
END COMPONENT; 

COMPONENT reset_sync is
    Port ( async_res_n : in  STD_LOGIC;
           clk         : in  STD_LOGIC;
           sync_res_n  : out  STD_LOGIC);
END COMPONENT;

COMPONENT synchronizer is
    Port ( clk       : IN  STD_LOGIC;
           res_n     : IN  STD_LOGIC;
           data_in   : IN  STD_LOGIC;
           data_out  : OUT STD_LOGIC
         );
END COMPONENT;

COMPONENT bi_dir is
  port(T     : in    std_logic;
       I     : in    std_logic;
       O_NEW : out   std_logic;
       IO    : inout std_logic);
END COMPONENT;

COMPONENT tri_out is
  port(T    : in  std_logic;
       I    : in  std_logic;
       O    : out std_logic);
END COMPONENT;

COMPONENT int_ctrl IS
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
END COMPONENT;


 signal start_sccb : std_logic;
 signal busy_sccb  : std_logic;
 signal ack_sccb   : std_logic;
 
 signal  vsync_cap : std_logic;
 signal  href_cap  : std_logic;
 signal  data_cap  : std_logic_vector(7 downto 0);
 
 -- fifo signals
 signal  data_w    : std_logic_vector(63 downto 0);
 signal  we        : std_logic;
 signal  full_w    : std_logic;
 signal  re        : std_logic;
 signal  full_r    : std_logic;
 signal  empty     : std_logic;
 signal  data_r    : std_logic_vector(63 downto 0); 
 
 -- interna registers signals
 signal  ena              : std_logic;
 signal  hp_run           : std_logic;
 signal  start_address    : std_logic_vector(31 downto 0);
 signal  curr_address     : std_logic_vector(31 downto 0);
 signal  addr_we          : std_logic;
 signal  num_frames       : std_logic_vector(7 downto 0);
 signal  sccb_data        : std_logic_vector(15 downto 0);
 signal  new_frame        : std_logic;
 signal  hp_busy          : std_logic;
 signal  xclk_mux         : std_logic;   
 signal  int_ena          : std_logic;
 signal  int_clr_err      : std_logic;
 signal  int_clr_fin      : std_logic;
 signal  int_sts_fin      : std_logic;
 signal  int_sts_err      : std_logic;
 
 -- signal throught clock domain
 signal  ena_25                 : std_logic; 
 signal  cap_run, cap_run_25    : std_logic;
 signal  test_ena, test_ena_25  : std_logic;  
 signal  cap_busy_25, cap_busy  : std_logic;
 signal  cap_frm_mis_25         : std_logic;
 signal  cap_frm_mis            : std_logic;  
 signal  cap_err, cap_err_25    : std_logic;
 signal  href_busy, href_busy_25: std_logic;
 
 signal  xclk_25   : std_logic; -- clock from camera used for capturing
 signal  xrstn_25  : std_logic; -- reset synchronized to xclk_25
 
 signal  siod_w    : std_logic;
 signal  siod_r    : std_logic;
 signal  sioc_i    : std_logic; -- interconnecte signal
  BEGIN
  
  i_axi_lite: axi_lite PORT MAP (
    -- Global signals
    ACLK       => clk_100,
    ARESETn    => rstn_100,
    -- write adress channel
    AWVALID    => AXI_L_AWVALID,
    AWREADY    => AXI_L_AWREADY,
    AWADDR     => AXI_L_AWADDR,
    AWPROT     => AXI_L_AWPROT,
    -- write data channel
    WVALID     => AXI_L_WVALID,
    WREADY     => AXI_L_WREADY,
    WDATA      => AXI_L_WDATA,
    WSTRB      => AXI_L_WSTRB,
    -- write response channel
    BVALID     => AXI_L_BVALID,
    BREADY     => AXI_L_BREADY,
    BRESP      => AXI_L_BRESP,
    -- read address channel
    ARVALID    => AXI_L_ARVALID,
    ARREADY    => AXI_L_ARREADY,
    ARADDR     => AXI_L_ARADDR,
    ARPROT     => AXI_L_ARPROT,
    -- read data channel
    RVALID     => AXI_L_RVALID,
    RREADY     => AXI_L_RREADY,
    RDATA      => AXI_L_RDATA,
    RRESP      => AXI_L_RRESP,
  
    -- sccb interface
    start_sccb => start_sccb,
    busy_sccb  => busy_sccb,
    ack_sccb   => ack_sccb,
  
    --registers 
    start_addr   => start_address, -- 
    addr_we      => addr_we,-- OUT std_logic;
    ena          => ena, -- OUT std_logic;
    cap_run      => cap_run,-- OUT std_logic; -- capture reciving data from camera
    hp_run       => hp_run,-- OUT std_logic;
    test_ena     => test_ena,-- OUT std_logic;
    clock_mux    => xclk_mux,-- OUT std_logic;
    clk_check_ena=> open, -- OUT std_logic;
    cam_reset    => reset,-- OUT std_logic;
    cam_pwdn     => pwdn,-- OUT std_logic;
    sccb_data    => sccb_data,-- OUT std_logic_vector(15 downto 0);
    int_ena      => int_ena, -- OUT std_logic;
    int_clr_fin  => int_clr_fin, -- OUT std_logic;
    int_clr_err  => int_clr_err, -- OUT std_logic;
    hp_busy      => hp_busy,-- IN  std_logic; -- axi HP busy
    capture_busy => cap_busy,-- IN  std_logic;
    href_busy    => href_busy, -- href capturing
    capture_err  => cap_err,-- IN  std_logic;
    cap_frm_miss => cap_frm_mis,-- IN  std_logic;
    clk_check_ok => '0', -- IN  std_logic;
    int_sts_fin  => int_sts_fin, -- IN  std_logic;
    int_sts_err  => int_sts_err, -- IN  std_logic;
    curr_addr    => curr_address, -- IN  std_logic_vector(31 downto 0);
    num_frames   => num_frames -- IN  std_logic_vector(7 downto 0)    
  ); 

  i_axi_hp: axi_hp PORT MAP (
    -- AXI signals
    -- Global signals
    ACLK    => clk_100,
    ARESETn => rstn_100,
    -- write adress channel
    AWADDR  => AXI_HP_AWADDR,
    AWVALID => AXI_HP_AWVALID,
    AWREADY => AXI_HP_AWREADY,
    AWID    => AXI_HP_AWID,   
    AWLOCK  => AXI_HP_AWLOCK, 
    AWCACHE => AXI_HP_AWCACHE, 
    AWPROT  => AXI_HP_AWPROT, 
    AWLEN   => AXI_HP_AWLEN,
    AWSIZE  => AXI_HP_AWSIZE, 
    AWBURST => AXI_HP_AWBURST, 
    AWQOS   => AXI_HP_AWQOS,  
    -- write data channel  
    WDATA   => AXI_HP_WDATA,
    WVALID  => AXI_HP_WVALID,
    WREADY  => AXI_HP_WREADY,
    WID     => AXI_HP_WID,
    WLAST   => AXI_HP_WLAST,
    WSTRB   => AXI_HP_WSTRB,
    WCOUNT  => AXI_HP_WCOUNT,
    WACOUNT => AXI_HP_WACOUNT,
    WRISSUECAP1EN => AXI_HP_WRISSUECAP1EN,
    -- write response channel
    BVALID  => AXI_HP_BVALID,  
    BREADY  => AXI_HP_BREADY,  
    BID     => AXI_HP_BID,  
    BRESP   => AXI_HP_BRESP,  
    -- read address channel  
    ARADDR  => AXI_HP_ARADDR,  
    ARVALID => AXI_HP_ARVALID,  
    ARREADY => AXI_HP_ARREADY, 
    ARID    => AXI_HP_ARID,  
    ARLOCK  => AXI_HP_ARLOCK,  
    ARCACHE => AXI_HP_ARCACHE,  
    ARPROT  => AXI_HP_ARPROT, 
    ARLEN   => AXI_HP_ARLEN,  
    ARSIZE  => AXI_HP_ARSIZE,  
    ARBURST => AXI_HP_ARBURST,  
    ARQOS   => AXI_HP_ARQOS,  
    -- read data channel  
    RDATA   => AXI_HP_RDATA,  
    RVALID  => AXI_HP_RVALID,  
    RREADY  => AXI_HP_RREADY, 
    RID     => AXI_HP_RID,   
    RLAST   => AXI_HP_RLAST,
    RRESP   => AXI_HP_RRESP, 
    RCOUNT  => AXI_HP_RCOUNT, 
    RACOUNT => AXI_HP_RACOUNT,
    RDISSUECAP1EN => AXI_HP_RDISSUECAP1EN,
  
    -- zynq fifo signals
    re      => re,
    full_r  => full_r,
    empty   => empty,  --IN  std_logic;
    data_r  => data_r,  --IN  std_logic_vector(63 downto 0);
  
    -- control signals
    ena      => ena, -- IN  std_logic;
    run      => hp_run,-- IN std_logic;
    address  => start_address, -- IN (31 downto 0);
    addr_we  => addr_we, -- IN
    curr_addr=> curr_address, --out (31 downto 0)
    num_frm  => num_frames, --out`(7 downto 0)
    busy     => hp_busy --out 
  ); 
  
  i_sccb : sccb PORT MAP (
    clk       => clk_100, -- 100Mhz clk
    rst_n     => rstn_100,-- active in 0
    start     => start_sccb,
    sccb_data => sccb_data,
    busy      => busy_sccb,
    ack       => ack_sccb,
    -- sccb interface
    siod_r    =>  siod_r, -- in
    siod_w    =>  siod_w, -- out
    sioc      =>  sioc_i  -- out   
  );
     
  i_fifo : fifo  PORT MAP (
    -- 100 mhz port
    clk_100  => clk_100, -- 100Mhz clk
    rst_100n => rstn_100,  -- active in 0
    re       => re,
    sa_rstn  => ena,
    full_r   => full_r,
    empty    => empty,
    data_r   => data_r,
    -- 25 mhz port
    clk_25   => xclk_25,
    rst_25n  => xrstn_25,
    sb_rstn  => ena_25,
    data_w   => data_w,
    we       => we,
    full_w   => full_w
  );   
  
  i_cam_capture : cam_capture PORT MAP (
    -- camera interaface 
    clk      => xclk_25,
    vsync    => vsync_cap,
    href     => href_cap,
    data     => data_cap,
    -- internal signals
    rstn     => xrstn_25,
    ena      => ena_25,
    run      => cap_run_25,
    busy     => cap_busy_25,
    href_busy=> href_busy_25,
    frame_mis=> cap_frm_mis_25,
    error    => cap_err_25,     
    -- fifo interface
    data_w   => data_w,
    we       => we,
    full_w   => full_w
  ); 
  
  i_clk_mux : clk_mux
  generic map (
    G_MUX => G_DIAG -- if mux is use
  )
  PORT MAP (
    clk    =>  clk_25, -- input clk from clk source
    pclk   =>  pclk,   -- input clk from camera
    mux    =>  xclk_mux,
    xclk   =>  xclk,   -- output to camera
    clk_25 =>  xclk_25 -- output to 25mhz clock domain
    
  );
 
  cam_test_full: if G_DIAG = true generate
    i_cam_test : cam_test 
    GENERIC MAP (
      vsync_dly   => C_VSYNC_DLY,  
      p1_dly      => C_P1_DLY, 
      href_dly    => C_HREF_DLY,  
      p2_dly      => C_P2_DLY,  
      p3_dly      => C_P3_DLY, 
      lines_num   => C_NUM_LINES
    )
    PORT MAP (
      clk         => xclk_25,
      rstn        => xrstn_25,
      -- data from camera
      vsync       => vsync,
      href        => href,
      data        => data,
      -- data to capture
      vsync_cap   => vsync_cap,
      href_cap    => href_cap,
      data_cap    => data_cap,
      -- control interface
      test_ena    => test_ena_25
    ); 
  end generate;
  
  cam_test_sig: if G_DIAG = false generate
    vsync_cap <= vsync;
    href_cap  <= href;
    data_cap  <= data;
  end generate;  
  
  i_bi_dir : bi_dir
  port map (
    T     => siod_w,
    I     => '0',
    O_NEW => siod_r,
    IO    => siod
  ); 
  
  i_tri_out : tri_out
  port map (
    T    => sioc_i,
    I    => '0',
    O    => sioc
  );  
  
  i_int_ctrl : int_ctrl
  port map(
   rstn       => rstn_100,
   clk        => clk_100,
   
   int_ena    => int_ena, --IN
   ena        => ena, --IN
   cap_err    => cap_err,--IN
   hp_busy    => hp_busy, --IN  
   sts_fin_clr=> int_clr_fin, --IN 
   sts_err_clr=> int_clr_err, --IN 
   sts_fin    => int_sts_fin, --OUT 
   sts_err    => int_sts_err, --OUT 
   
   int        => cam_int --OUT 
  ); 
  
  -------------------------------------------------------------------------------
  i_reset_xclk25 : reset_sync 
  port map (
    async_res_n => rstn_100,
    clk         => xclk_25,
    sync_res_n  => xrstn_25
  );  
  
  ------------------------------------------------------------------------------- 
  i_cap_busy : synchronizer
  port map (
    clk      => clk_100,
    res_n    => rstn_100,
    data_in  => cap_busy_25,
    data_out => cap_busy
  );  
  
  ------------------------------------------------------------------------------- 
  i_cap_href_busy : synchronizer
  port map (
    clk      => clk_100,
    res_n    => rstn_100,
    data_in  => href_busy_25,
    data_out => href_busy
  );  
    
  ------------------------------------------------------------------------------- 
  i_test_ena : synchronizer
  port map (
    clk      => xclk_25,
    res_n    => xrstn_25, 
    data_in  => test_ena,
    data_out => test_ena_25
  );    
  
  ------------------------------------------------------------------------------- 
  i_ena : synchronizer
  port map (
    clk      => xclk_25,
    res_n    => xrstn_25, 
    data_in  => ena,
    data_out => ena_25
  );   
  
  ------------------------------------------------------------------------------- 
  i_cap_run : synchronizer
  port map (
    clk      => xclk_25,
    res_n    => xrstn_25, 
    data_in  => cap_run,
    data_out => cap_run_25
  );
  
  ------------------------------------------------------------------------------- 
  i_cap_err : synchronizer
  port map (
    clk      => xclk_25,
    res_n    => xrstn_25, 
    data_in  => cap_err_25,
    data_out => cap_err
  );  
  
  ------------------------------------------------------------------------------- 
  i_cap_frm_miss : synchronizer
  port map (
    clk      => xclk_25,
    res_n    => xrstn_25, 
    data_in  => cap_frm_mis_25,
    data_out => cap_frm_mis
  );    
END ARCHITECTURE RTL;
