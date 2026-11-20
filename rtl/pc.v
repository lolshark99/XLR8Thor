`default_nettype none
module pc (
    input wire clk,
    input wire rst,
    input wire branch,
    input wire jal,
    input wire jalr,
    input wire [31:0] immediate,
    input wire [31:0] rs1_data,
    output reg [31:0] pc,
    output wire [31:0] pc_plus4
);  
wire [31:0] pc_target;
wire [31:0] pc_jarl;
wire [31:0] pc_now; // final addres in the pc

assign pc_target = pc + immediate;
assign pc_plus4 = pc + 32'd4;
assign pc_jarl = (rs1_data + immediate) & ~32'd1;

assign pc_now = jalr ? pc_jarl : (jal | branch) ? pc_target : pc_plus4;
always @(posedge clk) begin
    if(rst)begin
        pc <= 0;
    end
    else begin
        pc <= pc_now;
    end
end
endmodule
`default_nettype wire