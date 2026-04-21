`timescale 1ns / 1ps

module tb_ControlUnit;

    // Inputs to the Modules
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg funct7_bit;
    reg [1:0] ALUOp_wire; // Internal connection simulation

    // Outputs from Main Control
    wire RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch;
    wire [1:0] ALUOp;

    // Outputs from ALU Control
    wire [3:0] ALUControlOut;

    // Instantiate Main Control Unit
    MainControl uut_main (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch)
    );

    // Instantiate ALU Control Unit
    ALUControl uut_alu (
        .ALUOp(ALUOp), // Connected directly to Main Control output
        .funct3(funct3),
        .funct7_bit(funct7_bit),
        .ALUControlOut(ALUControlOut)
    );

    initial begin
        // Initialize Inputs
        opcode = 0; funct3 = 0; funct7_bit = 0;

        $display("Starting Simulation...");
        $monitor("Time=%0t | Op=%b | ALUControl=%b | RegW=%b | ALUSrc=%b", 
                 $time, opcode, ALUControlOut, RegWrite, ALUSrc);

        // --- Test 1: R-type ADD ---
        opcode = 7'b0110011; funct3 = 3'b000; funct7_bit = 0;
        #10;

        // --- Test 2: R-type SUB ---
        opcode = 7'b0110011; funct3 = 3'b000; funct7_bit = 1;
        #10;

        // --- Test 3: I-type ADDI ---
        opcode = 7'b0010011; funct3 = 3'b000; funct7_bit = 0;
        #10;

        // --- Test 4: Load Word (LW) ---
        opcode = 7'b0000011; funct3 = 3'b010; funct7_bit = 0;
        #10;

        // --- Test 5: Store Word (SW) ---
        opcode = 7'b0100011; funct3 = 3'b010; funct7_bit = 0;
        #10;

        // --- Test 6: Branch Equal (BEQ) ---
        opcode = 7'b1100011; funct3 = 3'b000; funct7_bit = 0;
        #10;

        // --- Test 7: R-type XOR ---
        opcode = 7'b0110011; funct3 = 3'b100; funct7_bit = 0;
        #10;

        $display("Simulation Finished.");
        $finish;
    end
endmodule