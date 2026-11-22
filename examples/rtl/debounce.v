// Input must be an external asynchronous button bit.
module debounce #(
    parameter integer STABLE_CYCLES = 4,
    parameter integer CW = 3
) (
    input wire clk, rst_n, noisy,
    output reg level
);
    reg meta, synced;
    reg [CW-1:0] stable_count;
    always @(posedge clk) begin
        if (!rst_n) begin
            meta <= 0; synced <= 0;
            stable_count <= 0; level <= 0;
        end else begin
            meta <= noisy;
            synced <= meta;
            if (synced == level)
                stable_count <= 0;
            else if (stable_count == STABLE_CYCLES-1) begin
                level <= synced;
                stable_count <= 0;
            end else
                stable_count <= stable_count + 1'b1;
        end
    end
endmodule
