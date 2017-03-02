module shifter (
    input logic [31:0] in,
    input logic [2:0] shift_op,
    input logic [5:0] shift_amt, // need 6 bits for reg values > 32 (in documentation its the bottom byte, 7:0 but its not necessary because values >64 are equivalent to the 5:0 value
    input logic carry_flag_in,
    output logic carry_flag_out,
    output logic [31:0] out
);
    //lines between each shifter level.
    logic [31:0]temp4;
    logic [31:0]temp3;
    logic [31:0]temp2;
    logic [31:0]temp1;

    //used for making rotations easier by just shifting two copies of input
    logic [63:0]temp4_64;
    logic [63:0]temp3_64;
    logic [63:0]temp2_64;
    logic [63:0]temp1_64;
    logic [63:0]temp0_64;


    always_comb
    begin
        case(shift_op)
        
        3'b000 : // LSL imm 0 to 31 //
        begin
            temp4 = (shift_amt[4]) ? in    << 16 : in;
            temp3 = (shift_amt[3]) ? temp4 << 8  : temp4;
            temp2 = (shift_amt[2]) ? temp3 << 4  : temp3;
            temp1 = (shift_amt[1]) ? temp2 << 2  : temp2;
            out   = (shift_amt[0]) ? temp1 << 1  : temp1;

            if(shift_amt == 6'b000000)
                carry_flag_out = carry_flag_in;
            else
                carry_flag_out = in[6'd32 - shift_amt];
        end

        3'b001 : // LSL reg 0 to 32 //
        begin
            if(shift_amt == 6'b000000)
            begin
                carry_flag_out = carry_flag_in;
                out = in;
            end

            else if(shift_amt < 6'd32)
            begin
                temp4 = (shift_amt[4]) ? in    << 16 : in;
                temp3 = (shift_amt[3]) ? temp4 << 8  : temp4;
                temp2 = (shift_amt[2]) ? temp3 << 4  : temp3;
                temp1 = (shift_amt[1]) ? temp2 << 2  : temp2;
                out   = (shift_amt[0]) ? temp1 << 1  : temp1;
                carry_flag_out = in[6'd32 - shift_amt];
            end
            else if(shift_amt == 6'd32)
            begin
                carry_flag_out = in[0];
                out = 32'd0;
            end
            else
            begin
                carry_flag_out = 0;
                out = 32'd0;
            end
        end


        3'b010 : // LSR imm 1 to 32
        begin

            if ((shift_amt == 6'd0) || (shift_amt == 6'd32))
            begin
                out = 32'd0;
                carry_flag_out = in[31];
            end
            else if(shift_amt < 6'd32)
            begin
                temp4 = (shift_amt[4]) ? in    >> 16 : in;
                temp3 = (shift_amt[3]) ? temp4 >> 8  : temp4;
                temp2 = (shift_amt[2]) ? temp3 >> 4  : temp3;
                temp1 = (shift_amt[1]) ? temp2 >> 2  : temp2;
                out   = (shift_amt[0]) ? temp1 >> 1  : temp1;

                carry_flag_out = in[shift_amt - 6'd1];
            end
            else
            begin

            end

        end

        3'b011 : // LSR reg 0 to 32
        begin
            if(shift_amt == 6'd0)
            begin
                out = in;
                carry_flag_out = carry_flag_in;
            end

            else if(shift_amt < 6'd32)
            begin
                temp4 = (shift_amt[4]) ? in    >> 16 : in;
                temp3 = (shift_amt[3]) ? temp4 >> 8  : temp4;
                temp2 = (shift_amt[2]) ? temp3 >> 4  : temp3;
                temp1 = (shift_amt[1]) ? temp2 >> 2  : temp2;
                out   = (shift_amt[0]) ? temp1 >> 1  : temp1;

                carry_flag_out = in[shift_amt - 6'd1];
            end
            else if(shift_amt == 6'd32)
            begin
                out = 32'd0;
                carry_flag_out = in[31];
            end
            else
            begin
                out = 32'd0;
                carry_flag_out = 1'b0;
            end
        end

        3'b100 : // ASR imm 1 to 32
        begin
            if((shift_amt == 6'd0) || (shift_amt == 6'd32))
            begin
                out = {32{in[31]}};
                carry_flag_out = in[31];
            end
            else
            begin
                temp4 = (shift_amt[4]) ? in    >> 16 | {{16{in[31]}},{16{1'b0}}} : in;
                temp3 = (shift_amt[3]) ? temp4 >> 8  | {{8{in[31]}},{24{1'b0}}}   : temp4;
                temp2 = (shift_amt[2]) ? temp3 >> 4  | {{4{in[31]}},{28{1'b0}}}   : temp3;
                temp1 = (shift_amt[1]) ? temp2 >> 2  | {{2{in[31]}},{30{1'b0}}}   : temp2;
                out   = (shift_amt[0]) ? temp1 >> 1  | {{1{in[31]}},{31{1'b0}}}   : temp1;     

                carry_flag_out = in[shift_amt - 6'd1];
            end
        end

        3'b101 : // ASR reg 1 to 32
        begin
            if(shift_amt == 6'd0)
            begin
                out = in;
                carry_flag_out = carry_flag_in;
            end

            else if(shift_amt < 6'd32)
            begin
                temp4 = (shift_amt[4]) ? in    >> 16 | {{16{in[31]}},{16{1'b0}}} : in;
                temp3 = (shift_amt[3]) ? temp4 >> 8  | {{8{in[31]}},{24{1'b0}}}   : temp4;
                temp2 = (shift_amt[2]) ? temp3 >> 4  | {{4{in[31]}},{28{1'b0}}}   : temp3;
                temp1 = (shift_amt[1]) ? temp2 >> 2  | {{2{in[31]}},{30{1'b0}}}   : temp2;
                out   = (shift_amt[0]) ? temp1 >> 1  | {{1{in[31]}},{31{1'b0}}}   : temp1;     

                carry_flag_out = in[shift_amt - 6'd1];
            end
            else 
            begin
                out = {32{in[31]}};
                carry_flag_out = in[31];
            end
        end
        3'b110 : // ROR imm 1 to 31 AND RRX if imm == 0
        begin
            if(shift_amt == 6'd0)
            begin
                out = in >> 1 | {carry_flag_out, 31'd0};
                carry_flag_out = in[0];
            end
            else
            begin
                temp4_64 = (shift_amt[4]) ? {in,in}  >> 16 : {in,in};
                temp3_64 = (shift_amt[3]) ? temp4_64 >> 8  : temp4_64;
                temp2_64 = (shift_amt[2]) ? temp3_64 >> 4  : temp3_64;
                temp1_64 = (shift_amt[1]) ? temp2_64 >> 2  : temp2_64;
                temp0_64 = (shift_amt[0]) ? temp1_64 >> 1  : temp1_64;

                out = temp0_64[31:0];
                carry_flag_out = in[shift_amt - 6'd1];
            end
        end
        3'b111 : // ROR reg 0 to 32
        begin
            if(shift_amt == 6'd0)
            begin
                out = in;
                carry_flag_out = carry_flag_in;
            end
            else if((shift_amt[4:0] == 5'd0) || (shift_amt == 6'd32))
            begin
                out = in;
                carry_flag_out = in[31];
            end
            else
            begin
                temp4_64 = (shift_amt[4]) ? {in,in}  >> 16 : {in,in};
                temp3_64 = (shift_amt[3]) ? temp4_64 >> 8  : temp4_64;
                temp2_64 = (shift_amt[2]) ? temp3_64 >> 4  : temp3_64;
                temp1_64 = (shift_amt[1]) ? temp2_64 >> 2  : temp2_64;
                temp0_64 = (shift_amt[0]) ? temp1_64 >> 1  : temp1_64;

                out = temp0_64[31:0];
                carry_flag_out = in[shift_amt - 6'd1];
            end
            
        end
        
    endcase
    end

endmodule

