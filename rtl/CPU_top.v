`default_nettype none

module cpu_top (
    input wire sys_clk,
    input wire sys_rst
);

    // ================= FETCH =================
    wire [31:0] current_pc;      // address of the instruction being run
    wire [31:0] next_seq_pc;     // current_pc + 4
    wire [31:0] fetched_instr;   // instruction read from ROM

    pc u_pc (
        .clk       (sys_clk),
        .rst       (sys_rst),
        .branch    (1'b0),          // TEMPORARY: connected in Step 5
        .jal       (1'b0),          // TEMPORARY: connected in Step 5
        .jalr      (1'b0),          // TEMPORARY: connected in Step 5
        .immediate (32'b0),         // TEMPORARY: connected in Step 5
        .rs1_data  (32'b0),         // TEMPORARY: connected in Step 5
        .pc        (current_pc),
        .pc_plus4  (next_seq_pc)
    );

    imem u_imem (
        .addr  (current_pc),
        .instr (fetched_instr)
    );

    // ================= DECODE =================
    // --- slice the instruction into its fields ---
    wire [6:0] instr_opcode = fetched_instr[6:0];
    wire [4:0] instr_rd     = fetched_instr[11:7];
    wire [2:0] instr_funct3 = fetched_instr[14:12];
    wire [4:0] instr_rs1    = fetched_instr[19:15];
    wire [4:0] instr_rs2    = fetched_instr[24:20];
    wire       instr_bit30  = fetched_instr[30];

    // --- control unit ---
    wire       ctrl_reg_write;
    wire       ctrl_alu_src;
    wire [1:0] ctrl_alu_a_sel;
    wire [3:0] ctrl_alu_ctrl;
    wire       ctrl_mem_read;
    wire       ctrl_mem_write;
    wire [1:0] ctrl_wb_sel;
    wire       ctrl_branch;
    wire       ctrl_jal;
    wire       ctrl_jalr;
    wire       ctrl_illegal;

    Control_Unit u_cu (
        .opcode    (instr_opcode),
        .funct3    (instr_funct3),
        .funct7    (instr_bit30),
        .reg_write (ctrl_reg_write),
        .alu_src   (ctrl_alu_src),
        .alu_a_sel (ctrl_alu_a_sel),
        .alu_ctrl  (ctrl_alu_ctrl),
        .mem_read  (ctrl_mem_read),
        .mem_write (ctrl_mem_write),
        .wb_sel    (ctrl_wb_sel),
        .branch    (ctrl_branch),
        .jal       (ctrl_jal),
        .jalr      (ctrl_jalr),
        .illegal   (ctrl_illegal)
    );

    // --- immediate generator ---
    wire [31:0] imm_value;

    imm_gen u_imm (
        .instr (fetched_instr),
        .imm   (imm_value)
    );

    // --- register file ---
    wire [31:0] reg_read1;
    wire [31:0] reg_read2;
    reg  [31:0] wb_data;         // value to save into rd (from the WB mux)

    reg_file u_rf (
        .clk    (sys_clk),
        .we     (ctrl_reg_write),   // whether to save
        .rs1    (instr_rs1),
        .rs2    (instr_rs2),
        .rd     (instr_rd),         // which register to save into
        .mess   (wb_data),          // what to save
        .rs1_op (reg_read1),
        .rs2_op (reg_read2)
    );

    // ================= EXECUTE =================
    // --- MUX A: picks the ALU's first input ---
    reg [31:0] alu_in_a;

    always @(*) begin
        case (ctrl_alu_a_sel)
            2'b00:   alu_in_a = reg_read1;     // rs1 (normal)
            2'b01:   alu_in_a = current_pc;    // PC  (AUIPC)
            2'b10:   alu_in_a = 32'b0;         // 0   (LUI)
            default: alu_in_a = reg_read1;
        endcase
    end

    // --- MUX B: picks the ALU's second input ---
    wire [31:0] alu_in_b = ctrl_alu_src ? imm_value : reg_read2;

    // --- ALU ---
    wire [31:0] alu_out;
    wire        alu_is_zero;

    ALU u_alu (
        .a       (alu_in_a),
        .b       (alu_in_b),
        .opr_sel (ctrl_alu_ctrl),
        .res     (alu_out),
        .zero    (alu_is_zero)
    );

    // ================= WRITE-BACK =================
    // --- WB MUX: picks what gets saved into rd ---
    always @(*) begin
        case (ctrl_wb_sel)
            2'b00:   wb_data = alu_out;        // ALU result
            2'b01:   wb_data = 32'b0;          // TEMPORARY: memory data (Step 5)
            2'b10:   wb_data = next_seq_pc;    // PC + 4 (JAL / JALR)
            default: wb_data = 32'b0;
        endcase
    end

endmodule

`default_nettype wire