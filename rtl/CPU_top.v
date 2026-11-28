`default_nettype none

module cpu_top (
    input wire sys_clk,
    input wire sys_rst
);

    
    wire [31:0] current_pc;  // address of the instruction being run
    wire [31:0] next_seq_pc;    // current_pc + 4
    wire [31:0] fetched_instr;  // instruction read from ROM

    
    pc u_pc (
        .clk (sys_clk),
        .rst (sys_rst),
        .branch (1'b0),          
        .jal (1'b0),
        .jalr (1'b0),
        .immediate (32'b0),
        .rs1_data (32'b0),
        .pc (current_pc),
        .pc_plus4 (next_seq_pc)
    );

    
    imem u_imem (
        .addr  (current_pc),
        .instr (fetched_instr)
    );

endmodule

`default_nettype wire