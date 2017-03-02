module arm(
    input logic clk, reset,
    output logic [31:0] PC,
    input logic [31:0] Instr,
    output logic MemWrite,
    output logic [31:0] ALUResult, WriteData,
    input logic [31:0] ReadData,
    output logic [3:0]byteEnable
    );

    logic [3:0] ALUFlags;
    logic RegWrite, ALUSrc, MemtoReg, PCSrc;
    logic [1:0] RegSrc, ImmSrc;
    logic [3:0] ALUControl;
    logic C_flag;
    
    controller c(clk, reset, Instr[31:0], ALUFlags,
        RegSrc, RegWrite, ImmSrc,
        ALUSrc, ALUControl,
        MemWrite, MemtoReg, PCSrc, C_flag, BranchLink, byteEnable, Rs_in_shifter);
    datapath dp(clk, reset,
        RegSrc, RegWrite, ImmSrc,
        ALUSrc, ALUControl,
        MemtoReg, PCSrc,
        ALUFlags, PC, Instr,
        ALUResult, WriteData, ReadData, C_flag, BranchLink, Rs_in_shifter);

endmodule


