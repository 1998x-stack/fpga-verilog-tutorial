// Minimal 8N1 receiver: 2 FF input synchronizer, center sampling.
module uart_rx #(parameter integer CLKS_PER_BIT=16) (
    input wire clk, rst_n, rx,
    output reg [7:0] data,
    output reg valid
);
    localparam [1:0] IDLE=0, START=1, DATA=2, STOP=3;
    reg [1:0] state;
    reg rx_meta, rx_sync;
    reg [15:0] count;
    reg [2:0] bit_index;
    reg [7:0] shift;
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
            count <= 0;
            bit_index <= 0;
            shift <= 0;
            data <= 0;
            valid <= 0;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
            valid <= 0;
            case (state)
                IDLE: if (!rx_sync) begin
                    state <= START;
                    count <= CLKS_PER_BIT/2 - 1;
                end
                START: if (count == 0) begin
                    if (!rx_sync) begin
                        state <= DATA;
                        count <= CLKS_PER_BIT - 1;
                        bit_index <= 0;
                    end else state <= IDLE;
                end else count <= count - 1'b1;
                DATA: if (count == 0) begin
                    shift[bit_index] <= rx_sync;
                    count <= CLKS_PER_BIT - 1;
                    if (bit_index == 7) state <= STOP;
                    else bit_index <= bit_index + 1'b1;
                end else count <= count - 1'b1;
                STOP: if (count == 0) begin
                    state <= IDLE;
                    if (rx_sync) begin
                        data <= shift;
                        valid <= 1'b1;
                    end
                end else count <= count - 1'b1;
                default: state <= IDLE;
            endcase
        end
    end
endmodule
