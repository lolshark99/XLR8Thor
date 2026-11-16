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
- [ ] Immediate generator
- [ ] Control unit
- [ ] Branch unit
- [ ] Instruction and data memory
- [ ] Top-level single-cycle CPU
- [ ] Run C programs (RISC-V GCC toolchain)
- [ ] Verification against the Spike ISA simulator
- [ ] Vivado synthesis (frequency and resource usage)
- [ ] M extension (hardware multiply)
- [ ] Custom SIMD MAC instruction + benchmark

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
rtl/              Verilog design files
  alu.v           ALU
  alu_defs.vh     Shared ALU operation codes
tb/               Testbenches
  alu_tb.v        ALU self-checking testbench
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
