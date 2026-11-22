// Minimal single-byte SPI master, mode 0 only (CPOL=0, CPHA=0).
module spi_master_mode0 #(parameter integer HALF_PERIOD=3) (
    input wire clk, rst_n, start,
    input wire [7:0] tx_data,
    input wire miso,
    output reg sclk, mosi, cs_n, busy,
    output reg [7:0] rx_data,
    output reg done
);
    reg [7:0] tx_latched, rx_shift;
    reg [2:0] bit_index;
    reg [15:0] timer;
    reg phase;
    always @(posedge clk) begin
        if (!rst_n) begin
            sclk<=0; mosi<=0; cs_n<=1; busy<=0; done<=0;
            tx_latched<=0; rx_shift<=0; rx_data<=0;
            bit_index<=0; timer<=0; phase<=0;
        end else begin
            done<=0;
            if (!busy) begin
                sclk<=0; cs_n<=1; phase<=0;
                if (start) begin
                    tx_latched<=tx_data;
                    rx_shift<=0;
                    bit_index<=7;
                    timer<=0;
                    mosi<=tx_data[7];
                    sclk<=0; cs_n<=0;
                    busy<=1;
                end
            end else if (timer == HALF_PERIOD-1) begin
                timer<=0;
                if (!phase) begin
                    sclk<=1;
                    rx_shift[bit_index]<=miso;
                    phase<=1;
                end else begin
                    sclk<=0;
                    phase<=0;
                    if (bit_index==0) begin
                        rx_data<=rx_shift;
                        busy<=0;
                        cs_n<=1;
                        done<=1;
                    end else begin
                        bit_index<=bit_index-1'b1;
                        mosi<=tx_latched[bit_index-1'b1];
                    end
                end
            end else timer<=timer+1'b1;
        end
    end
endmodule
