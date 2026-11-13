`include "alu_defs.vh"
module ALU (
    input  wire [31:0] a,        // 32-bit operand a
    input  wire [31:0] b,        // 32-bit operand b
    input  wire [3:0]  opr_sel,  // operation select
    output reg  [31:0] res,
    output wire zero
);
    always @(*) begin
        case (opr_sel)
            `ALU_ADD  : res = a + b;
            `ALU_SUB  : res = a - b;
            `ALU_SLL  : res = a << b[4:0];
            `ALU_SLT  : res = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLTU : res = (a < b) ? 32'd1 : 32'd0;
            `ALU_XOR  : res = a ^ b;
            `ALU_SRL  : res = a >> b[4:0];
            `ALU_SRA  : res = $signed(a) >>> b[4:0];
            `ALU_OR   : res = a | b;
            `ALU_AND  : res = a & b;
            default   : res = 32'd0;
        endcase
    end
    assign zero = (res == 32'd0);

endmodule