// Overlapping sequence detector with registered one-clock match pulse.
module detect101 (
    input wire clk, rst_n, bit_in,
    output reg match
);
    localparam [1:0] S0=0, S1=1, S10=2;
    reg [1:0] state, next_state;
    always @(*) begin
        next_state = S0;
        case (state)
            S0:  next_state = bit_in ? S1 : S0;
            S1:  next_state = bit_in ? S1 : S10;
            S10: next_state = bit_in ? S1 : S0;
            default: next_state = S0;
        endcase
    end
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S0;
            match <= 1'b0;
        end else begin
            state <= next_state;
            match <= (state == S10) && bit_in;
        end
    end
endmodule
