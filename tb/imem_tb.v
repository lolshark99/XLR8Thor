`timescale 1ns/1ps

module imem_tb;

    reg  [31:0] test_address;      // testbench's own signal
    wire [31:0] fetched_instr;     // testbench's own signal
    integer errors = 0;

    imem dut (
        .addr  (test_address),     // module port "addr"  ← connected to → test_address
        .instr (fetched_instr)     // module port "instr" ← connected to → fetched_instr
    );

    task check(input [31:0] a, input [31:0] expected);
        begin
            test_address = a; #1;
            if (fetched_instr !== expected) begin
                $display("FAIL addr %h: got %h, expected %h", a, fetched_instr, expected);
                errors = errors + 1;
            end else
                $display("PASS addr %h: %h", a, fetched_instr);
        end
    endtask

    initial begin
        check(32'h00, 32'h00500093);   // addi x1, x0, 5
        check(32'h04, 32'h00500113);   // addi x2, x0, 5
        check(32'h08, 32'h00208463);   // beq  x1, x2, +8
        check(32'h0C, 32'h00100193);   // addi x3, x0, 1
        check(32'h10, 32'h00000013);   // nop

        if (errors == 0) $display("\n*** ALL TESTS PASSED ***");
        else             $display("\n*** %0d TEST(S) FAILED ***", errors);
        $finish;
    end

endmodule