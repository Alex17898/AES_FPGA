//time scale
`timescale 1ns/1ps

//testbench
`include "../tb/testbench.sv"

//bfm
`include "../bfm/bfm_xmit.v"
`include "../bfm/bfm_rcvr.v"
`include "../bfm/bfm_chkr.v"

//dut
`ifdef USE_GLS
`include "../syn/aes_syn.v"
`include "/usr/cadtool/cbdk/CBDK_TSMC40_Arm_f2.0/CIC/Verilog/sc9_cln40g_base_rvt.v"
`include "/usr/cadtool/cbdk/CBDK_TSMC40_Arm_f2.0/CIC/Verilog/sc9_cln40g_base_rvt_udp.v"
`else
`include "../rtl/dut_include.v"
`endif
