module tb_spi_master_mode0;
    reg clk=0, rst_n=0, start=0;
    reg [7:0] tx_data=8'hA6;
    wire sclk, mosi, cs_n, busy, done;
    wire [7:0] rx_data;
    wire miso=mosi;
    integer rises=0, pulses=0;
    spi_master_mode0 #(.HALF_PERIOD(3)) dut (
        .clk(clk),.rst_n(rst_n),.start(start),.tx_data(tx_data),
        .miso(miso),.sclk(sclk),.mosi(mosi),.cs_n(cs_n),.busy(busy),
        .rx_data(rx_data),.done(done));
    always #5 clk=~clk;
    always @(posedge sclk) if (!cs_n) rises=rises+1;
    always @(posedge clk) if (done) pulses=pulses+1;
    initial begin
        repeat(2) @(negedge clk); rst_n=1;
        @(negedge clk); start=1;
        @(negedge clk); start=0;
        repeat(56) @(negedge clk);
        if (rx_data !== 8'hA6 || rises!=8 || pulses!=1 ||
            busy!==0 || cs_n!==1 || sclk!==0)
            $fatal(1,"SPI first byte rx=%h rises=%0d done=%0d",rx_data,rises,pulses);
        tx_data=8'h3C;
        @(negedge clk); start=1;
        @(negedge clk); start=0;
        repeat(56) @(negedge clk);
        if (rx_data !== 8'h3C || rises!=16 || pulses!=2 ||
            busy!==0 || cs_n!==1 || sclk!==0)
            $fatal(1,"SPI second byte rx=%h rises=%0d done=%0d",rx_data,rises,pulses);
        $display("PASS spi_master_mode0: two loopback bytes and 16 rising edges");
        $finish;
    end
    initial begin #5000; $fatal(1,"SPI watchdog"); end
endmodule
