// Two-way single-event CDC toggle handshake, one accepted event at a time.
// Both resets must be initialized coherently before exchanging events.
// In-service reset of one side alone is outside this teaching module's contract.
module cdc_toggle_event (
    input wire src_clk, src_rst_n, src_pulse,
    output wire src_ready,
    input wire dst_clk, dst_rst_n,
    output reg dst_pulse
);
    reg req_toggle;
    (* ASYNC_REG = "TRUE" *) reg ack_meta, ack_sync;
    (* ASYNC_REG = "TRUE" *) reg req_meta, req_sync;
    reg seen_toggle;

    assign src_ready = (req_toggle == ack_sync);
    wire ack_toggle = seen_toggle;

    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            req_toggle <= 1'b0;
            ack_meta <= 1'b0;
            ack_sync <= 1'b0;
        end else begin
            ack_meta <= ack_toggle;
            ack_sync <= ack_meta;
            if (src_pulse && src_ready)
                req_toggle <= ~req_toggle;
        end
    end
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            req_meta <= 1'b0;
            req_sync <= 1'b0;
            seen_toggle <= 1'b0;
            dst_pulse <= 1'b0;
        end else begin
            req_meta <= req_toggle;
            req_sync <= req_meta;
            dst_pulse <= (req_sync != seen_toggle);
            if (req_sync != seen_toggle)
                seen_toggle <= req_sync;
        end
    end
endmodule
