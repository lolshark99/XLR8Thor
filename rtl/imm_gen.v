`include "opcodes.vh"          // gives us names like `OP_IMM instead of 7'b0010011

module imm_gen (
    input  wire [31:0] instr,  // IN:  the full 32-bit instruction
    output reg  [31:0] imm     // OUT: the finished 32-bit number
);

    // STEP 1: check what type of instruction this is
    wire [6:0] opcode = instr[6:0];        // the lowest 7 bits = instruction type

    always @(*) begin                       // recompute whenever instr changes
        case (opcode)

            // STEPS 2–4 for each type: pick the bits, order them, sign-extend

            // I-type (addi, lw, jalr): number is in one piece, bits 31–20
            `OP_IMM, `OP_LOAD, `OP_JALR:
                imm = { {20{instr[31]}},   // sign extension: bit 31 copied 20 times
                        instr[31:20] };    // the 12-bit number

            // S-type (sw): number split in 2 pieces
            `OP_STORE:
                imm = { {20{instr[31]}},
                        instr[31:25],      // top 7 bits of the number
                        instr[11:7] };     // bottom 5 bits of the number

            // B-type (beq, bne): number split in 4 pieces, last bit always 0
            `OP_BRANCH:
                imm = { {19{instr[31]}},
                        instr[31], instr[7], instr[30:25], instr[11:8],
                        1'b0 };            // branch targets are always even

            // U-type (lui, auipc): top 20 bits, bottom 12 bits are zero
            `OP_LUI, `OP_AUIPC:
                imm = { instr[31:12],
                        12'b0 };

            // J-type (jal): number split in 4 pieces, last bit always 0
            `OP_JAL:
                imm = { {11{instr[31]}},
                        instr[31], instr[19:12], instr[20], instr[30:21],
                        1'b0 };

            // anything else (like add, which has no number): output 0
            default:
                imm = 32'd0;

        endcase
    end

endmodule