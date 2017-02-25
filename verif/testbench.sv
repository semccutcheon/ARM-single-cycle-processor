module testbench();
    logic clk;
    logic reset;
    logic [31:0] WriteData, DataAdr;
    logic MemWrite;


    // instantiate device to be tested
    top dut( 
           .clk (clk), 
           .reset     (reset     ),
           .WriteData (WriteData ), 
           .DataAdr   (DataAdr   ),
           
           .MemWrite  (MemWrite  )
           );


    // initialize test
    initial
    begin
        reset <= 1; # 22; reset <= 0;
    end

    // generate clock to sequence tests
    always
    begin
        clk <= 1; # 5; clk <= 0; # 5;
    end

    // check that 7 gets written to address 0x64
    // at end of program
    always @(negedge clk)
    begin
        if(MemWrite) begin
            if(DataAdr === 100 & WriteData === 7) 
            begin
                $display("Simulation succeeded");
                // $stop;
            end 
            else if (DataAdr !== 96) 
            begin
                $display("Simulation failed , DataAdr: %g, WriteData: %g ", DataAdr, WriteData );
                // $stop;
            end
        end
    end
    
   int clk_cnt;
    always @(posedge clk) begin
      clk_cnt++;
      if( clk_cnt > 100 )begin
         for(int i =0; i<16; i++) begin
            $display("%g %d", i, $signed(testbench.dut.arm.dp.rf.rf[i]) );
         end
         $finish;
      end
    end
    
endmodule
