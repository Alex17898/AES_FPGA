onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L microblaze_v10_0_5 -L axi_lite_ipif_v3_0_4 -L lib_pkg_v1_0_2 -L lib_srl_fifo_v1_0_2 -L lib_cdc_v1_0_2 -L axi_uartlite_v2_0_19 -L mdm_v3_2_12 -L proc_sys_reset_v5_0_12 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_15 -L fifo_generator_v13_2_1 -L axi_data_fifo_v2_1_14 -L axi_crossbar_v2_1_16 -L lmb_v10_v3_0_9 -L lmb_bram_if_cntlr_v4_0_14 -L blk_mem_gen_v8_4_1 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.urbana xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {urbana.udo}

run -all

quit -force
