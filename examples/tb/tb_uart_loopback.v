// TX and RX share an FPGA clock; compare frame bits and decoded byte.
module tb_uart_loopback;
    reg clk=0, rst_n=0, start=0;
    reg [7:0] data=8'hA5;
    wire tx, busy, valid;
    wire [7:0] decoded;
    reg [9:0] expected={1'b1,8'hA5,1'b0};
    integer k, hits=0;
    uart_tx #(.CLKS_PER_BIT(16)) sender (
        .clk(clk),.rst_n(rst_n),.start(start),.data(data),.tx(tx),.busy(busy));
    uart_rx #(.CLKS_PER_BIT(16)) receiver (
        .clk(clk),.rst_n(rst_n),.rx(tx),.data(decoded),.valid(valid));
    always #5 clk=~clk;
    always @(posedge clk) if (valid) begin
        hits=hits+1;
        if (decoded !== 8'hA5) $fatal(1,"UART got %h expected A5",decoded);
    end
    initial begin
        repeat(3) @(negedge clk);
        rst_n=1;
        @(negedge clk); start=1;
        @(negedge clk); start=0;
        for (k=0;k<10;k=k+1) begin
            if (k==0) repeat(8) @(negedge clk);
            else repeat(16) @(negedge clk);
            if (tx !== expected[k])
                $fatal(1,"UART bit %0d expected=%b actual=%b",k,expected[k],tx);
        end
        repeat(22) @(negedge clk);
        if (hits != 1 || busy !== 0 || tx !== 1)
            $fatal(1,"UART complete hits=%0d busy=%b tx=%b",hits,busy,tx);
        $display("PASS uart_loopback: 8N1 A5 frame and one valid pulse");
        $finish;
    end
    initial begin #5000; $fatal(1,"UART watchdog"); end
endmodule
