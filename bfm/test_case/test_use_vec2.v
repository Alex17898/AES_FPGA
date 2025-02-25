initial begin
   if($test$plusargs("test_use_vec2"))begin
      @(ev_load_mem);

      //config: RX data are always valid, TX data are valid in a while (depend on pause rate)
      `XMIT.setcfg_length(XMIT_TESTLEN);
      `XMIT.setcfg_pause(1);
      `XMIT.setcfg_pause_rate(60);

      `RCVR.setcfg_length(RCVR_TESTLEN);
      `RCVR.setcfg_pause(0);
      `RCVR.setcfg_pause_rate(10);

      `CHKR.setcfg_length(RCVR_TESTLEN);
      `CHKR.setcfg_check_unknown(1);
      `CHKR.setcfg_check_overflow(1);
      `CHKR.setcfg_pass_showmsg(SHW_PSMSG);//fail msg is always shown
      `CHKR.setcfg_fail_stopsim(FL_STPSIM);//fail then call $finish

      //start the test
      fork
         `XMIT.start(1,100);//delay 100 cycle then start bfm
         `RCVR.start(1,  0);
         `CHKR.start(1,  0);
      join

      //wait done
      @(posedge clk);
      while (tx_busy | rx_busy)begin//check bfm busy status
         @(posedge clk);
      end 

      //check the result
      `CHKR.get_pass_cnt(pass_cnt);
      `CHKR.get_fail_cnt(fail_cnt);
      //
      `ifdef TC2 //w/t unknown data
         if(fail_cnt==1 && (fail_cnt+pass_cnt)==RCVR_TESTLEN)begin//unknown 32-bit data: fl_cnt +4
            $display($time,,"===========================");
            $display($time,,"TEST is PASSED (TC2)");
            $display($time,,"  cnt_fl=1(unknown data) is the expected result");
            $display($time,,"===========================");
         end
         else begin
            $display($time,,"===========================");
            $display($time,,"TEST is FAILED (TC2)");
            $display($time,,"===========================");
            $display($time,,"  cnt_ps = h%8h", pass_cnt);
            $display($time,,"  cnt_fl = h%8h", fail_cnt);
            $display($time,,"===========================");
         end
      `else //w/o unknown data
         if(fail_cnt>0 && pass_cnt!=RCVR_TESTLEN)begin//w/t fail
            $display($time,,"===========================");
            $display($time,,"TEST is FAILED");
            $display($time,,"===========================");
            $display($time,,"  cnt_ps = h%8h", pass_cnt);
            $display($time,,"  cnt_fl = h%8h", fail_cnt);
            $display($time,,"===========================");
         end
         else begin
            $display($time,,"===========================");
            $display($time,,"TEST is PASSED");
            $display($time,,"===========================");
         end
      `endif

      #100;
      $finish;
   end
end
