module bfm_rcvr#(
parameter NAME = "Receiver"
)(
input      [ 127:0] rx_data,
input             rx_vld,
output reg        rx_rdy,
output reg        rx_busy,

input             clk,
input             rst_n
);
//
//
////////////////////////////
//DECLARITION
////////////////////////////
//state
localparam ST_IDLE = 2'b00;
localparam ST_WAIT = 2'b01;
localparam ST_RCVD = 2'b10;//receive state
localparam ST_HOLD = 2'b11;

reg [ 1:0] state;
reg [ 1:0] state_next; 

//control
wire       clr;
reg [31:0] cnt_clk;
reg [31:0] cnt_data;
reg [31:0] cnt_hold;

//setup configuration
reg [31:0] cfg_length;//length
reg        cfg_pause_en;//pause enable
reg [31:0] cfg_pause_cycle;//pause rate
reg [31:0] pause_cycle;

reg        run_en;
reg [31:0] wait_cycle;//wait cycle

////////////////////////////
//TASK: SETUP CONFIGURATION
////////////////////////////
//length of received data
task setcfg_length;
   input    [31:0]   length;
   begin
      @(posedge clk);
      cfg_length <= length;
      $display($time,,"setup cfg_length = %1d (%s)",length,NAME);
   end
endtask
//pause enable: data valid with a pause rate
task setcfg_pause;
   input             enable;
   begin
      @(posedge clk);
      cfg_pause_en <= enable;
      $display($time,,"setup cfg_pause_en = %1b (%s)",enable,NAME);
   end
endtask
//pause cycle: pause rate in a random range
task setcfg_pause_rate;
   input    [31:0]   clk_cycle;
   begin
      @(posedge clk);
      cfg_pause_cycle <= clk_cycle;
      $display($time,,"setup cfg_pause_cycle = %1d (%s)",clk_cycle,NAME);
   end
endtask
//start=1, to trigger state machine to receive data
task start;
   input    start_bit;
   input    [31:0]   cycle;
   begin
      @(posedge clk);
      run_en     <= start_bit;
      wait_cycle <= cycle;
      @(posedge clk);
      run_en     <= 0;
   end
endtask

////////////////////////////
//ASSIGNMENT
////////////////////////////
//transmitter signals
assign rx_busy = state!=ST_IDLE;
assign rx_rdy  = state==ST_RCVD;
//next state
always@*begin
   state_next = state;

   case(state)
      ST_IDLE: if(run_en) 
                  if(wait_cycle==0)              state_next = ST_RCVD;
                  else                           state_next = ST_WAIT;
      ST_WAIT: if(cnt_clk==wait_cycle-32'h1)     state_next = ST_RCVD;      
      ST_RCVD: if(rx_vld)
                  if(cnt_data==cfg_length-32'h1) state_next = ST_IDLE;
                  else if(cfg_pause_en)          state_next = ST_HOLD;
      ST_HOLD: if(cnt_hold==pause_cycle)         state_next = ST_RCVD;
   endcase
end

////////////////////////////
//Initial
////////////////////////////
//default value
initial begin
   cfg_length      = 0;
   cfg_pause_en    = 0;
   cfg_pause_cycle = 0;

   run_en          = 0;
   wait_cycle      = 0;
end

//state
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) state <= ST_IDLE;
   else state <= state_next;
end

//
assign clr = state==ST_IDLE && run_en;

//counter: count wait cycle
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) cnt_clk <= 0;
   else if(clr) cnt_clk <= 0;
   else if(state==ST_WAIT) cnt_clk <= cnt_clk+1;
end   

//counter: count received data
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) cnt_data <= 0;
   else if(clr) cnt_data <= 0;
   else if(state==ST_RCVD && rx_vld) cnt_data <= cnt_data+1;
end

//counter: count pause cycle
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) cnt_hold <= 0;
   else if(clr || state==ST_RCVD) cnt_hold <= 0;
   else if(state==ST_HOLD) cnt_hold <= cnt_hold+1;
end

//pause_cycle = pause_rate(random)*cfg_pause_cycle
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) pause_cycle <= 0;
   else if(state==ST_RCVD && rx_vld && rx_rdy && cfg_pause_en) pause_cycle <= {$random()} % cfg_pause_cycle;
end
endmodule

