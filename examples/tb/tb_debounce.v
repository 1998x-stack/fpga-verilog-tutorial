module tb_debounce;
    reg clk=0, rst_n=0, noisy=0;
    wire level;
    debounce #(.STABLE_CYCLES(4),.CW(3)) dut (
        .clk(clk),.rst_n(rst_n),.noisy(noisy),.level(level));
    always #5 clk=~clk;
    initial begin
        repeat (2) @(negedge clk);
        rst_n=1;
        noisy=1;
        repeat (2) @(negedge clk);
        noisy=0;
        repeat (8) @(negedge clk);
        if (level !== 0) $fatal(1,"bounce should have been suppressed");
        noisy=1;
        repeat (9) @(negedge clk);
        if (level !== 1) $fatal(1,"sustained high did not pass");
        noisy=0;
        repeat (9) @(negedge clk);
        if (level !== 0) $fatal(1,"sustained low did not pass");
        $display("PASS debounce: short bounce and stable changes");
        $finish;
    end
    initial begin #1000; $fatal(1,"debounce watchdog"); end
endmodule
