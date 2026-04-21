`timescale 1ns/1ps
module mux2 #(parameter width = 32)(
    input wire [width-1:0] In0,
    input wire [width-1:0] In1,
    input wire sel, //select signal
    output wire [width-1:0] Out
);
    assign Out = sel ? In1 : In0; //if sel=0, choose In0 elif sel=1, choose In1
endmodule