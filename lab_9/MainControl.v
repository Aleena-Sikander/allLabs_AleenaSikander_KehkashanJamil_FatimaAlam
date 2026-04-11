`timescale 1ns / 1ps

module MainControl(
input [6:0] opcode,
output reg RegWrite,
output reg [1:0] ALUOp,
output reg MemRead,
output reg MemWrite,
output reg ALUSrc,
output reg MemtoReg,
output reg Branch
);
always @(*) begin

// Default values to prevent latches
RegWrite = 0; ALUOp = 2'b00; MemRead = 0;
MemWrite = 0; ALUSrc = 0; MemtoReg = 0; Branch = 0;

case(opcode)
7'b0110011: begin // R-type 
RegWrite = 1;
ALUOp = 2'b10;
end
7'b0010011: begin // I-type ALU 
RegWrite = 1;
ALUSrc = 1;
ALUOp = 2'b10;
end
7'b0000011: begin // Load 
RegWrite = 1;
ALUSrc = 1;
MemtoReg = 1;
MemRead = 1;
ALUOp = 2'b00;
end
7'b0100011: begin // Store 
ALUSrc = 1;
MemWrite = 1;
ALUOp = 2'b00;
end
7'b1100011: begin // Branch 
Branch = 1;
ALUOp = 2'b01;
end
default: ; // signals remain 0
endcase
end
endmodule
