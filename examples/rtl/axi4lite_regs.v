`timescale 1ns/1ps
// Minimal single-outstanding AXI4-Lite subordinate (32-bit data, 6-bit address).
// 0x00 CTRL RW; 0x04 STATUS RO; 0x08 SCRATCH RW; 0x0C ID RO.
// AW and W are accepted independently and joined before a write commits.
// Unsupported or unaligned accesses return SLVERR. No AXI input-to-output combinational paths.
module axi4lite_regs (
    input wire s_axi_aclk, input wire s_axi_aresetn,
    input wire [5:0] s_axi_awaddr, input wire s_axi_awvalid, output wire s_axi_awready,
    input wire [31:0] s_axi_wdata, input wire [3:0] s_axi_wstrb,
    input wire s_axi_wvalid, output wire s_axi_wready,
    output reg [1:0] s_axi_bresp, output reg s_axi_bvalid, input wire s_axi_bready,
    input wire [5:0] s_axi_araddr, input wire s_axi_arvalid, output wire s_axi_arready,
    output reg [31:0] s_axi_rdata, output reg [1:0] s_axi_rresp,
    output reg s_axi_rvalid, input wire s_axi_rready,
    input wire [31:0] status_i, output wire [3:0] led_o
);
    localparam [1:0] RESP_OKAY = 2'b00;
    localparam [1:0] RESP_SLVERR = 2'b10;
    reg aw_pending, w_pending;
    reg [5:0] awaddr_hold;
    reg [31:0] wdata_hold;
    reg [3:0] wstrb_hold;
    reg [31:0] ctrl_reg, scratch_reg;
    wire aw_fire = s_axi_awvalid && s_axi_awready;
    wire w_fire = s_axi_wvalid && s_axi_wready;

    assign s_axi_awready = !aw_pending && !s_axi_bvalid;
    assign s_axi_wready = !w_pending && !s_axi_bvalid;
    assign s_axi_arready = !s_axi_rvalid;
    assign led_o = ctrl_reg[3:0];

    wire [5:0] write_addr = aw_pending ? awaddr_hold : s_axi_awaddr;
    wire [31:0] write_data = w_pending ? wdata_hold : s_axi_wdata;
    wire [3:0] write_strb = w_pending ? wstrb_hold : s_axi_wstrb;
    wire write_commit = !s_axi_bvalid &&
                        (aw_pending || aw_fire) && (w_pending || w_fire);

    integer lane;
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            aw_pending <= 1'b0; w_pending <= 1'b0;
            awaddr_hold <= 6'b0; wdata_hold <= 32'b0; wstrb_hold <= 4'b0;
            ctrl_reg <= 32'b0; scratch_reg <= 32'b0;
            s_axi_bresp <= RESP_OKAY; s_axi_bvalid <= 1'b0;
            s_axi_rdata <= 32'b0; s_axi_rresp <= RESP_OKAY; s_axi_rvalid <= 1'b0;
        end else begin
            if (aw_fire) begin awaddr_hold <= s_axi_awaddr; aw_pending <= 1'b1; end
            if (w_fire) begin
                wdata_hold <= s_axi_wdata; wstrb_hold <= s_axi_wstrb; w_pending <= 1'b1;
            end
            if (write_commit) begin
                aw_pending <= 1'b0; w_pending <= 1'b0;
                s_axi_bvalid <= 1'b1; s_axi_bresp <= RESP_OKAY;
                case (write_addr)
                    6'h00: begin
                        for (lane = 0; lane < 4; lane = lane + 1)
                            if (write_strb[lane])
                                ctrl_reg[lane*8 +: 8] <= write_data[lane*8 +: 8];
                    end
                    6'h08: begin
                        for (lane = 0; lane < 4; lane = lane + 1)
                            if (write_strb[lane])
                                scratch_reg[lane*8 +: 8] <= write_data[lane*8 +: 8];
                    end
                    default: s_axi_bresp <= RESP_SLVERR;
                endcase
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1'b1;
                case (s_axi_araddr)
                    6'h00: begin s_axi_rdata <= ctrl_reg; s_axi_rresp <= RESP_OKAY; end
                    6'h04: begin s_axi_rdata <= status_i; s_axi_rresp <= RESP_OKAY; end
                    6'h08: begin s_axi_rdata <= scratch_reg; s_axi_rresp <= RESP_OKAY; end
                    6'h0C: begin s_axi_rdata <= 32'h46504741; s_axi_rresp <= RESP_OKAY; end
                    default: begin s_axi_rdata <= 32'b0; s_axi_rresp <= RESP_SLVERR; end
                endcase
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end
endmodule
