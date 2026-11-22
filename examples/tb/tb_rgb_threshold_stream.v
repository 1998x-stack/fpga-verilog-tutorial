`timescale 1ns/1ps
module tb_rgb_threshold_stream;
    localparam W=7,H=4,FRAMES=3,PIXELS=W*H*FRAMES;
    reg clk=0,rst_n=0;
    always #5 clk=~clk;
    reg [7:0] threshold=8'd100;
    reg s_tvalid=0,m_tready=0,s_tuser=0,s_tlast=0;
    reg [23:0] s_tdata=0;
    wire s_tready,m_tvalid,m_tuser,m_tlast;
    wire [7:0] m_tdata;
    rgb_threshold_stream dut(
        .clk(clk),.rst_n(rst_n),.threshold(threshold),
        .s_tvalid(s_tvalid),.s_tready(s_tready),.s_tdata(s_tdata),
        .s_tuser(s_tuser),.s_tlast(s_tlast),
        .m_tvalid(m_tvalid),.m_tready(m_tready),.m_tdata(m_tdata),
        .m_tuser(m_tuser),.m_tlast(m_tlast)
    );
    reg [31:0] rng=32'hD0AB12E7;
    reg pending=0,was_stalled=0,source_was_stalled=0;
    reg [7:0] hold_data;
    reg hold_user,hold_last,source_hold_user,source_hold_last;
    reg [23:0] source_hold_data;
    reg [7:0] expected_data[0:PIXELS-1];
    reg expected_user[0:PIXELS-1],expected_last[0:PIXELS-1];
    integer wr=0,rd=0,cycle,total_stalls=0,gray_calc;
    integer rr,gg,bb,output_sof_count=0,output_eol_count=0;
    function [23:0] pattern;
        input integer n;
        begin
            pattern=(((n*17+11)&255)<<16) | (((n*29+107)&255)<<8) |
                    ((n*13+73)&255);
        end
    endfunction
    task sample_edge;
        begin
            @(posedge clk);
            if(source_was_stalled && (!s_tvalid || s_tdata!==source_hold_data ||
                                      s_tuser!==source_hold_user || s_tlast!==source_hold_last))
                $fatal(1,"source changed pixel/sideband before input handshake");
            if(was_stalled && (!m_tvalid || m_tdata!==hold_data ||
                               m_tuser!==hold_user || m_tlast!==hold_last))
                $fatal(1,"pixel/sideband changed under output backpressure");
            if(m_tvalid && m_tready) begin
                if(rd>=wr || m_tdata!==expected_data[rd] ||
                   m_tuser!==expected_user[rd] || m_tlast!==expected_last[rd])
                    $fatal(1,"pixel mismatch index=%0d data=%h SOF=%b EOL=%b",
                           rd,m_tdata,m_tuser,m_tlast);
                if(m_tuser) output_sof_count=output_sof_count+1;
                if(m_tlast) output_eol_count=output_eol_count+1;
                rd=rd+1;
            end
            if(s_tvalid && s_tready) begin
                rr=s_tdata[23:16]; gg=s_tdata[15:8]; bb=s_tdata[7:0];
                gray_calc=(77*rr+150*gg+29*bb+128)/256;
                expected_data[wr]=(gray_calc>=threshold)?8'hff:8'h00;
                expected_user[wr]=(wr%(W*H)==0);
                expected_last[wr]=(wr%W==W-1);
                if(s_tuser!==expected_user[wr] || s_tlast!==expected_last[wr])
                    $fatal(1,"SOF/EOL input geometry mismatch at %0d",wr);
                wr=wr+1;pending=0;
            end
            source_was_stalled=s_tvalid && !s_tready;
            if(source_was_stalled) begin
                source_hold_data=s_tdata;
                source_hold_user=s_tuser;
                source_hold_last=s_tlast;
            end
            was_stalled=m_tvalid && !m_tready;
            if(was_stalled) begin
                hold_data=m_tdata;hold_user=m_tuser;hold_last=m_tlast;
                total_stalls=total_stalls+1;
            end
        end
    endtask
    initial begin
        repeat(3) @(posedge clk);
        @(negedge clk);rst_n=1;
        for(cycle=0;cycle<1200;cycle=cycle+1) begin
            @(negedge clk);
            rng=rng*32'd1664525+32'd1013904223;
            m_tready=(cycle%23>=8) && rng[4];
            if(wr<PIXELS && !pending && (rng[7] || cycle<30))
                pending=1;
            s_tvalid=pending; s_tdata=pattern(wr);
            s_tuser=(wr%(W*H)==0); s_tlast=(wr%W==W-1);
            sample_edge();
        end
        if(wr!=PIXELS) $fatal(1,"source incomplete %0d/%0d",wr,PIXELS);
        repeat(5) begin
            @(negedge clk);s_tvalid=0;m_tready=1;
            sample_edge();
        end
        if(rd!=PIXELS || m_tvalid || total_stalls<5 ||
           output_sof_count!=FRAMES || output_eol_count!=H*FRAMES)
            $fatal(1,"sink/drain/marker/stall failure rd=%0d/%0d stalls=%0d SOF=%0d EOL=%0d",
                   rd,PIXELS,total_stalls,output_sof_count,output_eol_count);
        $display("PASS rgb_threshold_stream (%0d pixels, %0d stalls, %0d SOF, %0d EOL)",
                 rd,total_stalls,output_sof_count,output_eol_count);
        $finish;
    end
endmodule
