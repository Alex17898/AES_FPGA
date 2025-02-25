`ifdef TC2//unknown case
   `define XMIT_TESTLEN 200
   `define RCVR_TESTLEN 200//`XMIT_TESTLEN*4, multiply 4
`else//TC1
   `define XMIT_TESTLEN 1000
   `define RCVR_TESTLEN 1000//`XMIT_TESTLEN*4, multiply 4
`endif

import "DPI-C" function int c_gen_test_vec(output int  test_vec_key0[`XMIT_TESTLEN],output int  test_vec_key1[`XMIT_TESTLEN],output int  test_vec_key2[`XMIT_TESTLEN],output int  test_vec_key3[`XMIT_TESTLEN],
										   output int  test_vec_din0[`XMIT_TESTLEN],output int  test_vec_din1[`XMIT_TESTLEN],output int  test_vec_din2[`XMIT_TESTLEN],output int  test_vec_din3[`XMIT_TESTLEN],
										   output int enc[`XMIT_TESTLEN],input int test_len);
import "DPI-C" function int c_get_gold_vec(output int gold_vec_dout0[`RCVR_TESTLEN],output int gold_vec_dout1[`RCVR_TESTLEN],output int gold_vec_dout2[`RCVR_TESTLEN],output int gold_vec_dout3[`RCVR_TESTLEN], 
										   input int test_vec_key0[`XMIT_TESTLEN],input int test_vec_key1[`XMIT_TESTLEN],input int test_vec_key2[`XMIT_TESTLEN],input int test_vec_key3[`XMIT_TESTLEN],
										   input int test_vec_din0[`XMIT_TESTLEN],input int test_vec_din1[`XMIT_TESTLEN],input int test_vec_din2[`XMIT_TESTLEN],input int test_vec_din3[`XMIT_TESTLEN],
										   input int enc[`XMIT_TESTLEN],input int test_len);
module testbench;
   //==============================
   // parameters
   //==============================
`define XMIT BFM_TX
`define RCVR BFM_RX
`define CHKR BFM_CHKR

localparam XMIT_TESTLEN = `XMIT_TESTLEN;
localparam RCVR_TESTLEN = `RCVR_TESTLEN;

`ifndef SHW_PSMSG//show pass message
localparam SHW_PSMSG = 0;
`else
localparam SHW_PSMSG = `SHW_PSMSG;
`endif

`ifndef FL_STPSIM//fail case to stop simulation
localparam FL_STPSIM = 0;
`else
localparam FL_STPSIM = `FL_STPSIM; 
`endif
   //==============================
   // signals
   //==============================
event       ev_load_mem;

wire [256:0] tx_data;
wire        tx_vld;
wire        tx_rdy;
wire        tx_busy;

wire [127:0] rx_data;
wire        rx_vld;
wire        rx_rdy;
wire        rx_busy;

wire [31:0]cnt_clk,wait_cycle;

reg         rst_n;
reg         clk;
reg         key_ld_p;
wire 		run_en;

reg  [257             -1:0] test_vec[0:XMIT_TESTLEN-1]; 
reg  [257*XMIT_TESTLEN-1:0] test_vec_bus; 
reg  [257             -1:0] test_vec_tmp; 
reg  [128             -1:0] gold_vec[0:RCVR_TESTLEN-1]; 
reg  [128*RCVR_TESTLEN-1:0] gold_vec_bus; 

reg  [31:0] pass_cnt;
reg  [31:0] fail_cnt;

integer     time_out;
integer     i;

//==============================
// test pattern
//==============================
`include "../bfm/test_case/test_include.v"
//==============================
// bfm
//==============================
//TX
bfm_xmit#(
   .MEM_SIZE   (XMIT_TESTLEN)
)  BFM_TX
(
   .tx_data    (tx_data),
   .tx_vld     (tx_vld),
   .tx_rdy     (tx_rdy),
   .tx_busy    (tx_busy),

   .clk        (clk),
   .rst_n      (rst_n),
   
   .cnt_clk(cnt_clk),
   .wait_cycle(wait_cycle),
   .run_en(run_en),
   .key_ld_p(key_ld_p)
);
//RX
bfm_rcvr       BFM_RX
(
   .rx_data    (rx_data),
   .rx_vld     (rx_vld),
   .rx_rdy     (rx_rdy),
   .rx_busy    (rx_busy),

   .clk        (clk),
   .rst_n      (rst_n)
);
//checker
bfm_chkr#(
   .MEM_SIZE   (RCVR_TESTLEN)
)  BFM_CHKR
(
   .rx_data    (rx_data),
   .rx_vld     (rx_vld),
   .rx_rdy     (rx_rdy),

   .clk        (clk),
   .rst_n      (rst_n)
);

   //==============================
   // dut aes-128
   //==============================
   aes            I_DUT
   (
      .key_ld_p   (key_ld_p),
      .key        (tx_data[255:128]),
      .enc        (tx_data[256]),
      .din_vld    (tx_vld),
      .din        (tx_data[127:0]),
      .din_rdy    (tx_rdy),
      .dout_vld   (rx_vld),
      .dout       (rx_data),
      .dout_rdy   (rx_rdy),
      .clk        (clk),
      .rst_n      (rst_n) 
   );

//==============================
// reset
//==============================
initial begin
   #100;
   rst_n = 0;
   #10;
   rst_n = 1;
end
//==============================
// clock
//==============================
initial begin
   clk = 0;
   forever #5 clk = ~clk;
end
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		key_ld_p<=0;
	end
	else if( (run_en) | (rx_vld & rx_rdy))begin
		key_ld_p<=1;
	end
	else begin
		key_ld_p<=0;
	end
end
//==============================
// test vectors and load into memory
//==============================
initial begin
   `ifdef USE_DPI
      $display($time,,"=============================================================");
      $display($time,,"Use DPI-C to generate golden/test vectors in SystemVerilog...");
      $display($time,,"=============================================================");
      test_vec_bus = gen_test_vec();
      for(int i=0; i<XMIT_TESTLEN; i=i+1)begin
         test_vec_tmp=test_vec_bus[257*(XMIT_TESTLEN-1-i)+:257];

         `ifdef TC2//unknown case
            if(i==32'd7) test_vec_tmp={test_vec_bus[257*(XMIT_TESTLEN-1-i)],{256{1'bx}}};//32-bit unknown @7
         `endif   
         //little endian 32-bit = byte[3], byte[2], byte[1], byte[0]
         test_vec[i]=test_vec_tmp;
      end
    //$display("(main)function test_vector_bus = %0x", test_vec_bus);

      gold_vec_bus = get_gold_vec(test_vec_bus);
      for(int i=0; i<RCVR_TESTLEN; i=i+1) gold_vec[i]=gold_vec_bus[128*(RCVR_TESTLEN-1-i)+:128];
   `else
      //dat pattern
      $display($time,,"=============================================================");
      $display($time,,"Use FILE I/O(readmemh) golden/test vectors from .dat files...");
      $display($time,,"=============================================================");
      `ifdef TC2//unknown case
         $readmemh("../c_model/test_vec/test_vec2.dat",test_vec);
         $readmemh("../c_model/test_vec/gold_vec2.dat",gold_vec);
      `else//TC1
         $readmemh("../c_model/test_vec/test_vec1.dat",test_vec);
         $readmemh("../c_model/test_vec/gold_vec1.dat",gold_vec);
      `endif
   `endif
   $display($time,,"=============================================================");
   $display($time,,"Generate Done");
   $display($time,,"=============================================================");

   @(posedge rst_n);
   //load test vectors into memory
   for(i=0;i<XMIT_TESTLEN;i=i+1) `XMIT.loadmem(i,test_vec[i]);
   //load golden vectors into memory
   for(i=0;i<RCVR_TESTLEN;i=i+1) `CHKR.loadmem(i,gold_vec[i]);  
   -> ev_load_mem;
end
//==============================
// DPI function
//==============================
function bit [257*XMIT_TESTLEN-1:0] gen_test_vec();
   bit [257*XMIT_TESTLEN-1:0] test_vec_bus;
   int                       test_vec_key0[0:XMIT_TESTLEN-1];
   int                       test_vec_key1[0:XMIT_TESTLEN-1];
   int                       test_vec_key2[0:XMIT_TESTLEN-1];
   int                       test_vec_key3[0:XMIT_TESTLEN-1];
   int                       test_vec_din0[0:XMIT_TESTLEN-1];
   int                       test_vec_din1[0:XMIT_TESTLEN-1];
   int                       test_vec_din2[0:XMIT_TESTLEN-1];
   int                       test_vec_din3[0:XMIT_TESTLEN-1];
   int                       enc[0:XMIT_TESTLEN-1];
   bit [32             -1:0] status;

   //call C funtion to generate random test vector (4-byte length = XMIT_TESTLEN)
   status = c_gen_test_vec(test_vec_key0,test_vec_key1,test_vec_key2,test_vec_key3,
						   test_vec_din0,test_vec_din1,test_vec_din2,test_vec_din3,enc,XMIT_TESTLEN);

   if(status==0)begin
      //unpack test_vec to test_vec_bus
      for(int i=0; i<XMIT_TESTLEN; i++)begin
         test_vec_bus[257*(XMIT_TESTLEN-1-i)+:257] = {enc[i],test_vec_key0[i],test_vec_key1[i],test_vec_key2[i],test_vec_key3[i],test_vec_din0[i],test_vec_din1[i],test_vec_din2[i],test_vec_din3[i]};
       //$display("(gen) C function test_vector[%08x] = %08x", i, test_vec[i]);
      end
   end
   else begin
       $display("C function c_gen_test_vec fail");
   end

   return test_vec_bus;
endfunction

function bit [128*RCVR_TESTLEN-1:0] get_gold_vec(input bit [257*XMIT_TESTLEN-1:0] test_vec_bus);
   int                       test_vec_key0[0:XMIT_TESTLEN-1];
   int                       test_vec_key1[0:XMIT_TESTLEN-1];
   int                       test_vec_key2[0:XMIT_TESTLEN-1];
   int                       test_vec_key3[0:XMIT_TESTLEN-1];
   int                       test_vec_din0[0:XMIT_TESTLEN-1];
   int                       test_vec_din1[0:XMIT_TESTLEN-1];
   int                       test_vec_din2[0:XMIT_TESTLEN-1];
   int                       test_vec_din3[0:XMIT_TESTLEN-1];
   int                       enc[0:XMIT_TESTLEN-1];
   bit [ 128*RCVR_TESTLEN-1:0] gold_vec_bus;
   int                      gold_vec_dout0[0:RCVR_TESTLEN-1];
   int                      gold_vec_dout1[0:RCVR_TESTLEN-1];
   int                      gold_vec_dout2[0:RCVR_TESTLEN-1];
   int                      gold_vec_dout3[0:RCVR_TESTLEN-1];
   bit [32             -1:0] status;

   //pack test_vec_bus to test_vec_byte
   for(int i=0; i<XMIT_TESTLEN; i++)begin
      {enc[i],test_vec_key0[i],test_vec_key1[i],test_vec_key2[i],test_vec_key3[i],test_vec_din0[i],test_vec_din1[i],test_vec_din2[i],test_vec_din3[i]} = test_vec_bus[257*(XMIT_TESTLEN-1-i)+:257] ;
    //$display("(get)function test_vector[%08x] = %08x", i, test_vec[i]);
   end

   //call C funtion to get golden vector from test vector
   status = c_get_gold_vec(gold_vec_dout0,gold_vec_dout1,gold_vec_dout2,gold_vec_dout3,
						   test_vec_key0,test_vec_key1,test_vec_key2,test_vec_key3,
						   test_vec_din0,test_vec_din1,test_vec_din2,test_vec_din3,
						   enc,XMIT_TESTLEN);

   if(status==0)begin
      //unpack gold_vect_byte to gold_vec_bus
      for(int i=0; i<RCVR_TESTLEN; i++)begin
         gold_vec_bus[128*(RCVR_TESTLEN-1-i)+:128] = {gold_vec_dout0[i],gold_vec_dout1[i],gold_vec_dout2[i],gold_vec_dout3[i]};
       //$display("(get)function gold_vector[%08x] = %02x", i, gold_vec_byte[i]);
      end
   end   
   else begin
       $display("C function c_get_gold_vec fail");
   end


   return gold_vec_bus;
endfunction

   //==============================
   // timeout
   //==============================
   initial begin
      if(!$value$plusargs("time_out=%d",time_out))begin
         time_out = 4_00000;
      end
      repeat(time_out)begin
         #(1_000);//1us
      end   
      $display($time,,"FAILED, timeout...");
      $finish;
   end
   //==============================
   // dump
   //==============================
   initial begin
   `ifdef USE_FSDB
      if($test$plusargs("FSDB"))begin
         $fsdbDumpfile("wave.fsdb");
         $fsdbDumpvars();
      end
   `endif   
   `ifdef USE_VCD
      if($test$plusargs("VCD"))begin
         $dumpfile("wave.vcd");
         $dumpvars();
         //only dump one hierarchy from testbench top
         //$dumpvars(1,testbench);
      end
   `endif   
   `ifdef USE_GLS
      if($test$plusargs("FSDB"))begin
         $sdf_annotate("../syn/aes_syn.sdf", I_DUT);
         $fsdbDumpfile("wave_syn.fsdb");
         $fsdbDumpvars();
         //only dump one hierarchy from testbench top
         //$dumpvars(1,testbench);
      end
   `endif 
   end


endmodule
