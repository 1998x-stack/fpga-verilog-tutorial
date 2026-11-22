// Portable Verilog-2005; one full 1 Hz toggle cycle from a 100 MHz clock.
// Device pin/IO/reset polarity mapping is NOT specified here.
module blink_top (
    input wire clk,
    input wire rst_n,
    output reg led
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 0;
            led <= 0;
        end else if (count == 26'd49999999) begin
            count <= 0;
            led <= ~led;
        end else
            count <= count + 1'b1;
    end
endmodule
