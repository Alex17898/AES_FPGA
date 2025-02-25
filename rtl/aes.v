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
