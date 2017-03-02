module condlogic(input logic clk, reset,
    input logic [3:0] Cond,
    input logic [3:0] ALUFlags,
    input logic [1:0] FlagW,
    input logic PCS, RegW, MemW,
    output logic PCSrc, RegWrite, MemWrite,
    input logic NoWrite,
    output logic C_flag_out
    );

    logic [1:0] FlagWrite;
    logic [3:0] Flags;
    logic CondEx;


    // status register
    //N,Z
    flopenr #(2)flagreg1(clk, reset, FlagWrite[1],
        ALUFlags[3:2], Flags[3:2]);
    //C,V
    flopenr #(2)flagreg0(clk, reset, FlagWrite[0],
        ALUFlags[1:0], Flags[1:0]);
    
    // write controls are conditional
    condcheck cc(Cond, Flags, CondEx);
    assign FlagWrite = FlagW & {2{CondEx}};
    assign RegWrite = RegW & CondEx & ~NoWrite;
    assign MemWrite = MemW & CondEx;
    assign PCSrc = PCS & CondEx;
    assign C_flag_out = Flags[1];
endmodule

