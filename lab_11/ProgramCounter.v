`timescale 1ns/1ps
module ProgramCounter (
    input wire clk,
    input wire rst,
    input wire [31:0] PC_nxt, //next PC value to be loaded from mux
    input wire PC_In, //write enable signal
    output reg [31:0] PC_Out //curr PC
);
    always @(posedge clk) begin
        if (rst) //if reset is high then force the PC to become zero (start address)
            PC_Out <= 32'd0;
        else if (PC_In) //elif when PC_In is high then we update PC with the next value
            PC_Out <= PC_nxt;
            
        //else PC holds its previous value without change)
    end
endmodule