module bfm_chkr#(
parameter NAME = "Checker",
parameter MEM_SIZE = 100
)(
input      [127:0] rx_data,
input             rx_vld,
input             rx_rdy,

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
localparam ST_CHKR = 2'b10;

reg  [ 1:0] state;
reg  [ 1:0] state_next; 

//control
wire        clr;
reg  [31:0] cnt_clk;
reg  [31:0] cnt_data;
wire        cnt_ps_en;
reg  [31:0] cnt_ps;//verify data correctness: pass counter
wire        cnt_fl_en;
reg  [31:0] cnt_fl;//verify data correctness: fail counter
//fail case
integer     i;
wire        cmp_neq;
reg         flg_x;    
wire        flg_ovfl;    
wire        fail;    

//setup configuration
reg  [127:0] mem[0:MEM_SIZE-1];
wire [127:0] chk_data;
reg  [31:0] cfg_length;//length
reg         cfg_chk_x_en;
reg         cfg_chk_ovfl_en;
reg         cfg_ps_shwmsg_en;
reg         cfg_fl_hltsim_en;

reg         run_en;
reg  [31:0] wait_cycle;//wait cycle

////////////////////////////
//TASK: SETUP CONFIGURATION
////////////////////////////
//load test vectors into memory
task loadmem;
   input    [31:0]   addr;
   input    [127:0]   data;
   begin
      @(posedge clk);
      mem[addr] <= data;
      $display($time,,"load data = h%2h into memory[0x%8h] (%s)",data,addr,NAME);
   end
endtask
//length of checked data
task setcfg_length;
   input    [31:0]   length;
   begin
      @(posedge clk);
      cfg_length <= length;
      $display($time,,"setup cfg_length = %1d (%s)",length,NAME);
   end
endtask
//check data value if is unknown
task setcfg_check_unknown;
   input             enable;
   begin
      @(posedge clk);
      cfg_chk_x_en <= enable;
      $display($time,,"setup cfg_chk_x_en = %1b (%s)",enable,NAME);
   end
endtask
//check data length is overflow
task setcfg_check_overflow;
   input             enable;
   begin
      @(posedge clk);
      cfg_chk_ovfl_en <= enable;
      $display($time,,"setup cfg_chk_ovfl_en = %1b (%s)",enable,NAME);
   end
endtask
//display passed message
task setcfg_pass_showmsg;
   input             enable;
   begin
      @(posedge clk);
      cfg_ps_shwmsg_en <= enable;
      $display($time,,"setup cfg_ps_shwmsg_en = %1b (%s)",enable,NAME);
   end
endtask
//fail case to stop simulation
task setcfg_fail_stopsim;
   input             enable;
   begin
      @(posedge clk);
      cfg_fl_hltsim_en <= enable;
      $display($time,,"setup cfg_fl_hltsim_en = %1b (%s)",enable,NAME);
   end
endtask
//return pass count
task get_pass_cnt;
   output reg [31:0] ps_cnt;
   begin
      ps_cnt = cnt_ps;
      $display($time,,"get back cnt_ps = %1d (%s)",cnt_ps,NAME);
   end
endtask
//return fail count
task get_fail_cnt;
   output reg [31:0] fl_cnt;
   begin
      fl_cnt = cnt_fl;
      $display($time,,"get back cnt_fl = %1d (%s)",cnt_fl,NAME);
   end
endtask
//start=1, to trigger state machine to transmit data
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
//fail case
assign cmp_neq = rx_vld && rx_rdy && rx_data!==chk_data;
assign flg_x = cfg_chk_x_en && rx_vld && rx_rdy && rx_data === 8'hxx;
assign flg_ovfl = cfg_chk_ovfl_en && cnt_data > cfg_length;
assign fail = cmp_neq || flg_x || flg_ovfl;
//checker signals
assign chk_data = mem[cnt_data];
//next state
always@*begin
   state_next = state;

   case(state)
      ST_IDLE: if(run_en) 
                  if(wait_cycle==0)          state_next = ST_CHKR;
                  else                       state_next = ST_WAIT;
      ST_WAIT: if(cnt_clk==wait_cycle-32'h1) state_next = ST_CHKR;      
      ST_CHKR: if(cnt_data==cfg_length)      state_next = ST_IDLE;
   endcase
end

////////////////////////////
//Initial
////////////////////////////
//default value
initial begin
   for(i=0; i<MEM_SIZE; i=i+1)begin
      mem[i] = 0;
   end

   cfg_length       = 0;
   cfg_chk_x_en     = 0;
   cfg_chk_ovfl_en  = 0;
   cfg_ps_shwmsg_en = 0;
   cfg_fl_hltsim_en = 0;

   run_en           = 0;
   wait_cycle       = 0;
end
//state
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) state <= ST_IDLE;
   else state <= state_next;
end

//
assign clr = state==ST_IDLE && run_en;
//
//counter: count wait cycle
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) cnt_clk <= ST_IDLE;
   else if(clr) cnt_clk <= 0;
   else if(state==ST_WAIT) cnt_clk <= cnt_clk+1;
end

//counter: count received data
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) cnt_data <= ST_IDLE;
   else if(clr) cnt_data <= 0;
   else if(rx_vld && rx_rdy) cnt_data <= cnt_data+1;
end

//counter: count passed data
//
assign cnt_ps_en  = rx_vld && rx_rdy && rx_data===chk_data && ~fail;
//
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) cnt_ps <= 0;
   else if(clr) cnt_ps <= 0;
   else if(cnt_ps_en)begin
      cnt_ps <= cnt_ps+1;
      //display
      if(cfg_ps_shwmsg_en) $display($time,,"PASS) RX_DATA[0x%8h] (%s)",cnt_data,NAME);//shown pass message
   end
end

//counter: count failed data
//
assign cnt_fl_en  = rx_vld && rx_rdy && fail;
//
always@(posedge clk or negedge rst_n) begin
   if(~rst_n) cnt_fl <= 0;
   else if(clr) cnt_fl <= 0;
   else if(cnt_fl_en)begin
      cnt_fl <= cnt_fl+1;
      //display
      if(cmp_neq)          $display($time,,"NEQ) RX_DATA[0x%8h] = %2h, GOLD_DATA[0x%8h] = %2h (%s)",cnt_data,rx_data,cnt_data,mem[cnt_data],NAME);
      if(flg_x)            $display($time,,"UNKNOWN) RX_DATA[0x%8h] (%s)",cnt_data,NAME);//check unknown data
      if(flg_ovfl)         $display($time,,"OVERFLOW) (%s)",NAME);//check data length is overflow
      //Fail to halt simulation
      if(cfg_fl_hltsim_en)begin
         $display($time,,"FAIL) stop simultion (%s)",NAME);
         $finish;//check fail case, and finish simulation
      end
   end
end
endmodule
