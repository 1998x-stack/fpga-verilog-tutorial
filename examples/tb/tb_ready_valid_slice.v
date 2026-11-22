`timescale 1ns/1ps
module tb_ready_valid_slice;
    reg clk=0,rst_n=0,s_valid=0,m_ready=0;
    reg [15:0] s_data=0;
    wire s_ready,m_valid;
    wire [15:0] m_data;
    ready_valid_slice #(.WIDTH(16)) dut(
        .clk(clk),.rst_n(rst_n),.s_valid(s_valid),.s_ready(s_ready),
        .s_data(s_data),.m_valid(m_valid),.m_ready(m_ready),.m_data(m_data)
    );
    always #5 clk=~clk;
    reg [31:0] rng=32'h45AF19C3;
    reg pending=0, was_stalled=0, source_was_stalled=0;
    reg [15:0] candidate=0,stalled_data=0,source_hold_data=0;
    reg [15:0] queue[0:4095];
    integer wr=0,rd=0,next_value=0,cycle,stalls=0,simultaneous=0;
    task sample_edge;
        begin
            @(posedge clk);
            if(source_was_stalled && (!s_valid || s_data !== source_hold_data))
                $fatal(1,"source changed VALID/DATA before input handshake");
            if(was_stalled && (!m_valid || m_data !== stalled_data))
                $fatal(1,"output changed while stalled");
            if(m_valid && m_ready) begin
                if(rd>=wr || m_data !== queue[rd])
                    $fatal(1,"lost/reordered item %0d got %h",rd,m_data);
                rd=rd+1;
            end
            if(s_valid && s_ready) begin
                if(wr>=4096) $fatal(1,"scoreboard overflow");
                queue[wr]=s_data; wr=wr+1; next_value=next_value+1;
                pending=0;
            end
            if(m_valid && !m_ready) stalls=stalls+1;
            if(s_valid && s_ready && m_valid && m_ready)
                simultaneous=simultaneous+1;
            source_was_stalled=s_valid && !s_ready;
            if(source_was_stalled) source_hold_data=s_data;
            was_stalled=m_valid && !m_ready;
            if(was_stalled) stalled_data=m_data;
        end
    endtask
    initial begin
        repeat(3) @(posedge clk);
        @(negedge clk); rst_n=1;

        // Directed: fill, hold a second input during backpressure, then
        // dequeue the old item and enqueue the new item on the same edge.
        @(negedge clk); s_valid=1; s_data=16'h1111; m_ready=0;
        sample_edge();
        @(negedge clk); s_valid=1; s_data=16'h2222; m_ready=0;
        sample_edge();
        @(negedge clk); s_valid=1; s_data=16'h2222; m_ready=1;
        sample_edge();
        @(negedge clk); s_valid=0; m_ready=1;
        sample_edge();

        // Deterministic randomized source and sink traffic.
        for(cycle=0;cycle<1600;cycle=cycle+1) begin
            @(negedge clk);
            rng=rng*32'd1664525+32'd1013904223;
            m_ready=rng[2];
            if(!pending && (cycle<40 || rng[5])) begin
                pending=1; candidate=(next_value*16'd37)^16'hA59D;
            end
            s_valid=pending; s_data=candidate;
            sample_edge();
        end

        // Drain without violating the source contract: an unaccepted pending
        // item remains VALID with unchanged DATA until its handshake.
        for(cycle=0;cycle<10;cycle=cycle+1) begin
            @(negedge clk);
            m_ready=1; s_valid=pending; s_data=candidate;
            sample_edge();
        end
        if(pending || s_valid)
            $fatal(1,"source still has an unaccepted item after drain");
        if(rd!=wr || m_valid || wr<200 || stalls==0 || simultaneous==0)
            $fatal(1,"coverage/drain mismatch written=%0d read=%0d valid=%b stalls=%0d simultaneous=%0d",
                   wr,rd,m_valid,stalls,simultaneous);
        $display("PASS ready_valid_slice (%0d ordered transfers, %0d stalls, %0d simultaneous replacements)",
                 rd,stalls,simultaneous);
        $finish;
    end
endmodule
