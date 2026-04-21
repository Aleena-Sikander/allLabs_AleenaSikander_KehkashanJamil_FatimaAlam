`timescale 1ns/1ps
module tb_Task1;
    reg clk, rst, PCWrite, PCSrc;
    reg [31:0] ins;

    wire [31:0] curr_pc, pc_p4, br_target, nxt_pc, imm_out;

    reg  [1:0]  immType;

    ProgramCounter DUT_PC (clk, rst, nxt_pc, PCWrite, curr_pc);
    pcAdder DUT_PCA (curr_pc,pc_p4);
    branchAdder DUT_BA (curr_pc,imm_out,br_target);
    mux2 DUT_MUX (pc_p4,br_target,PCSrc,nxt_pc);
    immGen DUT_IG (instruction,immType,imm_out);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        // Reset
        rst = 1; PCWrite = 1; PCSrc = 0;
        instruction = 32'b0; immType = 2'b00;
        #12; rst = 0;

        //Test 1: sequential PC increment (PCSrc=0)
        //PC steps: 0->4->8->12->16->20
        PCSrc = 0;
        instruction = 32'h00000013; // NOP
        immType = 2'b00;
        repeat(5) @(posedge clk); #1;

        // Test 2: branch taken (PCSrc=1)
        // BEQ with B-type imm = +8
        instruction = 32'b0_000000_00000_00001_000_0100_0_1100011;
        immType = 2'b10;
        PCSrc = 1;
        @(posedge clk); #1;

        // Test 3: back to sequential
        PCSrc = 0;
        repeat(3) @(posedge clk); #1;

        // Test 4: immGen I-type positive  ADDI x1,x0,15
        instruction = 32'b000000001111_00000_000_00001_0010011;
        immType = 2'b00; #2;

        // Test 5: immGen I-type negative  ADDI x2,x1,-4
        instruction = 32'b111111111100_00001_000_00010_0010011;
        immType = 2'b00; #2;

        // Test 6: immGen S-type  SW x2,12(x1)
        // imm=12: s_hi=0000000, s_lo=01100
        instruction = 32'b0000000_00010_00001_010_01100_0100011;
        immType = 2'b01; #2;

        // Test 7: immGen B-type  BEQ with negative offset=-8
        instruction = 32'b1_111111_00000_00001_000_1100_1_1100011;
        immType = 2'b10; #2;

        // Test 8: immGen I-type  LW x1,8(x2)
        instruction = 32'b000000001000_00010_010_00001_0000011;
        immType = 2'b00; #2;

        $finish;
    end

endmodule