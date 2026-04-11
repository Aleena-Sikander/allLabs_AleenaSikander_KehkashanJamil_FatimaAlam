module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  wire [OPERAND_LENGTH:0] instAddress,
    output reg  [31:0]             instruction
);
    
    // Using 32-bit wide memory to match your hex file
    reg [31:0] memory [0:63]; 
    integer i;

    always @(*) begin
        // Convert byte address to word index (0, 4, 8 -> 0, 1, 2)
        instruction = memory[instAddress >> 2];
    end

    initial begin
        for (i = 0; i < 64; i = i + 1)
        memory[i] = 32'h00000000;

    $display("Loading memory from file...");
    $readmemh("l10.hex", memory);

    $display("First few memory values:");
    for (i = 0; i < 10; i = i + 1)
        $display("mem[%0d] = %h", i, memory[i]);
    end                       
endmodule