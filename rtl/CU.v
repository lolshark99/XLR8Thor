`default_nettype none
`include "imm_gen_opcodes.vh"
`include "alu_defs.vh"
module Control_Unit (
    input wire [6:0] opcode, // main job of the CU is to see 
    input wire [2:0] funct3,
    input wire funct7,
    output reg reg_write,
    output reg alu_src,
    output reg [3:0] alu_ctrl,
    output reg branch
);
    always @(*) begin
        reg_write = 1'b0;
        alu_src = 1'b0;
        alu_ctrl = `ALU_ADD;
        branch = 1'b0;
    case (opcode)
        `OP_R_TYPE:begin
            reg_write = 1'b1;
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
    endcase
    end
endmodule