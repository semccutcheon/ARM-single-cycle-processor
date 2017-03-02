module shiftlogic (
    input logic [11:0] shift_instr,
    input logic I_bit,
    output logic [2:0] sh_op,
    output logic shift_src
);

    always_comb
    begin
        if(I_bit)
        begin
            sh_op = 3'b111;
        end
        else
            sh_op = shift_instr[6:4];
    end
    
endmodule