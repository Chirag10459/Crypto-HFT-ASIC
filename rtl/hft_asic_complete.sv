`timescale 1ns/1ps

module hft_asic_complete (
    input wire clk,
    input wire rst_n,
    input wire spi_sclk,
    input wire spi_mosi,
    output wire spi_miso,
    input wire spi_cs_n,
    input wire [63:0] market_data,
    input wire market_valid,
    output wire [63:0] trade_order,
    output wire trade_valid,
    output wire trade_buy_sell,
    output wire [7:0] execution_reason
);

wire [31:0] spi_buy_limit, spi_sell_limit, spi_buy_qty, spi_sell_qty;
wire [7:0] spi_strategy_mode;
wire [15:0] spi_strategy_params;
wire spi_config_updated;
wire [31:0] current_btc_price = market_data[63:32];
wire [31:0] current_eth_price = market_data[31:0];
wire trade_triggered;
wire [31:0] trade_price, trade_quantity;
wire trade_direction;
wire [7:0] trade_reason;

spi_interface spi_ctrl (
    .clk(clk), .rst_n(rst_n), .spi_sclk(spi_sclk), .spi_mosi(spi_mosi), 
    .spi_miso(spi_miso), .spi_cs_n(spi_cs_n), .buy_price_limit(spi_buy_limit),
    .sell_price_limit(spi_sell_limit), .buy_quantity(spi_buy_qty),
    .sell_quantity(spi_sell_qty), .strategy_mode(spi_strategy_mode),
    .strategy_params(spi_strategy_params), .config_updated(spi_config_updated)
);

hybrid_trading_core trading_engine (
    .clk(clk), .rst_n(rst_n), .btc_price(current_btc_price), .eth_price(current_eth_price),
    .market_data_valid(market_valid), .host_buy_limit(spi_buy_limit),
    .host_sell_limit(spi_sell_limit), .host_buy_qty(spi_buy_qty),
    .host_sell_qty(spi_sell_qty), .strategy_mode(spi_strategy_mode),
    .strategy_params(spi_strategy_params), .config_updated(spi_config_updated),
    .trade_trigger(trade_triggered), .trade_price(trade_price),
    .trade_quantity(trade_quantity), .trade_direction(trade_direction),
    .trade_reason(trade_reason)
);

assign trade_order = {trade_price, trade_quantity};
assign trade_valid = trade_triggered;
assign trade_buy_sell = trade_direction;
assign execution_reason = trade_reason;

endmodule
