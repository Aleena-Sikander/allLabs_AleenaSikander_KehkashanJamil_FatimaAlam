`timescale 1ns / 1ps

module AddressDecoder(
    input [31:0] address,
    input readEnable,
    input writeEnable,
    output DataMemWrite,
    output DataMemRead,
    output LEDWrite,
    output SwitchReadEnable
);
    assign DataMemWrite = (address[9:8] == 2'b00) & writeEnable;
    assign DataMemRead = (address[9:8] == 2'b00) & readEnable;
    assign LEDWrite = (address[9:8] == 2'b01) & writeEnable;
    assign SwitchReadEnable = (address[9:8] == 2'b10) & readEnable;

endmodule



