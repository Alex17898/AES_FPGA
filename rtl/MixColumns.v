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