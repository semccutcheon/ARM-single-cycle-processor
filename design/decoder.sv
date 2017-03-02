module decoder(input logic [1:0] Op,
    input logic [5:0] Funct,
    input logic [3:0] Rd,
    output logic [1:0] FlagW,
    output logic PCS, RegW, MemW,
    output logic MemtoReg, ALUSrc,
    output logic [1:0] ImmSrc, RegSrc,
    output logic [3:0] ALUControl,
    output logic NoWrite,
    output logic BranchLink,
    output logic [3:0]byteEnable,
    output logic Rs_in_shifter,
    input logic [11:0]Src2_value //needed to affirm NoWrite since extra mem could accidentally meet conditions
    );

    logic [10:0] controls;
    logic Branch, ALUOp, BranchLink;
    logic [3:0] byte_enable_bits;
    logic mem_instr;

    //added for readability
    logic I_bit, S_bit;
    assign I_bit = Funct[5];
    assign S_bit = Funct[0];
    assign mem_instr = ~Op[1] & Op[0];
    
    
    // Main Decoder
    always_comb
        casex(Op)
            // Data-processing
            2'b00:
                //          RegSrc      ImmSrc     ALUSrc    MemtoReg    RegW       MemW       Branch     ALUOp      Rs_in
                controls = {{2{1'b0}}, {2{1'b0}}, {1{1'b0}}, {1{1'b0}}, {1{1'b1}}, {1{1'b0}}, {1{1'b0}}, {1{1'b1}}, {1'b0}};
            // Memory
            2'b01: 
            begin

                //byte enable bits for LDRB and STRB
                if(Funct[2]==1)
                begin
                    byte_enable_bits = 4'b0001;
                end

                else
                begin
                    byte_enable_bits = 4'b1111;
                end
                

                //LDR
                if(Funct[0]=={1'b1})
                begin
                    //          RegSrc    ImmSrc   ALUSrc       MemtoReg   RegW       MemW       Branch     ALUOp      Rs_in
                    controls = {{2'b00}, {2'b01}, {~Funct[5]}, {1{1'b1}}, {1{1'b1}}, {1{1'b0}}, {1{1'b0}}, {1{1'b1}}, {1'b1}};
                end

                //  
                else
                begin
                    //          RegSrc    ImmSrc   ALUSrc       MemtoReg    RegW       MemW       Branch     ALUOp      Rs_in
                    controls = {{2'b10}, {2'b01}, {~Funct[5]}, {1{1'b0}}, {1{1'b0}}, {1{1'b1}}, {1{1'b0}}, {1{1'b1}}, {1'b1}};
                end
            end
            // Branch
            2'b10: 
            begin
                //          RegSrc    ImmSrc   ALUSrc    MemtoReg    RegW       MemW       Branch     ALUOp      Rs_in
                controls = {{2'b01}, {2'b10}, {1{1'b1}}, {1{1'b0}},  Funct[4], {1{1'b0}}, {1{1'b1}}, {1{1'b0}}, {1'b0}};
            end
            // Unimplemented
            default: controls = 11'bx;
        endcase
    
    assign {RegSrc, ImmSrc, ALUSrc, MemtoReg,
        RegW, MemW, Branch, ALUOp, Rs_in_shifter} = controls;
    assign byteEnable = byte_enable_bits;
    assign NoWrite = (~|Op) & Funct[4] & ~Funct[3] & ~(Src2_value[7] & Src2_value[4]);
    
    // ALU Decoder
    always_comb
    begin
        if (ALUOp) 
        begin
            //Data processing
            ALUControl = Funct[4:1];
            // update flags if S bit is set
            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0];

        end
            //Op == 10
        else if (mem_instr)
        begin
            //add
            if (Funct[3]) 
            begin
                ALUControl = 4'b0100;
            end

            //sub
            else
            begin
                ALUControl = 4'b0010;    
            end
        end

        //Branch instructions
        else
        begin
            ALUControl = 4'b0100; // add for non-DP instructions
            FlagW = 2'b00; // don't update Flags
        end
    end

    // PC Logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
    assign BranchLink = (Funct[4] & Branch);
endmodule
