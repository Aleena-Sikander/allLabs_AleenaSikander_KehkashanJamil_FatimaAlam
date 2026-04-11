`timescale 1ns / 1ps

module fsm_counter(
    input clk,
    input rst,
    input [15:0] switch_in,
    output reg [15:0] led_out
);

    // State definitions
    parameter IDLE = 1'b0, COUNTDOWN = 1'b1;

    reg state;
    reg [15:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            counter <= 0;
            led_out <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    led_out <= 0;
                    if (switch_in != 0) begin
                        counter <= switch_in;
                        led_out <= switch_in;
                        state   <= COUNTDOWN;
                    end
                end

                COUNTDOWN: begin
                    led_out <= counter;
                    if (counter > 0) begin
                        counter <= counter - 1;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule