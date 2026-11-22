// Models open-drain output as wired-low with a pull-up; target stretches SCL.
module tb_i2c_bit_cell;
    reg clk=0, rst_n=0, start=0, data_bit=1, stretch=0;
    wire scl_drive_low, sda_drive_low, busy, done, error;
    wire scl_line = !(scl_drive_low || stretch);
    wire sda_line = !sda_drive_low;
    integer hits=0, errors=0;
    i2c_bit_cell #(.HALF_PERIOD(3),.TIMEOUT_CYCLES(14)) dut (
        .clk(clk),.rst_n(rst_n),.start(start),.data_bit(data_bit),
        .scl_in(scl_line),.scl_drive_low(scl_drive_low),
        .sda_drive_low(sda_drive_low),.busy(busy),.done(done),.error(error));
    always #5 clk=~clk;
    always @(posedge clk) if (done) begin
        hits=hits+1;
        if (error) errors=errors+1;
    end
    task send;
        input value;
        begin
            @(negedge clk); data_bit=value; start=1;
            @(negedge clk); start=0;
        end
    endtask
    initial begin
        repeat(3) @(negedge clk); rst_n=1;
        send(1);
        repeat(18) @(negedge clk);
        if (hits!=1 || errors!=0 || busy!==0 || sda_line!==1)
            $fatal(1,"I2C released-high bit failed hits=%0d err=%0d",hits,errors);
        stretch=1;
        send(0);
        repeat(6) @(negedge clk);
        if (busy!==1 || scl_line!==0 || sda_line!==0)
            $fatal(1,"I2C stretch not respected");
        stretch=0;
        repeat(20) @(negedge clk);
        if (hits!=2 || errors!=0 || busy!==0)
            $fatal(1,"I2C release after stretch failed hits=%0d err=%0d",hits,errors);
        stretch=1;
        send(1);
        repeat(40) @(negedge clk);
        if (hits!=3 || errors!=1 || busy!==0)
            $fatal(1,"I2C timeout failed hits=%0d err=%0d",hits,errors);
        $display("PASS i2c_bit_cell: release, stretching, timeout");
        $finish;
    end
    initial begin #5000; $fatal(1,"I2C watchdog"); end
endmodule
