#!/bin/bash -f
#*********************************************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# Filename    : urbana.sh
# Simulator   : Synopsys Verilog Compiler Simulator
# Description : Simulation script for compiling, elaborating and verifying the project source files.
#               The script will automatically create the design libraries sub-directories in the run
#               directory, add the library logical mappings in the simulator setup file, create default
#               'do/prj' file, execute compilation, elaboration and simulation steps.
#
# Generated by Vivado on Thu May 30 02:50:15 +0800 2024
# SW Build 2086221 on Fri Dec 15 20:55:39 MST 2017
#
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved. 
#
# usage: urbana.sh [-help]
# usage: urbana.sh [-lib_map_path]
# usage: urbana.sh [-noclean_files]
# usage: urbana.sh [-reset_run]
#
# Prerequisite:- To compile and run simulation, you must compile the Xilinx simulation libraries using the
# 'compile_simlib' TCL command. For more information about this command, run 'compile_simlib -help' in the
# Vivado Tcl Shell. Once the libraries have been compiled successfully, specify the -lib_map_path switch
# that points to these libraries and rerun export_simulation. For more information about this switch please
# type 'export_simulation -help' in the Tcl shell.
#
# You can also point to the simulation libraries by either replacing the <SPECIFY_COMPILED_LIB_PATH> in this
# script with the compiled library directory path or specify this path with the '-lib_map_path' switch when
# executing this script. Please type 'urbana.sh -help' for more information.
#
# Additional references - 'Xilinx Vivado Design Suite User Guide:Logic simulation (UG900)'
#
#*********************************************************************************************************

# Directory path for design sources and include directories (if any) wrt this path
ref_dir="."

# Override directory with 'export_sim_ref_dir' env path value if set in the shell
if [[ (! -z "$export_sim_ref_dir") && ($export_sim_ref_dir != "") ]]; then
  ref_dir="$export_sim_ref_dir"
fi

# Command line options
vlogan_opts="-full64"
vhdlan_opts="-full64"
vcs_elab_opts="-full64 -debug_pp -t ps -licqueue -l elaborate.log"
vcs_sim_opts="-ucli -licqueue -l simulate.log"

# Design libraries
design_libs=(xil_defaultlib xpm microblaze_v10_0_5 axi_lite_ipif_v3_0_4 lib_pkg_v1_0_2 lib_srl_fifo_v1_0_2 lib_cdc_v1_0_2 axi_uartlite_v2_0_19 mdm_v3_2_12 proc_sys_reset_v5_0_12 generic_baseblocks_v2_1_0 axi_infrastructure_v1_1_0 axi_register_slice_v2_1_15 fifo_generator_v13_2_1 axi_data_fifo_v2_1_14 axi_crossbar_v2_1_16 lmb_v10_v3_0_9 lmb_bram_if_cntlr_v4_0_14 blk_mem_gen_v8_4_1)

# Simulation root library directory
sim_lib_dir="vcs_lib"

# Script info
echo -e "urbana.sh - Script generated by export_simulation (Vivado v2017.4 (64-bit)-id)\n"

# Main steps
run()
{
  check_args $# $1
  setup $1 $2
  compile
  elaborate
  simulate
}

# RUN_STEP: <compile>
compile()
{
  # Compile design files
  vlogan -work xil_defaultlib $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "D:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
    "D:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
  2>&1 | tee -a vlogan.log

  vhdlan -work xpm $vhdlan_opts \
    "D:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work microblaze_v10_0_5 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4f30/hdl/microblaze_v10_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/urbana/ip/urbana_microblaze_0_0/sim/urbana_microblaze_0_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work axi_lite_ipif_v3_0_4 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/cced/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lib_pkg_v1_0_2 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lib_srl_fifo_v1_0_2 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lib_cdc_v1_0_2 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work axi_uartlite_v2_0_19 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/c778/hdl/axi_uartlite_v2_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/urbana/ip/urbana_axi_uartlite_0_0/sim/urbana_axi_uartlite_0_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work mdm_v3_2_12 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/8608/hdl/mdm_v3_2_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/urbana/ip/urbana_mdm_1_1/sim/urbana_mdm_1_1.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../bd/urbana/ip/urbana_clk_wiz_1_1/urbana_clk_wiz_1_1_clk_wiz.v" \
    "$ref_dir/../../../bd/urbana/ip/urbana_clk_wiz_1_1/urbana_clk_wiz_1_1.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work proc_sys_reset_v5_0_12 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/f86a/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/urbana/ip/urbana_rst_clk_wiz_1_100M_0/sim/urbana_rst_clk_wiz_1_100M_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work generic_baseblocks_v2_1_0 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_infrastructure_v1_1_0 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_register_slice_v2_1_15 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/3ed1/hdl/axi_register_slice_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work fifo_generator_v13_2_1 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/5c35/simulation/fifo_generator_vlog_beh.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work fifo_generator_v13_2_1 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/5c35/hdl/fifo_generator_v13_2_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work fifo_generator_v13_2_1 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/5c35/hdl/fifo_generator_v13_2_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_data_fifo_v2_1_14 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/9909/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_crossbar_v2_1_16 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/c631/hdl/axi_crossbar_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../bd/urbana/ip/urbana_xbar_1/sim/urbana_xbar_1.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work lmb_v10_v3_0_9 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/78eb/hdl/lmb_v10_v3_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/urbana/ip/urbana_dlmb_v10_0/sim/urbana_dlmb_v10_0.vhd" \
    "$ref_dir/../../../bd/urbana/ip/urbana_ilmb_v10_0/sim/urbana_ilmb_v10_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lmb_bram_if_cntlr_v4_0_14 $vhdlan_opts \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/226d/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/urbana/ip/urbana_dlmb_bram_if_cntlr_0/sim/urbana_dlmb_bram_if_cntlr_0.vhd" \
    "$ref_dir/../../../bd/urbana/ip/urbana_ilmb_bram_if_cntlr_0/sim/urbana_ilmb_bram_if_cntlr_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work blk_mem_gen_v8_4_1 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/67d8/simulation/blk_mem_gen_v8_4.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/4868" +incdir+"$ref_dir/../../../../nthu_sys_lcm_only.srcs/sources_1/bd/urbana/ipshared/ec67/hdl" \
    "$ref_dir/../../../bd/urbana/ip/urbana_lmb_bram_0/sim/urbana_lmb_bram_0.v" \
    "$ref_dir/../../../bd/urbana/sim/urbana.v" \
    "$ref_dir/../../../bd/urbana/ipshared/73f3/src/aes.v" \
    "$ref_dir/../../../bd/urbana/ipshared/73f3/hdl/aes_v1_0_S00_AXI.v" \
    "$ref_dir/../../../bd/urbana/ipshared/73f3/hdl/aes_v1_0.v" \
    "$ref_dir/../../../bd/urbana/ip/urbana_aes_0_1/sim/urbana_aes_0_1.v" \
  2>&1 | tee -a vlogan.log


  vlogan -work xil_defaultlib $vlogan_opts +v2k \
    glbl.v \
  2>&1 | tee -a vlogan.log

}

# RUN_STEP: <elaborate>
elaborate()
{
  vcs $vcs_elab_opts xil_defaultlib.urbana xil_defaultlib.glbl -o urbana_simv
}

# RUN_STEP: <simulate>
simulate()
{
  ./urbana_simv $vcs_sim_opts -do simulate.do
}

# STEP: setup
setup()
{
  case $1 in
    "-lib_map_path" )
      if [[ ($2 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./urbana.sh -help\" for more information)\n"
        exit 1
      fi
      create_lib_mappings $2
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      # do not remove previous data
    ;;
    * )
      create_lib_mappings $2
  esac

  create_lib_dir

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Define design library mappings
create_lib_mappings()
{
  file="synopsys_sim.setup"
  if [[ -e $file ]]; then
    if [[ ($1 == "") ]]; then
      return
    else
      rm -rf $file
    fi
  fi

  touch $file

  lib_map_path=""
  if [[ ($1 != "") ]]; then
    lib_map_path="$1"
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    mapping="$lib:$sim_lib_dir/$lib"
    echo $mapping >> $file
  done

  if [[ ($lib_map_path != "") ]]; then
    incl_ref="OTHERS=$lib_map_path/synopsys_sim.setup"
    echo $incl_ref >> $file
  fi
}

# Create design library directory paths
create_lib_dir()
{
  if [[ -e $sim_lib_dir ]]; then
    rm -rf $sim_lib_dir
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    lib_dir="$sim_lib_dir/$lib"
    if [[ ! -e $lib_dir ]]; then
      mkdir -p $lib_dir
    fi
  done
}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(ucli.key urbana_simv vlogan.log vhdlan.log compile.log elaborate.log simulate.log .vlogansetup.env .vlogansetup.args .vcs_lib_lock scirocco_command.log 64 AN.DB csrc urbana_simv.daidir)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done

  create_lib_dir
}

# Check command line arguments
check_args()
{
  if [[ ($1 == 1 ) && ($2 != "-lib_map_path" && $2 != "-noclean_files" && $2 != "-reset_run" && $2 != "-help" && $2 != "-h") ]]; then
    echo -e "ERROR: Unknown option specified '$2' (type \"./urbana.sh -help\" for more information)\n"
    exit 1
  fi

  if [[ ($2 == "-help" || $2 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
  msg="Usage: urbana.sh [-help]\n\
Usage: urbana.sh [-lib_map_path]\n\
Usage: urbana.sh [-reset_run]\n\
Usage: urbana.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $1 $2
