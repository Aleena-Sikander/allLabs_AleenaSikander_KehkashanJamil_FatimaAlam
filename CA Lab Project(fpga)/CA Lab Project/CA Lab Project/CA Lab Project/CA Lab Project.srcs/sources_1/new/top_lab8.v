`timescale 1ns / 1ps

module top_lab8(
    input clk,
    input reset_btn,
    input [15:0] switches,
    output [15:0] leds,
    output [6:0] seg,
    output [3:0] an
);

    // Internal Signals
    wire reset_debounced;
    wire enable_1hz;
    
    // Address Decoder Interface
    reg [31:0] addr;
    reg rd_en, wr_en;
    reg [31:0] w_data;
    wire [31:0] r_data;
    wire [15:0] led_out;

    // FSM States 
    localparam S_IDLE           = 3'd0,
               S_READ_SWITCHES  = 3'd1,
               S_WRITE_DATAMEM  = 3'd2,
               S_READ_DATAMEM   = 3'd3,
               S_WRITE_LED      = 3'd4,
               S_DONE           = 3'd5;

    reg [2:0] state = S_IDLE;
    reg [31:0] temp_reg; // Temporary storage for data transfer

    // Reuse Debouncer and Clock Divider from Lab 7
    debouncer u_db (.clk(clk), .pbin(reset_btn), .pbout(reset_debounced));
    clock_divider #(.ONE_HZ_LIMIT(10)) u_cd (.clk(clk), .rst(reset_debounced), .enable_1hz(enable_1hz));

    // Address Decoder Instance [cite: 186, 187]
    addressDecoderTop u_decoder (
        .clk(clk), .rst(reset_debounced),
        .address(addr),
        .readEnable(rd_en), .writeEnable(wr_en),
        .writeData(w_data),
        .switches(switches),
        .readData(r_data),
        .leds(led_out)
    );

    // FSM Control Logic [cite: 220]
    always @(posedge clk) begin
        if (reset_debounced) begin
            state <= S_IDLE;
            wr_en <= 0; rd_en <= 0;
        end else if (enable_1hz) begin
            case (state)
                S_IDLE: state <= S_READ_SWITCHES;

                S_READ_SWITCHES: begin
                    addr <= 32'd768; // Switch base address [cite: 145]
                    rd_en <= 1; wr_en <= 0;
                    state <= S_WRITE_DATAMEM;
                end

                S_WRITE_DATAMEM: begin
                    temp_reg <= r_data; // Store switch value
                    addr <= 32'd10;     // Choose a DataMem address (0-511) [cite: 145]
                    rd_en <= 0; wr_en <= 1;
                    w_data <= r_data;   // Write the value we just read from switches
                    state <= S_READ_DATAMEM;
                end

                S_READ_DATAMEM: begin
                    addr <= 32'd10;     // Read back from same address
                    rd_en <= 1; wr_en <= 0;
                    state <= S_WRITE_LED;
                end

                S_WRITE_LED: begin
                    temp_reg <= r_data; // Store data from memory
                    addr <= 32'd512;    // LED base address [cite: 145]
                    rd_en <= 0; wr_en <= 1;
                    w_data <= r_data;   // Write memory value to LEDs
                    state <= S_DONE;
                end

                S_DONE: begin
                    wr_en <= 0; rd_en <= 0;
                    state <= S_DONE;
                end
            endcase
        end
    end

    assign leds = led_out;

endmodule