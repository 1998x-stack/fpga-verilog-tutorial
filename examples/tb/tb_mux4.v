// Deterministic combinational self-check; no simulator-specific APIs.
module tb_mux4;
    reg [3:0] d0, d1, d2, d3;
    reg [1:0] sel;
    wire [3:0] y;
    reg [3:0] expected;
    integer i, k;
    mux4 dut (.d0(d0), .d1(d1), .d2(d2), .d3(d3), .sel(sel), .y(y));
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            d0 = i;
            d1 = i + 1;
            d2 = i ^ 15;
            d3 = 15 - i;
            for (k = 0; k < 4; k = k + 1) begin
                sel = k;
                case (k)
                    0: expected = d0;
                    1: expected = d1;
                    2: expected = d2;
                    3: expected = d3;
                endcase
                #1;
                if (y !== expected)
                    $fatal(1, "mux4 failed i=%0d sel=%0d got=%h expected=%h",
                           i, k, y, expected);
            end
        end
        $display("PASS mux4: 4 selects x sample patterns (16 each)");
        $finish;
    end
endmodule
