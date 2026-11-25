module Jump_Comparator (
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [2:0] funct3,
    output reg branch
);
always @(*) begin
    case (funct3)
        3'b000: branch = (rs1 == rs2); 
        //default:
        3'b001: branch = (rs1 != rs2);
        3'b010: branch = 
    endcase
end
endmodule