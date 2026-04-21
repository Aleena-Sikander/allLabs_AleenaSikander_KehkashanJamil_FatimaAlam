`timescale 1ns / 1ps

module DataMemory (
    input clk,
    input MemWrite,           // Enable signal from Decoder
    input [31:0] address,     // Full address
    input [31:0] write_data,  // Data to store
    output [31:0] read_data   // Data to read
);
    // 512 words of 32 bits each 
    reg [31:0] mem [0:511];
    
    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1) begin
            mem[i] = 32'b0;
        end
    end

    // Synchronous Write
    always @(posedge clk) begin
        if (MemWrite) begin
            // Use address[8:0] to index 512 locations
            mem[address[10:2]] <= write_data;
        end
    end

    // Asynchronous Read
    assign read_data = mem[address[8:0]];

endmodule