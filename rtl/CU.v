module Control_Unit (
    input wire [6:0] opcode,
    output wire result
);
    always@(*)begin
        case (opcode)
            : 
            default: res = 0;
        endcase
    end
endmodule