`timescale 1ns/1ps

module TopLevel (
    input        clk,
    input        rst,
    input  [15:0] sw,
    output [15:0] led
);

    //Decode switch inputs 
    wire [6:0] opcode = sw[15:9];
    wire [2:0] funct3 = sw[8:6];
    wire funct7_bit = sw[5];

    //MainControl outputs
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;

    //ALUControl output
    wire [3:0] ALUControlOut;

    MainControl MC (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    ALUControl AC (
        .ALUOp        (ALUOp),
        .funct3       (funct3),
        .funct7_bit   (funct7_bit),
        .ALUControlOut(ALUControlOut)
    );

    assign led[15]   = RegWrite;
    assign led[14]   = ALUSrc;
    assign led[13]   = MemRead;
    assign led[12]   = MemWrite;
    assign led[11]   = MemtoReg;
    assign led[10]   = Branch;
    assign led[9:8]  = ALUOp;
    assign led[7:4]  = ALUControlOut;
    assign led[3:0]  = 4'b0000;

endmodule