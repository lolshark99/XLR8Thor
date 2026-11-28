`timescale 1ns/1ps

module cpu_top_tb;

    reg tb_clk = 0;
    reg tb_rst = 1;

    cpu_top dut (
        .sys_clk (tb_clk),
        .sys_rst (tb_rst)
    );

    always #5 tb_clk = ~tb_clk;

    initial begin
        @(posedge tb_clk); #1;
        tb_rst = 0;

        repeat (6) begin
            $display("PC=%h instr=%h | A=%0d B=%0d | ALU=%0d | x1=%0d x2=%0d x3=%0d",
                     dut.current_pc, dut.fetched_instr,
                     dut.alu_in_a, dut.alu_in_b, dut.alu_out,
                     dut.u_rf.regis[1], dut.u_rf.regis[2], dut.u_rf.regis[3]);
            @(posedge tb_clk); #1;
        end
        $finish;
    end

endmodule