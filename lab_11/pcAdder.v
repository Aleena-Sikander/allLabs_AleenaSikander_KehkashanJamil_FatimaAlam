`timescale 1ns/1ps
module pcAdder (
    input  [31:0] PC_In, //curr pc val from prog_cntr
    output [31:0] PC_Plus4 //next sequential instruction address
);
    assign PC_Plus4 = PC_In + 32'd4; //adding 4
endmodule