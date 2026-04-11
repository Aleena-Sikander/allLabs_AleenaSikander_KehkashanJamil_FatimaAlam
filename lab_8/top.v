module addressDecoderTop_lab8(
    input clk, rst,
    input [31:0] address,
    input readEnable, writeEnable,
    input [31:0] writeData,
    input [15:0] switches,

    output [31:0] readData,
    output [15:0] leds
);

wire DataMemWrite;
wire DataMemRead;
wire LEDWrite;
wire SwitchReadEnable;

wire [31:0] memReadData;
wire [31:0] switchReadData;

AddressDecoder decoder(
    .address(address),
    .readEnable(readEnable),
    .writeEnable(writeEnable),
    .DataMemWrite(DataMemWrite),
    .DataMemRead(DataMemRead),
    .LEDWrite(LEDWrite),
    .SwitchReadEnable(SwitchReadEnable)
);


DataMemory dataMem(
    .clk(clk),
    .MemWrite(DataMemWrite),
    .address(address),
    .write_data(writeData),
    .read_data(memReadData)
);


led led_module(
    .clk(clk),
    .rst(rst),
    .writeData(writeData),
    .writeEnable(LEDWrite),
    .memAddress(address[1:0]),   
    .readData(),
    .leds(leds)
);

switches switch_module(
    .clk(clk),
    .rst(rst),
    .btns(16'b0),
    .writeData(writeData),
    .writeEnable(1'b0),
    .readEnable(SwitchReadEnable),
    .memAddress(address[1:0]),   
    .switches(switches),
    .readData(switchReadData)
);


assign readData =
    (readEnable && DataMemRead) ? memReadData :
    (readEnable && SwitchReadEnable) ? switchReadData :
    32'b0;

endmodule