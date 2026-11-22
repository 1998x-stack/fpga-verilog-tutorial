// Exhaustive 16 x 16 x 4 self-check against independent expressions.
module tb_alu4;
    reg [3:0] a, b;
    reg [1:0] op;
    wire [3:0] result;
    wire carry;
    reg [3:0] expected_result;
    reg expected_carry;
    reg [4:0] expected_sum;
    integer i, j, k, checks;
    alu4 dut (.a(a), .b(b), .op(op), .result(result), .carry(carry));
    initial begin
        checks = 0;
        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1)
                for (k = 0; k < 4; k = k + 1) begin
                    a = i; b = j; op = k;
                    expected_sum = {1'b0, a} + {1'b0, b};
                    expected_carry = 1'b0;
                    case (k)
                        0: begin
                            expected_result = expected_sum[3:0];
                            expected_carry = expected_sum[4];
                        end
                        1: expected_result = a & b;
                        2: expected_result = a ^ b;
                        3: expected_result = ~a;
                    endcase
                    #1;
                    if (result !== expected_result || carry !== expected_carry)
                        $fatal(1, "alu4 failed a=%h b=%h op=%d got=%h/%b expected=%h/%b",
                               a, b, k, result, carry, expected_result, expected_carry);
                    checks = checks + 1;
                end
        if (checks != 1024) $fatal(1, "expected 1024 checks");
        $display("PASS alu4: %0d combinations", checks);
        $finish;
    end
endmodule
