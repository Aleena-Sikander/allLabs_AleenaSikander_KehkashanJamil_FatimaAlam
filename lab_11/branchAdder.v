`timescale 1ns/1ps
module branchAdder (
    input  [31:0] PC_In, //curr pc val
    input  [31:0] Imm, //sign-extended immediate from immGen
    output [31:0] BranchTarget //final branch target address
);
    assign BranchTarget = PC_In + Imm; //ddding curr pc with the immediate offset
endmodule