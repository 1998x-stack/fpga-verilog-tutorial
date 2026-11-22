\`timescale 1ns/1ps
module tb_axi4lite_regs;
    reg aclk=0, aresetn=0;
    reg [5:0] awaddr=0, araddr=0;
    reg awvalid=0, wvalid=0, bready=0, arvalid=0, rready=0;
    reg [31:0] wdata=0, status_i=32'hCAFE1234;
    reg [3:0] wstrb=0;
    wire awready, wready, arready, bvalid, rvalid;
    wire [1:0] bresp, rresp;
    wire [31:0] rdata;
    wire [3:0] led_o;
    integer checks=0;

    axi4lite_regs dut (
        .s_axi_aclk(aclk), .s_axi_aresetn(aresetn),
        .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(wstrb), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready),
        .status_i(status_i), .led_o(led_o)
    );
    always #5 aclk=~aclk;

    task send_aw;
        input [5:0] addr;
        begin
            @(negedge aclk); awaddr=addr; awvalid=1;
            do begin @(posedge aclk); end while (awready !== 1'b1);
            @(negedge aclk); awvalid=0;
        end
    endtask

    task send_w;
        input [31:0] data;
        input [3:0] strb;
        begin
            @(negedge aclk); wdata=data; wstrb=strb; wvalid=1;
            do begin @(posedge aclk); end while (wready !== 1'b1);
            @(negedge aclk); wvalid=0;
        end
    endtask

    task collect_b;
        input [1:0] expected_resp;
        integer k;
        begin
            bready=0;
            wait (bvalid === 1'b1); #1;
            if (bresp !== expected_resp)
                $fatal(1,"BRESP got=%b expected=%b",bresp,expected_resp);
            for (k=0;k<3;k=k+1) begin
                @(posedge aclk); #1;
                if (bvalid !== 1'b1 || bresp !== expected_resp)
                    $fatal(1,"B channel changed while BREADY=0");
            end
            @(negedge aclk); bready=1;
            @(posedge aclk); #1;
            if (bvalid !== 1'b0) $fatal(1,"BVALID did not clear after handshake");
            @(negedge aclk); bready=0;
            checks=checks+1;
        end
    endtask

    task write_tx;
        input [5:0] addr;
        input [31:0] data;
        input [3:0] strb;
        input integer order; // 0=AW first, 1=W first, 2=simultaneous
        input [1:0] expected_resp;
        begin
            case (order)
                0: begin send_aw(addr); repeat(2) @(negedge aclk); send_w(data,strb); end
                1: begin send_w(data,strb); repeat(2) @(negedge aclk); send_aw(addr); end
                default: begin
                    @(negedge aclk);
                    awaddr=addr; awvalid=1; wdata=data; wstrb=strb; wvalid=1;
                    do begin @(posedge aclk); end
                    while (!(awready === 1'b1 && wready === 1'b1));
                    @(negedge aclk); awvalid=0; wvalid=0;
                end
            endcase
            collect_b(expected_resp);
        end
    endtask

    task read_tx;
        input [5:0] addr;
        input [31:0] expected_data;
        input [1:0] expected_resp;
        integer k;
        begin
            rready=0;
            @(negedge aclk); araddr=addr; arvalid=1;
            do begin @(posedge aclk); end while (arready !== 1'b1);
            @(negedge aclk); arvalid=0;
            wait (rvalid === 1'b1); #1;
            if (rdata !== expected_data || rresp !== expected_resp)
                $fatal(1,"READ addr=%h data=%h/%h resp=%b/%b",
                       addr,rdata,expected_data,rresp,expected_resp);
            for (k=0;k<3;k=k+1) begin
                @(posedge aclk); #1;
                if (rvalid !== 1'b1 || rdata !== expected_data || rresp !== expected_resp)
                    $fatal(1,"R channel changed while RREADY=0");
            end
            @(negedge aclk); rready=1;
            @(posedge aclk); #1;
            if (rvalid !== 1'b0) $fatal(1,"RVALID did not clear after handshake");
            @(negedge aclk); rready=0;
            checks=checks+1;
        end
    endtask

    initial begin
        repeat(3) @(negedge aclk);
        aresetn=1;
        write_tx(6'h00,32'h000000A5,4'b0001,0,2'b00);
        if (led_o !== 4'h5) $fatal(1,"CTRL low nibble should be 5");
        read_tx(6'h00,32'h000000A5,2'b00);
        write_tx(6'h00,32'h0000003C,4'b0001,1,2'b00);
        if (led_o !== 4'hC) $fatal(1,"CTRL low nibble should be C");
        write_tx(6'h08,32'h11223344,4'b1111,2,2'b00);
        write_tx(6'h08,32'hAA000000,4'b1000,0,2'b00);
        read_tx(6'h08,32'hAA223344,2'b00);
        read_tx(6'h04,32'hCAFE1234,2'b00);
        read_tx(6'h0C,32'h46504741,2'b00);
        write_tx(6'h04,32'hFFFFFFFF,4'b1111,2,2'b10);
        write_tx(6'h09,32'h12345678,4'b1111,1,2'b10);
        read_tx(6'h10,32'h00000000,2'b10);
        if (checks != 9) $fatal(1,"Unexpected transaction count %0d",checks);
        $display("PASS tb_axi4lite_regs: %0d read/write responses, channel order, strobes and backpressure",checks);
        $finish;
    end
    initial begin #100000; $fatal(1,"AXI4-Lite testbench watchdog"); end
endmodule
