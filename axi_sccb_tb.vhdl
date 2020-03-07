LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--use IEEE.numeric_std.all;

ENTITY axi_sccb_tb IS 
END ENTITY axi_sccb_tb;

ARCHITECTURE behavior OF axi_sccb_tb IS
-------------------------------------------------------------------------------
COMPONENT axi_cam IS
  generic (
    G_MUX : boolean -- if internal clock can be switched to second clock domain
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
  siod                 : INOUT  std_logic;
  sioc                 : OUT  std_logic
  ); 
END COMPONENT;
-------------------------------------------------------------------------------

   signal clk_100   : std_logic := '0';
   signal clk_25    : std_logic := '0';   
   signal rst_n     : std_logic := '0';   
   signal siod      : std_logic := '0';
   signal sioc      : std_logic := '0';
   
   -- axi lite signals
   signal AXI_L_AWVALID : std_logic := '0';
   signal AXI_L_AWREADY : std_logic;
   signal AXI_L_AWADDR  : std_logic_vector(31 downto 0) := (others => '0');
   signal AXI_L_AWPROT  : std_logic_vector(2 downto 0)  := (others => '0');
    -- write data channel
   signal AXI_L_WVALID  : std_logic := '0';
   signal AXI_L_WREADY  : std_logic;
   signal AXI_L_WDATA   : std_logic_vector(31 downto 0) := (others => '0');
   signal AXI_L_WSTRB   : std_logic_vector(3 downto 0)  := (others => '0'); -- C_S_AXI_DATA_WIDTH/8)-1 : 0
    -- write response channel
   signal AXI_L_BVALID  : std_logic;
   signal AXI_L_BREADY  : std_logic := '0';
   signal AXI_L_BRESP   : std_logic_vector(1 downto 0);
    -- read address channel
   signal AXI_L_ARVALID : std_logic;
   signal AXI_L_ARREADY : std_logic;
   signal AXI_L_ARADDR  : std_logic_vector(31 downto 0);
   signal AXI_L_ARPROT  : std_logic_vector(2 downto 0);
    -- read data channel
   signal AXI_L_RVALID  : std_logic;
   signal AXI_L_RREADY  : std_logic;
   signal AXI_L_RDATA   : std_logic_vector(31 downto 0);
   signal AXI_L_RRESP   : std_logic_vector(1 downto 0);    

   -- axi hp
   -- write adress channel
   signal AXI_HP_AWADDR        : std_logic_vector(31 downto 0);
   signal AXI_HP_AWVALID       : std_logic;
   signal AXI_HP_AWREADY       : std_logic;
   signal AXI_HP_AWID          : std_logic_vector(5 downto 0);   
   signal AXI_HP_AWLOCK        : std_logic_vector(1 downto 0); 
   signal AXI_HP_AWCACHE       : std_logic_vector(3 downto 0); 
   signal AXI_HP_AWPROT        : std_logic_vector(2 downto 0); 
   signal AXI_HP_AWLEN         : std_logic_vector(3 downto 0); 
   signal AXI_HP_AWSIZE        : std_logic_vector(2 downto 0); 
   signal AXI_HP_AWBURST       : std_logic_vector(1 downto 0); 
   signal AXI_HP_AWQOS         : std_logic_vector(3 downto 0);  
     -- write data channel  
   signal AXI_HP_WDATA         : std_logic_vector(63 downto 0);
   signal AXI_HP_WVALID        : std_logic;
   signal AXI_HP_WREADY        : std_logic;
   signal AXI_HP_WID           : std_logic_vector(5 downto 0);
   signal AXI_HP_WLAST         : std_logic;
   signal AXI_HP_WSTRB         : std_logic_vector(7 downto 0);
   signal AXI_HP_WCOUNT        : std_logic_vector(7 downto 0);
   signal AXI_HP_WACOUNT       : std_logic_vector(5 downto 0);
   signal AXI_HP_WRISSUECAP1EN : std_logic;
     -- write response channel
   signal AXI_HP_BVALID        : std_logic;
   signal AXI_HP_BREADY        : std_logic;
   signal AXI_HP_BID           : std_logic_vector(5 downto 0);
   signal AXI_HP_BRESP         : std_logic_vector(1 downto 0);
     -- read address channel  
   signal AXI_HP_ARADDR        : std_logic_vector(31 downto 0);
   signal AXI_HP_ARVALID       : std_logic;
   signal AXI_HP_ARREADY       : std_logic;
   signal AXI_HP_ARID          : std_logic_vector(5 downto 0);    
   signal AXI_HP_ARLOCK        : std_logic_vector(1 downto 0);
   signal AXI_HP_ARCACHE       : std_logic_vector(3 downto 0);
   signal AXI_HP_ARPROT        : std_logic_vector(2 downto 0);
   signal AXI_HP_ARLEN         : std_logic_vector(3 downto 0);
   signal AXI_HP_ARSIZE        : std_logic_vector(2 downto 0);
   signal AXI_HP_ARBURST       : std_logic_vector(1 downto 0);
   signal AXI_HP_ARQOS         : std_logic_vector(3 downto 0);
     -- read data channel  
   signal AXI_HP_RDATA         : std_logic_vector(63 downto 0);
   signal AXI_HP_RVALID        : std_logic;
   signal AXI_HP_RREADY        : std_logic;
   signal AXI_HP_RID           : std_logic_vector(5 downto 0);    
   signal AXI_HP_RLAST         : std_logic;
   signal AXI_HP_RRESP         : std_logic_vector(1 downto 0);
   signal AXI_HP_RCOUNT        : std_logic_vector(7 downto 0);
   signal AXI_HP_RACOUNT       : std_logic_vector(2 downto 0);
   signal AXI_HP_RDISSUECAP1EN : std_logic;     
   
   signal stop_sim: boolean := false;
   constant clk_period_100  : time := 10 ns;
   constant clk_period_25   : time := 40 ns;
   
   signal address : std_logic_vector(31 downto 0);
   signal data    : std_logic_vector(31 downto 0);   
   
   signal write_start : std_logic := '0';
   signal read_start : std_logic := '0';   
begin

   i_axi_cam: axi_cam
   generic map(
     G_MUX => true 
   )
   PORT MAP (
     -- clocks and resets
     CLK_100 => CLK_100,
     rstn_100  => rst_n,
     
     clk_25  => clk_25,

     -- axi-lite
     AXI_L_ACLK => '0',
     -- write adress channel
     AXI_L_AWVALID => AXI_L_AWVALID,
     AXI_L_AWREADY => AXI_L_AWREADY,
     AXI_L_AWADDR  => AXI_L_AWADDR,
     AXI_L_AWPROT  => AXI_L_AWPROT,
     -- write data channel
     AXI_L_WVALID  => AXI_L_WVALID,
     AXI_L_WREADY  => AXI_L_WREADY,
     AXI_L_WDATA   => AXI_L_WDATA,
     AXI_L_WSTRB   => AXI_L_WSTRB,
     -- write response channel
     AXI_L_BVALID  => AXI_L_BVALID,
     AXI_L_BREADY  => AXI_L_BREADY,
     AXI_L_BRESP   => AXI_L_BRESP,
     -- read address channel
     AXI_L_ARVALID => AXI_L_ARVALID,
     AXI_L_ARREADY => AXI_L_ARREADY,
     AXI_L_ARADDR  => AXI_L_ARADDR,
     AXI_L_ARPROT  => AXI_L_ARPROT,
     -- read data channel
     AXI_L_RVALID  => AXI_L_RVALID,
     AXI_L_RREADY  => AXI_L_RREADY,
     AXI_L_RDATA   => AXI_L_RDATA,
     AXI_L_RRESP   => AXI_L_RRESP, 

     -- axi hp
     AXI_HP_ACLK     => '0',
     -- write adress channel
     AXI_HP_AWADDR   => AXI_HP_AWADDR,
     AXI_HP_AWVALID  => AXI_HP_AWVALID,
     AXI_HP_AWREADY  => AXI_HP_AWREADY,
     AXI_HP_AWID     => AXI_HP_AWID,  
     AXI_HP_AWLOCK   => AXI_HP_AWLOCK,
     AXI_HP_AWCACHE  => AXI_HP_AWCACHE,
     AXI_HP_AWPROT   => AXI_HP_AWPROT,
     AXI_HP_AWLEN    => AXI_HP_AWLEN,
     AXI_HP_AWSIZE   => AXI_HP_AWSIZE,
     AXI_HP_AWBURST  => AXI_HP_AWBURST,
     AXI_HP_AWQOS    => AXI_HP_AWQOS,
     -- write data channel  
     AXI_HP_WDATA         => AXI_HP_WDATA,
     AXI_HP_WVALID        => AXI_HP_WVALID,
     AXI_HP_WREADY        => AXI_HP_WREADY,
     AXI_HP_WID           => AXI_HP_WID,
     AXI_HP_WLAST         => AXI_HP_WLAST,
     AXI_HP_WSTRB         => AXI_HP_WSTRB,
     AXI_HP_WCOUNT        => AXI_HP_WCOUNT,
     AXI_HP_WACOUNT       => AXI_HP_WACOUNT,
     AXI_HP_WRISSUECAP1EN => AXI_HP_WRISSUECAP1EN,
     -- write response channel
     AXI_HP_BVALID        => AXI_HP_BVALID,
     AXI_HP_BREADY        => AXI_HP_BREADY,
     AXI_HP_BID           => AXI_HP_BID, 
     AXI_HP_BRESP         => AXI_HP_BRESP,
     -- read address channel   
     AXI_HP_ARADDR        => AXI_HP_ARADDR,
     AXI_HP_ARVALID       => AXI_HP_ARVALID,
     AXI_HP_ARREADY       => AXI_HP_ARREADY,
     AXI_HP_ARID          => AXI_HP_ARID,   
     AXI_HP_ARLOCK        => AXI_HP_ARLOCK,
     AXI_HP_ARCACHE       => AXI_HP_ARCACHE,
     AXI_HP_ARPROT        => AXI_HP_ARPROT,
     AXI_HP_ARLEN         => AXI_HP_ARLEN,
     AXI_HP_ARSIZE        => AXI_HP_ARSIZE,
     AXI_HP_ARBURST       => AXI_HP_ARBURST,
     AXI_HP_ARQOS         => AXI_HP_ARQOS,
     -- read data channel  
     AXI_HP_RDATA         => AXI_HP_RDATA,
     AXI_HP_RVALID        => AXI_HP_RVALID,
     AXI_HP_RREADY        => AXI_HP_RREADY,
     AXI_HP_RID           => AXI_HP_RID,
     AXI_HP_RLAST         => AXI_HP_RLAST,
     AXI_HP_RRESP         => AXI_HP_RRESP,
     AXI_HP_RCOUNT        => AXI_HP_RCOUNT,
     AXI_HP_RACOUNT       => AXI_HP_RACOUNT,
     AXI_HP_RDISSUECAP1EN => AXI_HP_RDISSUECAP1EN,
  
     -- ov7670 signals
     pclk    => '0',
     xclk    => open,
     vsync   => '1',
     href    => '1',
     data    => (others => '0'),
     reset   => open,
     pwdn    => open,     
     siod    => siod,
     sioc    => sioc 
   );
           
   sim: process
     begin
     AXI_L_ARPROT  <= (others => '0');
     --AXI_L_ARVALID <= '0';     
     rst_n <= '0';
     wait for 100 ns;
     AXI_HP_AWREADY <= '1';
     AXI_HP_WREADY  <= '1';
     AXI_HP_BVALID  <= '1';
     rst_n <= '1';
     
     wait for 50 us;
     address <= x"00000010";
     read_start <= NOT read_start;       
     
     wait for 50 us;
     address <= x"00000010";
     data    <= x"00001280";
     write_start <= NOT write_start;  
     
     wait for 50 us;
     address <= x"00000014";
     data    <= x"00000001";
     write_start <= NOT write_start;       
     
     wait for 300 us;
     address <= x"00000014";
     data    <= x"00000001";
     write_start <= NOT write_start;         
     
     wait for 300 us;
     address <= x"00000014";
     data    <= x"00000001";
     write_start <= NOT write_start;         
     
     wait for 300 us;
     address <= x"00000014";
     read_start <= NOT read_start;     
     
     wait for 10 us;
     
     stop_sim <= true;
     --report "simulation finished successfully" severity FAILURE;
     wait;    
   end process;
   
   clock_100: process
     begin
        clk_100 <= '0';
        wait for clk_period_100/2;  --
        clk_100 <= '1';
        wait for clk_period_100/2;  --
        if stop_sim = true then
          wait;
        end if;
   end process;
   
   clock_25: process
     begin
        clk_25 <= '0';
        wait for clk_period_25/2;  --
        clk_25 <= '1';
        wait for clk_period_25/2;  --
        if stop_sim = true then
          wait;
        end if;
   end process;   
   
   write: process
     begin 
       wait until write_start'event;
       AXI_L_AWVALID <= '1';
       AXI_L_awaddr  <= address;
       wait for 10 ns;
       AXI_L_wvalid  <= '1';
       AXI_L_wstrb   <= (others => '1');
       AXI_L_wdata   <= data;
       wait until AXI_L_awready = '1' AND AXI_L_awready'EVENT;
       wait for 1 ns;
       AXI_L_awvalid <= '0';
       AXI_L_wvalid  <= '0';
       AXI_L_awaddr  <= (others => '0');
       AXI_L_wstrb   <= (others => '0');   
       wait until clk_100 = '1' AND clk_100'EVENT;
       wait for 1 ns;
       AXI_L_bready <= '1';
       wait until clk_100 = '1' AND clk_100'EVENT;
       wait for 1 ns;
       AXI_L_bready <= '0'; 
   end process;
   
   read: process
     begin 
       AXI_L_ARVALID <= '0';
       AXI_L_rready  <= '0';
       wait until read_start'event;
       wait until clk_100 = '0' AND clk_100'EVENT;
       AXI_L_ARVALID <= '1';
       AXI_L_araddr  <= address;
       --wait until AXI_L_arready = '1' AND AXI_L_awready'EVENT;
       wait until clk_100 = '1' AND clk_100'EVENT;
       wait for 1 ns;
       AXI_L_arvalid <= '0';
       AXI_L_rready  <= '1';
       AXI_L_araddr  <= (others => '0');
       wait until clk_100 = '1' AND clk_100'EVENT;
       wait for 1 ns;
       AXI_L_rready  <= '0';
   end process;   

end ARCHITECTURE behavior; 
