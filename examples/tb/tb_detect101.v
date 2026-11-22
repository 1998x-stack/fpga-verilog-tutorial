module tb_detect101;
    reg clk=0, rst_n=0, bit_in=0;
    wire match;
    integer hits=0;
    detect101 dut (.clk(clk),.rst_n(rst_n),.bit_in(bit_in),.match(match));
    always #5 clk=~clk;
    task send;
        input value;
        input expected;
        begin
            @(negedge clk); bit_in=value;
            @(negedge clk);
            if (match !== expected)
                $fatal(1,"FSM input=%b expected=%b got=%b",value,expected,match);
            if (match) hits=hits+1;
        end
    endtask
    initial begin
        repeat(2) @(negedge clk);
        rst_n=1;
        send(1,0); send(0,0); send(1,1);
        send(0,0); send(1,1); // 10101: two overlapping matches
        send(1,0); send(1,0); send(0,0);
        if (hits != 2) $fatal(1,"FSM expected 2 matches, got %0d",hits);
        rst_n=0;
        @(negedge clk);
        if (match !== 0) $fatal(1,"FSM reset failed");
        $display("PASS detect101: overlap, no matches, reset");
        $finish;
    end
    initial begin #1000; $fatal(1,"FSM watchdog"); end
endmodule
