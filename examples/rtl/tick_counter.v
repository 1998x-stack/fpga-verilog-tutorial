// Synchronous reset; registered one-clock pulse on modulo rollover.
module tick_counter #(
    parameter integer MODULUS = 5,
    parameter integer CW = 3
) (
    input wire clk, rst_n, en,
    output reg [CW-1:0] count,
    output reg tick
);
    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 0;
            tick <= 0;
        end else begin
            tick <= 1'b0;
            if (en) begin
                if (count == MODULUS - 1) begin
                    count <= 0;
                    tick <= 1'b1;
                end else count <= count + 1'b1;
            end
        end
    end
endmodule
