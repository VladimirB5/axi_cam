`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2018 04:07:34 PM
// Design Name: 
// Module Name: test_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;
import design_1_axi_vip_1_0_pkg::*;
module test_tb();
  
  design_1_axi_vip_0_0_mst_t                               agent;
  design_1_axi_vip_1_0_slv_t                               agent_slv;

  /*************************************************************************************************
  * Declare variables which will be used in API and parital randomization for transaction generation
  * and data read back from driver.
  *************************************************************************************************/
  axi_transaction                                          wr_trans;            // Write transaction
  axi_transaction                                          rd_trans;            // Read transaction
  xil_axi_uint                                             mtestWID;            // Write ID  
  xil_axi_ulong                                            mtestWADDR;          // Write ADDR  
  xil_axi_len_t                                            mtestWBurstLength;   // Write Burst Length   
  xil_axi_size_t                                           mtestWDataSize;      // Write SIZE  
  xil_axi_burst_t                                          mtestWBurstType;     // Write Burst Type  
  xil_axi_uint                                             mtestRID;            // Read ID  
  xil_axi_ulong                                            mtestRADDR;          // Read ADDR  
  xil_axi_len_t                                            mtestRBurstLength;   // Read Burst Length   
  xil_axi_size_t                                           mtestRDataSize;      // Read SIZE  
  xil_axi_burst_t                                          mtestRBurstType;     // Read Burst Type  

  xil_axi_data_beat [255:0]                                mtestWUSER;         // Write user  
  xil_axi_data_beat                                        mtestAWUSER;        // Write Awuser 
  xil_axi_data_beat                                        mtestARUSER;        // Read Aruser 
  /************************************************************************************************
  * A burst can not cross 2KB address boundry AXI3
  * Maximum data bits = 2*1024*8 =16384
  * Write Data Value for WRITE_BURST transaction
  * Read Data Value for READ_BURST transaction
  ************************************************************************************************/
  bit [16383:0]                                            mtestWData;         // Write Data
  bit[8*4096-1:0]                                          Rdatablock;        // Read data block
  xil_axi_data_beat                                        Rdatabeat[];       // Read data beats
  bit[8*4096-1:0]                                          Wdatablock;        // Write data block
  xil_axi_data_beat                                        Wdatabeat[];       // Write data beats
  
  xil_axi_payload_byte                    data_mem[xil_axi_ulong];
  initial begin
      /***********************************************************************************************
      * Before agent is newed, user has to run simulation with an empty testbench to find the hierarchy
      * path of the AXI VIP's instance.Message like
      * "Xilinx AXI VIP Found at Path: my_ip_exdes_tb.DUT.ex_design.axi_vip_mst.inst" will be printed 
      * out. Pass this path to the new function. 
      ***********************************************************************************************/
      agent = new("master vip agent",test_tb.i_design_1_wrapper.design_1_i.axi_vip_0.inst.IF);
      agent.start_master();               // agent start to run

      agent_slv = new("slave vip agent",test_tb.i_design_1_wrapper.design_1_i.axi_vip_1.inst.IF);
      agent_slv.start_slave();          //agent start to run
      agent_slv.start_monitor();
  
     //fork off the process of write response and/or read response
      fork
        wr_response();
        rd_response();
      join_none     
  
      #(5us);
      mtestWID = $urandom_range(0,(1<<(0)-1)); 
      mtestWADDR = 32'h0000_0004;
      mtestWBurstLength = 0;
      mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
      mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
      mtestWData = 32'h44A0_0000;
      //single write transaction filled in user inputs through API 
      single_write_transaction_api("single write with api",
                                   .id(mtestWID),
                                   .addr(mtestWADDR),
                                   .len(mtestWBurstLength), 
                                   .size(mtestWDataSize),
                                   .burst(mtestWBurstType),
                                   .wuser(mtestWUSER),
                                   .awuser(mtestAWUSER), 
                                   .data(mtestWData)
                                   );    
  
  
      #(5us);
      mtestWID = $urandom_range(0,(1<<(0)-1)); 
      mtestWADDR = 32'h0000_0000;
      mtestWBurstLength = 0;
      mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
      mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
      mtestWData[31:0] = 32'h0000_0001;
      //single write transaction filled in user inputs through API 
      single_write_transaction_api("single write with api",
                                   .id(mtestWID),
                                   .addr(mtestWADDR),
                                   .len(mtestWBurstLength), 
                                   .size(mtestWDataSize),
                                   .burst(mtestWBurstType),
                                   .wuser(mtestWUSER),
                                   .awuser(mtestAWUSER), 
                                   .data(mtestWData)
                                   );   

      #(5us);
      mtestWID = $urandom_range(0,(1<<(0)-1)); 
      mtestWADDR = 32'h0000_000C; // activate test mode
      mtestWBurstLength = 0;
      mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
      mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
      mtestWData[31:0] = 32'h0000_0001;
      //single write transaction filled in user inputs through API 
      single_write_transaction_api("single write with api",
                                   .id(mtestWID),
                                   .addr(mtestWADDR),
                                   .len(mtestWBurstLength), 
                                   .size(mtestWDataSize),
                                   .burst(mtestWBurstType),
                                   .wuser(mtestWUSER),
                                   .awuser(mtestAWUSER), 
                                   .data(mtestWData)
                                   );   


        #(10us);        
        mtestRID = 0;
        mtestRADDR = 0;
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        //single read transaction filled in user inputs through API 
        single_read_transaction_api("single read with api",
                                     .id(mtestRID),
                                     .addr(mtestRADDR),
                                     .len(mtestRBurstLength), 
                                     .size(mtestRDataSize),
                                     .burst(mtestRBurstType)
                                     );  
               
         
      agent.wait_drivers_idle();           // Wait driver is idle 
     
    end
    
  /*************************************************************************************************
     * wr_response: Task which write driver in slave agent waits till it sees a write transaction
     * and then user enviroment fill in write response, write driver send it over to VIP interface
     * When slave VIP is configured in READ_WRITE/WRITE_ONLY mode,user environment must call this task
     * Otherwise, the simulation will hang there waiting for BRESP from slave till time out.
     *************************************************************************************************/
     task wr_response();
       axi_transaction                    wr_reactive;  //Declare a handle for write response
       forever begin  
         agent_slv.wr_driver.get_wr_reactive(wr_reactive); //Block till write transaction occurs
         fill_wr_reactive(wr_reactive);                //User fill in write response
         agent_slv.wr_driver.send(wr_reactive);            //Write driver send response to VIP interface
         $display("VB AXI CMD:%s", wr_reactive.cmd_sprintf());
         $display("VB AXI CMD CNT:%d", wr_reactive.get_transfer_byte_count());
       end
     endtask
   
     /*************************************************************************************************
     * rd_response: Task which read driver in slave agent waits till it sees a read transaction
     * and then user enviroment fill in read data channel,read driver send it over to VIP interface
     * When slave VIP is configured in READ_WRITE/READ_ONLY mode,user environment must call this task
     * Otherwise, the simulation will hang there waiting for data channel from slave till time out.
     *************************************************************************************************/
     task rd_response();
       //axi_transaction                   rd_reactive;  //Declare a handle for read response
       forever begin
         //agent_slv.rd_driver.get_rd_reactive(rd_reactive); //Block till read transaction occurs
         //fill_rd_reactive(rd_reactive);                //User fill in read response
         //agent_slv.rd_driver.send(rd_reactive);            //Write driver send response to VIP interface
         #(10us);
       end  
     endtask
  
    /*************************************************************************************************
    * Fill_wr_reactive: Task fills in BREPS,BUSER(when BUSER_WIDTH>0) for write response channel
    * This task show simple example so buser is being set to 0 and bresp is XIL_AXI_RESP_OKAY
    * Fill in all these information into reactive response
    *************************************************************************************************/
    function automatic void fill_wr_reactive(inout axi_transaction t);
      t.set_bresp(XIL_AXI_RESP_OKAY);
    endfunction: fill_wr_reactive    
  
  /************************************************************************************************
  *  task single_write_transaction_api is to create a single write transaction, fill in transaction 
  *  by using APIs and send it to write driver.
  *   1. declare write transction
  *   2. Create the write transaction
  *   3. set addr, burst,ID,length,size by calling set_write_cmd(addr, burst,ID,length,size), 
  *   4. set prot.lock, cache,region and qos
  *   5. set beats
  *   6. set AWUSER if AWUSER_WIDH is bigger than 0
  *   7. set WUSER if WUSR_WIDTH is bigger than 0
  *************************************************************************************************/

  task automatic single_write_transaction_api ( 
                                input string                     name ="single_write",
                                input xil_axi_uint               id =0, 
                                input xil_axi_ulong              addr =0,
                                input xil_axi_len_t              len =0, 
                                input xil_axi_size_t             size =xil_axi_size_t'(xil_clog2((32)/8)),
                                input xil_axi_burst_t            burst =XIL_AXI_BURST_TYPE_INCR,
                                input xil_axi_lock_t             lock = XIL_AXI_ALOCK_NOLOCK,
                                input xil_axi_cache_t            cache =3,
                                input xil_axi_prot_t             prot =0,
                                input xil_axi_region_t           region =0,
                                input xil_axi_qos_t              qos =0,
                                input xil_axi_data_beat [255:0]  wuser =0, 
                                input xil_axi_data_beat          awuser =0,
                                input bit [16383:0]              data =0
                                                );
    axi_transaction                               wr_trans;
    wr_trans = agent.wr_driver.create_transaction(name);
    wr_trans.set_write_cmd(addr,burst,id,len,size);
    wr_trans.set_prot(prot);
    wr_trans.set_lock(lock);
    wr_trans.set_cache(cache);
    wr_trans.set_region(region);
    wr_trans.set_qos(qos);
    wr_trans.set_data_block(data);
    agent.wr_driver.send(wr_trans);   
  endtask  : single_write_transaction_api 
  
  /************************************************************************************************
  *  task single_read_transaction_api is to create a single read transaction, fill in command with user
  *  inputs and send it to read driver.
  *   1. declare read transction
  *   2. Create the read transaction
  *   3. set addr, burst,ID,length,size by calling set_read_cmd(addr, burst,ID,length,size), 
  *   4. set prot.lock, cache,region and qos
  *   5. set ARUSER if ARUSER_WIDH is bigger than 0
  *************************************************************************************************/
  task automatic single_read_transaction_api ( 
                                    input string                     name ="single_read",
                                    input xil_axi_uint               id =0, 
                                    input xil_axi_ulong              addr =0,
                                    input xil_axi_len_t              len =0, 
                                    input xil_axi_size_t             size =xil_axi_size_t'(xil_clog2((32)/8)),
                                    input xil_axi_burst_t            burst =XIL_AXI_BURST_TYPE_INCR,
                                    input xil_axi_lock_t             lock =XIL_AXI_ALOCK_NOLOCK ,
                                    input xil_axi_cache_t            cache =3,
                                    input xil_axi_prot_t             prot =0,
                                    input xil_axi_region_t           region =0,
                                    input xil_axi_qos_t              qos =0,
                                    input xil_axi_data_beat          aruser =0
                                                );
    axi_transaction                               rd_trans;
    rd_trans = agent.rd_driver.create_transaction(name);
    rd_trans.set_read_cmd(addr,burst,id,len,size);
    rd_trans.set_prot(prot);
    rd_trans.set_lock(lock);
    rd_trans.set_cache(cache);
    rd_trans.set_region(region);
    rd_trans.set_qos(qos);
    agent.rd_driver.send(rd_trans);   
  endtask  : single_read_transaction_api  
  

   bit rstn;
   bit clk;
   bit clk_25;
  
  initial begin
    rstn <= 1'b1;
    #(10ns);
    rstn <= 1'b0;
    #(10ns);
    rstn <= 1'b1;
  end
  
  always #5 clk <= ~clk; 
  always #20 clk_25 <= ~clk_25; 
  
  design_1_wrapper i_design_1_wrapper
     (.AXI_HP_RACOUNT(),
      .AXI_HP_RCOUNT(),
      .AXI_HP_RDISSUECAP1EN(),
      .AXI_HP_WACOUNT(),
      .AXI_HP_WCOUNT(),
      .AXI_HP_WRISSUECAP1EN(),
      .clk(clk),
      .clk25(clk_25),
      .data(),
      .href(1'b1),
      .pclk(),
      .pwdn(),
      .reset(),
      .rstn(rstn),
      .sioc(),
      .siod(),
      .vsync(1'b1),
      .xclk());
endmodule
