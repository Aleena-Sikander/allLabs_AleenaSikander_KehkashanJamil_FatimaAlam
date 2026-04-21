module Top_ControlPath(
    input [15:0] sw,        // 16 Switches on the FPGA
    output [15:0] led       // 16 LEDs on the FPGA
);

    // Mapping Switches to Instruction Fields
    // sw[6:0]   -> opcode
    // sw[9:7]   -> funct3
    // sw[10]    -> funct7_bit (bit 30)
    
    wire [1:0] alu_op_wire;

    // Instantiate Main Control
    MainControl main_ctrl (
        .opcode(sw[6:0]),
        .RegWrite(led[0]),
        .ALUOp(alu_op_wire),
        .MemRead(led[1]),
        .MemWrite(led[2]),
        .ALUSrc(led[3]),
        .MemtoReg(led[4]),
        .Branch(led[5])
    );

    // Instantiate ALU Control
    // We map ALUControlOut to LEDs 9 down to 6
    ALUControl alu_ctrl (
        .ALUOp(alu_op_wire),
        .funct3(sw[9:7]),
        .funct7_bit(sw[10]),
        .ALUControlOut(led[9:6])
    );

    // Optional: map ALUOp to LEDs to see internal state
    assign led[11:10] = alu_op_wire;

endmodule