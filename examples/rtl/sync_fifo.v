// Single-clock, count-based FIFO with explicit edge conditions.
// When full, concurrent read+write accepts read only.
// When empty, concurrent read+write accepts write only.
// Output rd_valid pulses on every accepted read; data is registered.
module sync_fifo #(
    parameter integer AW = 2,
    parameter integer DW = 8
) (
    input wire clk, rst_n,
    input wire wr_en, rd_en,
    input wire [DW-1:0] wr_data,
    output reg [DW-1:0] rd_data,
    output reg rd_valid,
    output wire full, empty,
    output reg [AW:0] count
);
    localparam integer DEPTH = 1 << AW;
    reg [DW-1:0] mem [0:DEPTH-1];
    reg [AW-1:0] wr_ptr, rd_ptr;
    assign full  = (count == DEPTH);
    assign empty = (count == 0);
    wire wr_fire = wr_en && !full;
    wire rd_fire = rd_en && !empty;
    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 0; wr_ptr <= 0; rd_ptr <= 0;
            rd_data <= 0; rd_valid <= 0;
        end else begin
            rd_valid <= rd_fire;
            if (wr_fire) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (rd_fire) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end
            case ({wr_fire,rd_fire})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule
