// Single-clock read-first RAM model; implementation resource is tool dependent.
// No reset on memory; do not read any unwritten address.
module ram_sp_read_first #(
    parameter integer AW = 4,
    parameter integer DW = 8
) (
    input wire clk, we,
    input wire [AW-1:0] addr,
    input wire [DW-1:0] din,
    output reg [DW-1:0] dout
);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    always @(posedge clk) begin
        if (we) mem[addr] <= din;
        dout <= mem[addr];
    end
endmodule
