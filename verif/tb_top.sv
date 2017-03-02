
module tb_top();
    logic clk;
    logic reset;
    logic [31:0] DataAdr;
    logic [31:0] WriteData;
    logic MemWrite;


    // instantiate device to be tested
    top dut(clk, reset, DataAdr, WriteData, MemWrite);


    // initialize test
    initial
    begin
        reset <= 1; # 5; reset <= 0;
    end

    // generate clock to sequence tests
    always
    begin
        clk <= 1; # 10; clk <= 0; # 5;
    end

    // Limits sim time to 1600ns
    initial begin
    #1600;
    $finish;
    end
endmodule
