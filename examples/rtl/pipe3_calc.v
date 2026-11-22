// Three register stages; out_valid after edge E2 for input sampled at E0.
// ce stalls the entire pipeline; consumer must also not re-consume while ce=0.
// 16-bit x: (x+7)*3 fits 18 unsigned bits.
module pipe3_calc (
    input wire clk, rst_n, ce, in_valid,
    input wire [15:0] in_data,
    output reg out_valid,
    output reg [17:0] out_data
);
    reg [15:0] s0;
    reg [16:0] s1;
    reg v0, v1;
    always @(posedge clk) begin
        if (!rst_n) begin
            s0<=0; s1<=0; out_data<=0;
            v0<=0; v1<=0; out_valid<=0;
        end else if (ce) begin
            s0<=in_data; v0<=in_valid;
            s1<={1'b0,s0}+17'd7; v1<=v0;
            out_data<=({1'b0,s1}<<1)+{1'b0,s1};
            out_valid<=v1;
        end
    end
endmodule
