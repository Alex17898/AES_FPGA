//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
//Date        : Thu May 30 02:50:12 2024
//Host        : LAPTOP-4TN2N2PV running 64-bit major release  (build 9200)
//Command     : generate_target urbana_wrapper.bd
//Design      : urbana_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module urbana_wrapper
   (clk_in1_0,
    resetn_0,
    uart_rtl_0_rxd,
    uart_rtl_0_txd);
  input clk_in1_0;
  input resetn_0;
  input uart_rtl_0_rxd;
  output uart_rtl_0_txd;

  wire clk_in1_0;
  wire resetn_0;
  wire uart_rtl_0_rxd;
  wire uart_rtl_0_txd;

  urbana urbana_i
       (.clk_in1_0(clk_in1_0),
        .resetn_0(resetn_0),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd));
endmodule
