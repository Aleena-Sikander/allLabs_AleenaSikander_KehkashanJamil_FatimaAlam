// basys3_top.v
// Lab 8: Basys3 FPGA Top-Level Test Wrapper
//
// This module lets you physically test the memory system using
// Basys3 switches and buttons. It wraps addressDecoderTop and
// provides a simple manual test interface.
//
// ============================================================
// PHYSICAL INTERFACE:
// ============================================================
//
//  SWITCHES:
//    SW[15:8]  = address[7:0]  (local offset within selected region)
//    SW[7:0]   = write data    (8-bit value to write, zero-extended to 32-bit)
//
//  BUTTONS (debounced):
//    BTNC = Reset       ? clears LED register, resets state
//    BTNU = Mode UP     ? cycle mode forward
//    BTND = Mode DOWN   ? cycle mode backward
//    BTNL = WRITE       ? execute write to selected region
//    BTNR = READ        ? execute read from selected region
//
//  MODES (shown on 7-seg display rightmost digit):
//    Mode 0 (d0): Write to Data Memory  ? address = {2'b00, SW[15:8]} = 0x000 + offset
//    Mode 1 (d1): Write to LEDs         ? address = 0x100 (fixed)
//    Mode 2 (d2): Read  from Data Mem   ? address = {2'b00, SW[15:8]}
//    Mode 3 (d3): Read  from Switches   ? address = 0x200 (fixed)
//
//  LEDs (LD15..LD0):
//    After WRITE: shows writeData[15:0]  (what you sent)
//    After READ:  shows readData[15:0]   (what came back)
//    LED region writes also appear on LD15..LD0 directly
//
//  7-SEGMENT DISPLAY:
//    Digit 3 (leftmost):  shows current MODE number (0-3)
//    Digit 2:             shows address[7:4] (upper nibble of offset)
//    Digit 1:             shows address[3:0] (lower nibble of offset)
//    Digit 0 (rightmost): shows SW[7:4] (upper nibble of write data)
// ============================================================

module basys3_top (
    input  wire        clk,      // W5  - 100 MHz
    input  wire        btnC,     // U18 - BTNC (reset)
    input  wire        btnU,     // T18 - BTNU (mode up)
    input  wire        btnD,     // U17 - BTND (mode down)
    input  wire        btnL,     // W19 - BTNL (write)
    input  wire        btnR,     // T17 - BTNR (read)
    input  wire [15:0] sw,            // SW15..SW0
    output wire [15:0] led,           // LD15..LD0
    output wire [6:0]  seg,           // 7-segment cathodes
    output wire        dp,            // decimal point
    output wire [3:0]  an             // 7-segment anodes (active LOW)
);

    // -------------------------------------------------------
    // Debounce all buttons
    // -------------------------------------------------------
    wire rst_db, btnU_db, btnD_db, btnL_db, btnR_db;

    debouncer db_rst  (.clk(clk), .pbin(btnC), .pbout(rst_db));
    debouncer db_up   (.clk(clk), .pbin(btnU), .pbout(btnU_db));
    debouncer db_down (.clk(clk), .pbin(btnD), .pbout(btnD_db));
    debouncer db_left (.clk(clk), .pbin(btnL), .pbout(btnL_db));
    debouncer db_right(.clk(clk), .pbin(btnR), .pbout(btnR_db));

    // -------------------------------------------------------
    // Edge detect (only trigger on rising edge of button)
    // -------------------------------------------------------
    reg btnU_prev, btnD_prev, btnL_prev, btnR_prev;
    wire btnU_pulse = btnU_db & ~btnU_prev;
    wire btnD_pulse = btnD_db & ~btnD_prev;
    wire btnL_pulse = btnL_db & ~btnL_prev;
    wire btnR_pulse = btnR_db & ~btnR_prev;

    always @(posedge clk or posedge rst_db) begin
        if (rst_db) begin
            btnU_prev <= 0; btnD_prev <= 0;
            btnL_prev <= 0; btnR_prev <= 0;
        end else begin
            btnU_prev <= btnU_db; btnD_prev <= btnD_db;
            btnL_prev <= btnL_db; btnR_prev <= btnR_db;
        end
    end

    // -------------------------------------------------------
    // Mode register (0-3)
    // -------------------------------------------------------
    reg [1:0] mode;

    always @(posedge clk or posedge rst_db) begin
        if (rst_db)
            mode <= 2'd0;
        else if (btnU_pulse)
            mode <= (mode == 2'd3) ? 2'd0 : mode + 1;
        else if (btnD_pulse)
            mode <= (mode == 2'd0) ? 2'd3 : mode - 1;
    end

    // -------------------------------------------------------
    // Address and data from switches
    // SW[15:8] = address offset  SW[7:0] = write data
    // -------------------------------------------------------
    wire [31:0] addr_datamem = {22'b0, 2'b00, sw[15:8]};  // 0x000 + offset
    wire [31:0] addr_led     = 32'h0000_0100;              // 0x100 fixed
    wire [31:0] addr_switch  = 32'h0000_0200;              // 0x200 fixed
    wire [31:0] write_val    = {24'b0, sw[7:0]};           // zero-extend SW[7:0]

    // -------------------------------------------------------
    // CPU signal generation
    // -------------------------------------------------------
    reg [31:0] address_r;
    reg        readEnable_r;
    reg        writeEnable_r;
    reg [31:0] writeData_r;
    reg [15:0] display_reg;  // holds last result for LEDs/display

    always @(posedge clk or posedge rst_db) begin
        if (rst_db) begin
            address_r    <= 32'b0;
            readEnable_r  <= 1'b0;
            writeEnable_r <= 1'b0;
            writeData_r  <= 32'b0;
            display_reg  <= 16'b0;
        end else begin
            // Default: de-assert strobes every cycle
            readEnable_r  <= 1'b0;
            writeEnable_r <= 1'b0;

            case (mode)
                2'd0: begin  // Write to Data Memory
                    address_r  <= addr_datamem;
                    writeData_r <= write_val;
                    if (btnL_pulse) begin
                        writeEnable_r <= 1'b1;
                        display_reg   <= write_val[15:0];
                    end
                end
                2'd1: begin  // Write to LEDs
                    address_r  <= addr_led;
                    writeData_r <= write_val;
                    if (btnL_pulse) begin
                        writeEnable_r <= 1'b1;
                        display_reg   <= write_val[15:0];
                    end
                end
                2'd2: begin  // Read from Data Memory
                    address_r <= addr_datamem;
                    if (btnR_pulse) begin
                        readEnable_r <= 1'b1;
                        // readData is combinational - sample it next cycle via flag
                    end
                end
                2'd3: begin  // Read from Switches
                    address_r <= addr_switch;
                    if (btnR_pulse) begin
                        readEnable_r <= 1'b1;
                    end
                end
            endcase

            // Capture readData into display_reg - merged here to avoid multi-driver
            // readEnable_r is set this cycle; readData is combinational so valid now
            if (readEnable_r)
                display_reg <= readData[15:0];
        end
    end

    // -------------------------------------------------------
    // DUT - Memory System
    // -------------------------------------------------------
    wire [31:0] readData;
    wire [15:0] mem_leds;

    addressDecoderTop dut (
        .clk         (clk),
        .rst         (rst_db),
        .address     (address_r),
        .readEnable  (readEnable_r),
        .writeEnable (writeEnable_r),
        .writeData   (writeData_r),
        .switches    (sw),
        .readData    (readData),
        .leds        (mem_leds)
    );

    // -------------------------------------------------------
    // LED output
    // In Mode 1 (LED write): physical LEDs driven by mem_leds
    // All other modes: LEDs show last read/write result
    // -------------------------------------------------------
    assign led = (mode == 2'd1) ? mem_leds : display_reg;

    // -------------------------------------------------------
    // 7-Segment Display Controller
    // 4-digit multiplexed display
    // Digit3=mode  Digit2=addr[7:4]  Digit1=addr[3:0]  Digit0=data[7:4]
    // -------------------------------------------------------
    reg [16:0] refresh_cnt;
    always @(posedge clk) refresh_cnt <= refresh_cnt + 1;
    wire [1:0] digit_sel = refresh_cnt[16:15];  // ~763 Hz refresh

    reg [3:0] digit_val;
    reg [3:0] anode_r;

    always @(*) begin
        case (digit_sel)
            2'd3: begin digit_val = {2'b0, mode};      anode_r = 4'b0111; end
            2'd2: begin digit_val = sw[15:12];          anode_r = 4'b1011; end
            2'd1: begin digit_val = sw[11:8];           anode_r = 4'b1101; end
            2'd0: begin digit_val = sw[7:4];            anode_r = 4'b1110; end
            default: begin digit_val = 4'b0;            anode_r = 4'b1111; end
        endcase
    end

    assign an = anode_r;
    assign dp = 1'b1;  // decimal point off

    // Hex to 7-segment decoder (active LOW segments: abcdefg)
    reg [6:0] seg_r;
    always @(*) begin
        case (digit_val)
            4'h0: seg_r = 7'b0000001;
            4'h1: seg_r = 7'b1001111;
            4'h2: seg_r = 7'b0010010;
            4'h3: seg_r = 7'b0000110;
            4'h4: seg_r = 7'b1001100;
            4'h5: seg_r = 7'b0100100;
            4'h6: seg_r = 7'b0100000;
            4'h7: seg_r = 7'b0001111;
            4'h8: seg_r = 7'b0000000;
            4'h9: seg_r = 7'b0000100;
            4'hA: seg_r = 7'b0001000;
            4'hB: seg_r = 7'b1100000;
            4'hC: seg_r = 7'b0110001;
            4'hD: seg_r = 7'b1000010;
            4'hE: seg_r = 7'b0110000;
            4'hF: seg_r = 7'b0111000;
            default: seg_r = 7'b1111111;
        endcase
    end
    assign seg = seg_r;

endmodule
