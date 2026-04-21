module lab10_instructionMemory#(
    parameter OPERAND_LENGTH = 31
)(
    input  wire [OPERAND_LENGTH:0] instAddress,
    output reg  [31:0]             instruction
);
    // defining memory: 256 locations, each 8 bits (1 byte) wide 
    // This gives a total of 256 bytes, which can hold 64 RISC-V instructions.
    reg [7:0] memory [0:255]; 

    // Memory is byte-addressed. We must concatenate 4 consecutive bytes.
    // RISC-V is Little-Endian, meaning the least significant byte is at the lowest address.
    always @(*) begin
        instruction = {memory[instAddress+3], 
                       memory[instAddress+2], 
                       memory[instAddress+1], 
                       memory[instAddress]};
    end
    integer i;
    initial begin
        // Clear memory first to prevent 'X' states
        
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'h00;
        end
        
        // load the assembled file
        $readmemh("E:\CA Lab\CA Lab Project\CA Lab Project.srcs\sources_1\new\machine_code.hex", memory);
    end


endmodule