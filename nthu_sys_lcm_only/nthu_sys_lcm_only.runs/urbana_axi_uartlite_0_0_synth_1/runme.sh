#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/puf/cad/eda_tools/Xilinx/Vivado/2017.4/SDK/2017.4/bin:/puf/cad/eda_tools/Xilinx/Vivado/2017.4/Vivado/2017.4/ids_lite/ISE/bin/lin64:/puf/cad/eda_tools/Xilinx/Vivado/2017.4/Vivado/2017.4/bin
else
  PATH=/puf/cad/eda_tools/Xilinx/Vivado/2017.4/SDK/2017.4/bin:/puf/cad/eda_tools/Xilinx/Vivado/2017.4/Vivado/2017.4/ids_lite/ISE/bin/lin64:/puf/cad/eda_tools/Xilinx/Vivado/2017.4/Vivado/2017.4/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/puf/cad/eda_tools/Xilinx/Vivado/2017.4/Vivado/2017.4/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/puf/cad/eda_tools/Xilinx/Vivado/2017.4/Vivado/2017.4/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/balance/work/FPGA/nthu_sys_lcm_only/nthu_sys_lcm_only.runs/urbana_axi_uartlite_0_0_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log urbana_axi_uartlite_0_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source urbana_axi_uartlite_0_0.tcl
