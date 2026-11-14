module reg_fie (
    input wire clk,
    input wire we, // simple enable pin
    input wire[4:0] rs1,  // 5 bits so we have 32 regs 
    input wire[4:0] rs2, // 5 bits so we have 32 regs 
    input wire[4:0] rd, // address of the reg wjere we have written things
    input wire[31:0] mess, // message , data that is written
    input wire[31:0] rs1_op, // final syate of reg1 
    input wire[31:0] rs2_op // final stage of reg2
);
reg [31:0] regis [0:31];
integer i;
initial begin
    for(i = 0 ; i < 32 ; i = i +1)
        reg[i] = 32'd0; // preventing reading garbage
end
always @(posedge clk) begin
    if(we && (!rd == 5'd0))begin
        reg[rd] <= mess;
    end
end
assign rs1_op = (rs1_op == 5'd0) ? 32'd0 : regs[rs1_op];
assign rs2_op = (rs2_op == 5'd0) ? 32'd0 : regs[rs2_op];
endmodule