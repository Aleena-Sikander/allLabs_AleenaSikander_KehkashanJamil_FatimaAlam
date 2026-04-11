`timescale 1ns / 1ps

module DataMemory(
    input wire clk,
    input wire MemWrite,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data
);

    reg [31:0] mem [0:511];
    integer j;

    // Initialize memory
    initial begin
        for (j = 0; j < 512; j = j + 1)
//            mem[j] = 32'b0;
            mem[j] = 32'd0;
    end

    // Write operation
    always @(posedge clk) begin
        if (MemWrite)
            mem[address[8:0]] <= write_data;
    end

    // Read operation
    always @(*) begin
        read_data = mem[address[8:0]];
    end

endmodule