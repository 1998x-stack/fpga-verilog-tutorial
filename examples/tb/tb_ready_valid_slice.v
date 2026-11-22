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
    reg pending=0, was_stalled=0;
    reg [15:0] candidate=0,stalled_data=0;
    reg [15:0] queue[0:4095];
    integer wr=0,rd=0,next_value=0,cycle;
    task sample_edge;
        begin
            @(posedge clk);
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
            was_stalled=m_valid && !m_ready;
            if(was_stalled) stalled_data=m_data;
        end
    endtask
    initial begin
        repeat(3) @(posedge clk);
        @(negedge clk); rst_n=1;
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
        for(cycle=0;cycle<10;cycle=cycle+1) begin
            @(negedge clk); m_ready=1; s_valid=0;
            sample_edge();
        end
        if(rd!=wr || m_valid || wr<200)
            $fatal(1,"drain mismatch written=%0d read=%0d valid=%b",wr,rd,m_valid);
        $display("PASS ready_valid_slice (%0d ordered transfers)",rd);
        $finish;
    end
endmodule
