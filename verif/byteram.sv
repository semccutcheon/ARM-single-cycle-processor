module byteram (
    input clk ,
    input we ,
    input be , // Byte-enable for this byte
    input [10:0] addr , //only need 9 bits not including the 2 lsb for 512 addresses
    input [7:0] dataI ,
    output [7:0] dataO
);
    logic [7:0] ram[511:0];
    logic [7:0] readvalue;

    always_comb
    begin
        if(be)
            readvalue = ram[addr[10:2]]; // addr is still word aligned 
        else
            readvalue = 8'd0;
    end
    
    assign dataO = readvalue;
        
    always_ff @(posedge clk)
        if (we&be) ram[addr[10:2]] <= dataI;
endmodule