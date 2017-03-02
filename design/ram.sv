module ram
(
    input clk ,
    input we ,
    input [ 3:0] be , // Byte-enable
    input [31:0] addr ,
    input [31:0] dataI ,
    output [31:0] dataO
);

    logic [7:0] dataByte0, dataByte1, dataByte2, dataByte3;

    byteram byte0(clk,we,be[0],addr[10:0],dataI[7:0],dataByte0); //lsb
    byteram byte1(clk,we,be[1],addr[10:0],dataI[15:8],dataByte1);
    byteram byte2(clk,we,be[2],addr[10:0],dataI[23:16],dataByte2);
    byteram byte3(clk,we,be[3],addr[10:0],dataI[31:24],dataByte3); //msb

    assign dataO = {dataByte3,dataByte2,dataByte1,dataByte0};

endmodule