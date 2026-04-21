`timescale 1ns / 1ps

module addressDecoderTop(
    input clk, rst,
    input [31:0] address,
    input readEnable, writeEnable,
    input [31:0] writeData,
    input [15:0] switches,
    output reg [31:0] readData,
    output reg [15:0] leds
);

    // Internal Enable Signals [cite: 173, 174]
    wire DataMemSelect  = (address[9:8] == 2'b00); // 0-511 
    wire LEDSelect      = (address[9:8] == 2'b01); // 512-767 
    wire SwitchSelect   = (address[9:8] == 2'b10); // 768-1023 

    // Data Memory Instance
    wire [31:0] memReadBus;
    DataMemory dmem (
        .clk(clk),
        .MemWrite(writeEnable && DataMemSelect), // Only write if selected [cite: 149]
        .address(address),
        .write_data(writeData),
        .read_data(memReadBus)
    );

    // LED Register Logic [cite: 150, 157]
    always @(posedge clk) begin
        if (rst) 
            leds <= 16'h0000;
        else if (writeEnable && LEDSelect)
            leds <= writeData[15:0]; // Map lower 16 bits to LEDs
    end

    // Mux for readData output 
    always @(*) begin
        if (readEnable) begin
            case (address[9:8])
                2'b00: readData = memReadBus;        // From Data Memory
                2'b10: readData = {16'b0, switches}; // From Switches [cite: 151]
                default: readData = 32'h0;
            endcase
        end else begin
            readData = 32'h0;
        end
    end

endmodule