`timescale 1ns/1ps

module hft_asic_complete (
    input wire clk,
    input wire rst_n,
    
    // SPI interface to host PC
    input wire spi_sclk,
    input wire spi_mosi,
    output wire spi_miso,
    input wire spi_cs_n,
    
    // Market data interface
    input wire [63:0] market_data,   // BTC[63:32], ETH[31:0]
    input wire market_valid,
    
    // Trade execution outputs
    output wire [63:0] trade_order,  // Price[63:32], Qty[31:0]
    output wire trade_valid,
    output wire trade_buy_sell,      // 0=buy, 1=sell
    output wire [7:0] execution_reason
);

// Internal signals
wire [31:0] spi_buy_limit, spi_sell_limit, spi_buy_qty, spi_sell_qty;
wire [7:0] spi_strategy_mode;
wire [15:0] spi_strategy_params;
wire spi_config_updated;

// Extract market prices
wire [31:0] current_btc_price = market_data[63:32];
wire [31:0] current_eth_price = market_data[31:0];

// Trading signals
wire trade_triggered;
wire [31:0] trade_price, trade_quantity;
wire trade_direction;
wire [7:0] trade_reason;

// SPI Interface Module
spi_interface spi_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .spi_sclk(spi_sclk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_cs_n(spi_cs_n),
    .buy_price_limit(spi_buy_limit),
    .sell_price_limit(spi_sell_limit),
    .buy_quantity(spi_buy_qty),
    .sell_quantity(spi_sell_qty),
    .strategy_mode(spi_strategy_mode),
    .strategy_params(spi_strategy_params),
    .config_updated(spi_config_updated)
);

// Hybrid Trading Core
hybrid_trading_core trading_engine (
    .clk(clk),
    .rst_n(rst_n),
    .btc_price(current_btc_price),
    .eth_price(current_eth_price),
    .market_data_valid(market_valid),
    .host_buy_limit(spi_buy_limit),
    .host_sell_limit(spi_sell_limit),
    .host_buy_qty(spi_buy_qty),
    .host_sell_qty(spi_sell_qty),
    .strategy_mode(spi_strategy_mode),
    .strategy_params(spi_strategy_params),
    .config_updated(spi_config_updated),
    .trade_trigger(trade_triggered),
    .trade_price(trade_price),
    .trade_quantity(trade_quantity),
    .trade_direction(trade_direction),
    .trade_reason(trade_reason)
);

// Output assignments
assign trade_order = {trade_price, trade_quantity};
assign trade_valid = trade_triggered;
assign trade_buy_sell = trade_direction;
assign execution_reason = trade_reason;

endmodule
