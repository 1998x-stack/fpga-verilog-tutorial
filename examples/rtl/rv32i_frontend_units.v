// Small RV32I front-end helpers used to teach immediate decoding and hazards.
// This file is NOT a complete processor implementation.
module rv32i_imm_gen (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_sel,
    output reg  [31:0] imm
);
    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    always @* begin
        case (imm_sel)
            IMM_I: imm = {{20{instr[31]}}, instr[31:20]};
            IMM_S: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            IMM_B: imm = {{19{instr[31]}}, instr[31], instr[7],
                          instr[30:25], instr[11:8], 1'b0};
            IMM_U: imm = {instr[31:12], 12'b0};
            IMM_J: imm = {{11{instr[31]}}, instr[31], instr[19:12],
                          instr[20], instr[30:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end
endmodule

module rv32i_hazard_unit (
    input  wire [4:0] id_rs1,
    input  wire [4:0] id_rs2,
    input  wire       id_uses_rs1,
    input  wire       id_uses_rs2,
    input  wire       id_ex_is_load,
    input  wire [4:0] id_ex_rd,
    input  wire [4:0] ex_rs1,
    input  wire [4:0] ex_rs2,
    input  wire       ex_mem_regwrite,
    input  wire       ex_mem_is_load,
    input  wire [4:0] ex_mem_rd,
    input  wire       mem_wb_regwrite,
    input  wire [4:0] mem_wb_rd,
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b,
    output wire       load_use_stall
);
    // 00: register-file value; 10: EX/MEM; 01: MEM/WB.
    // EX/MEM has priority when both pipeline stages match the same source.
    always @* begin
        forward_a = 2'b00;
        if (ex_mem_regwrite && !ex_mem_is_load && (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == ex_rs1))
            forward_a = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == ex_rs1))
            forward_a = 2'b01;

        forward_b = 2'b00;
        if (ex_mem_regwrite && (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == ex_rs2))
            forward_b = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == ex_rs2))
            forward_b = 2'b01;
    end

    // A load value is not available from EX/MEM in the following cycle.
    // Freeze IF/ID and inject a bubble into ID/EX when a used source matches.
    assign load_use_stall = id_ex_is_load && (id_ex_rd != 5'd0) &&
        ((id_uses_rs1 && (id_rs1 == id_ex_rd)) ||
         (id_uses_rs2 && (id_rs2 == id_ex_rd)));
endmodule
