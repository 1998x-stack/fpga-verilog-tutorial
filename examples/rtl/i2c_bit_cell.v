// A single DATA-bit clock cell, NOT an I2C controller.
// Does not generate START/STOP/ACK/arbitration; SCL starts LOW.
module i2c_bit_cell #(
    parameter integer HALF_PERIOD=3,
    parameter integer TIMEOUT_CYCLES=14
) (
    input wire clk, rst_n, start, data_bit, scl_in,
    output reg scl_drive_low, sda_drive_low,
    output reg busy, done, error
);
    localparam [2:0] IDLE=0, SETUP=1, WAIT_HIGH=2,
                     HIGH_HOLD=3, FINISH=4;
    reg [2:0] state;
    reg scl_meta, scl_sync;
    reg [15:0] timer, timeout_count;
    always @(posedge clk) begin
        if (!rst_n) begin
            state<=IDLE; scl_drive_low<=1; sda_drive_low<=0;
            busy<=0; done<=0; error<=0;
            timer<=0; timeout_count<=0;
            scl_meta<=0; scl_sync<=0;
        end else begin
            scl_meta<=scl_in;
            scl_sync<=scl_meta;
            done<=0;
            case (state)
                IDLE: begin
                    scl_drive_low<=1;
                    sda_drive_low<=0;
                    busy<=0; error<=0;
                    timer<=0; timeout_count<=0;
                    if (start) begin
                        sda_drive_low<=!data_bit;
                        state<=SETUP;
                        busy<=1;
                    end
                end
                SETUP: begin
                    scl_drive_low<=1;
                    if (timer==HALF_PERIOD-1) begin
                        scl_drive_low<=0; timer<=0;
                        state<=WAIT_HIGH;
                    end else timer<=timer+1'b1;
                end
                WAIT_HIGH: begin
                    scl_drive_low<=0;
                    if (scl_sync) begin
                        state<=HIGH_HOLD; timer<=0;
                    end else if (timeout_count==TIMEOUT_CYCLES-1) begin
                        state<=FINISH; error<=1;
                        scl_drive_low<=1;
                    end else timeout_count<=timeout_count+1'b1;
                end
                HIGH_HOLD: begin
                    scl_drive_low<=0;
                    if (timer==HALF_PERIOD-1) begin
                        scl_drive_low<=1;
                        state<=FINISH;
                    end else timer<=timer+1'b1;
                end
                FINISH: begin
                    state<=IDLE;
                    sda_drive_low<=0;
                    busy<=0;
                    done<=1;
                end
                default: state<=IDLE;
            endcase
        end
    end
endmodule
