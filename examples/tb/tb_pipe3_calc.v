module tb_pipe3_calc;
    reg clk=0, rst_n=0, ce=0, in_valid=0;
    reg [15:0] in_data=0;
    wire out_valid;
    wire [17:0] out_data;
    pipe3_calc dut(
        .clk(clk),.rst_n(rst_n),.ce(ce),
        .in_valid(in_valid),.in_data(in_data),
        .out_valid(out_valid),.out_data(out_data));
    always #5 clk=~clk;

    reg [15:0] reference_s0=0;
    reg [16:0] reference_s1=0;
    reg [17:0] reference_out=0;
    reg reference_v0=0,reference_v1=0,reference_v2=0;
    integer checks=0, accepted=0, observed=0;

    task step;
        input enable,valid;
        input [15:0] datum;
        begin
            ce=enable; in_valid=valid; in_data=datum;
            if(enable) begin
                // Update in reverse stage order, just as nonblocking FFs do.
                reference_out=(reference_s1 * 3);
                reference_v2=reference_v1;
                reference_s1=reference_s0+17'd7;
                reference_v1=reference_v0;
                reference_s0=datum;
                reference_v0=valid;
                if(valid) accepted=accepted+1;
                if(reference_v2) observed=observed+1;
            end
            @(posedge clk); #1;
            if(out_valid !== reference_v2 || out_data !== reference_out)
                $fatal(1,"pipeline valid/data mismatch got=%h/%b expected=%h/%b",
                      out_data,out_valid,reference_out,reference_v2);
            checks=checks+1;
            @(negedge clk);
        end
    endtask
    integer k;
    initial begin
        repeat(3) @(negedge clk); rst_n=1;
        step(1,1,16'd0); step(1,1,16'd1); step(1,1,16'hFFFF);
        step(0,1,16'd9); step(0,1,16'd999); // stall must hold all stages
        step(1,0,16'd2); step(1,0,16'd3);
        for(k=0;k<100;k=k+1)
            step((k%9!=3)&&(k%9!=4),(k%4!=0),((k*997)&16'hFFFF));
        repeat(4) step(1,0,0);
        if(accepted!=observed) $fatal(1,"pipeline lost transaction: %0d vs %0d",accepted,observed);
        $display("PASS pipe3_calc: %0d checks; %0d accepted/observed",checks,accepted);
        $finish;
    end
    initial begin #10000; $fatal(1,"pipeline watchdog"); end
endmodule
