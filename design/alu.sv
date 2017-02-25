module alu(
    input logic [31:0] SrcA,
    input logic [31:0] SrcB,
    input logic [3:0] ALUControl,
    output logic [31:0] ALUResult,
    output logic [3:0] ALUFlags,   // {Neg, Zero, Carry, Overflow}
    input logic carry_in,
    input logic shifter_carry_in
    );

    logic neg_flag;
    logic zero_flag;
    logic carry_flag;
    logic overflow_flag;
    
    logic [31:0]carry_extend;

    assign ALUFlags = {neg_flag, zero_flag, carry_flag, overflow_flag};

    assign zero_flag = ~|ALUResult;
    assign neg_flag = ALUResult[31];

    assign carry_extend = {{31{0}}, {carry_in}};

    always_comb
    begin
        ALUResult = 'd0;

        case(ALUControl)
        4'b0000 :   // Bitwise AND
        begin
            ALUResult = SrcA & SrcB;
            carry_flag = shifter_carry_in;
        end

        4'b0001 :   // Bitwise XOR
        begin
            ALUResult = SrcA ^ SrcB;
            carry_flag = shifter_carry_in;
        end

        4'b0010 :   // Subtract
        begin
            {carry_flag, ALUResult} = SrcA - SrcB;
            if (~SrcA[31] & SrcB[31] & ALUResult[31])
                overflow_flag = 1'b1;
            if (SrcA[31] & ~SrcB[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;
        end

        4'b0011 :   // Reverse Subtract
        begin
            {carry_flag, ALUResult} = SrcB - SrcA;
            // neg - pos -> neg + neg = neg
            if (SrcB[31] & ~SrcA[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            // pos - neg -> pos + pos = pos
            else if (~SrcB[31] & SrcA[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;           
        end

        4'b0100 :     //add
        begin
            {carry_flag, ALUResult} = SrcA + SrcB;
            if (~SrcA[31] & ~SrcB[31] & ALUResult[31])
                overflow_flag = 1'b1;
            else if (SrcA[31] & SrcB[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;
        end

        4'b0101 :     //add with Carry
        begin
            {carry_flag, ALUResult} = SrcA + SrcB + carry_extend;
            if (~SrcA[31] & ~SrcB[31] & ALUResult[31])
                overflow_flag = 1'b1;
            else if (SrcA[31] & SrcB[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;
        end
        
        4'b0110 :     //sub with Carry
        begin
            {carry_flag, ALUResult} = ((SrcA - SrcB) - ~carry_extend);

            // pos - neg -> pos + pos = pos  
            if (~SrcA[31] & SrcB[31] & ALUResult[31])
                overflow_flag = 1'b1;
            // neg - pos -> neg + neg = neg
            else if (SrcA[31] & ~SrcB[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;
        end
        4'b0111 :     //Reverse Sub w/ Carry
        begin
            {carry_flag, ALUResult} = SrcB - SrcA - ~carry_extend;

            // neg - pos -> neg + neg = neg
            if (SrcB[31] & ~SrcA[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            // pos - neg -> pos + pos = pos
            else if (~SrcB[31] & SrcA[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;        
        end
        4'b1000 :     // Test
        begin
            ALUResult = SrcA & SrcB;
            carry_flag = shifter_carry_in;
        end

        4'b1001 : // Test Equivalence 
        begin
            ALUResult = SrcA ^ SrcB;
            carry_flag = shifter_carry_in;          
        end

        4'b1010 : // Compare
        begin
            {carry_flag, ALUResult} = SrcA - SrcB;
            if (~SrcA[31] & SrcB[31] & ALUResult[31])
                overflow_flag = 1'b1;
            if (SrcA[31] & ~SrcB[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;        
        end

        4'b1011 : // Compare Negative
        begin
            {carry_flag, ALUResult} = SrcA + SrcB;
            if (~SrcA[31] & ~SrcB[31] & ALUResult[31])
                overflow_flag = 1'b1;
            else if (SrcA[31] & SrcB[31] & ~ALUResult[31])
                overflow_flag = 1'b1;
            else
                overflow_flag = 1'b0;
        end

        4'b1100 : // Bitwise OR
        begin
            ALUResult = SrcA + SrcB;
            carry_flag = shifter_carry_in;
            // carry_flag = shifter_carry_in
        end

        4'b1101 : // Shifts
        begin
            ALUResult = SrcB;
            carry_flag = shifter_carry_in;
        end

        4'b1110 : // Bitwise Clear
        begin
            ALUResult = SrcA & ~SrcB;
            carry_flag = shifter_carry_in;
        end

        4'b1111 : // Bitwise Not
        begin
            ALUResult = ~SrcB;
            carry_flag = shifter_carry_in;
        end                
        default :
        begin
            ALUResult = 'd0;
            carry_flag = 'd0;
            overflow_flag = 'd0;
        end
        endcase
    end

endmodule
