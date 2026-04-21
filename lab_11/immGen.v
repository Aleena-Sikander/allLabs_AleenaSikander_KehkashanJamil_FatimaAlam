`timescale 1ns/1ps
module immGen (
    input  [31:0] ins,
    input wire [1:0] Imm_Type,
    output reg [31:0] ImmOut
);
    wire [11:0] i_typeImm = ins[31:20];
    wire [6:0]  upp_s_typeImm  = ins[31:25];
    wire [4:0]  low_s_typeImm  = ins[11:7];
    wire [12:0] raw_b_typeImm = {ins[31], ins[7], ins[30:25], ins[11:8], 1'b0};

    always @(*) begin
        case (Imm_Type)
            // I-type
            2'b00: ImmOut= {{20{i_typeImm[11]}}, i_typeImm};

            // S-type
            2'b01: ImmOut = {{20{upp_s_typeImm[6]}}, upp_s_typeImm, low_s_typeImm};

            // B-type
            2'b10: ImmOut = {{19{raw_b_typeImm[12]}}, raw_b_typeImm};
            2'b11: ImmOut= {{19{raw_b_typeImm[12]}}, raw_b_typeImm};

            default: ImmOut = 32'b0;
        endcase
    end
endmodule