module tb_ram_sp_read_first;
    reg clk=0, we=0;
    reg [3:0] addr=0;
    reg [7:0] din=0;
    wire [7:0] dout;
    integer count=0;
    ram_sp_read_first dut(.clk(clk),.we(we),.addr(addr),.din(din),.dout(dout));
    always #5 clk=~clk;

    task edge;
        begin @(posedge clk); #1; count=count+1; @(negedge clk); end
    endtask

    initial begin
        @(negedge clk);
        addr=4'd2; we=1; din=8'hA5; edge();
        // The first read of unwritten location 2 is deliberately unspecified.
        we=0; edge();
        if(dout !== 8'hA5) $fatal(1,"first stable read expected A5 got %h",dout);
        we=1; din=8'h3C; edge();
        if(dout !== 8'hA5) $fatal(1,"READ_FIRST collision must return old A5 got %h",dout);
        we=0; edge();
        if(dout !== 8'h3C) $fatal(1,"subsequent read expected 3C got %h",dout);
        addr=4'd7; we=1; din=8'h12; edge();
        we=0; edge();
        if(dout !== 8'h12) $fatal(1,"address 7 mismatch");
        addr=4'd2; edge();
        if(dout !== 8'h3C) $fatal(1,"address 2 unexpectedly overwritten");
        $display("PASS ram_sp_read_first: read-old collision and later read, %0d edges",count);
        $finish;
    end
    initial begin #2000; $fatal(1,"RAM watchdog"); end
endmodule
