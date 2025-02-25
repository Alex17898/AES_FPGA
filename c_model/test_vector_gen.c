#include<string.h>
#include"./lib/gen_pat.c"

int main()
{
   unsigned int i,status;
            int tc;
   unsigned int test_len;
   unsigned int gold_len;
   unsigned int  *rn_32b_key0;
   unsigned int  *rn_32b_key1;
   unsigned int  *rn_32b_key2;
   unsigned int  *rn_32b_key3;
   unsigned int  *rn_32b_din0;
   unsigned int  *rn_32b_din1;
   unsigned int  *rn_32b_din2;
   unsigned int  *rn_32b_din3;
   unsigned int *rn_32b_dout0;
   unsigned int *rn_32b_dout1;
   unsigned int *rn_32b_dout2;
   unsigned int *rn_32b_dout3;
   unsigned int *enc;

   FILE *fPtr_out1 = fopen("test_vec.dat","w");//for TX (32-bit)
   FILE *fPtr_out2 = fopen("gold_vec.dat","w");//for RX golden (8-bit)

   // test file not existing
   if (fPtr_out1 == NULL || fPtr_out2 == NULL){
      printf("Error! Could not open file\n");
      exit(-1);
   }

   printf("//---------------------------//\n");
   printf("//-- Test Vector Generator --//\n");
   printf("//---------------------------//\n");

   printf("Choose Test Case(Type in 1 or 2):\n");
   scanf("%d", &tc);

   if(tc==1) test_len=1000;
   else      test_len=200;//test case = 2
   printf("test length = %d\n",test_len);
   srand((unsigned)time(NULL));
 //printf("Enter the 32-bit test length:\n");
 //scanf("%d", &test_len);
   
   if(test_len <=0){
      printf("The value (%d) must be positive (>0)!\n", test_len);
      fclose(fPtr_out1);
      fclose(fPtr_out2);
      return 1;
   }
   else{
      rn_32b_key0 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
      rn_32b_key1 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
      rn_32b_key2 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
      rn_32b_key3 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
	  
      rn_32b_din0 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
      rn_32b_din1 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
      rn_32b_din2 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
      rn_32b_din3 = (unsigned int*)malloc(test_len * sizeof(unsigned int));
      enc = (unsigned int*)malloc(test_len * sizeof(unsigned int));

      c_gen_test_vec(rn_32b_key0,rn_32b_key1,rn_32b_key2,rn_32b_key3,rn_32b_din0,rn_32b_din1,rn_32b_din2,rn_32b_din3,enc, test_len);
	  
      for(i=0; i<test_len; i=i+1){//test vector length
         fprintf(fPtr_out1,"@%08x ",i);
		 
		if(tc==2 && i==7){//32-bit unknown @7
            fprintf(fPtr_out1,"%d_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",enc[i]);
         }
         else {
         fprintf(fPtr_out1,"%d_%08x%08x%08x%08x_%08x%08x%08x%08x",enc[i],rn_32b_key0[i],rn_32b_key1[i],rn_32b_key2[i],rn_32b_key3[i],rn_32b_din0[i],rn_32b_din1[i],rn_32b_din2[i],rn_32b_din3[i]);
		 }
         fprintf(fPtr_out1,"\n");
      }

      gold_len = test_len;
      rn_32b_dout0 = (unsigned int*)malloc(gold_len * sizeof(unsigned int));
      rn_32b_dout1 = (unsigned int*)malloc(gold_len * sizeof(unsigned int));
      rn_32b_dout2 = (unsigned int*)malloc(gold_len * sizeof(unsigned int));
      rn_32b_dout3 = (unsigned int*)malloc(gold_len * sizeof(unsigned int));

      status = c_get_gold_vec(rn_32b_dout0,rn_32b_dout1,rn_32b_dout2,rn_32b_dout3,rn_32b_key0,rn_32b_key1,rn_32b_key2,rn_32b_key3,rn_32b_din0,rn_32b_din1,rn_32b_din2,rn_32b_din3,enc,test_len);
      if(status == 0){//unpacked array for RX
         for(i=0; i<gold_len; i=i+1){//golden vector length
            fprintf(fPtr_out2,"@%08x %08x%08x%08x%08x\n",i,rn_32b_dout0[i],rn_32b_dout1[i],rn_32b_dout2[i],rn_32b_dout3[i]);
         }
      }
      else{
         printf("Get golden vector fail!:\n");
      }

      free(rn_32b_key0);
      free(rn_32b_key1);
      free(rn_32b_key2);
      free(rn_32b_key3);
      free(rn_32b_din0);
      free(rn_32b_din1);
      free(rn_32b_din2);
      free(rn_32b_din3);
      free(rn_32b_dout0);
      free(rn_32b_dout1);
      free(rn_32b_dout2);
      free(rn_32b_dout3);

      fclose(fPtr_out1);
      fclose(fPtr_out2);
      return (0);
   }
}
