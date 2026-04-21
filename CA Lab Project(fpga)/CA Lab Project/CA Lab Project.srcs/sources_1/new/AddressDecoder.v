// AddressDecoder.v
// Lab 8: Address Decoder Module
//
// Memory Map (using address[9:0]):
//   address[9:8] = 2'b00  ->  Data Memory   (0   - 511)   DataMemSelect
//   address[9:8] = 2'b01  ->  LEDs          (512 - 767)   LEDSelect
//   address[9:8] = 2'b10  ->  Switches      (768 - 1023)  SwitchSelect
//   address[9:8] = 2'b11  ->  Unused        (-)           none
//
// The decoder uses address[9:8] to route CPU read/write enables to the
// appropriate device.  Only one device is enabled at a time (no bus contention).

module AddressDecoder (
    input  wire        readEnable,     // CPU asserts for a read operation
    input  wire        writeEnable,    // CPU asserts for a write operation
    input  wire [31:0] address,        // full 32-bit CPU address (only [9:8] decoded)
    // Data Memory control
    output reg         DataMemWrite,   // enables write to DataMemory
    output reg         DataMemRead,    // enables read from DataMemory
    // LED control
    output reg         LEDWrite,       // enables write to LED register
    // Switch control
    output reg         SwitchReadEnable // enables read from Switch register
);

    wire [1:0] device_sel;
    assign device_sel = address[9:8];

    always @(*) begin
        // Default: all enables de-asserted
        DataMemWrite      = 1'b0;
        DataMemRead       = 1'b0;
        LEDWrite          = 1'b0;
        SwitchReadEnable  = 1'b0;

        case (device_sel)
            2'b00: begin   // Data Memory (0 - 511)
                DataMemWrite = writeEnable;
                DataMemRead  = readEnable;
            end
            2'b01: begin   // LED Output Interface (512 - 767)
                LEDWrite = writeEnable;
                // LEDs are write-only; reads are ignored
            end
            2'b10: begin   // Switch Input Interface (768 - 1023)
                SwitchReadEnable = readEnable;
                // Switches are read-only; writes are ignored
            end
            2'b11: begin   // Unused
                // No device enabled
            end
            default: begin
                DataMemWrite     = 1'b0;
                DataMemRead      = 1'b0;
                LEDWrite         = 1'b0;
                SwitchReadEnable = 1'b0;
            end
        endcase
    end

endmodule
