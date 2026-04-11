module top(
    input clk,
    input reset_button,
    input [15:0] SW,
    output [15:0] LED
);

    wire rst_clean;
    wire [15:0] switch_value;
    wire [15:0] led_value;

    // Instance of a debouncer for the reset button
    debouncer db(
        .clk(clk),
        .pbin(reset_button),
        .pbout(rst_clean)
    );

    // Instance of the switches/leds interface
    switches sw(
        .clk(clk),
        .rst(rst_clean),
        .writeData({16'b0, SW}),
        .writeEnable(1'b1),
        .readEnable(1'b0),
        .memAddress(30'b0),
        .readData(),
        .leds(switch_value)
    );

    // Instance of the FSM counter
    fsm_counter fsm(
        .clk(clk),
        .rst(rst_clean),
        .switch_in(switch_value),
        .led_out(led_value)
    );

    assign LED = led_value;

endmodule