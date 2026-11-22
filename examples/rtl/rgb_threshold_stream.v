`timescale 1ns/1ps
// RGB888 thresholding stage for AXI4-Stream Video-style pixel streams.
// TUSER=SOF of frame; TLAST=EOL of line, NOT end of frame.
// This is not a camera PHY, DDR controller, video timing generator or full SoC.
module rgb_threshold_stream(
    input wire clk,input wire rst_n,input wire [7:0] threshold,
    input wire s_tvalid,output wire s_tready,
    input wire [23:0] s_tdata,input wire s_tuser,input wire s_tlast,
    output reg m_tvalid,input wire m_tready,
    output reg [7:0] m_tdata,output reg m_tuser,output reg m_tlast
);
    wire [7:0] r=s_tdata[23:16],g=s_tdata[15:8],b=s_tdata[7:0];
    // 77+150+29=256. Max sum incl. rounding 65408 fits 16 bits.
    wire [15:0] weighted=r*16'd77+g*16'd150+b*16'd29+16'd128;
    wire [7:0] gray=weighted[15:8];
    assign s_tready=~m_tvalid | m_tready;
    always @(posedge clk) begin
        if(!rst_n) begin
            m_tvalid<=0; m_tdata<=0; m_tuser<=0; m_tlast<=0;
        end else if(s_tready) begin
            m_tvalid<=s_tvalid;
            if(s_tvalid) begin
                m_tdata<=(gray>=threshold)?8'hff:8'h00;
                m_tuser<=s_tuser;
                m_tlast<=s_tlast;
            end
        end
    end
endmodule
