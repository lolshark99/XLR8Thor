`timescale 1ns/1ps
`default_nettype none

// Instruction memory (ROM) for a single-cycle RV32I CPU
// - Loaded from a hex file at the start of simulation
// - Combinational read: the instruction appears as soon as the address changes
module imem #(
    parameter DEPTH    = 256,                    // number of 32-bit instructions
    parameter MEM_FILE = "programs/program.hex"  // program to load
) (
    input  wire [31:0] addr,     // byte address, from the PC
    output wire [31:0] instr     // instruction at that address
);

    reg [31:0] mem [0:DEPTH-1];  // DEPTH slots, each 32 bits wide

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    // addr is a BYTE address, but each slot holds 4 bytes,
    // so drop the lowest 2 bits (divide by 4) to get the slot number.
    assign instr = mem[addr[$clog2(DEPTH)+1:2]];

endmodule

`default_nettype wire