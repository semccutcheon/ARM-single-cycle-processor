        casex(Op)
            // Data-processing immediate
            2'b00: if (Funct[5]) controls = 10'b0000101001;
            // Data-processing register
            else controls = 10'b0000001001;
            // LDR
            2'b01: if (Funct[0]) controls = 10'b0001111000;
            // STR
            else controls = 10'b1001110100;
            // B
            2'b10: controls = 10'b0110100010;
            // Unimplemented
            default: controls = 10'bx;
        endcase