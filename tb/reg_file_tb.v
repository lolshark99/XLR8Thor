`timescale 1ns/1ps
`include "reg_file.v"

module tb_reg_file;
reg tb_clk;
reg tb_we;
reg [4:0] tb_rs1 , tb_rs2 , tb_rd;
reg [31:0] tb_mess  
wire [31:0] tb_rs1_op, tb_rs2_op;
integer errors = 0;

reg_file dut(
    .clk(tb_clk),
    .we(tb_we),
    .rs1(tb_rs1),
    .rs2(tb_rs2),
    .rd(tb_rd),
    .mess(tb_mess),
    .rs1_op(tb_rs1_op),
    .rs2_op(tb_rs2_op)
);
initial tb_clk = 0; 
always #5 tb_clk = !tb_clk; // clk flips every 5ns

task write_reg;
input [4:0] addr;
input [31:0] data;
begin
    tb_rd = addr;
    tb_mess = data;
    tb_we = 1;
    @(posedge tb_clk)begin
        #1;
        tb_we = 0;
    end
end
endtask
task check_read;
input [4:0] addr;
input [31:0] expected_op;
begin
    tb_rs1 = addr;
    tb_rs2 = addr;
    #1;
    if(tb_rs1_op !== expected_op || tb_rs2_op !== expected_op)begin
        $display("FAIL: read x%0d  rs1_op=%h rs2_op=%h expected=%h",addr, tb_rs1_op, tb_rs2_op, expected_op);
        errors = errors + 1;                 
    end
end
endtask
 initial begin
        // Start with everything off
        tb_we = 0; tb_rs1 = 0; tb_rs2 = 0; tb_rd = 0; tb_mess = 0;
        #2;

        // Test 1: registers start at 0
        check_read(5'd5, 32'd0);

        // Test 2: write and read back
        write_reg(5'd5, 32'd42);
        check_read(5'd5, 32'd42);

        // Test 3: writing x0 is ignored
        write_reg(5'd0, 32'hDEADBEEF);
        check_read(5'd0, 32'd0);

        // Test 4: no write when we = 0
        tb_rd = 5'd6; tb_mess = 32'd99; tb_we = 0;
        @(posedge tb_clk); #1;
        check_read(5'd6, 32'd0);

        // Test 5: overwrite a register
        write_reg(5'd5, 32'd100);
        check_read(5'd5, 32'd100);

        // Test 6: both ports read different registers at once
        write_reg(5'd31, 32'hFFFFFFFF);
        tb_rs1 = 5'd5; tb_rs2 = 5'd31;
        #1;
        if (tb_rs1_op !== 32'd100 || tb_rs2_op !== 32'hFFFFFFFF) begin
            $display("FAIL: dual read  rs1_op=%h rs2_op=%h", tb_rs1_op, tb_rs2_op);
            errors = errors + 1;
        end

        // Test 7: the value changes only at the clock edge
        tb_rd = 5'd7; tb_mess = 32'd77; tb_we = 1;
        check_read(5'd7, 32'd0);          // before the edge: still 0
        @(posedge tb_clk); #1;
        tb_we = 0;
        check_read(5'd7, 32'd77);         // after the edge: 77

        // Result
        if (errors == 0) $display("ALL REG FILE TESTS PASSED");
        else             $display("%0d REG FILE TESTS FAILED", errors);
        $finish;
    end

endmodule