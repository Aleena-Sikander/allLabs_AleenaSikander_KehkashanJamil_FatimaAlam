`timescale 1ns / 1ps

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUControl,
    output reg [31:0] ALUResult,
    output Zero
);

wire [31:0] B_in;
wire [31:0] add_sub_res;

// Invert B for subtraction
assign B_in = (ALUControl == 4'b0001) ? ~B : B;

// Perform add or subtract
assign add_sub_res = A + B_in + ((ALUControl == 4'b0001) ? 1'b1 : 1'b0);

always @(*) begin
    case (ALUControl)

        4'b0000: ALUResult = A & B;          // AND
        4'b0010: ALUResult = A | B;          // OR
        4'b0011: ALUResult = A ^ B;          // XOR
        4'b0001: ALUResult = add_sub_res;    // SUB
        4'b0100: ALUResult = add_sub_res;    // ADD
        4'b0101: ALUResult = A << B[4:0];    // SLL
        4'b0110: ALUResult = A >> B[4:0];    // SRL
        4'b0111: ALUResult = (A < B) ? 32'd1 : 32'd0; // SLT

        default: ALUResult = 32'b0;

    endcase
end

assign Zero = (ALUResult == 32'b0);

endmodule