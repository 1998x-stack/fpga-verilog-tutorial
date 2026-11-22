module tb_sync_fifo;
    reg clk=0, rst_n=0, wr_en=0, rd_en=0;
    reg [7:0] wr_data=0;
    wire [7:0] rd_data;
    wire rd_valid, full, empty;
    wire [2:0] count;
    sync_fifo #(.AW(2),.DW(8)) dut(
        .clk(clk),.rst_n(rst_n),.wr_en(wr_en),.rd_en(rd_en),
        .wr_data(wr_data),.rd_data(rd_data),.rd_valid(rd_valid),
        .full(full),.empty(empty),.count(count));
    always #5 clk=~clk;

    reg [7:0] model [0:3];
    integer head=0,tail=0,occupancy=0,checks=0;
    reg wr_fire_expected,rd_fire_expected;
    reg [7:0] expected_data;
    task step;
        input wr,rd;
        input [7:0] val;
        begin
            wr_en=wr; rd_en=rd; wr_data=val;
            wr_fire_expected = wr && (occupancy<4);
            rd_fire_expected = rd && (occupancy>0);
            if (rd_fire_expected) begin
                expected_data=model[head];
                head=(head+1)%4;
            end
            if (wr_fire_expected) begin
                model[tail]=val;
                tail=(tail+1)%4;
            end
            if(wr_fire_expected && !rd_fire_expected) occupancy=occupancy+1;
            else if(rd_fire_expected && !wr_fire_expected) occupancy=occupancy-1;

            @(posedge clk); #1;
            if(count !== occupancy || full !== (occupancy==4) ||
               empty !== (occupancy==0) || rd_valid !== rd_fire_expected)
                $fatal(1,"FIFO flags count=%d expected=%d valid=%b expected=%b",
                       count,occupancy,rd_valid,rd_fire_expected);
            if(rd_fire_expected && rd_data !== expected_data)
                $fatal(1,"FIFO order lost got=%h expected=%h",rd_data,expected_data);
            checks=checks+1;
            @(negedge clk);
        end
    endtask

    integer k;
    initial begin
        repeat(3) @(negedge clk);
        rst_n=1;
        step(0,1,0);               // Empty: rejected read
        step(1,0,8'h11);
        step(1,0,8'h22);
        step(1,0,8'h33);
        step(1,0,8'h44);           // Full
        step(1,1,8'hEE);           // Full: read only, write rejected
        step(1,1,8'h55);
        step(0,1,0);
        step(0,1,0);
        step(0,1,0);
        step(1,1,8'h66);           // Empty: write only
        step(0,1,0);
        for(k=0;k<100;k=k+1)
            step(((k*7+3)%11)<8, ((k*5+1)%13)<8, k ^ 8'hA5);
        while(occupancy>0) step(0,1,0);
        if(checks<100) $fatal(1,"FIFO insufficient checks");
        $display("PASS sync_fifo: %0d directed and deterministic-random edges",checks);
        $finish;
    end
    initial begin #10000; $fatal(1,"FIFO watchdog"); end
endmodule
