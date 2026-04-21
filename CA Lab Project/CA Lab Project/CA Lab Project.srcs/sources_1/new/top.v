`timescale 1ns / 1ps

module top(
    input clk,
    input reset_btn,        // Physical Reset Button
    input [15:0] switches,  // Physical Switches
    output [15:0] leds,     // Physical LEDs
    output [6:0] seg,       // 7-Segment Cathodes (a-g, active-low)
    output [3:0] an         // 7-Segment Anodes   (active-low)
    );
    // Internal Signals
    wire reset_debounced;
    wire [15:0] led_val;
    wire enable_1hz;
    wire enable_refresh;
    wire [15:0] decoded_switches;  // Output from one-hot decoder

    // Debouncer for Reset Button
    debouncer u_debouncer (
        .clk(clk),
        .pbin(reset_btn),
        .pbout(reset_debounced)
    );

    // Clock Divider
    clock_divider u_clkdiv (
        .clk(clk),
        .rst(reset_debounced),
        .enable_1hz(enable_1hz),
        .enable_refresh(enable_refresh)
    );

    // One-Hot Decoder (SW0?0, SW1?1, SW2?2, ...)
    onehot_decoder u_decoder (
        .switches(switches),
        .decoded_value(decoded_switches)
    );

    // FSM Counter Module (uses decoded switch values)
    fsm_counter u_fsm (
        .clk(clk),
        .reset(reset_debounced),
        .enable(enable_1hz),
        .switches(decoded_switches),
        .leds(led_val)
    );

    // LEDs Module
    led u_leds (
        .clk(clk),
        .rst(1'b0),
        .writeData({16'b0, led_val}),
        .writeEnable(1'b1),
        .readEnable(1'b0),
        .memAddress(30'b0),
        .readData(),
        .leds(leds)
    );

    // Seven Segment Display
    seven_segment u_7seg (
        .clk(clk),
        .rst(reset_debounced),
        .enable_refresh(enable_refresh),
        .val(led_val),
        .seg(seg),
        .an(an)
    );

endmodule
