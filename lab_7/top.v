`timescale 1ns / 1ps

module top_lab7(
    input CLK100MHZ,
    input btnC,
    output [15:0] led
);

// Clock Divider (1 Hz)
reg [26:0] counter = 0;
reg slow_clk = 0;

always @(posedge CLK100MHZ) begin
    counter <= counter + 1;

    if(counter == 50_000_000) begin
        counter <= 0;
        slow_clk <= ~slow_clk;   // toggle every ~0.5 sec
    end
end

wire [63:0] ReadData1;
wire [63:0] ReadData2;

reg RegWrite;
reg [4:0] RS1;
reg [4:0] RS2;
reg [4:0] RD;
reg [63:0] WriteData;

wire [31:0] ALUResult;
wire Zero;
reg [3:0] ALUControl;

localparam S_IDLE       = 4'd0,
           S_INIT_X1    = 4'd1,
           S_INIT_X2    = 4'd2,
           S_ALU_ADD    = 4'd3,
           S_WRITE_ADD  = 4'd4,
           S_ALU_SUB    = 4'd5,
           S_WRITE_SUB  = 4'd6,
           S_ALU_AND    = 4'd7,
           S_WRITE_AND  = 4'd8,
           S_DONE       = 4'd9;

reg [3:0] state = S_IDLE;

registerFile regfile(
    .WriteData(WriteData),
    .RS1(RS1),
    .RS2(RS2),
    .RD(RD),
    .RegWrite(RegWrite),
    .Clk(CLK100MHZ),
    .Reset(btnC),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2)
);

ALU alu(
    .A(ReadData1[31:0]),
    .B(ReadData2[31:0]),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
);

always @(posedge slow_clk or posedge btnC) begin

    if(btnC) begin
        state <= S_IDLE;
        RegWrite <= 0;
    end

    else begin

        case(state)

        S_IDLE:
            state <= S_INIT_X1;

        // x1 = 0x10101010
        S_INIT_X1: begin
            RegWrite <= 1;
            RD <= 5'd1;
            WriteData <= 64'h10101010;
            state <= S_INIT_X2;
        end

        // x2 = 0x01010101
        S_INIT_X2: begin
            RegWrite <= 1;
            RD <= 5'd2;
            WriteData <= 64'h01010101;
            state <= S_ALU_ADD;
        end

        // ADD
        S_ALU_ADD: begin
            RegWrite <= 0;
            RS1 <= 5'd1;
            RS2 <= 5'd2;
            ALUControl <= 4'b0100;
            state <= S_WRITE_ADD;
        end

        S_WRITE_ADD: begin
            RegWrite <= 1;
            RD <= 5'd4;
            WriteData <= ALUResult;
            state <= S_ALU_SUB;
        end

        // SUB
        S_ALU_SUB: begin
            RegWrite <= 0;
            RS1 <= 5'd1;
            RS2 <= 5'd2;
            ALUControl <= 4'b0001;
            state <= S_WRITE_SUB;
        end

        S_WRITE_SUB: begin
            RegWrite <= 1;
            RD <= 5'd5;
            WriteData <= ALUResult;
            state <= S_ALU_AND;
        end

        // AND
        S_ALU_AND: begin
            RegWrite <= 0;
            RS1 <= 5'd1;
            RS2 <= 5'd2;
            ALUControl <= 4'b0000;
            state <= S_WRITE_AND;
        end

        S_WRITE_AND: begin
            RegWrite <= 1;
            RD <= 5'd6;
            WriteData <= ALUResult;
            state <= S_DONE;
        end

        S_DONE: begin
            RegWrite <= 0;
            state <= S_DONE;
        end

        default:
            state <= S_IDLE;

        endcase

    end

end

// LED Output
assign led = ALUResult[15:0];

endmodule
