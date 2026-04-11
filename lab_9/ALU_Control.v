`timescale 1ns / 1ps

module ALUControl(
input [1:0] ALUOp,
input [2:0] funct3,
input funct7_bit, // instruction bit [30]
output reg [3:0] ALUControlOut
);
always @(*) begin
case(ALUOp)
2'b00: ALUControlOut = 4'b0010; // Load/Store -> ADD
2'b01: ALUControlOut = 4'b0110; // Branch -> SUB
2'b10: begin // R-type / I-type
case(funct3)
3'b000: ALUControlOut = funct7_bit ? 4'b0110 : 4'b0010;

// SUB : ADD
3'b111: ALUControlOut = 4'b0000; // AND
3'b110: ALUControlOut = 4'b0001; // OR
3'b100: ALUControlOut = 4'b0011; // XOR
3'b001: ALUControlOut = 4'b1000; // SLL
3'b101: ALUControlOut = 4'b1001; // SRL
default: ALUControlOut = 4'b1111;
endcase
end
default: ALUControlOut = 4'b1111;
endcase
end
endmodule
