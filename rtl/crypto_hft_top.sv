`timescale 1ns/1ps

// Complete Crypto HFT ASIC with Network Interface
module crypto_hft_asic_top (
    input wire clk_core,            // 2GHz core clock
    input wire clk_net,             // 156.25MHz network clock  
    input wire rst_n,
    
    // 10GbE Network Interface
    input wire [63:0] net_rx_data,
    input wire net_rx_valid,
    output wire [63:0] net_tx_data,
    output wire net_tx_valid,
    
    // Status and Performance Monitoring
    output wire [31:0] network_latency,
    output wire [31:0] total_latency,
    output wire [31:0] trades_executed,
    output wire system_active
);

// Internal signals between network and trading core
wire [63:0] btc_price_internal;
wire [63:0] eth_price_internal;  
wire price_update_internal;
wire trade_trigger_internal;
wire [63:0] trade_price_internal;

// Network Interface Module
network_interface net_if (
    .clk_156mhz(clk_net),
    .clk_core(clk_core), 
    .rst_n(rst_n),
    .rx_data(net_rx_data),
    .rx_valid(net_rx_valid),
    .tx_data(net_tx_data),
    .tx_valid(net_tx_valid),
    .btc_price(btc_price_internal),
    .eth_price(eth_price_internal),
    .price_update(price_update_internal),
    .trade_trigger(trade_trigger_internal),
    .trade_price(trade_price_internal),
    .network_latency(network_latency),
    .total_packets(trades_executed)
);

// Trading Core Module (your existing design)
crypto_trading_core trading_engine (
    .clk(clk_core),
    .rst_n(rst_n),
    .btc_price(btc_price_internal),
    .eth_price(eth_price_internal),
    .trade_trigger(trade_trigger_internal),
    .trade_price(trade_price_internal)
);

// Total latency calculation (network + processing)
assign total_latency = network_latency + 32'd1; // +1 cycle for core
assign system_active = price_update_internal;

endmodule
