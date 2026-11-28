`default_nettype none
`include "imm_gen_opcodes.vh"
`include "alu_defs.vh"
module Control_Unit (
    input  wire [6:0] opcode,     
    input  wire [2:0] funct3,     
    input  wire funct7,     
    output reg reg_write,  
    output reg alu_src,    // ALU B: 0 = rs2, 1 = imm
    output reg  [1:0] alu_a_sel,  
    output reg  [3:0] alu_ctrl,   
    output reg mem_read,   
    output reg mem_write,  
    output reg [1:0] wb_sel,     // what data gets stored in the rd 00 -> Simple ALU , 01 -> load ,01 -> PC + 4 for jump 
    output reg branch,     
    output reg jal,        
    output reg jalr,      
    output reg illegal     
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
        `OP_LUI:begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_a_sel = 2'b10;
        end
        `OP_AUIPC:begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_a_sel = 2'b01;
        end
        `OP_JAL: begin             // save checkpoint, jump
            reg_write = 1'b1;
            wb_sel    = 2'b10;     // rd gets PC+4
            jal       = 1'b1;
        end
        `OP_JALR: begin            // save checkpoint, jump to rs1 + imm
            reg_write = 1'b1;
            wb_sel    = 2'b10;
            jalr      = 1'b1;
        end
        `OP_FENCE, `OP_SYSTEM: ;
        default: illegal = 1'b1;
        endcase
    end
endmodule