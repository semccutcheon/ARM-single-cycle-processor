module top(
    input  logic clk, reset,
    output logic [31:0] DataAdr,
    output logic [31:0] WriteData,
    output logic MemWrite
    );

    logic [31:0] PC, Instr, ReadData;

    logic [3:0] byteEnable;


    // instantiate processor and memories
    arm  arm (clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData, byteEnable);
    
    imem imem(PC, Instr); // not merged with RAM due not being able to load programs into RAM and needing tests.
    
    ram ram(clk, MemWrite, byteEnable, DataAdr, WriteData, ReadData);

endmodule
