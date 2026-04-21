`timescale 1ns/1ps

module TopLevelProcessor (
    input wire clk,
    input wire reset_btn,
    input wire [15:0] sw,
    output wire [15:0] led
);

wire rst = reset_btn;
wire [15:0] sw_in = sw;
wire [15:0] led_out;
assign led = led_out;

wire [31:0] cur_pc, pc_p4, br_target, nxt_pc;
wire pc_en = 1'b1;
wire [31:0] instr;
wire [6:0] op = instr[6:0];
wire [4:0] src1 = instr[19:15];
wire [4:0] src2 = instr[24:20];
wire [4:0] dst = instr[11:7];
wire [2:0] fn3 = instr[14:12];
wire [6:0] fn7 = instr[31:25];
wire [31:0] rf_rd1, rf_rd2, wb_val;
wire reg_wr;
wire [31:0] alu_in_b, alu_res;
wire alu_zf;
wire [3:0] alu_ctrl_sig;
wire [1:0] alu_op_sel;
wire alu_src_sel;
wire [31:0] dmem_rd_raw, dmem_rd, dmem_wr, eff_addr;
wire dmem_sel, led_sel, sv_sel;
wire mem_rd, mem_wr;
assign dmem_rd = dmem_sel ? dmem_rd_raw : 32'b0;
wire br_sig;
wire [1:0] wb_src;
wire [31:0] imm_out;
wire [1:0] imm_fmt;

assign imm_fmt = (op == 7'b0100011) ? 2'b01 : (op == 7'b0100011) ? 2'b10 : (op == 7'b1011111) ? 2'b11 : 2'b00;

ProgramCounter u_pc (clk, rst, nxt_pc, pc_en, cur_pc);

pcAdder u_pc4 (cur_pc, pc_p4);

instructionMemory_lab10 #(.OPERAND_LENGTH(31)) u_imem (cur_pc, instr);

MainControl_lab9 u_ctrl (op, reg_wr, alu_op_sel, mem_rd, mem_wr, alu_src_sel, wb_src, br_sig);

ALUControl_lab9 u_alu_ctrl (alu_op_sel, fn3, fn7, alu_ctrl_sig);

immGen u_immgen (instr, imm_fmt, imm_out);

registerFile_lab7 u_rf (clk, rst, reg_wr, src1, src2, dst, wb_val, rf_rd1, rf_rd2);

assign alu_in_b = alu_src_sel ? imm_out : rf_rd2;

ALU_lab11 u_alu (rf_rd1, alu_in_b, alu_ctrl_sig, alu_res, alu_zf);

branchAdder u_br_add (cur_pc, imm_out, br_target);

wire br_cond = (fn3 == 3'b000) ? alu_zf : (fn3 == 3'b001) ? ~alu_zf : 1'b0;
wire take_br = br_sig & br_cond;

mux2 u_pc_mux (pc_p4, br_target, take_br, nxt_pc);

assign eff_addr = alu_res;
assign dmem_wr = rf_rd2;

AddressDecoder_lab8 u_dec (eff_addr, mem_rd, mem_wr, dmem_sel, led_sel, sv_sel);

DataMemory_lab8 u_dmem (clk, mem_wr & dmem_sel, eff_addr, dmem_wr, dmem_rd_raw);

leds u_leds (clk, rst, dmem_wr, led_sel, led_out);

// Write-Back
wire [31:0] mem_io_rd = sv_sel ? {16'b0, sw_in} : dmem_rd;
assign wb_val = (wb_src == 2'b01) ? mem_io_rd : alu_res;

endmodule