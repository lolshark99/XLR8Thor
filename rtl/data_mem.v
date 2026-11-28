`default_nettype none
module dmem (
    input wire clk,
    input wire write_per, //permissionb to write
    input wire read_per,
    input wire [31:0] address ,
    input wire  [31:0] write_data,
    output wire [31:0] read_data
);
reg [31:0] mem [0:255];
    always@(posedge clk)begin
        if(write_per)begin
            mem[address[9:2]] <= write_data;
        end
    end
    assign read_data = read_per ? mem[address[9:2]] : 32'b0;
endmodule
`default_nettype wire