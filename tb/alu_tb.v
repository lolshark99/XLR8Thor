`timescale 1ns/1ps
`include "alu_defs.vh"
`include "alu.v"
module tb_alu;

    // Testbench signals
    reg  [31:0] tb_a, tb_b;
    reg  [3:0]  tb_sel;
    wire [31:0] tb_res;
    wire        tb_zero;
    integer     errors = 0;

    // Connect the ALU:  .alu_port(testbench_signal)
    ALU dut (
        .a       (tb_a),
        .b       (tb_b),
        .opr_sel (tb_sel),
        .res     (tb_res),
        .zero    (tb_zero)
    );

    task check;
        input [3:0]  op;
        input [31:0] x;
        input [31:0] y;
        input [31:0] expected;
        begin
            tb_sel = op;
            tb_a   = x;
            tb_b   = y;
            #1;
            if (tb_res !== expected) begin
                $display("FAIL: op=%b a=%h b=%h got=%h expected=%h",
                         op, x, y, tb_res, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        check(`ALU_ADD,  32'd5,        32'd3,        32'd8);
        check(`ALU_SUB,  32'd5,        32'd3,        32'd2);
        check(`ALU_SUB,  32'd3,        32'd5,        32'hFFFFFFFE);  // -2
        check(`ALU_AND,  32'hF0F0F0F0, 32'hFF00FF00, 32'hF000F000);
        check(`ALU_OR,   32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF);
        check(`ALU_XOR,  32'hFFFF0000, 32'hFF00FF00, 32'h00FFFF00);
        check(`ALU_SLL,  32'd1,        32'd4,        32'd16);
        check(`ALU_SRL,  32'h80000000, 32'd4,        32'h08000000);
        check(`ALU_SRA,  32'h80000000, 32'd4,        32'hF8000000);
        check(`ALU_SLT,  32'hFFFFFFFF, 32'd1,        32'd1);         // -1 < 1
        check(`ALU_SLTU, 32'hFFFFFFFF, 32'd1,        32'd0);
        check(`ALU_SLL,  32'd1,        32'd33,       32'd2);         // uses b[4:0]

        if (errors == 0) $display("ALL ALU TESTS PASSED");
        else             $display("%0d ALU TESTS FAILED", errors);
        $finish;
    end

endmodule