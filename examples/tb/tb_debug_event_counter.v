\`timescale 1ns/1ps
module tb_debug_event_counter;
    reg clk=0, rst_n=0, clear=0, event_pulse=0;
    wire [3:0] count;
    integer checks=0;
    always #5 clk=~clk;
    debug_event_counter #(.WIDTH(4)) dut(
        .clk(clk), .rst_n(rst_n), .clear(clear),
        .event_pulse(event_pulse), .count(count)
    );
    task tick;
        begin @(posedge clk); #1; end
    endtask
    task expect_count;
        input [3:0] expected;
        begin
            if (count !== expected) begin
                $display("COUNT FAIL got=%h expected=%h",count,expected);
                $fatal(1);
            end
            checks=checks+1;
        end
    endtask
    integer i;
    initial begin
        tick(); expect_count(0);
        rst_n=1;
        event_pulse=1; tick(); expect_count(1);
        event_pulse=0; tick(); expect_count(1);
        for(i=0;i<20;i=i+1) begin event_pulse=1; tick(); end
        expect_count(15); // saturates instead of wrapping
        clear=1; event_pulse=1; tick(); expect_count(0); // clear has priority
        clear=0; event_pulse=0; tick(); expect_count(0);
        $display("PASS tb_debug_event_counter (%0d checks)",checks);
        $finish;
    end
endmodule
