#include"gen_pat.h"
int c_gen_test_vec(unsigned int *test_vec_key0,unsigned int *test_vec_key1,unsigned int *test_vec_key2,unsigned int *test_vec_key3,
				   unsigned int *test_vec_din0,unsigned int *test_vec_din1,unsigned int *test_vec_din2,unsigned int *test_vec_din3,unsigned *enc,unsigned int test_len)
{
    unsigned int i;

    srand((unsigned)time(NULL));//set random seed = time
    for(i=0; i<test_len; i=i+1){
      *(test_vec_key0+i) = random();
      *(test_vec_key1+i) = random();
      *(test_vec_key2+i) = random();
      *(test_vec_key3+i) = random();
      *(test_vec_din0+i) = random();
      *(test_vec_din1+i) = random();
      *(test_vec_din2+i) = random();
      *(test_vec_din3+i) = random();
	  *(enc+i) = random()&1;
    }

    return 0;
}

int c_get_gold_vec(unsigned int *gold_vec_dout0,unsigned int *gold_vec_dout1,unsigned int *gold_vec_dout2,unsigned int *gold_vec_dout3,
				   unsigned int *test_vec_key0,unsigned int *test_vec_key1,unsigned int *test_vec_key2,unsigned int *test_vec_key3,
				   unsigned int *test_vec_din0,unsigned int *test_vec_din1,unsigned int *test_vec_din2,unsigned int *test_vec_din3,
				   unsigned int *enc,unsigned int test_len)
{
    unsigned int i;
	unsigned int expandedKey0;
	unsigned int expandedKey1;
	unsigned int expandedKey2;
	unsigned int expandedKey3;
	unsigned int kexp0[11];
	unsigned int kexp1[11];
	unsigned int kexp2[11];
	unsigned int kexp3[11];
	unsigned int *dout0;
	unsigned int *dout1;
	unsigned int *dout2;
	unsigned int *dout3;
	
	dout0 = (unsigned int*)malloc(sizeof(unsigned int));
	dout1 = (unsigned int*)malloc(sizeof(unsigned int));
	dout2 = (unsigned int*)malloc(sizeof(unsigned int));
	dout3 = (unsigned int*)malloc(sizeof(unsigned int));


    if( (test_vec_key0==NULL) | (test_vec_key1==NULL) | (test_vec_key2==NULL) | (test_vec_key3==NULL) | (test_vec_din0==NULL) | (test_vec_din1==NULL) | (test_vec_din2==NULL) | (test_vec_din3==NULL) ){
       printf("test_vec is not allocated.\n");
       return 1;
    }
    else{
      for(i=0; i<test_len; i=i+1){
		if(*(enc+i)==1){
		  AddRoundKey(&test_vec_key0[i],&test_vec_key1[i],&test_vec_key2[i],&test_vec_key3[i],&test_vec_din0[i],&test_vec_din1[i],&test_vec_din2[i],&test_vec_din3[i],dout0,dout1,dout2,dout3);
		  KeyExpansion(test_vec_key0[i],test_vec_key1[i],test_vec_key2[i],test_vec_key3[i],&expandedKey0,&expandedKey1,&expandedKey2,&expandedKey3,0);
		  for(int j=1;j<10;j++){
			SubBytes(dout0,dout1,dout2,dout3);
			ShiftRows(dout0,dout1,dout2,dout3);
			MixColumns(dout0,dout1,dout2,dout3);
			AddRoundKey_1(&expandedKey0,&expandedKey1,&expandedKey2,&expandedKey3,dout0,dout1,dout2,dout3);
			KeyExpansion_1(&expandedKey0,&expandedKey1,&expandedKey2,&expandedKey3,j);
		  }
		  SubBytes(dout0,dout1,dout2,dout3);
		  ShiftRows(dout0,dout1,dout2,dout3);
		  AddRoundKey_1(&expandedKey0,&expandedKey1,&expandedKey2,&expandedKey3,dout0,dout1,dout2,dout3);
       //printf("tmp[%08x] = %08x\n",i,tmp);
	     *(gold_vec_dout0+i)=*dout0;
	     *(gold_vec_dout1+i)=*dout1;
	     *(gold_vec_dout2+i)=*dout2;
	     *(gold_vec_dout3+i)=*dout3;
		}
		else {
			kexp0[0]=test_vec_key0[i];
			kexp1[0]=test_vec_key1[i];
			kexp2[0]=test_vec_key2[i];
			kexp3[0]=test_vec_key3[i];
			KeyExpansion(test_vec_key0[i],test_vec_key1[i],test_vec_key2[i],test_vec_key3[i],&expandedKey0,&expandedKey1,&expandedKey2,&expandedKey3,0);
			kexp0[1]=expandedKey0;
			kexp1[1]=expandedKey1;
			kexp2[1]=expandedKey2;
			kexp3[1]=expandedKey3;
			for(int k=1;k<10;k++){
				KeyExpansion_1(&expandedKey0,&expandedKey1,&expandedKey2,&expandedKey3,k);
				kexp0[k+1]=expandedKey0;
				kexp1[k+1]=expandedKey1;
				kexp2[k+1]=expandedKey2;
				kexp3[k+1]=expandedKey3;
			}
			//printf("din=%08x%08x%08x%08x\n",*(test_vec_din0+i),*(test_vec_din1+i),*(test_vec_din2+i),*(test_vec_din3+i));
			AddRoundKey(&kexp0[10],&kexp1[10],&kexp2[10],&kexp3[10],&test_vec_din0[i],&test_vec_din1[i],&test_vec_din2[i],&test_vec_din3[i],dout0,dout1,dout2,dout3);
			for(int l=9;l>0;l--){
				InvShiftRows(dout0,dout1,dout2,dout3);
				InvSubBytes(dout0,dout1,dout2,dout3);
				AddRoundKey_1(&kexp0[l],&kexp1[l],&kexp2[l],&kexp3[l],dout0,dout1,dout2,dout3);
				InvMixColumns(dout0,dout1,dout2,dout3);
			}
			InvShiftRows(dout0,dout1,dout2,dout3);
			InvSubBytes(dout0,dout1,dout2,dout3);
			AddRoundKey_1(&kexp0[0],&kexp1[0],&kexp2[0],&kexp3[0],dout0,dout1,dout2,dout3);
	        *(gold_vec_dout0+i)=*dout0;
	        *(gold_vec_dout1+i)=*dout1;
	        *(gold_vec_dout2+i)=*dout2;
	        *(gold_vec_dout3+i)=*dout3;
		}

      }

      return 0;
    }  
}

unsigned int SubWord(unsigned int word) {
    unsigned int sbox_in0=word&255;
    unsigned int sbox_in1=(word>>8)&255;
    unsigned int sbox_in2=(word>>16)&255;
    unsigned int sbox_in3=(word>>24)&255;
	word=(Sbox[sbox_in3]<<24) | (Sbox[sbox_in2]<<16) | (Sbox[sbox_in1]<<8) | (Sbox[sbox_in0]);
	return word;
}

unsigned int RotWord(unsigned int word) {
    word=(word<<8) | (word>>24);
	return word;
}

void KeyExpansion(unsigned int key0,unsigned int key1,unsigned int key2,unsigned int key3, unsigned int *expandedKey0,unsigned int *expandedKey1,unsigned int *expandedKey2,unsigned int *expandedKey3,unsigned int j) {
    unsigned int temp;
	
    temp = key3;
    temp=RotWord(temp);
    temp=SubWord(temp);
    temp = temp ^ Rcon[j];
	
    *expandedKey0 = key0 ^ temp;
    *expandedKey1 = *expandedKey0 ^ key1;
    *expandedKey2 = *expandedKey1 ^ key2;
    *expandedKey3 = *expandedKey2 ^ key3;
	
}

void KeyExpansion_1(unsigned int *expandedKey0,unsigned int *expandedKey1,unsigned int *expandedKey2,unsigned int *expandedKey3,unsigned int j) {
    unsigned int temp;
	
    temp = *expandedKey3;
    temp=RotWord(temp);
    temp=SubWord(temp);
    temp = temp ^ Rcon[j];
	
    *expandedKey0 = *expandedKey0 ^ temp;
    *expandedKey1 = *expandedKey0 ^ *expandedKey1;
    *expandedKey2 = *expandedKey1 ^ *expandedKey2;
    *expandedKey3 = *expandedKey2 ^ *expandedKey3;
	
}

void AddRoundKey(unsigned int *expandedKey0,unsigned int *expandedKey1,unsigned int *expandedKey2,unsigned int *expandedKey3,
				 unsigned int *din0,unsigned int *din1,unsigned int *din2,unsigned int *din3,
				 unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {

    *dout0 = *din0 ^ *expandedKey0;
    *dout1 = *din1 ^ *expandedKey1;
    *dout2 = *din2 ^ *expandedKey2;
    *dout3 = *din3 ^ *expandedKey3;
	
}

void AddRoundKey_1(unsigned int *expandedKey0,unsigned int *expandedKey1,unsigned int *expandedKey2,unsigned int *expandedKey3,
				 unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {

    *dout0 = *dout0 ^ *expandedKey0;
    *dout1 = *dout1 ^ *expandedKey1;
    *dout2 = *dout2 ^ *expandedKey2;
    *dout3 = *dout3 ^ *expandedKey3;
	
}

void SubBytes(unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {

    *dout0 = SubWord(*dout0);
    *dout1 = SubWord(*dout1);
    *dout2 = SubWord(*dout2);
    *dout3 = SubWord(*dout3);
	
}

void ShiftRows(unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {
	unsigned int s0,s1,s2,s3;
	unsigned int s4,s5,s6,s7;
	unsigned int s8,s9,s10,s11;
	unsigned int s12,s13,s14,s15;
	s0=(*dout0>>24) & 255;
	s1=(*dout0>>16) & 255;
	s2=(*dout0>>8) & 255;
	s3=*dout0 & 255;
	s4=(*dout1>>24) & 255;
	s5=(*dout1>>16) & 255;
	s6=(*dout1>>8) & 255;
	s7=*dout1 & 255;
	s8=(*dout2>>24) & 255;
	s9=(*dout2>>16) & 255;
	s10=(*dout2>>8) & 255;
	s11=*dout2 & 255;
	s12=(*dout3>>24) & 255;
	s13=(*dout3>>16) & 255;
	s14=(*dout3>>8) & 255;
	s15=*dout3 & 255;
	
    *dout0 = (s0<<24) | (s5<<16) | (s10<<8) | s15;
    *dout1 = (s4<<24) | (s9<<16) | (s14<<8) | s3;
    *dout2 = (s8<<24) | (s13<<16) | (s2<<8) | s7;
    *dout3 = (s12<<24) | (s1<<16) | (s6<<8) | s11;
	
}

void MixColumns(unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {
	unsigned int s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15;
	unsigned int s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31;
	unsigned int s32,s33,s34,s35,s36,s37,s38,s39,s40,s41,s42,s43,s44,s45,s46,s47;
	unsigned int s48,s49,s50,s51,s52,s53,s54,s55,s56,s57,s58,s59,s60,s61,s62,s63;
	unsigned int out0,out1,out2,out3,out4,out5,out6,out7;
	unsigned int out8,out9,out10,out11,out12,out13,out14,out15;
	s0= xTimes2((*dout0>>24) & 255);
	s1= xTimes3((*dout0>>16) & 255);
	s2=(*dout0>>8) & 255;
	s3=*dout0 & 255;
	out0=s0 ^ s1 ^ s2 ^ s3;
	
	s4=(*dout0>>24) & 255;
	s5= xTimes2((*dout0>>16) & 255);
	s6= xTimes3((*dout0>>8) & 255);
	s7=*dout0 & 255;
	out1=s4 ^ s5 ^ s6 ^ s7;
	
	s8=(*dout0>>24) & 255;
	s9=(*dout0>>16) & 255;
	s10= xTimes2((*dout0>>8) & 255);
	s11= xTimes3(*dout0 & 255);
	out2=s8 ^ s9 ^ s10 ^ s11;
	
	s12= xTimes3((*dout0>>24) & 255);
	s13=(*dout0>>16) & 255;
	s14=(*dout0>>8) & 255;
	s15= xTimes2(*dout0 & 255);
	out3=s12 ^ s13 ^ s14 ^ s15;
	
	s16= xTimes2((*dout1>>24) & 255);
	s17= xTimes3((*dout1>>16) & 255);
	s18=(*dout1>>8) & 255;
	s19=*dout1 & 255;
	out4=s16 ^ s17 ^ s18 ^ s19;
	
	s20=(*dout1>>24) & 255;
	s21= xTimes2((*dout1>>16) & 255);
	s22= xTimes3((*dout1>>8) & 255);
	s23=*dout1 & 255;
	out5=s20 ^ s21 ^ s22 ^ s23;
	
	s24=(*dout1>>24) & 255;
	s25=(*dout1>>16) & 255;
	s26= xTimes2((*dout1>>8) & 255);
	s27= xTimes3(*dout1 & 255);
	out6=s24 ^ s25 ^ s26 ^ s27;
	
	s28= xTimes3((*dout1>>24) & 255);
	s29=(*dout1>>16) & 255;
	s30=(*dout1>>8) & 255;
	s31= xTimes2(*dout1 & 255);
	out7=s28 ^ s29 ^ s30 ^ s31;
	
	s32= xTimes2((*dout2>>24) & 255);
	s33= xTimes3((*dout2>>16) & 255);
	s34=(*dout2>>8) & 255;
	s35=*dout2 & 255;
	out8=s32 ^ s33 ^ s34 ^ s35;
	
	s36=(*dout2>>24) & 255;
	s37= xTimes2((*dout2>>16) & 255);
	s38= xTimes3((*dout2>>8) & 255);
	s39=*dout2 & 255;
	out9=s36 ^ s37 ^ s38 ^ s39;
	
	s40=(*dout2>>24) & 255;
	s41=(*dout2>>16) & 255;
	s42= xTimes2((*dout2>>8) & 255);
	s43= xTimes3(*dout2 & 255);
	out10=s40 ^ s41 ^ s42 ^ s43;
	
	s44= xTimes3((*dout2>>24) & 255);
	s45=(*dout2>>16) & 255;
	s46=(*dout2>>8) & 255;
	s47= xTimes2(*dout2 & 255);
	out11=s44 ^ s45 ^ s46 ^ s47;
	
	s48= xTimes2((*dout3>>24) & 255);
	s49= xTimes3((*dout3>>16) & 255);
	s50=(*dout3>>8) & 255;
	s51=*dout3 & 255;
	out12=s48 ^ s49 ^ s50 ^ s51;
	
	s52=(*dout3>>24) & 255;
	s53= xTimes2((*dout3>>16) & 255);
	s54= xTimes3((*dout3>>8) & 255);
	s55=*dout3 & 255;
	out13=s52 ^ s53 ^ s54 ^ s55;
	
	s56=(*dout3>>24) & 255;
	s57=(*dout3>>16) & 255;
	s58= xTimes2((*dout3>>8) & 255);
	s59= xTimes3(*dout3 & 255);
	out14=s56 ^ s57 ^ s58 ^ s59;
	
	s60= xTimes3((*dout3>>24) & 255);
	s61=(*dout3>>16) & 255;
	s62=(*dout3>>8) & 255;
	s63= xTimes2(*dout3 & 255);
	out15=s60 ^ s61 ^ s62 ^ s63;
	
    *dout0 = (out0<<24) | (out1<<16) | (out2<<8) | out3;
    *dout1 = (out4<<24) | (out5<<16) | (out6<<8) | out7;
    *dout2 = (out8<<24) | (out9<<16) | (out10<<8) | out11;
    *dout3 = (out12<<24) | (out13<<16) | (out14<<8) | out15;
	
}

unsigned int xTimes2(unsigned int word) {
    if( ((word>>7) & 1)==0){
		word=(word<<1) & 255;
	}
	else {
		word=( (word<<1) & 255) ^ 27;
	}
	return word;
}

unsigned int xTimes3(unsigned int word) {
	unsigned temp;
    temp=xTimes2(word);
	word= word ^ temp;
	return word;
}


void InvShiftRows(unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {
	unsigned int s0,s1,s2,s3;
	unsigned int s4,s5,s6,s7;
	unsigned int s8,s9,s10,s11;
	unsigned int s12,s13,s14,s15;
	s0=(*dout0>>24) & 255;
	s1=(*dout0>>16) & 255;
	s2=(*dout0>>8) & 255;
	s3=*dout0 & 255;
	s4=(*dout1>>24) & 255;
	s5=(*dout1>>16) & 255;
	s6=(*dout1>>8) & 255;
	s7=*dout1 & 255;
	s8=(*dout2>>24) & 255;
	s9=(*dout2>>16) & 255;
	s10=(*dout2>>8) & 255;
	s11=*dout2 & 255;
	s12=(*dout3>>24) & 255;
	s13=(*dout3>>16) & 255;
	s14=(*dout3>>8) & 255;
	s15=*dout3 & 255;
	
    *dout0 = (s0<<24) | (s13<<16) | (s10<<8) | s7;
    *dout1 = (s4<<24) | (s1<<16) | (s14<<8) | s11;
    *dout2 = (s8<<24) | (s5<<16) | (s2<<8) | s15;
    *dout3 = (s12<<24) | (s9<<16) | (s6<<8) | s3;
	
}

unsigned int InvSubWord(unsigned int word) {
    unsigned int sbox_in0=word&255;
    unsigned int sbox_in1=(word>>8)&255;
    unsigned int sbox_in2=(word>>16)&255;
    unsigned int sbox_in3=(word>>24)&255;
	word=(inv_s_box[sbox_in3]<<24) | (inv_s_box[sbox_in2]<<16) | (inv_s_box[sbox_in1]<<8) | (inv_s_box[sbox_in0]);
	return word;
}

void InvSubBytes(unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {

    *dout0 = InvSubWord(*dout0);
    *dout1 = InvSubWord(*dout1);
    *dout2 = InvSubWord(*dout2);
    *dout3 = InvSubWord(*dout3);
	
}

unsigned int xTimes0e(unsigned int word) {
	unsigned temp0,temp1,temp2;
    temp0=xTimes2(word);
    temp1=xTimes2(xTimes2(word));
    temp2=xTimes2(xTimes2(xTimes2(word)));
	word= temp0 ^ temp1 ^ temp2;
	return word;
}

unsigned int xTimes0b(unsigned int word) {
	unsigned temp0,temp1,temp2;
    temp0=word;
    temp1=xTimes2(word);
    temp2=xTimes2(xTimes2(xTimes2(word)));
	word= temp0 ^ temp1 ^ temp2;
	return word;
}

unsigned int xTimes0d(unsigned int word) {
	unsigned temp0,temp1,temp2;
    temp0=word;
    temp1=xTimes2(xTimes2(word));
    temp2=xTimes2(xTimes2(xTimes2(word)));
	word= temp0 ^ temp1 ^ temp2;
	return word;
}

unsigned int xTimes09(unsigned int word) {
	unsigned temp0,temp1;
    temp0=word;
    temp1=xTimes2(xTimes2(xTimes2(word)));
	word= temp0 ^ temp1;
	return word;
}

void InvMixColumns(unsigned int *dout0,unsigned int *dout1,unsigned int *dout2,unsigned int *dout3) {
	unsigned int s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15;
	unsigned int s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31;
	unsigned int s32,s33,s34,s35,s36,s37,s38,s39,s40,s41,s42,s43,s44,s45,s46,s47;
	unsigned int s48,s49,s50,s51,s52,s53,s54,s55,s56,s57,s58,s59,s60,s61,s62,s63;
	unsigned int out0,out1,out2,out3,out4,out5,out6,out7;
	unsigned int out8,out9,out10,out11,out12,out13,out14,out15;
	s0= xTimes0e((*dout0>>24) & 255);
	s1= xTimes0b((*dout0>>16) & 255);
	s2= xTimes0d((*dout0>>8) & 255);
	s3= xTimes09(*dout0 & 255);
	out0=s0 ^ s1 ^ s2 ^ s3;
	
	s4= xTimes09((*dout0>>24) & 255);
	s5= xTimes0e((*dout0>>16) & 255);
	s6= xTimes0b((*dout0>>8) & 255);
	s7= xTimes0d(*dout0 & 255);
	out1=s4 ^ s5 ^ s6 ^ s7;
	
	s8= xTimes0d((*dout0>>24) & 255);
	s9= xTimes09((*dout0>>16) & 255);
	s10= xTimes0e((*dout0>>8) & 255);
	s11= xTimes0b(*dout0 & 255);
	out2=s8 ^ s9 ^ s10 ^ s11;
	
	s12= xTimes0b((*dout0>>24) & 255);
	s13= xTimes0d((*dout0>>16) & 255);
	s14= xTimes09((*dout0>>8) & 255);
	s15= xTimes0e(*dout0 & 255);
	out3=s12 ^ s13 ^ s14 ^ s15;
	
	s16= xTimes0e((*dout1>>24) & 255);
	s17= xTimes0b((*dout1>>16) & 255);
	s18= xTimes0d((*dout1>>8) & 255);
	s19= xTimes09(*dout1 & 255);
	out4=s16 ^ s17 ^ s18 ^ s19;
	
	s20= xTimes09((*dout1>>24) & 255);
	s21= xTimes0e((*dout1>>16) & 255);
	s22= xTimes0b((*dout1>>8) & 255);
	s23= xTimes0d(*dout1 & 255);
	out5=s20 ^ s21 ^ s22 ^ s23;
	
	s24= xTimes0d((*dout1>>24) & 255);
	s25= xTimes09((*dout1>>16) & 255);
	s26= xTimes0e((*dout1>>8) & 255);
	s27= xTimes0b(*dout1 & 255);
	out6=s24 ^ s25 ^ s26 ^ s27;
	
	s28= xTimes0b((*dout1>>24) & 255);
	s29= xTimes0d((*dout1>>16) & 255);
	s30= xTimes09((*dout1>>8) & 255);
	s31= xTimes0e(*dout1 & 255);
	out7=s28 ^ s29 ^ s30 ^ s31;
	
	
	s32= xTimes0e((*dout2>>24) & 255);
	s33= xTimes0b((*dout2>>16) & 255);
	s34= xTimes0d((*dout2>>8) & 255);
	s35= xTimes09(*dout2 & 255);
	out8=s32 ^ s33 ^ s34 ^ s35;
	
	s36= xTimes09((*dout2>>24) & 255);
	s37= xTimes0e((*dout2>>16) & 255);
	s38= xTimes0b((*dout2>>8) & 255);
	s39= xTimes0d(*dout2 & 255);
	out9=s36 ^ s37 ^ s38 ^ s39;
	
	s40= xTimes0d((*dout2>>24) & 255);
	s41= xTimes09((*dout2>>16) & 255);
	s42= xTimes0e((*dout2>>8) & 255);
	s43= xTimes0b(*dout2 & 255);
	out10=s40 ^ s41 ^ s42 ^ s43;
	
	s44= xTimes0b((*dout2>>24) & 255);
	s45= xTimes0d((*dout2>>16) & 255);
	s46= xTimes09((*dout2>>8) & 255);
	s47= xTimes0e(*dout2 & 255);
	out11=s44 ^ s45 ^ s46 ^ s47;
	
	s48= xTimes0e((*dout3>>24) & 255);
	s49= xTimes0b((*dout3>>16) & 255);
	s50= xTimes0d((*dout3>>8) & 255);
	s51= xTimes09(*dout3 & 255);
	out12=s48 ^ s49 ^ s50 ^ s51;
	
	s52= xTimes09((*dout3>>24) & 255);
	s53= xTimes0e((*dout3>>16) & 255);
	s54= xTimes0b((*dout3>>8) & 255);
	s55= xTimes0d(*dout3 & 255);
	out13=s52 ^ s53 ^ s54 ^ s55;
	
	s56= xTimes0d((*dout3>>24) & 255);
	s57= xTimes09((*dout3>>16) & 255);
	s58= xTimes0e((*dout3>>8) & 255);
	s59= xTimes0b(*dout3 & 255);
	out14=s56 ^ s57 ^ s58 ^ s59;
	
	s60= xTimes0b((*dout3>>24) & 255);
	s61= xTimes0d((*dout3>>16) & 255);
	s62= xTimes09((*dout3>>8) & 255);
	s63= xTimes0e(*dout3 & 255);
	out15=s60 ^ s61 ^ s62 ^ s63;
	
    *dout0 = (out0<<24) | (out1<<16) | (out2<<8) | out3;
    *dout1 = (out4<<24) | (out5<<16) | (out6<<8) | out7;
    *dout2 = (out8<<24) | (out9<<16) | (out10<<8) | out11;
    *dout3 = (out12<<24) | (out13<<16) | (out14<<8) | out15;
	
}