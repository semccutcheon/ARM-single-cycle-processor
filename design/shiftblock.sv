module shiftblock (
    input logic [11:0]Instr,
    input logic [31:0]Rs,
    input logic [31:0]Rm,
    input logic carry_flag,
    input logic rot_imm,
    output logic shifter_carry,
    output logic [31:0]shifter_operand,
    input logic Rs_in
);

    logic [2:0]op;
    logic src;
    logic [5:0]shift_val;
    logic [5:0]temp_val;
    logic [31:0]shift_in, shift_temp;


    //for data processing with an imm8 rotated
    mux2 #32 rot_imm_mux(Rm,{{24{1'b0}},Instr[7:0]},rot_imm,shift_temp);
     //for mem instructions which need to preserve Rd2 but still shift, use Rs as the input
    mux2 #32 mem_instr_mux(shift_temp, Rs, Rs_in, shift_in);

    // mux for shift amount inputs, 11:7 and Rs[5:0]
    mux2 #6 shamt_mux({1'b0,Instr[11:7]},Rs[5:0],Instr[4] & ~Rs_in,temp_val);
    // mux for shift amount input for DP with rot imm8
    //                                    [11:8]<<1 
    mux2 #6 shamt_mux_imm(temp_val,{{1{1'b0}},Instr[11:8],{1{1'b0}}},rot_imm,shift_val);   

    shiftlogic sh_logic(Instr,rot_imm,op,src);
    shifter shifter(shift_in,op,shift_val,carry_flag,shifter_carry,shifter_operand);
endmodule