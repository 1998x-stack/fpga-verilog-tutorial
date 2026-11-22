// Synchronous saturating event counter for low-cost FPGA observability.
module debug_event_counter #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             clear,
    input  wire             event_pulse,
    output reg  [WIDTH-1:0] count
);
    always @(posedge clk) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (clear)
            count <= {WIDTH{1'b0}};
        else if (event_pulse && (count != {WIDTH{1'b1}}))
            count <= count + {{(WIDTH-1){1'b0}}, 1'b1};
    end
endmodule
