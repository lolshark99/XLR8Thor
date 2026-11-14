module reg_file (
    input wire clk,
    input wire we, // simple enable pin
    input wire[4:0] rs1,  // 5 bits as we have 32 regs 
    input wire[4:0] rs2, // 5 bits as we have 32 regs 
    input wire[4:0] rd, // address of the reg where we have written data
    input wire[31:0] mess, // message , data that is written
    output wire[31:0] rs1_op, // final state of reg1 that is read
    output wire[31:0] rs2_op // final stage of reg2 that is read 
);
reg [31:0] regis [0:31]; // meaning 32 bit sized 32 regis
integer i; 
initial begin
    for(i = 0 ; i < 32 ; i = i +1)
        regis[i] = 32'd0; // preventing reading garbage values
end
always @(posedge clk) begin
    if(we && (rd != 5'd0))begin
        regis[rd] <= mess;
    end
end
assign rs1_op = (rs1 == 5'd0) ? 32'd0 : regis[rs1];
assign rs2_op = (rs2 == 5'd0) ? 32'd0 : regis[rs2];
endmodule