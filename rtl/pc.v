module pc (
    input wire clk;
    input wire rst;
    input wire branch;
    input wire Jal;
    input wire Jalr;
    input wire [31:0] immediate;
    input wire [31:0] rs_1_data;
    output reg [31:0] pc;
    output wire [31:0] pc_plus4;
);  
wire [31:0] pc_target;
wire [31:0] pc_jarl;
wire [31:0] pc_now; // final addres in the pc

assign pc_target = pc + immediate;
assign pc_plus4 = pc + 32'd4;
assign jalr_target = (rs1_data + imm) & ~32'd1;

endmodule