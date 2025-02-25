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