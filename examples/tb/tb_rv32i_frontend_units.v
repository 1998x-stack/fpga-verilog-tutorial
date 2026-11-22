`timescale 1ns/1ps
module tb_rv32i_frontend_units;
    reg [31:0] instr;
    reg [2:0] imm_sel;
    wire [31:0] imm;
    reg [4:0] id_rs1, id_rs2, id_ex_rd, ex_rs1, ex_rs2, ex_mem_rd, mem_wb_rd;
    reg id_uses_rs1, id_uses_rs2, id_ex_is_load;
    reg ex_mem_regwrite, mem_wb_regwrite;
    wire [1:0] forward_a, forward_b;
    wire load_use_stall;
    integer checks = 0;

    rv32i_imm_gen imm_dut(.instr(instr), .imm_sel(imm_sel), .imm(imm));
    rv32i_hazard_unit hazard_dut(
        .id_rs1(id_rs1), .id_rs2(id_rs2),
        .id_uses_rs1(id_uses_rs1), .id_uses_rs2(id_uses_rs2),
        .id_ex_is_load(id_ex_is_load), .id_ex_rd(id_ex_rd),
        .ex_rs1(ex_rs1), .ex_rs2(ex_rs2),
        .ex_mem_regwrite(ex_mem_regwrite), .ex_mem_rd(ex_mem_rd),
        .mem_wb_regwrite(mem_wb_regwrite), .mem_wb_rd(mem_wb_rd),
        .forward_a(forward_a), .forward_b(forward_b),
        .load_use_stall(load_use_stall)
    );

    task expect_imm;
        input [2:0] sel;
        input [31:0] word;
        input [31:0] expected;
        begin
            imm_sel = sel; instr = word; #1;
            if (imm !== expected) begin
                $display("IMM FAIL sel=%0d instr=%h got=%h expected=%h",
                         sel, word, imm, expected);
                $fatal(1);
            end
            checks = checks + 1;
        end
    endtask

    task expect_forward;
        input [1:0] expected_a;
        input [1:0] expected_b;
        begin
            #1;
            if (forward_a !== expected_a || forward_b !== expected_b) begin
                $display("FWD FAIL A=%b B=%b expected A=%b B=%b",
                         forward_a, forward_b, expected_a, expected_b);
                $fatal(1);
            end
            checks = checks + 1;
        end
    endtask

    task expect_stall;
        input expected;
        begin
            #1;
            if (load_use_stall !== expected) begin
                $display("STALL FAIL got=%b expected=%b", load_use_stall, expected);
                $fatal(1);
            end
            checks = checks + 1;
        end
    endtask

    initial begin
        instr=0; imm_sel=0;
        id_rs1=0; id_rs2=0; id_ex_rd=0; ex_rs1=0; ex_rs2=0;
        ex_mem_rd=0; mem_wb_rd=0;
        id_uses_rs1=0; id_uses_rs2=0; id_ex_is_load=0;
        ex_mem_regwrite=0; mem_wb_regwrite=0;

        // ADDI x1,x0,-1; SW x2,-4(x3); BEQ x0,x0,-4;
        // LUI x1,0xABCDE; JAL x1,-4.
        expect_imm(3'd0, 32'hFFF00093, 32'hFFFF_FFFF);
        expect_imm(3'd1, 32'hFE21_AE23, 32'hFFFF_FFFC);
        expect_imm(3'd2, 32'hFE00_0E63, 32'hFFFF_FFFC);
        expect_imm(3'd3, 32'hABCDE0B7, 32'hABCDE000);
        expect_imm(3'd4, 32'hFFDFF0EF, 32'hFFFF_FFFC);
        expect_imm(3'd7, 32'hFFFF_FFFF, 32'h0000_0000);

        // EX/MEM forwarding wins over an older matching MEM/WB destination.
        ex_rs1=5'd7; ex_rs2=5'd8;
        ex_mem_regwrite=1; ex_mem_rd=5'd7;
        mem_wb_regwrite=1; mem_wb_rd=5'd7;
        expect_forward(2'b10, 2'b00);

        // MEM/WB forwarding when EX/MEM does not match.
        ex_mem_rd=5'd9; mem_wb_rd=5'd8;
        expect_forward(2'b00, 2'b01);

        // x0 never forwards, even if a write-enable is accidentally asserted.
        ex_rs1=0; ex_rs2=0; ex_mem_rd=0; mem_wb_rd=0;
        expect_forward(2'b00, 2'b00);

        // Load-use stall only if a source actually used by the ID instruction matches.
        id_ex_is_load=1; id_ex_rd=5'd5;
        id_rs1=5'd5; id_rs2=5'd9; id_uses_rs1=1; id_uses_rs2=0;
        expect_stall(1'b1);
        id_rs1=5'd1; id_rs2=5'd5; id_uses_rs1=1; id_uses_rs2=1;
        expect_stall(1'b1);
        id_rs1=5'd1; id_rs2=5'd5; id_uses_rs1=1; id_uses_rs2=0;
        expect_stall(1'b0);
        id_ex_rd=0;
        expect_stall(1'b0);

        $display("PASS tb_rv32i_frontend_units (%0d checks)", checks);
        $finish;
    end
endmodule
