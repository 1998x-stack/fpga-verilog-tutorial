module tb_cdc_toggle_event;
    reg src_clk=0, dst_clk=0;
    reg src_rst_n=0, dst_rst_n=0;
    reg src_pulse=0;
    wire src_ready,dst_pulse;
    integer accepted=0,delivered=0,k;
    cdc_toggle_event dut (
        .src_clk(src_clk),.src_rst_n(src_rst_n),.src_pulse(src_pulse),
        .src_ready(src_ready),.dst_clk(dst_clk),.dst_rst_n(dst_rst_n),
        .dst_pulse(dst_pulse));
    always #4 src_clk=~src_clk;
    always #7 dst_clk=~dst_clk;
    always @(posedge dst_clk) if(dst_rst_n && dst_pulse) delivered=delivered+1;

    task send_event;
        begin
            @(negedge src_clk);
            while(src_ready !== 1'b1) @(negedge src_clk);
            src_pulse=1'b1; accepted=accepted+1;
            @(negedge src_clk); src_pulse=1'b0;
        end
    endtask

    initial begin
        repeat(4) @(negedge src_clk);
        src_rst_n=1; dst_rst_n=1;
        for(k=0;k<14;k=k+1) begin
            send_event();
            // Request can only be accepted once; delayed dest acknowledges later.
            if(k%3==1) repeat(2) @(negedge src_clk);
        end
        @(negedge src_clk);
        while(src_ready !== 1'b1) @(negedge src_clk);
        repeat(8) @(negedge dst_clk);
        if(accepted!=14 || delivered!=14)
            $fatal(1,"CDC count mismatch: accepted=%0d delivered=%0d",accepted,delivered);
        $display("PASS cdc_toggle_event: 14 accepted events, 14 dest pulses");
        $finish;
    end
    initial begin #10000; $fatal(1,"CDC handshake watchdog"); end
endmodule
