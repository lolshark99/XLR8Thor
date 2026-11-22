`default_nettype none
`include "imm_gen_opcodes.vh"
`include "alu_defs.vh"
module Control_Unit (
    input  wire [6:0] opcode,     // instr[6:0]
    input  wire [2:0] funct3,     // instr[14:12]
    input  wire funct7,     // instr[30] ONLY
    output reg reg_write,  // 1 = save result into rd
    output reg alu_src,    // ALU B: 0 = rs2, 1 = imm
    output reg  [1:0] alu_a_sel,  // ALU A: 00 = rs1, 01 = PC, 10 = zero
    output reg  [3:0] alu_ctrl,   // exact ALU operation
    output reg mem_read,   // 1 = read data memory
    output reg mem_write,  // 1 = write data memory
    output reg [1:0] wb_sel,     // rd gets: 00 = ALU, 01 = memory, 10 = PC+4
    output reg branch,     // 1 = branch instruction
    output reg jal,        // 1 = JAL
    output reg jalr,       // 1 = JALR
    output reg illegal     // 1 = unknown opcode
);
    always @(*) begin
        reg_write = 1'b0;
        alu_src   = 1'b0;
        alu_a_sel = 2'b00;
        alu_ctrl  = `ALU_ADD;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        wb_sel    = 2'b00;
        branch    = 1'b0;
        jal       = 1'b0;
        jalr      = 1'b0;
        illegal   = 1'b0;
    case (opcode)
        `OP_R_TYPE:begin
            reg_write = 1'b1;
            wb_sel = 2'b00;
            alu_ctrl = {funct7 , funct3};
        end
        `OP_IMM:begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            if(funct3 == 3'b101)begin
                alu_ctrl = {funct7 , funct3};
            end
            else
            alu_ctrl = {1'b0, funct3};
        end
        `OP_BRANCH:begin
            branch = 1'b1;
        end
        `OP_STORE : begin
            mem_write = 1'b1;
            alu_src = 1'b1;
        end
        `OP_LOAD:begin
            reg_write = 1'b1;
            mem_read = 1'b1;
            alu_src = 1'b1;
            wb_sel = 2'b01;
        end
    endcase
    end
endmodule