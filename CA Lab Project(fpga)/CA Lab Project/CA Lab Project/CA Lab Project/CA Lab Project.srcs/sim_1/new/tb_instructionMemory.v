`timescale 1ns / 1ps

module tb_instructionMemory;
    reg  [31:0] pc;
    wire [31:0] instr;
    instructionMemory uut (
        .instAddress(pc),
        .instruction(instr)
    );

    initial begin
        $display("Addr  | Instruction | Expected label");
        $display("------+-------------+----------------");
        pc = 0;   #10; $display("0x%02h  | 0x%08h  | li   t0, 0x200      (inputWait)", pc, instr);
        pc = 4;   #10; $display("0x%02h  | 0x%08h  | lw   t1, 0(t0)", pc, instr);
        pc = 8;   #10; $display("0x%02h  | 0x%08h  | beq  t1, zero, inputWait", pc, instr);
        pc = 12;  #10; $display("0x%02h  | 0x%08h  | mv   a0, t1", pc, instr);
        pc = 16;  #10; $display("0x%02h  | 0x%08h  | jal  ra, countdown", pc, instr);
        pc = 20;  #10; $display("0x%02h  | 0x%08h  | j    inputWait", pc, instr);
        
        pc = 24;  #10; $display("0x%02h  | 0x%08h  | addi sp, sp, -8     (countdown)", pc, instr);
        pc = 28;  #10; $display("0x%02h  | 0x%08h  | sw   ra, 4(sp)", pc, instr);
        pc = 32;  #10; $display("0x%02h  | 0x%08h  | sw   s0, 0(sp)", pc, instr);
        pc = 36;  #10; $display("0x%02h  | 0x%08h  | mv   s0, a0", pc, instr);
        pc = 40;  #10; $display("0x%02h  | 0x%08h  | li   t0, 0x100", pc, instr);
        
        pc = 44;  #10; $display("0x%02h  | 0x%08h  | sw   s0, 0(t0)      (update_led)", pc, instr);
        pc = 48;  #10; $display("0x%02h  | 0x%08h  | li   t2, 0x200", pc, instr);
        pc = 52;  #10; $display("0x%02h  | 0x%08h  | lw   s1, 0(t2)", pc, instr);
        pc = 56;  #10; $display("0x%02h  | 0x%08h  | bne  s1, zero, handle_reset", pc, instr);
        pc = 60;  #10; $display("0x%02h  | 0x%08h  | lui  t3, 488", pc, instr);
        pc = 64;  #10; $display("0x%02h  | 0x%08h  | addi t3, t3, 1152", pc, instr);
        
        pc = 68;  #10; $display("0x%02h  | 0x%08h  | addi t3, t3, -1     (delay_loop)", pc, instr);
        pc = 72;  #10; $display("0x%02h  | 0x%08h  | bne  t3, zero, delay_loop", pc, instr);
        
        pc = 76;  #10; $display("0x%02h  | 0x%08h  | addi s0, s0, -1", pc, instr);
        pc = 80;  #10; $display("0x%02h  | 0x%08h  | bge  s0, zero, update_led", pc, instr);
        
        pc = 100; #10; $display("0x%02h  | 0x%08h  | sw   zero, 0(t0)    (handle_reset)", pc, instr);
        pc = 116; #10; $display("0x%02h  | 0x%08h  | j    inputWait", pc, instr);
        $finish;
    end
endmodule