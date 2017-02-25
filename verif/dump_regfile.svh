 
    int WDOG_TIMER_MAX = 200; // Cycles
    int clk_cnt;
    always @(posedge clk) begin
      clk_cnt++;
      if( clk_cnt > WDOG_TIMER_MAX )begin
         for(int i =0; i<16; i++) begin
            $display("%g %d", i, $signed(testbench.dut.arm.dp.rf.rf[i]) );
         end
         $finish;
      end
    end