`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/28 02:03:51
// Design Name: 
// Module Name: aes
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


module aes(
   input              key_ld_p, //key load pulse
   input      [127:0] key     , //cipher key
   input              enc     , //0: decryption, 1:encryption
   input              din_vld , //
   input      [127:0] din     , //data in
   output             din_rdy , //
   output             dout_vld, //
   output     reg [127:0] dout    , //data out
   input              dout_rdy, //
   input              clk     ,
   input              rst_n     //active low asynchronous reset
   );
	
	wire rk_vld,rk_rdy,val,din_val,dout_val,flag;
    reg [31:0]mix_in_0;
	wire [31:0]mix_in,mix_out,invmix_out;
	wire [127:0]rk;
	reg [1:0]mix_cnt;
	reg [3:0]sub_cnt,round_cnt;
	reg [7:0]sbox_in;
  wire [7:0]sbox_out,invsbox_out;
	reg [127:0]dout_next;
	reg [4:0]state,next_state;
	parameter [4:0] IDLE =5'd0;
	parameter [4:0] DIN_LD =5'd1;
	parameter [4:0] AddRoundKey_0 =5'd2;
	
	parameter [4:0] SubBytes =5'd3;
	parameter [4:0] ShiftRows =5'd4;
	parameter [4:0] MixColumns =5'd5;
	
	parameter [4:0] InvShiftRow =5'd6;
	parameter [4:0] InvSubBytes =5'd7;
	parameter [4:0] InvMixColumns =5'd8;
	
	parameter [4:0] AddRoundKey =5'd9;

	parameter [4:0] SubBytes_10 =5'd10;
	parameter [4:0] ShiftRows_10 =5'd11;
	
	parameter [4:0] InvShiftRows_10 =5'd12;
	parameter [4:0] InvSubBytes_10 =5'd13;
	
	parameter [4:0] AddRoundKey_10 =5'd14;
	parameter [4:0] Done =5'd15;
	
	parameter [4:0] Revoke =5'd16;
	
	kexp U0(.key_ld_p(key_ld_p),.key(key),.enc(enc),.rk_vld(rk_vld),.rk(rk),.rk_rdy(rk_rdy),.clk(clk),.rst_n(rst_n),.flag(flag));
	sbox U1(.data_in(sbox_in),.data_out(sbox_out));
	InvSbox U2(.data_in(sbox_in),.data_out(invsbox_out));
	MixColumns U3(.In(mix_in),.Out(mix_out));
	InvMixColumns U4(.In(mix_in),.Out(invmix_out));
	
	assign mix_in=mix_in_0;
	assign din_rdy=(state==DIN_LD)?1'b1:1'b0;
	assign din_val=din_rdy & din_vld;
	assign rk_rdy=(state==AddRoundKey_0 | state==AddRoundKey | state==AddRoundKey_10)?1'b1:1'b0;
	assign val=rk_rdy & rk_vld;
	assign dout_vld=(state==Done)?1'b1:1'b0;
	assign dout_val=dout_rdy & dout_vld;
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			state<=IDLE;
		end
		else if(key_ld_p & din_rdy)begin
			state<=Revoke;
		end
		else begin
			state<=next_state;
		end
	end
	
	always@(*)begin
		case(state)
			IDLE:next_state<=(key_ld_p | din_val)?DIN_LD:IDLE;
			DIN_LD:next_state<=(din_val)?AddRoundKey_0:DIN_LD;
			AddRoundKey_0:next_state<=(val)?( (flag)?InvShiftRow:SubBytes ):AddRoundKey_0;
			
			SubBytes:next_state<=(sub_cnt==15)?ShiftRows:SubBytes;  //enc start
			ShiftRows:next_state<=MixColumns;
			MixColumns:next_state<=(mix_cnt==3)?AddRoundKey:MixColumns;  //enc end
			
			InvShiftRow:next_state<=InvSubBytes;  //dec start
			InvSubBytes:next_state<=(sub_cnt==15)?AddRoundKey:InvSubBytes;
			InvMixColumns:next_state<=(mix_cnt==3)?( (round_cnt==8)?InvShiftRows_10:InvShiftRow ):InvMixColumns;
			
			AddRoundKey:next_state<=(val)?( (flag)?InvMixColumns:( (round_cnt==8)?SubBytes_10:SubBytes ) ):AddRoundKey;
			
			SubBytes_10:next_state<=(sub_cnt==15)?ShiftRows_10:SubBytes_10;
			ShiftRows_10:next_state<=AddRoundKey_10;
			
			InvShiftRows_10:next_state<=InvSubBytes_10;
			InvSubBytes_10:next_state<=(sub_cnt==15)?AddRoundKey_10:InvSubBytes_10;
			
			AddRoundKey_10:next_state<=(val)?Done:AddRoundKey_10;
			Done:next_state<=(dout_val)?DIN_LD:Done;
			
			Revoke:next_state<=DIN_LD;
      default:next_state<=IDLE;
		endcase
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			dout<=0;
		end
		else begin
			dout<=dout_next;
		end
	end
	
	always@(*)begin
		if(state==IDLE)begin
			dout_next<=0;
		end
		else if(state==DIN_LD)begin
			dout_next<=din;
		end
		else if(state==AddRoundKey_0 | state==AddRoundKey | state==AddRoundKey_10)begin
			dout_next<=(val)?dout ^ rk:dout;
		end
		else if(state==SubBytes | state==SubBytes_10 | state==InvSubBytes | state==InvSubBytes_10)begin
			case(sub_cnt)
				4'd0:dout_next<=(flag)?{dout[127:8],invsbox_out}:{dout[127:8],sbox_out};
				4'd1:dout_next<=(flag)?{dout[127:16],invsbox_out,dout[7:0]}:{dout[127:16],sbox_out,dout[7:0]};
				4'd2:dout_next<=(flag)?{dout[127:24],invsbox_out,dout[15:0]}:{dout[127:24],sbox_out,dout[15:0]};
				4'd3:dout_next<=(flag)?{dout[127:32],invsbox_out,dout[23:0]}:{dout[127:32],sbox_out,dout[23:0]};
				4'd4:dout_next<=(flag)?{dout[127:40],invsbox_out,dout[31:0]}:{dout[127:40],sbox_out,dout[31:0]};
				4'd5:dout_next<=(flag)?{dout[127:48],invsbox_out,dout[39:0]}:{dout[127:48],sbox_out,dout[39:0]};
				4'd6:dout_next<=(flag)?{dout[127:56],invsbox_out,dout[47:0]}:{dout[127:56],sbox_out,dout[47:0]};
				4'd7:dout_next<=(flag)?{dout[127:64],invsbox_out,dout[55:0]}:{dout[127:64],sbox_out,dout[55:0]};
				4'd8:dout_next<=(flag)?{dout[127:72],invsbox_out,dout[63:0]}:{dout[127:72],sbox_out,dout[63:0]};
				4'd9:dout_next<=(flag)?{dout[127:80],invsbox_out,dout[71:0]}:{dout[127:80],sbox_out,dout[71:0]};
				4'd10:dout_next<=(flag)?{dout[127:88],invsbox_out,dout[79:0]}:{dout[127:88],sbox_out,dout[79:0]};
				4'd11:dout_next<=(flag)?{dout[127:96],invsbox_out,dout[87:0]}:{dout[127:96],sbox_out,dout[87:0]};
				4'd12:dout_next<=(flag)?{dout[127:104],invsbox_out,dout[95:0]}:{dout[127:104],sbox_out,dout[95:0]};
				4'd13:dout_next<=(flag)?{dout[127:112],invsbox_out,dout[103:0]}:{dout[127:112],sbox_out,dout[103:0]};
				4'd14:dout_next<=(flag)?{dout[127:120],invsbox_out,dout[111:0]}:{dout[127:120],sbox_out,dout[111:0]};
				4'd15:dout_next<=(flag)?{invsbox_out,dout[119:0]}:{sbox_out,dout[119:0]};
				default:dout_next<=dout;
			endcase
		end
		else if(state==ShiftRows | state==ShiftRows_10 | state==InvShiftRow | state==InvShiftRows_10)begin
			dout_next<=(flag)?{dout[127:120],dout[23:16],dout[47:40],dout[71:64],
						dout[95:88],dout[119:112],dout[15:8],dout[39:32],
						dout[63:56],dout[87:80],dout[111:104],dout[7:0],
						dout[31:24],dout[55:48],dout[79:72],dout[103:96]}:
						{dout[127:120],dout[87:80],dout[47:40],dout[7:0],
						dout[95:88],dout[55:48],dout[15:8],dout[103:96],
						dout[63:56],dout[23:16],dout[111:104],dout[71:64],
						dout[31:24],dout[119:112],dout[79:72],dout[39:32]};
		end
		else if(state==MixColumns | state==InvMixColumns)begin
			case(mix_cnt)
				2'd0:dout_next<=(flag)?{dout[127:32],invmix_out}:{dout[127:32],mix_out};
				2'd1:dout_next<=(flag)?{dout[127:64],invmix_out,dout[31:0]}:{dout[127:64],mix_out,dout[31:0]};
				2'd2:dout_next<=(flag)?{dout[127:96],invmix_out,dout[63:0]}:{dout[127:96],mix_out,dout[63:0]};
				2'd3:dout_next<=(flag)?{invmix_out,dout[95:0]}:{mix_out,dout[95:0]};
				default:dout_next<=dout;
			endcase
		end
		else begin
			dout_next<=dout;
		end
	end
	
	always@(*)begin
		case(sub_cnt)
			4'd0:sbox_in<=dout[7:0];
			4'd1:sbox_in<=dout[15:8];
			4'd2:sbox_in<=dout[23:16];
			4'd3:sbox_in<=dout[31:24];
			4'd4:sbox_in<=dout[39:32];
			4'd5:sbox_in<=dout[47:40];
			4'd6:sbox_in<=dout[55:48];
			4'd7:sbox_in<=dout[63:56];
			4'd8:sbox_in<=dout[71:64];
			4'd9:sbox_in<=dout[79:72];
			4'd10:sbox_in<=dout[87:80];
			4'd11:sbox_in<=dout[95:88];
			4'd12:sbox_in<=dout[103:96];
			4'd13:sbox_in<=dout[111:104];
			4'd14:sbox_in<=dout[119:112];
			4'd15:sbox_in<=dout[127:120];
			default:sbox_in<=0;
		endcase
	end
	
	always@(*)begin
		case(mix_cnt)
			2'd0:mix_in_0<=dout[31:0];
			2'd1:mix_in_0<=dout[63:32];
			2'd2:mix_in_0<=dout[95:64];
			2'd3:mix_in_0<=dout[127:96];
			default:mix_in_0<=0;
		endcase
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			sub_cnt<=0;
		end
		else if(sub_cnt==15)begin
			sub_cnt<=0;
		end
		else if(state==SubBytes | state==SubBytes_10 | state==InvSubBytes | state==InvSubBytes_10)begin
			sub_cnt<=sub_cnt+1;
		end
		else begin
			sub_cnt<=sub_cnt;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			mix_cnt<=0;
		end
		else if(mix_cnt==3)begin
			mix_cnt<=0;
		end
		else if(state==MixColumns | state==InvMixColumns)begin
			mix_cnt<=mix_cnt+1;
		end
		else begin
			mix_cnt<=mix_cnt;
		end
	end	
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			round_cnt<=0;
		end
		else if(round_cnt==9)begin
			round_cnt<=0;
		end
		else if( (~flag & state==AddRoundKey & val) |(flag & state==InvMixColumns & mix_cnt==3))begin
			round_cnt<=round_cnt+1;
		end
		else begin
			round_cnt<=round_cnt;
		end
	end	

endmodule

module kexp(
   input              key_ld_p, //key load pulse
   input      [127:0] key     , //cipher key
   input              enc     , //0:decryption, 1:encryption
   output             rk_vld  , //round key valid
   output     reg [127:0] rk      , //round key
   input              rk_rdy  , //round key ready
   input              clk     , //clock
   input              rst_n   , //active low asynchronous reset
   output reg flag
   );
   wire [31:0]shift,rc;
   wire [31:0]w0_enc,w1_enc,w2_enc,w3_enc;
   wire [31:0]w0_dec,w1_dec,w2_dec,w3_dec;
   wire [127:0]rk_next;
   wire [7:0]sbox_out;
   wire val;
   reg dec,next_trigger,first;
   reg [2:0]cnt;
   reg [7:0]sbox_in;
   reg [127:0]key_ld;
   reg [31:0]RCON,new_sboxw,shift_reg;
   reg [3:0]state,next_state;
   parameter [3:0] IDLE =4'd0;
   parameter [3:0] RK0 = 4'd1;
   parameter [3:0] RK1 = 4'd2;
   parameter [3:0] RK2 = 4'd3;
   parameter [3:0] RK3 = 4'd4;
   parameter [3:0] RK4 = 4'd5;
   parameter [3:0] RK5 = 4'd6;
   parameter [3:0] RK6 = 4'd7;
   parameter [3:0] RK7 = 4'd8;
   parameter [3:0] RK8 = 4'd9;
   parameter [3:0] RK9 = 4'd10;
   parameter [3:0] DONE = 4'd11;


always@(posedge clk or negedge rst_n)begin
  if(~rst_n)begin
    state<=IDLE;
  end
  else
    state<=next_state;
end

always@(*)begin
  case(state)
    IDLE:begin
      next_state=( (key_ld_p & ~enc) | (rk_rdy & next_trigger & flag) | (rk_rdy & next_trigger & val) | val)?RK0:IDLE;
      RCON=32'h0;
    end
    RK0:begin
      next_state=(flag)? ( (dec)?( (val)?DONE:RK0 ):(cnt==6)?RK1:RK0 ) : ( (val)?RK1:RK0 );
      RCON=32'h01_00_00_00;
    end
    RK1:begin
      next_state=(flag)? ( (dec)?( (val)?RK0:RK1 ):(cnt==6)?RK2:RK1 ) : ( (val)?RK2:RK1 );
      RCON=32'h02_00_00_00;
    end
    RK2:begin
      next_state=(flag)? ( (dec)?( (val)?RK1:RK2 ):(cnt==6)?RK3:RK2 ) : ( (val)?RK3:RK2 );
      RCON=32'h04_00_00_00;
    end
    RK3:begin
      next_state=(flag)? ( (dec)?( (val)?RK2:RK3 ):(cnt==6)?RK4:RK3 ) : ( (val)?RK4:RK3 );
      RCON=32'h08_00_00_00;
    end
    RK4:begin
      next_state=(flag)? ( (dec)?( (val)?RK3:RK4 ):(cnt==6)?RK5:RK4 ) : ( (val)?RK5:RK4 );
      RCON=32'h10_00_00_00;
    end
    RK5:begin
      next_state=(flag)? ( (dec)?( (val)?RK4:RK5 ):(cnt==6)?RK6:RK5 ) : ( (val)?RK6:RK5 );
      RCON=32'h20_00_00_00;
    end
    RK6:begin
      next_state=(flag)? ( (dec)?( (val)?RK5:RK6 ):(cnt==6)?RK7:RK6 ) : ( (val)?RK7:RK6 );
      RCON=32'h40_00_00_00;
    end
    RK7:begin
      next_state=(flag)? ( (dec)?( (val)?RK6:RK7 ):(cnt==6)?RK8:RK7 ) : ( (val)?RK8:RK7 );
      RCON=32'h80_00_00_00;
    end
    RK8:begin
      next_state=(flag)? ( (dec)?( (val)?RK7:RK8 ):(cnt==6)?RK9:RK8 ) : ( (val)?RK9:RK8 );
      RCON=32'h1b_00_00_00;
    end
    RK9:begin
      next_state=(flag)? ((dec & cnt==6 & val)?RK8:RK9 ): ( (val)?DONE:RK9 );
      RCON=32'h36_00_00_00;
    end
	DONE:begin
      next_state=IDLE;
      RCON=32'h0;
    end
    default:begin
      next_state=IDLE;
      RCON=32'h0;
    end
  endcase
end

always@(posedge clk or negedge rst_n)begin
  if(~rst_n)begin
    rk<=128'd0;
	key_ld<=128'd0;
  end
  else if(key_ld_p) begin
    rk<=key;
	key_ld<=key;
  end
  else if(state==IDLE)begin
	rk<=key_ld;
	key_ld<=key_ld;
  end
  else if(state!=IDLE & state!=DONE & cnt==5)begin
    rk<=rk_next;
	key_ld<=key_ld;
  end
  else begin
    rk<=rk;
	key_ld<=key_ld;
  end
end

always@(posedge clk or negedge rst_n)begin
  if(~rst_n)begin
    first<=0;
  end
  else if(state==DONE)begin
	first<=0;
  end
  else if(key_ld_p | (rk_rdy & next_trigger) ) begin
    first<=1;
  end
  else begin
    first<=first;
  end
end

assign val=rk_rdy & rk_vld;
assign rk_vld=(cnt==6)?( (flag)?( (state<=DONE & state>=RK0 & dec)?1'b1:((state==RK9)?1'b1:1'b0) ) : ( (state<=DONE & state>=RK0)?1'b1:1'b0 ) ):(state==IDLE & first & ~flag)?1:0;
assign rk_next=(flag)?( (dec)?( (cnt==5)?{w0_dec,w1_dec,w2_dec,w3_dec}:rk ):{w0_enc,w1_enc,w2_enc,w3_enc} ) : ( (cnt==5)?{w0_enc,w1_enc,w2_enc,w3_enc}:rk);

always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		flag<=1'b0;
	end
	else if(key_ld_p & (~enc))begin
		flag<=1'b1;
	end
	else if(key_ld_p & enc)begin
		flag<=1'b0;
	end
	else begin
		flag<=flag;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		dec<=1'b0;
	end
	else if( (state==RK9) & flag & cnt==6 & val)begin
		dec<=1'b1;
	end
	else if(state==IDLE)begin
		dec<=1'b0;
	end
	else begin
		dec<=dec;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		next_trigger<=1'b0;
	end
	else if( state==DONE )begin
		next_trigger<=1'b1;
	end
	else if(key_ld_p)begin
		next_trigger<=1'b0;
	end
	else begin
		next_trigger<=next_trigger;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		cnt<=0;
	end
	else if( (~flag & val) | (state!=RK9 & flag & ~dec & cnt==6) | (state==RK9 & cnt==6 & val) | (flag & dec & val) | state==IDLE)begin
		cnt<=0;
	end
	else if(cnt==6)begin
		cnt<=cnt;
	end
	else if(state>IDLE)begin
		cnt<=cnt+1;
	end
	else begin
		cnt<=cnt;
	end
end

assign shift=(dec)? {w3_dec[23:0],w3_dec[31:24]} : {rk[23:0],rk[31:24]};
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		shift_reg<=0;
	end
	else if(cnt==0)begin
		shift_reg<=shift;
	end
	else begin
		shift_reg<=shift_reg;
	end
end

always@(*)begin
	case(cnt)
		3'd1:sbox_in<=shift_reg[7:0];
		3'd2:sbox_in<=shift_reg[15:8];
		3'd3:sbox_in<=shift_reg[23:16];
		3'd4:sbox_in<=shift_reg[31:24];
		default:sbox_in<=0;
	endcase
end
sbox U0(.data_in(sbox_in),.data_out(sbox_out));
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		new_sboxw<=0;
	end
	else begin
		case(cnt)
			3'd1:new_sboxw<={24'd0,sbox_out};
			3'd2:new_sboxw<={16'd0,sbox_out,new_sboxw[7:0]};
			3'd3:new_sboxw<={8'd0,sbox_out,new_sboxw[15:0]};
			3'd4:new_sboxw<={sbox_out,new_sboxw[23:0]};
			default:new_sboxw<=0;
		endcase
	end
end
assign rc=new_sboxw ^ RCON;

assign w0_enc=rk[127:96] ^ rc;
assign w1_enc=w0_enc ^ rk[95:64];
assign w2_enc=w1_enc ^ rk[63:32];
assign w3_enc=w2_enc ^ rk[31:0];


assign w0_dec=rk[127:96] ^ rc;
assign w1_dec=rk[127:96] ^ rk[95:64];
assign w2_dec=rk[95:64] ^ rk[63:32];
assign w3_dec=rk[63:32] ^ rk[31:0];

endmodule

module sbox (
    input  [7:0] data_in,
    output reg [7:0] data_out
);

always @(*) begin
    case(data_in)
       8'h00: data_out = 8'h63;
       8'h01: data_out = 8'h7c;
       8'h02: data_out = 8'h77;
       8'h03: data_out = 8'h7b;
       8'h04: data_out = 8'hf2;
       8'h05: data_out = 8'h6b;
       8'h06: data_out = 8'h6f;
       8'h07: data_out = 8'hc5;
       8'h08: data_out = 8'h30;
       8'h09: data_out = 8'h01;
       8'h0a: data_out = 8'h67;
       8'h0b: data_out = 8'h2b;
       8'h0c: data_out = 8'hfe;
       8'h0d: data_out = 8'hd7;
       8'h0e: data_out = 8'hab;
       8'h0f: data_out = 8'h76;

       8'h10: data_out = 8'hca;
       8'h11: data_out = 8'h82;
       8'h12: data_out = 8'hc9;
       8'h13: data_out = 8'h7d;
       8'h14: data_out = 8'hfa;
       8'h15: data_out = 8'h59;
       8'h16: data_out = 8'h47;
       8'h17: data_out = 8'hf0;
       8'h18: data_out = 8'had;
       8'h19: data_out = 8'hd4;
       8'h1a: data_out = 8'ha2;
       8'h1b: data_out = 8'haf;
       8'h1c: data_out = 8'h9c;
       8'h1d: data_out = 8'ha4;
       8'h1e: data_out = 8'h72;
       8'h1f: data_out = 8'hc0;

       8'h20: data_out = 8'hb7;
       8'h21: data_out = 8'hfd;
       8'h22: data_out = 8'h93;
       8'h23: data_out = 8'h26;
       8'h24: data_out = 8'h36;
       8'h25: data_out = 8'h3f;
       8'h26: data_out = 8'hf7;
       8'h27: data_out = 8'hcc;
       8'h28: data_out = 8'h34;
       8'h29: data_out = 8'ha5;
       8'h2a: data_out = 8'he5;
       8'h2b: data_out = 8'hf1;
       8'h2c: data_out = 8'h71;
       8'h2d: data_out = 8'hd8;
       8'h2e: data_out = 8'h31;
       8'h2f: data_out = 8'h15;

       8'h30: data_out = 8'h04;
       8'h31: data_out = 8'hc7;
       8'h32: data_out = 8'h23;
       8'h33: data_out = 8'hc3;
       8'h34: data_out = 8'h18;
       8'h35: data_out = 8'h96;
       8'h36: data_out = 8'h05;
       8'h37: data_out = 8'h9a;
       8'h38: data_out = 8'h07;
       8'h39: data_out = 8'h12;
       8'h3a: data_out = 8'h80;
       8'h3b: data_out = 8'he2;
       8'h3c: data_out = 8'heb;
       8'h3d: data_out = 8'h27;
       8'h3e: data_out = 8'hb2;
       8'h3f: data_out = 8'h75;

       8'h40: data_out = 8'h09;
       8'h41: data_out = 8'h83;
       8'h42: data_out = 8'h2c;
       8'h43: data_out = 8'h1a;
       8'h44: data_out = 8'h1b;
       8'h45: data_out = 8'h6e;
       8'h46: data_out = 8'h5a;
       8'h47: data_out = 8'ha0;
       8'h48: data_out = 8'h52;
       8'h49: data_out = 8'h3b;
       8'h4a: data_out = 8'hd6;
       8'h4b: data_out = 8'hb3;
       8'h4c: data_out = 8'h29;
       8'h4d: data_out = 8'he3;
       8'h4e: data_out = 8'h2f;
       8'h4f: data_out = 8'h84;

       8'h50: data_out = 8'h53;
       8'h51: data_out = 8'hd1;
       8'h52: data_out = 8'h00;
       8'h53: data_out = 8'hed;
       8'h54: data_out = 8'h20;
       8'h55: data_out = 8'hfc;
       8'h56: data_out = 8'hb1;
       8'h57: data_out = 8'h5b;
       8'h58: data_out = 8'h6a;
       8'h59: data_out = 8'hcb;
       8'h5a: data_out = 8'hbe;
       8'h5b: data_out = 8'h39;
       8'h5c: data_out = 8'h4a;
       8'h5d: data_out = 8'h4c;
       8'h5e: data_out = 8'h58;
       8'h5f: data_out = 8'hcf;

       8'h60: data_out = 8'hd0;
       8'h61: data_out = 8'hef;
       8'h62: data_out = 8'haa;
       8'h63: data_out = 8'hfb;
       8'h64: data_out = 8'h43;
       8'h65: data_out = 8'h4d;
       8'h66: data_out = 8'h33;
       8'h67: data_out = 8'h85;
       8'h68: data_out = 8'h45;
       8'h69: data_out = 8'hf9;
       8'h6a: data_out = 8'h02;
       8'h6b: data_out = 8'h7f;
       8'h6c: data_out = 8'h50;
       8'h6d: data_out = 8'h3c;
       8'h6e: data_out = 8'h9f;
       8'h6f: data_out = 8'ha8;

       8'h70: data_out = 8'h51;
       8'h71: data_out = 8'ha3;
       8'h72: data_out = 8'h40;
       8'h73: data_out = 8'h8f;
       8'h74: data_out = 8'h92;
       8'h75: data_out = 8'h9d;
       8'h76: data_out = 8'h38;
       8'h77: data_out = 8'hf5;
       8'h78: data_out = 8'hbc;
       8'h79: data_out = 8'hb6;
       8'h7a: data_out = 8'hda;
       8'h7b: data_out = 8'h21;
       8'h7c: data_out = 8'h10;
       8'h7d: data_out = 8'hff;
       8'h7e: data_out = 8'hf3;
       8'h7f: data_out = 8'hd2;

       8'h80: data_out = 8'hcd;
       8'h81: data_out = 8'h0c;
       8'h82: data_out = 8'h13;
       8'h83: data_out = 8'hec;
       8'h84: data_out = 8'h5f;
       8'h85: data_out = 8'h97;
       8'h86: data_out = 8'h44;
       8'h87: data_out = 8'h17;
       8'h88: data_out = 8'hc4;
       8'h89: data_out = 8'ha7;
       8'h8a: data_out = 8'h7e;
       8'h8b: data_out = 8'h3d;
       8'h8c: data_out = 8'h64;
       8'h8d: data_out = 8'h5d;
       8'h8e: data_out = 8'h19;
       8'h8f: data_out = 8'h73;

       8'h90: data_out = 8'h60;
       8'h91: data_out = 8'h81;
       8'h92: data_out = 8'h4f;
       8'h93: data_out = 8'hdc;
       8'h94: data_out = 8'h22;
       8'h95: data_out = 8'h2a;
       8'h96: data_out = 8'h90;
       8'h97: data_out = 8'h88;
       8'h98: data_out = 8'h46;
       8'h99: data_out = 8'hee;
       8'h9a: data_out = 8'hb8;
       8'h9b: data_out = 8'h14;
       8'h9c: data_out = 8'hde;
       8'h9d: data_out = 8'h5e;
       8'h9e: data_out = 8'h0b;
       8'h9f: data_out = 8'hdb;

       8'ha0: data_out = 8'he0;
       8'ha1: data_out = 8'h32;
       8'ha2: data_out = 8'h3a;
       8'ha3: data_out = 8'h0a;
       8'ha4: data_out = 8'h49;
       8'ha5: data_out = 8'h06;
       8'ha6: data_out = 8'h24;
       8'ha7: data_out = 8'h5c;
       8'ha8: data_out = 8'hc2;
       8'ha9: data_out = 8'hd3;
       8'haa: data_out = 8'hac;
       8'hab: data_out = 8'h62;
       8'hac: data_out = 8'h91;
       8'had: data_out = 8'h95;
       8'hae: data_out = 8'he4;
       8'haf: data_out = 8'h79;

       8'hb0: data_out = 8'he7;
       8'hb1: data_out = 8'hc8;
       8'hb2: data_out = 8'h37;
       8'hb3: data_out = 8'h6d;
       8'hb4: data_out = 8'h8d;
       8'hb5: data_out = 8'hd5;
       8'hb6: data_out = 8'h4e;
       8'hb7: data_out = 8'ha9;
       8'hb8: data_out = 8'h6c;
       8'hb9: data_out = 8'h56;
       8'hba: data_out = 8'hf4;
       8'hbb: data_out = 8'hea;
       8'hbc: data_out = 8'h65;
       8'hbd: data_out = 8'h7a;
       8'hbe: data_out = 8'hae;
       8'hbf: data_out = 8'h08;

       8'hc0: data_out = 8'hba;
       8'hc1: data_out = 8'h78;
       8'hc2: data_out = 8'h25;
       8'hc3: data_out = 8'h2e;
       8'hc4: data_out = 8'h1c;
       8'hc5: data_out = 8'ha6;
       8'hc6: data_out = 8'hb4;
       8'hc7: data_out = 8'hc6;
       8'hc8: data_out = 8'he8;
       8'hc9: data_out = 8'hdd;
       8'hca: data_out = 8'h74;
       8'hcb: data_out = 8'h1f;
       8'hcc: data_out = 8'h4b;
       8'hcd: data_out = 8'hbd;
       8'hce: data_out = 8'h8b;
       8'hcf: data_out = 8'h8a;

       8'hd0: data_out = 8'h70;
       8'hd1: data_out = 8'h3e;
       8'hd2: data_out = 8'hb5;
       8'hd3: data_out = 8'h66;
       8'hd4: data_out = 8'h48;
       8'hd5: data_out = 8'h03;
       8'hd6: data_out = 8'hf6;
       8'hd7: data_out = 8'h0e;
       8'hd8: data_out = 8'h61;
       8'hd9: data_out = 8'h35;
       8'hda: data_out = 8'h57;
       8'hdb: data_out = 8'hb9;
       8'hdc: data_out = 8'h86;
       8'hdd: data_out = 8'hc1;
       8'hde: data_out = 8'h1d;
       8'hdf: data_out = 8'h9e;

       8'he0: data_out = 8'he1;
       8'he1: data_out = 8'hf8;
       8'he2: data_out = 8'h98;
       8'he3: data_out = 8'h11;
       8'he4: data_out = 8'h69;
       8'he5: data_out = 8'hd9;
       8'he6: data_out = 8'h8e;
       8'he7: data_out = 8'h94;
       8'he8: data_out = 8'h9b;
       8'he9: data_out = 8'h1e;
       8'hea: data_out = 8'h87;
       8'heb: data_out = 8'he9;
       8'hec: data_out = 8'hce;
       8'hed: data_out = 8'h55;
       8'hee: data_out = 8'h28;
       8'hef: data_out = 8'hdf;

       8'hf0: data_out = 8'h8c;
       8'hf1: data_out = 8'ha1;
       8'hf2: data_out = 8'h89;
       8'hf3: data_out = 8'h0d;
       8'hf4: data_out = 8'hbf;
       8'hf5: data_out = 8'he6;
       8'hf6: data_out = 8'h42;
       8'hf7: data_out = 8'h68;
       8'hf8: data_out = 8'h41;
       8'hf9: data_out = 8'h99;
       8'hfa: data_out = 8'h2d;
       8'hfb: data_out = 8'h0f;
       8'hfc: data_out = 8'hb0;
       8'hfd: data_out = 8'h54;
       8'hfe: data_out = 8'hbb;
       8'hff: data_out = 8'h16;
    endcase
end
endmodule

module InvMixColumns(
   input [31:0]In,
   output [31:0]Out
);

	wire [7:0]out0,out1,out2,out3,out4,out5,out6,out7;
	wire [7:0]out8,out9,out10,out11,out12,out13,out14,out15;
	
	xTimes0e x0(.In(In[31:24]),.Out(out0));
	xTimes0b x1(.In(In[23:16]),.Out(out1));
	xTimes0d x2(.In(In[15:8]),.Out(out2));
	xTimes09 x3(.In(In[7:0]),.Out(out3));
	assign Out[31:24]=out0 ^ out1 ^ out2 ^ out3;
	
	xTimes09 x4(.In(In[31:24]),.Out(out4));
	xTimes0e x5(.In(In[23:16]),.Out(out5));
	xTimes0b x6(.In(In[15:8]),.Out(out6));
	xTimes0d x7(.In(In[7:0]),.Out(out7));
	assign Out[23:16]=out4 ^ out5 ^ out6 ^ out7;
	
	xTimes0d x8(.In(In[31:24]),.Out(out8));
	xTimes09 x9(.In(In[23:16]),.Out(out9));
	xTimes0e x10(.In(In[15:8]),.Out(out10));
	xTimes0b x11(.In(In[7:0]),.Out(out11));
	assign Out[15:8]=out8 ^ out9 ^ out10 ^ out11;
	
	xTimes0b x12(.In(In[31:24]),.Out(out12));
	xTimes0d x13(.In(In[23:16]),.Out(out13));
	xTimes09 x14(.In(In[15:8]),.Out(out14));
	xTimes0e x15(.In(In[7:0]),.Out(out15));
	assign Out[7:0]=out12 ^ out13 ^ out14 ^ out15;
	

endmodule

module xTimes0e(
	input [7:0]In,
	output [7:0]Out
);
	wire [7:0]out0,out1,out2;
	xTimes2 xt0(.In(In),.Out(out0));
	xTimes2 xt1(.In(out0),.Out(out1));
	xTimes2 xt2(.In(out1),.Out(out2));
	assign Out=out0 ^ out1 ^ out2;
endmodule

module xTimes0b(
	input [7:0]In,
	output [7:0]Out
);
	wire [7:0]out0,out1,out2;
	xTimes2 xt0(.In(In),.Out(out0));
	xTimes2 xt1(.In(out0),.Out(out1));
	xTimes2 xt2(.In(out1),.Out(out2));
	assign Out=In ^ out0 ^ out2;
endmodule

module xTimes0d(
	input [7:0]In,
	output [7:0]Out
);
	wire [7:0]out0,out1,out2;
	xTimes2 xt0(.In(In),.Out(out0));
	xTimes2 xt1(.In(out0),.Out(out1));
	xTimes2 xt2(.In(out1),.Out(out2));
	assign Out=In ^ out1 ^ out2;
endmodule

module xTimes09(
	input [7:0]In,
	output [7:0]Out
);
	wire [7:0]out0,out1,out2;
	xTimes2 xt0(.In(In),.Out(out0));
	xTimes2 xt1(.In(out0),.Out(out1));
	xTimes2 xt2(.In(out1),.Out(out2));
	assign Out=In ^ out2;
endmodule
module MixColumns(
   input [31:0]In,
   output [31:0]Out
);

	wire [7:0]out0,out1,out2,out3,out4,out5,out6,out7;
	
	xTimes2 x0(.In(In[31:24]),.Out(out0));
	xTimes3 x1(.In(In[23:16]),.Out(out1));
	assign Out[31:24]=out0 ^ out1 ^ In[15:8] ^ In[7:0];
	
	xTimes2 x2(.In(In[23:16]),.Out(out2));
	xTimes3 x3(.In(In[15:8]),.Out(out3));
	assign Out[23:16]=In[31:24] ^ out2 ^ out3 ^ In[7:0];
	
	xTimes2 x4(.In(In[15:8]),.Out(out4));
	xTimes3 x5(.In(In[7:0]),.Out(out5));
	assign Out[15:8]=In[31:24] ^ In[23:16] ^ out4 ^ out5;
	
	xTimes2 x6(.In(In[7:0]),.Out(out6));
	xTimes3 x7(.In(In[31:24]),.Out(out7));
	assign Out[7:0]=out7 ^ In[23:16] ^ In[15:8] ^ out6;
	

endmodule

module xTimes2(
	input [7:0]In,
	output reg [7:0]Out
);
	always@(*)begin
		if(In[7]==0)begin
			Out<={In[6:0],1'b0};
		end
		else begin
			Out<={In[6:0],1'b0} ^ 8'b00011011;
		end
	end
endmodule

module xTimes3(
	input [7:0]In,
	output [7:0]Out
);
	wire [7:0]out0;
	xTimes2 xt0(.In(In),.Out(out0));
	assign Out=In ^ out0;
endmodule
module InvSbox(data_in,data_out);
input	[7:0]	data_in;
output	[7:0]	data_out;
reg	[7:0]	data_out;

always @(data_in)
	case(data_in)		// synopsys full_case parallel_case
	   8'h00: data_out=8'h52;
	   8'h01: data_out=8'h09;
	   8'h02: data_out=8'h6a;
	   8'h03: data_out=8'hd5;
	   8'h04: data_out=8'h30;
	   8'h05: data_out=8'h36;
	   8'h06: data_out=8'ha5;
	   8'h07: data_out=8'h38;
	   8'h08: data_out=8'hbf;
	   8'h09: data_out=8'h40;
	   8'h0a: data_out=8'ha3;
	   8'h0b: data_out=8'h9e;
	   8'h0c: data_out=8'h81;
	   8'h0d: data_out=8'hf3;
	   8'h0e: data_out=8'hd7;
	   8'h0f: data_out=8'hfb;
	   8'h10: data_out=8'h7c;
	   8'h11: data_out=8'he3;
	   8'h12: data_out=8'h39;
	   8'h13: data_out=8'h82;
	   8'h14: data_out=8'h9b;
	   8'h15: data_out=8'h2f;
	   8'h16: data_out=8'hff;
	   8'h17: data_out=8'h87;
	   8'h18: data_out=8'h34;
	   8'h19: data_out=8'h8e;
	   8'h1a: data_out=8'h43;
	   8'h1b: data_out=8'h44;
	   8'h1c: data_out=8'hc4;
	   8'h1d: data_out=8'hde;
	   8'h1e: data_out=8'he9;
	   8'h1f: data_out=8'hcb;
	   8'h20: data_out=8'h54;
	   8'h21: data_out=8'h7b;
	   8'h22: data_out=8'h94;
	   8'h23: data_out=8'h32;
	   8'h24: data_out=8'ha6;
	   8'h25: data_out=8'hc2;
	   8'h26: data_out=8'h23;
	   8'h27: data_out=8'h3d;
	   8'h28: data_out=8'hee;
	   8'h29: data_out=8'h4c;
	   8'h2a: data_out=8'h95;
	   8'h2b: data_out=8'h0b;
	   8'h2c: data_out=8'h42;
	   8'h2d: data_out=8'hfa;
	   8'h2e: data_out=8'hc3;
	   8'h2f: data_out=8'h4e;
	   8'h30: data_out=8'h08;
	   8'h31: data_out=8'h2e;
	   8'h32: data_out=8'ha1;
	   8'h33: data_out=8'h66;
	   8'h34: data_out=8'h28;
	   8'h35: data_out=8'hd9;
	   8'h36: data_out=8'h24;
	   8'h37: data_out=8'hb2;
	   8'h38: data_out=8'h76;
	   8'h39: data_out=8'h5b;
	   8'h3a: data_out=8'ha2;
	   8'h3b: data_out=8'h49;
	   8'h3c: data_out=8'h6d;
	   8'h3d: data_out=8'h8b;
	   8'h3e: data_out=8'hd1;
	   8'h3f: data_out=8'h25;
	   8'h40: data_out=8'h72;
	   8'h41: data_out=8'hf8;
	   8'h42: data_out=8'hf6;
	   8'h43: data_out=8'h64;
	   8'h44: data_out=8'h86;
	   8'h45: data_out=8'h68;
	   8'h46: data_out=8'h98;
	   8'h47: data_out=8'h16;
	   8'h48: data_out=8'hd4;
	   8'h49: data_out=8'ha4;
	   8'h4a: data_out=8'h5c;
	   8'h4b: data_out=8'hcc;
	   8'h4c: data_out=8'h5d;
	   8'h4d: data_out=8'h65;
	   8'h4e: data_out=8'hb6;
	   8'h4f: data_out=8'h92;
	   8'h50: data_out=8'h6c;
	   8'h51: data_out=8'h70;
	   8'h52: data_out=8'h48;
	   8'h53: data_out=8'h50;
	   8'h54: data_out=8'hfd;
	   8'h55: data_out=8'hed;
	   8'h56: data_out=8'hb9;
	   8'h57: data_out=8'hda;
	   8'h58: data_out=8'h5e;
	   8'h59: data_out=8'h15;
	   8'h5a: data_out=8'h46;
	   8'h5b: data_out=8'h57;
	   8'h5c: data_out=8'ha7;
	   8'h5d: data_out=8'h8d;
	   8'h5e: data_out=8'h9d;
	   8'h5f: data_out=8'h84;
	   8'h60: data_out=8'h90;
	   8'h61: data_out=8'hd8;
	   8'h62: data_out=8'hab;
	   8'h63: data_out=8'h00;
	   8'h64: data_out=8'h8c;
	   8'h65: data_out=8'hbc;
	   8'h66: data_out=8'hd3;
	   8'h67: data_out=8'h0a;
	   8'h68: data_out=8'hf7;
	   8'h69: data_out=8'he4;
	   8'h6a: data_out=8'h58;
	   8'h6b: data_out=8'h05;
	   8'h6c: data_out=8'hb8;
	   8'h6d: data_out=8'hb3;
	   8'h6e: data_out=8'h45;
	   8'h6f: data_out=8'h06;
	   8'h70: data_out=8'hd0;
	   8'h71: data_out=8'h2c;
	   8'h72: data_out=8'h1e;
	   8'h73: data_out=8'h8f;
	   8'h74: data_out=8'hca;
	   8'h75: data_out=8'h3f;
	   8'h76: data_out=8'h0f;
	   8'h77: data_out=8'h02;
	   8'h78: data_out=8'hc1;
	   8'h79: data_out=8'haf;
	   8'h7a: data_out=8'hbd;
	   8'h7b: data_out=8'h03;
	   8'h7c: data_out=8'h01;
	   8'h7d: data_out=8'h13;
	   8'h7e: data_out=8'h8a;
	   8'h7f: data_out=8'h6b;
	   8'h80: data_out=8'h3a;
	   8'h81: data_out=8'h91;
	   8'h82: data_out=8'h11;
	   8'h83: data_out=8'h41;
	   8'h84: data_out=8'h4f;
	   8'h85: data_out=8'h67;
	   8'h86: data_out=8'hdc;
	   8'h87: data_out=8'hea;
	   8'h88: data_out=8'h97;
	   8'h89: data_out=8'hf2;
	   8'h8a: data_out=8'hcf;
	   8'h8b: data_out=8'hce;
	   8'h8c: data_out=8'hf0;
	   8'h8d: data_out=8'hb4;
	   8'h8e: data_out=8'he6;
	   8'h8f: data_out=8'h73;
	   8'h90: data_out=8'h96;
	   8'h91: data_out=8'hac;
	   8'h92: data_out=8'h74;
	   8'h93: data_out=8'h22;
	   8'h94: data_out=8'he7;
	   8'h95: data_out=8'had;
	   8'h96: data_out=8'h35;
	   8'h97: data_out=8'h85;
	   8'h98: data_out=8'he2;
	   8'h99: data_out=8'hf9;
	   8'h9a: data_out=8'h37;
	   8'h9b: data_out=8'he8;
	   8'h9c: data_out=8'h1c;
	   8'h9d: data_out=8'h75;
	   8'h9e: data_out=8'hdf;
	   8'h9f: data_out=8'h6e;
	   8'ha0: data_out=8'h47;
	   8'ha1: data_out=8'hf1;
	   8'ha2: data_out=8'h1a;
	   8'ha3: data_out=8'h71;
	   8'ha4: data_out=8'h1d;
	   8'ha5: data_out=8'h29;
	   8'ha6: data_out=8'hc5;
	   8'ha7: data_out=8'h89;
	   8'ha8: data_out=8'h6f;
	   8'ha9: data_out=8'hb7;
	   8'haa: data_out=8'h62;
	   8'hab: data_out=8'h0e;
	   8'hac: data_out=8'haa;
	   8'had: data_out=8'h18;
	   8'hae: data_out=8'hbe;
	   8'haf: data_out=8'h1b;
	   8'hb0: data_out=8'hfc;
	   8'hb1: data_out=8'h56;
	   8'hb2: data_out=8'h3e;
	   8'hb3: data_out=8'h4b;
	   8'hb4: data_out=8'hc6;
	   8'hb5: data_out=8'hd2;
	   8'hb6: data_out=8'h79;
	   8'hb7: data_out=8'h20;
	   8'hb8: data_out=8'h9a;
	   8'hb9: data_out=8'hdb;
	   8'hba: data_out=8'hc0;
	   8'hbb: data_out=8'hfe;
	   8'hbc: data_out=8'h78;
	   8'hbd: data_out=8'hcd;
	   8'hbe: data_out=8'h5a;
	   8'hbf: data_out=8'hf4;
	   8'hc0: data_out=8'h1f;
	   8'hc1: data_out=8'hdd;
	   8'hc2: data_out=8'ha8;
	   8'hc3: data_out=8'h33;
	   8'hc4: data_out=8'h88;
	   8'hc5: data_out=8'h07;
	   8'hc6: data_out=8'hc7;
	   8'hc7: data_out=8'h31;
	   8'hc8: data_out=8'hb1;
	   8'hc9: data_out=8'h12;
	   8'hca: data_out=8'h10;
	   8'hcb: data_out=8'h59;
	   8'hcc: data_out=8'h27;
	   8'hcd: data_out=8'h80;
	   8'hce: data_out=8'hec;
	   8'hcf: data_out=8'h5f;
	   8'hd0: data_out=8'h60;
	   8'hd1: data_out=8'h51;
	   8'hd2: data_out=8'h7f;
	   8'hd3: data_out=8'ha9;
	   8'hd4: data_out=8'h19;
	   8'hd5: data_out=8'hb5;
	   8'hd6: data_out=8'h4a;
	   8'hd7: data_out=8'h0d;
	   8'hd8: data_out=8'h2d;
	   8'hd9: data_out=8'he5;
	   8'hda: data_out=8'h7a;
	   8'hdb: data_out=8'h9f;
	   8'hdc: data_out=8'h93;
	   8'hdd: data_out=8'hc9;
	   8'hde: data_out=8'h9c;
	   8'hdf: data_out=8'hef;
	   8'he0: data_out=8'ha0;
	   8'he1: data_out=8'he0;
	   8'he2: data_out=8'h3b;
	   8'he3: data_out=8'h4d;
	   8'he4: data_out=8'hae;
	   8'he5: data_out=8'h2a;
	   8'he6: data_out=8'hf5;
	   8'he7: data_out=8'hb0;
	   8'he8: data_out=8'hc8;
	   8'he9: data_out=8'heb;
	   8'hea: data_out=8'hbb;
	   8'heb: data_out=8'h3c;
	   8'hec: data_out=8'h83;
	   8'hed: data_out=8'h53;
	   8'hee: data_out=8'h99;
	   8'hef: data_out=8'h61;
	   8'hf0: data_out=8'h17;
	   8'hf1: data_out=8'h2b;
	   8'hf2: data_out=8'h04;
	   8'hf3: data_out=8'h7e;
	   8'hf4: data_out=8'hba;
	   8'hf5: data_out=8'h77;
	   8'hf6: data_out=8'hd6;
	   8'hf7: data_out=8'h26;
	   8'hf8: data_out=8'he1;
	   8'hf9: data_out=8'h69;
	   8'hfa: data_out=8'h14;
	   8'hfb: data_out=8'h63;
	   8'hfc: data_out=8'h55;
	   8'hfd: data_out=8'h21;
	   8'hfe: data_out=8'h0c;
	   8'hff: data_out=8'h7d;
	endcase
endmodule
