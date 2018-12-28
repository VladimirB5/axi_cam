LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--use IEEE.numeric_std.all;

ENTITY axi_cam IS
  port (
    -- clocks and resets
  clk_100              : IN std_logic;
  rstn_100             : IN std_logic;
  
  clk_25               : IN std_logic;
  
  -- AXI lite 
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
  siod                 : OUT  std_logic;
  sioc                 : OUT  std_logic
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
  
  --registers 
  start_addr   : OUT std_logic_vector(31 downto 0);
  power        : OUT std_logic;
  test_ena     : OUT std_logic;
  clock_mux    : OUT std_logic;
  hp_busy      : IN  std_logic; -- axi HP busy
  capture_busy : IN  std_logic;
  curr_addr    : IN  std_logic_vector(31 downto 0);
  num_frames   : IN  std_logic_vector(7 downto 0);
  new_frm      : IN  std_logic  -- new frame sended throught AXI HP
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
  power    : IN  std_logic;
  address  : IN  std_logic_vector(31 downto 0);
  curr_addr: OUT std_logic_vector(31 downto 0);
  num_frm  : OUT std_logic_vector(7 downto 0);
  new_frm  : OUT std_logic;
  busy     : OUT std_logic;
  power_sf : OUT std_logic  -- power safety according to axi transaction
  ); 
end COMPONENT; 

COMPONENT sccb IS
  port (
    clk   : IN std_logic; -- 100Mhz clk
    rst_n : IN std_logic; -- active in 0
    start : IN std_logic;
    busy  : OUT std_logic;
    -- sccb interface
    siod  : out  STD_LOGIC;
    sioc  : out  STD_LOGIC
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
   reset      : OUT   std_logic;
   pwdn       : OUT   std_logic;
   -- internal signals
   rstn       : IN    std_logic;
   power      : IN    std_logic;
   busy       : OUT   std_logic;
   -- fifo interface
   data_w     : OUT std_logic_vector(63 downto 0);
   we         : OUT std_logic;
   full_w     : IN  std_logic
  ); 
END COMPONENT;

COMPONENT clk_mux IS
  port (
    clk    : IN std_logic;  -- input clk from clk source
    pclk   : IN std_logic;  -- input clk from camera
    mux    : IN std_logic;
    xclk   : OUT std_logic; -- output to camera
    clk_25 : OUT std_logic -- output to 25mhz clock domain
    
  ); 
END COMPONENT; 

COMPONENT cam_test IS
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

 signal start_sccb : std_logic;
 signal busy_sccb  : std_logic;
 
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
 signal  start_address    : std_logic_vector(31 downto 0);
 signal  curr_address     : std_logic_vector(31 downto 0); 
 signal  num_frames       : std_logic_vector(7 downto 0);
 signal  new_frame        : std_logic;
 signal  hp_busy          : std_logic;
 
 -- signal throught clock domain
 signal  clk_mux_100, clk_mux_25               : std_logic;  
 signal  test_ena_100, test_ena_25             : std_logic;  
 signal  power, power_sf, power_25             : std_logic;  
 signal  cap_busy_25, cap_busy_100             : std_logic;
 
 signal  xclk_25   : std_logic; -- clock from camera used for capturing
 signal  xrstn_25  : std_logic; -- reset synchronized to xclk_25
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
  
    start_addr   => start_address,
    power        => power,
    test_ena     => test_ena_100,
    clock_mux    => clk_mux_100,
    hp_busy      => hp_busy,
    capture_busy => cap_busy_100,
    curr_addr    => curr_address, 
    num_frames   => num_frames,
    new_frm      => new_frame
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
  power    => power,  --IN  std_logic;
  address  => start_address,  --std_logic_vector(31 downto 0);
  curr_addr=> curr_address,  --OUT std_logic_vector(31 downto 0);
  num_frm  => num_frames,  --OUT std_logic_vector(7 downto 0);
  new_frm  => new_frame,    --OUT std_logic
  busy     => hp_busy,
  power_sf => power_sf
  ); 
  
  i_sccb : sccb PORT MAP (
    clk   => clk_100, -- 100Mhz clk
    rst_n => rstn_100,-- active in 0
    start => start_sccb,
    busy  => busy_sccb,
    -- sccb interface
    siod  => siod,
    sioc  => sioc   
  );
  
  i_fifo : fifo  PORT MAP (
    -- 100 mhz port
    clk_100  => clk_100, -- 100Mhz clk
    rst_100n => rstn_100,  -- active in 0
    re       => re,
    sa_rstn  => power_sf,
    full_r   => full_r,
    empty    => empty,
    data_r   => data_r,
    -- 25 mhz port
    clk_25   => xclk_25,
    rst_25n  => xrstn_25,
    sb_rstn  => power_25,
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
    reset    => reset,
    pwdn     => pwdn,
    -- internal signals
    rstn       => xrstn_25, 
    power      => power_25,
    busy       => cap_busy_25,
    -- fifo interface
    data_w     => data_w,
    we         => we,
    full_w     => full_w
  ); 
  
  i_clk_mux : clk_mux  PORT MAP (
    clk    =>  clk_25, -- input clk from clk source
    pclk   =>  pclk,   -- input clk from camera
    mux    =>  clk_mux_25,
    xclk   =>  xclk,   -- output to camera
    clk_25 =>  xclk_25 -- output to 25mhz clock domain
    
  );

  i_cam_test : cam_test PORT MAP (
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
  
  -------------------------------------------------------------------------------
  i_reset_xclk25 : reset_sync port map (
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
     data_out => cap_busy_100
  );  
  
  ------------------------------------------------------------------------------- 
  i_clock_mux : synchronizer
  port map (
     clk      => xclk_25,
     res_n    => xrstn_25, 
     data_in  => clk_mux_100,
     data_out => clk_mux_25
  );  
  
  ------------------------------------------------------------------------------- 
  i_test_ena : synchronizer
  port map (
     clk      => xclk_25,
     res_n    => xrstn_25, 
     data_in  => test_ena_100,
     data_out => test_ena_25
  );    
  
  ------------------------------------------------------------------------------- 
  i_power : synchronizer
  port map (
     clk      => xclk_25,
     res_n    => xrstn_25, 
     data_in  => power_sf,
     data_out => power_25
  );    
END ARCHITECTURE RTL;
