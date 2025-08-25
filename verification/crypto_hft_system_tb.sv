`timescale 1ns/1ps

module crypto_hft_system_tb;
    reg clk_core, clk_net, rst_n;
    reg [63:0] net_rx_data;
    reg net_rx_valid;
    wire [63:0] net_tx_data;
    wire net_tx_valid;
    wire [31:0] network_latency, total_latency, trades_executed;
    wire system_active;

    // Instantiate complete system
    crypto_hft_asic_top dut (
        .clk_core(clk_core),
        .clk_net(clk_net),
        .rst_n(rst_n),
        .net_rx_data(net_rx_data),
        .net_rx_valid(net_rx_valid),
        .net_tx_data(net_tx_data),
        .net_tx_valid(net_tx_valid),
        .network_latency(network_latency),
        .total_latency(total_latency),
        .trades_executed(trades_executed),
        .system_active(system_active)
    );

    // Generate clocks
    initial begin
        clk_core = 0;
        forever #0.25 clk_core = ~clk_core;  // 2GHz
    end
    
    initial begin
        clk_net = 0;  
        forever #3.2 clk_net = ~clk_net;     // 156.25MHz
    end

    // Generate waveform dump
    initial begin
        $dumpfile("crypto_hft_system.vcd");
        $dumpvars(0, crypto_hft_system_tb);
    end

    // Test stimulus - simulate real market data packets
    initial begin
        $display("=== CRYPTO HFT ASIC SYSTEM SIMULATION ===");
        
        rst_n = 0;
        net_rx_data = 64'h0;
        net_rx_valid = 0;
        #100;
        rst_n = 1;
        
        // Simulate incoming market data packet
        $display("Sending market data packet...");
        net_rx_data = 64'h1234_5678_A8C0_0000; // Header + BTC price
        net_rx_valid = 1;
        #6.4; // One network clock
        
        net_rx_data = 64'h9ABC_DEF0_0A00_0000; // ETH price data
        #6.4;
        
        net_rx_valid = 0;
        
        // Wait for processing and order generation
        #200;
        
        if (net_tx_valid) begin
            $display("✅ SUCCESS: Order transmitted");
            $display("   Network Latency: %d cycles", network_latency);
            $display("   Total Latency: %d cycles", total_latency);
            $display("   Total Trades: %d", trades_executed);
        end else begin
            $display("❌ FAILED: No order generated");
        end
        
        #500;
        $display("=== END-TO-END LATENCY TEST COMPLETE ===");
        $finish;
    end

    // Monitor network transactions
    always @(posedge clk_net) begin
        if (net_tx_valid) begin
            $display("Time %t: ORDER SENT - Data: %h", $time, net_tx_data);
        end
        if (system_active) begin
            $display("Time %t: SYSTEM PROCESSING - Total Latency: %d cycles", 
                     $time, total_latency);
        end
    end

endmodule
