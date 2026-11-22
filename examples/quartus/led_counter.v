// Generic Quartus teaching top.
// HALF_PERIOD_CYCLES=25,000,000 gives a 1 Hz square wave only with a 50 MHz clk.
// No board pin or I/O-standard assignment is implied by this RTL.
module led_counter #(
    parameter [31:0] HALF_PERIOD_CYCLES = 32'd25000000
) (
    input wire clk,
    input wire reset_n,
    output reg led
);
    reg [31:0] count;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count <= 32'd0;
            led <= 1'b0;
        end else if (count == HALF_PERIOD_CYCLES - 1'b1) begin
            count <= 32'd0;
            led <= ~led;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
