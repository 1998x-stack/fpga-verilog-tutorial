module tb_tick_counter;
    reg clk=0, rst_n=0, en=1;
    wire [2:0] count;
    wire tick;
    integer k;
    tick_counter #(.MODULUS(5), .CW(3)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .count(count), .tick(tick));
    always #5 clk=~clk;
    initial begin
        repeat (2) @(negedge clk);
        rst_n=1;
        for (k=1;k<=13;k=k+1) begin
            @(negedge clk);
            if (count !== (k%5) || tick !== ((k%5)==0))
                $fatal(1,"tick k=%0d count=%0d tick=%0b", k,count,tick);
        end
        en=0;
        repeat(3) @(negedge clk);
        if (count !== 3 || tick !== 0) $fatal(1,"disabled count mismatch");
        rst_n=0;
        @(negedge clk);
        if (count !== 0 || tick !== 0) $fatal(1,"sync reset failed");
        $display("PASS tick_counter: 13 enables, holds and reset");
        $finish;
    end
    initial begin #500; $fatal(1,"tick watchdog"); end
endmodule
