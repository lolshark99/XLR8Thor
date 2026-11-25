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
        3'b100: branch = ($signed(rs1) < $signed(rs2));
        3'b101: branch = ($signed(rs1) >= $signed(rs2));
        3'b110: branch = (rs1 < rs2);
        3'b111: branch = (rs1 >= rs2); 
        default: branch = 1'b0;
    endcase
end
endmodule