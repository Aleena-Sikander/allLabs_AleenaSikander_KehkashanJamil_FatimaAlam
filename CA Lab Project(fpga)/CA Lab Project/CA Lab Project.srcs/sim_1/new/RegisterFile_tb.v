`timescale 1ns / 1ps

module RegisterFile_tb();
    reg clk, rst, WriteEnable;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;

    // Instantiate UUT
    RegisterFile uut (
        .clk(clk), .rst(rst), .WriteEnable(WriteEnable),
        .rs1(rs1), .rs2(rs2), .rd(rd), .WriteData(WriteData),
        .ReadData1(ReadData1), .ReadData2(ReadData2)
    );

    always #5 clk = ~clk; // 100MHz clock

    initial begin
        clk = 0; rst = 1; WriteEnable = 0;
        rs1 = 0; rs2 = 0; rd = 0; WriteData = 0;
        #15 rst = 0;

        // Test Case 1: Write to x5 and verify [cite: 38]
        @(posedge clk);
        WriteEnable = 1; rd = 5'd5; WriteData = 32'hDEADBEEF;
        @(posedge clk);
        WriteEnable = 0; rs1 = 5'd5;
        #5;
        if (ReadData1 === 32'hDEADBEEF) $display("Pass: x5 written correctly");
        else $display("Fail: x5 expected DEADBEEF, got %h", ReadData1);

        // Test Case 2: Attempt write to x0 [cite: 39]
        @(posedge clk);
        WriteEnable = 1; rd = 5'd0; WriteData = 32'hFFFFFFFF;
        @(posedge clk);
        WriteEnable = 0; rs2 = 5'd0;
        #5;
        if (ReadData2 === 32'h0) $display("Pass: x0 remains zero");
        else $display("Fail: x0 was overwritten!");

        // Test Case 3: Dual Read [cite: 40]
        @(posedge clk);
        WriteEnable = 1; rd = 5'd10; WriteData = 32'h12345678;
        @(posedge clk);
        WriteEnable = 0; rs1 = 5'd5; rs2 = 5'd10;
        #5;
        $display("Dual Read: rs1=%h, rs2=%h", ReadData1, ReadData2);

        #20 $finish;
    end
endmodule