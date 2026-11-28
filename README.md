# XLR8Thor ⚡

An RV32I RISC-V CPU written in Verilog, being built from scratch and extended
with a custom SIMD multiply-accumulate (MAC) instruction to accelerate
ML workloads on small, low-power hardware.

🚧 **Work in progress**

## Goal
Small edge devices (wearables, sensors, voice wake-word detection) need to run
ML locally, but plain microcontroller-class CPUs are slow at the core ML
operation, multiply-accumulate. XLR8Thor explores adding a small custom
instruction to a RISC-V core to speed this up, and measures the speedup
against the hardware cost.

## Progress
- [x] ALU, with a self-checking testbench
- [x] Register file
- [x] Immediate generator
- [x] Program counter (next-PC logic for branches, JAL, JALR), with testbench
- [x] Instruction memory (ROM loaded from a hex file), with testbench
- [x] Control unit (all 11 RV32I opcodes, ALU control merged in)
- [x] Branch comparator (signed and unsigned)
- [x] Data memory: word access (lw/sw)
- [ ] Data memory: byte and halfword access (lb/lh/lbu/lhu/sb/sh)
- [ ] Top-level single-cycle CPU
- [ ] Test programs for every instruction type
- [ ] Run C programs (RISC-V GCC toolchain)
- [ ] Verification against the Spike ISA simulator
- [ ] Vivado synthesis (frequency and resource usage)
- [ ] M extension (hardware multiply)
- [ ] Custom SIMD MAC instruction + benchmark

## Control unit
Decodes all 11 RV32I opcodes into the datapath control signals.
The ALU control is merged into the main control unit: it takes the opcode,
funct3 and instr[30], and outputs the 4-bit ALU operation directly.
For I-type instructions, instr[30] is forced to 0 (it is part of the
immediate), except for shift-right, where it selects SRLI vs SRAI.


## ALU
Supports all RV32I arithmetic, logic, shift, and compare operations.
Operation codes are `{instr[30], funct3}`, so the control unit can take them
straight from the instruction bits. They're defined once in `alu_defs.vh` and
shared across files.

| Code | Operation | Description |
|---|---|---|
| `0000` | ADD  | a + b |
| `1000` | SUB  | a − b |
| `0001` | SLL  | shift left logical |
| `0010` | SLT  | set if less than (signed) |
| `0011` | SLTU | set if less than (unsigned) |
| `0100` | XOR  | bitwise XOR |
| `0101` | SRL  | shift right logical |
| `1101` | SRA  | shift right arithmetic |
| `0110` | OR   | bitwise OR |
| `0111` | AND  | bitwise AND |

Shift amounts use only `b[4:0]`, as required by the RISC-V spec.

## Verification
The ALU testbench is **self-checking**: each test applies inputs, compares
the result with the expected value, and reports PASS/FAIL. The tests cover
corner cases, including:
- negative results from subtraction
- sign extension on arithmetic right shift
- signed vs unsigned comparison on the same inputs
- shift amounts greater than 31

## Repository Structure
```
rtl/                     Verilog design files
  alu.v                  ALU
  alu_defs.vh            Shared ALU operation codes
  regfile.v ?            Register file (32 x 32-bit, x0 hardwired to 0)
  imm_gen.v ?            Immediate generator (I/S/B/U/J formats)
  imm_gen_opcodes.vh     Shared RV32I opcode definitions
  pc.v                   Program counter and next-PC logic
  instruction_mem.v      Instruction memory (ROM)
  CU.v                   Control unit
  Branch_Comparator.v    Branch condition logic
  dmem.v                 Data memory (RAM)
tb/                      Testbenches
  alu_tb.v
  pc_tb.v
  imem_tb.v
programs/                Test programs (hex)
  program.hex
```

## How to Run
Requires [Icarus Verilog](http://iverilog.icarus.com/).
```bash
iverilog -I rtl -o alu_sim tb/alu_tb.v
vvp alu_sim
```
Expected output:
```
ALL ALU TESTS PASSED
```

## References
- [RISC-V Unprivileged ISA Specification](https://riscv.org/technical/specifications/)
- *Digital Design and Computer Architecture: RISC-V Edition*, Harris & Harris
