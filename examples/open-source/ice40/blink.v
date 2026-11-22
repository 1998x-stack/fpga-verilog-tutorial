// iCEstick / iCE40-HX1K-TQ144 example; board pin assignments live in blink.pcf.
module blink (
    input  wire clki,
    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4,
    output wire led5
);
    wire clk_global;
    SB_GB clock_buffer (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
        .GLOBAL_BUFFER_OUTPUT(clk_global)
    );

    reg [24:0] counter = 25'd0;
    always @(posedge clk_global)
        counter <= counter + 1'b1;

    assign led1 = counter[24];
    assign led2 = counter[23];
    assign led3 = counter[22];
    assign led4 = counter[21];
    assign led5 = counter[20];
endmodule
