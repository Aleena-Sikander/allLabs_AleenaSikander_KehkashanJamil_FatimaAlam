`timescale 1ns / 1ps

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUct1,
    output reg [31:0] ALUout,
    output zero
    );
    always @(*) begin
    case (ALUct1)
    4'b0000: ALUout = A & B; // AND
    4'b0001: ALUout = A | B; // OR
    4'b0010: ALUout = A + B; // ADD
    4'b0110: ALUout = A - B; // SUB
    4'b0111: ALUout = (A < B) ? 1 : 0;// SLT
    4'b1100: ALUout = ~(A | B); // NOR
    4'b1010: ALUout = A ^ B; // XOR
    4'b1000: ALUout = A << B; // SLL
    4'b1001: ALUout = A >> B; // SRL
    default: ALUout = 32'b0;
    endcase
    end
    assign zero = (ALUout == 0);
endmodule