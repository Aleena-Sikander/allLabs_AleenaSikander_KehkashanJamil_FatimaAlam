`timescale 1ns / 1ps

module top_lab7(
    input clk,
    input reset_btn,        
    input [15:0] switches,  
    output [15:0] leds,     
    output [6:0] seg,       
    output [3:0] an         
    );

    // =========================
    // Debounced Button
    // =========================
    wire write_enable;

    debouncer u_debouncer (
        .clk(clk),
        .pbin(reset_btn),
        .pbout(write_enable)   // one-pulse write enable
    );

    // =========================
    // ALU + Register File Wiring
    // =========================
    wire [31:0] rf_ReadData1;
    wire [31:0] rf_ReadData2;
    wire [31:0] alu_result;
    wire alu_zero;

    wire [4:0] rf_rs1;
    wire [4:0] rf_rs2;
    wire [4:0] rf_rd;
    wire [3:0] alu_control;

    // =========================
    // Switch Assignments
    // =========================

    // ALU operation
    assign alu_control = switches[2:0];

    // Source registers
    assign rf_rs1 = switches[7:3];
    assign rf_rs2 = switches[12:8];

    // Destination register (limit to x0-x7)
    assign rf_rd = {2'b00, switches[15:13]};

    // =========================
    // Register File
    // =========================
    RegisterFile u_regfile (
        .clk(clk),
        .rst(1'b0),                    // no reset clearing
        .WriteEnable(write_enable),    
        .rs1(rf_rs1),
        .rs2(rf_rs2),
        .rd(rf_rd),
        .WriteData(alu_result),
        .ReadData1(rf_ReadData1),
        .ReadData2(rf_ReadData2)
    );

    // =========================
    // ALU
    // =========================
    ALU_wrapper u_alu (
        .A(rf_ReadData1),
        .B(rf_ReadData2),
        .ALUControl(alu_control),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

    // =========================
    // LEDs show ALU result
    // =========================
    assign leds = alu_result[15:0];

    // =========================
    // 7-Segment Display
    // =========================
    // Left 2 digits  = Write Data (upper byte)
    // Right 2 digits = ALU result (lower byte)

    wire [15:0] display_val;

    assign display_val[7:0]   = alu_result[7:0];      // right side
    assign display_val[15:8]  = alu_result[15:8];     // left side

    // If you instead want to show:
    // left = WriteData, right = ALU
    // change second line to:
    // assign display_val[15:8] = rf_ReadData1[7:0];

    // Refresh clock (reuse your divider)
    wire enable_refresh;

    clock_divider u_clkdiv (
        .clk(clk),
        .rst(1'b0),
        .enable_1hz(),          // unused
        .enable_refresh(enable_refresh)
    );

    seven_segment u_7seg (
        .clk(clk),
        .rst(1'b0),
        .enable_refresh(enable_refresh),
        .val(display_val),
        .seg(seg),
        .an(an)
    );

endmodule