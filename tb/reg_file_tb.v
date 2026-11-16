`timescale 1ns/1ps
`include "reg_file.v"

module tb_reg_file;
reg tb_clk;
reg tb_we;
reg [4:0] tb_rs1 , tb_rs2 , tb_rd;
reg [31:0] tb_mess , tb_rs1_op ,tb_rs2_op; 
//reg [31:0]
integer errors = 0;

reg_file dut(
    .clk(tb_clk),
    .we(tb_we),
    .rs1(tb_rs1),
    .rs2(tb_rs2),
    .rd(tb_rd),
    .mess(tb_mess),
    .rs1_op(tb_rs1_op),
    .rs2_op(tb_rs2_op),
);


endmodule