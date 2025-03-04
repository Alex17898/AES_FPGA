/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#define IP_ADDR 0x44A00000


int main()
{
	init_platform();
	while(1){
		uint32_t dout0,dout1,dout2,dout3;
		char temp;
		xil_printf("Key:");
		char key[16];
		int i=0;
		key[i]=inbyte();
		while(key[i]!='\r' && i!=15){
			i++;
			key[i]=inbyte();
		}
		if(i<15){
			i=i-1;
		}
		else {
			temp=inbyte();
		}
		for(int l=0;l<=15;l++){
			if(l>i){
				key[l]=0;
			}
		}
		for(int a=0;a<=i;a++){
			xil_printf("%c",key[a]);
		}
		xil_printf("\n\r");

		xil_printf("Din:");
		char din[16];
		int j=0;
		din[j]=inbyte();
		while(din[j]!='\r' && j!=15){
			j++;
			din[j]=inbyte();
		}
		if(j<15){
			j=j-1;
		}
		else {
			temp=inbyte();
		}

		for(int m=0;m<=15;m++){
			if(m>j){
				din[m]=0;
			}
		}
		for(int b=0;b<=j;b++){
			xil_printf("%c",din[b]);
		}
		xil_printf("\n\r");

		uint32_t key3 = ((uint32_t)key[0] << 24) | ((uint32_t)key[1] << 16) | ((uint32_t)key[2] << 8) | (uint32_t)key[3];
		uint32_t key2 = ((uint32_t)key[4] << 24) | ((uint32_t)key[5] << 16) | ((uint32_t)key[6] << 8) | (uint32_t)key[7];
		uint32_t key1 = ((uint32_t)key[8] << 24) | ((uint32_t)key[9] << 16) | ((uint32_t)key[10] << 8) | (uint32_t)key[11];
		uint32_t key0 = ((uint32_t)key[12] << 24) | ((uint32_t)key[13] << 16) | ((uint32_t)key[14] << 8) | (uint32_t)key[15];

		uint32_t din3 = ((uint32_t)din[0] << 24) | ((uint32_t)din[1] << 16) | ((uint32_t)din[2] << 8) | (uint32_t)din[3];
		uint32_t din2 = ((uint32_t)din[4] << 24) | ((uint32_t)din[5] << 16) | ((uint32_t)din[6] << 8) | (uint32_t)din[7];
		uint32_t din1 = ((uint32_t)din[8] << 24) | ((uint32_t)din[9] << 16) | ((uint32_t)din[10] << 8) | (uint32_t)din[11];
		uint32_t din0 = ((uint32_t)din[12] << 24) | ((uint32_t)din[13] << 16) | ((uint32_t)din[14] << 8) | (uint32_t)din[15];

		Xil_Out32(IP_ADDR,key0);
		Xil_Out32(IP_ADDR+0x4,key1);
		Xil_Out32(IP_ADDR+0x8,key2);
		Xil_Out32(IP_ADDR+0xc,key3);

		Xil_Out32(IP_ADDR+0x10,din0);
		Xil_Out32(IP_ADDR+0x14,din1);
		Xil_Out32(IP_ADDR+0x18,din2);
		Xil_Out32(IP_ADDR+0x1c,din3);

		int k=0;
		while(k!=1){
			k=Xil_In32(IP_ADDR+0x30);
		}

		dout0=Xil_In32(IP_ADDR+0x20);
		dout1=Xil_In32(IP_ADDR+0x24);
		dout2=Xil_In32(IP_ADDR+0x28);
		dout3=Xil_In32(IP_ADDR+0x2c);

		xil_printf("Dout:%08x%08x%08x%08x\n\r",dout3,dout2,dout1,dout0);
	}

    cleanup_platform();
    return 0;
}
