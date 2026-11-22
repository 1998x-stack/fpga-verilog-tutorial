// Minimal 8N1 transmitter, LSB first, integer divider >= 4.
module uart_tx #(parameter integer CLKS_PER_BIT=16) (
    input wire clk, rst_n, start,
    input wire [7:0] data,
    output reg tx, busy
);
    reg [9:0] frame;
    reg [3:0] bit_index;
    reg [15:0] count;
    always @(posedge clk) begin
        if (!rst_n) begin
            frame <= 0;
            bit_index <= 0;
            count <= 0;
            tx <= 1'b1;
            busy <= 0;
        end else if (!busy) begin
            tx <= 1'b1;
            if (start) begin
                frame <= {1'b1, data, 1'b0};
                bit_index <= 0;
                count <= 0;
                tx <= 1'b0;
                busy <= 1'b1;
            end
        end else if (count == CLKS_PER_BIT-1) begin
            count <= 0;
            if (bit_index == 9) begin
                tx <= 1'b1;
                busy <= 0;
            end else begin
                bit_index <= bit_index + 1'b1;
                tx <= frame[bit_index + 1'b1];
            end
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
