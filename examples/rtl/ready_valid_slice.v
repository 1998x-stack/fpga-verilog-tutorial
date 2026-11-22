`timescale 1ns/1ps
// One-entry elastic register stage. A stored payload is held during backpressure.
// No combinational input-to-output data bypass: one registered cycle of latency.
module ready_valid_slice #(parameter WIDTH=16)(
    input wire clk, input wire rst_n,
    input wire s_valid, output wire s_ready, input wire [WIDTH-1:0] s_data,
    output wire m_valid, input wire m_ready, output wire [WIDTH-1:0] m_data
);
    reg full;
    reg [WIDTH-1:0] payload;
    assign s_ready = ~full | m_ready;
    assign m_valid = full;
    assign m_data = payload;
    always @(posedge clk) begin
        if (!rst_n) begin
            full <= 1'b0;
            payload <= {WIDTH{1'b0}};
        end else if (s_ready) begin
            full <= s_valid;
            if (s_valid)
                payload <= s_data;
        end
    end
endmodule
