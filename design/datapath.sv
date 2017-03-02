module datapath(
    input logic clk, reset,
    input logic [1:0] RegSrc,
    input logic RegWrite,
    input logic [1:0] ImmSrc,
    input logic ALUSrc,
    input logic [3:0] ALUControl,
    input logic MemtoReg,
    input logic PCSrc,
    output logic [3:0] ALUFlags,
    output logic [31:0] PC,
    input logic [31:0] Instr,
    output logic [31:0] ALUResult, WriteData,
    input logic [31:0] ReadData,
    input logic carry_flag,
    input logic BranchLink,
    input logic Rs_in_shifter
    );


    logic [31:0] PCNext, PCPlus4, PCPlus8;
    logic [31:0] ExtImm, SrcA, SrcB, Result;
    logic [3:0] RA1, RA2, RA3;
    logic [31:0] Rs, shifter_operand, WD3;
    logic shifter_carry;


    // next PC logic
    mux2 #(32) pcmux(PCPlus4, Result, PCSrc, PCNext);
    flopr #(32) pcreg(clk, reset, PCNext, PC);
    adder #(32) pcadd1(PC, 32'b100, PCPlus4);
    adder #(32) pcadd2(PCPlus4, 32'b100, PCPlus8);


    // register file logic
    mux2 #(4) ra1mux(Instr[19:16], 4'b1111, RegSrc[0], RA1);
    mux2 #(4) ra2mux(Instr[3:0], Instr[15:12], RegSrc[1], RA2);

    //Added in order to make BL able to write into reg 14
    mux2 #(4) BLmux(Instr[15:12], 4'b1110, BranchLink, RA3);
    //Added in order to switch the value written to PC+4
    mux2 #(32) LinkPCmux(Result, PCPlus4, BranchLink, WD3);

    //Added for mem instructions which preserve Rd2 but need to shift Rm
    mux2 #(4) Rs_src(Instr[11:8],Instr[3:0],Rs_in_shifter,Rsa);

    regfile rf(clk, RegWrite, RA1, RA2,
        RA3, WD3, PCPlus8,
        SrcA, WriteData, Rsa, Rs);

    shiftblock shift(Instr[11:0], Rs, WriteData, carry_flag, Instr[25], shifter_carry, shifter_operand, Rs_in_shifter);


    mux2 #(32) resmux(ALUResult, ReadData, MemtoReg, Result);
    extend ext(Instr[23:0], ImmSrc, ExtImm);

    // ALU logic
    mux2 #(32) srcbmux(shifter_operand, ExtImm, ALUSrc, SrcB);
    alu alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags, carry_flag, shifter_carry);
endmodule
