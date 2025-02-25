set_property SRC_FILE_INFO {cfile:/home/balance/work/FPGA/nthu_sys_lcm_only/nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ip/urbana_clk_wiz_1_1/urbana_clk_wiz_1_1.xdc rfile:../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ip/urbana_clk_wiz_1_1/urbana_clk_wiz_1_1.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
