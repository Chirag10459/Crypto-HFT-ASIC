`timescale 1ns/1ps

module minimal_test;
    reg clk, rst_n;
    reg [63:0] btc, eth;
    wire trigger;

    crypto_trading_core core (
        .clk(clk), .rst_n(rst_n),
        .btc_price(btc), .eth_price(eth),
        .trade_trigger(trigger), .trade_price()
    );

    initial clk = 0;
    always #1 clk = ~clk;

    initial begin
        $dumpfile("minimal.vcd");
        $dumpvars(0, minimal_test);
        
        rst_n = 0; btc = 64'hA8C0_0000_0000_0000; eth = 64'h0A00_0000_0000_0000;
        #10; rst_n = 1;
        #20; $finish;
    end
endmodule
