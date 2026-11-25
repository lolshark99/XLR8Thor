module Jump_Comparator (
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [2:0] funct3,
    output reg cond_true;
);
always @(*) begin
    case (funct3)
        //default:
        3'b000: cond_true = (rs1 == rs2); 
        3'b001: cond_true = (rs1 != rs2);
        3'b100: cond_true = ($signed(rs1) < $signed(rs2));
        3'b101: cond_true = ($signed(rs1) >= $signed(rs2));
        3'b110: cond_true = (rs1 < rs2);
        3'b111: cond_true = (rs1 >= rs2); 
        default: cond_true = 1'b0;
    endcase
end
endmodule