`timescale 1ns/1ps

module hybrid_trading_core (
    input wire clk,
    input wire rst_n,
    input wire [31:0] btc_price,
    input wire [31:0] eth_price,
    input wire market_data_valid,
    input wire [31:0] host_buy_limit,
    input wire [31:0] host_sell_limit,
    input wire [31:0] host_buy_qty,
    input wire [31:0] host_sell_qty,
    input wire [7:0] strategy_mode,
    input wire [15:0] strategy_params,
    input wire config_updated,
    output reg trade_trigger,
    output reg [31:0] trade_price,
    output reg [31:0] trade_quantity,
    output reg trade_direction,
    output reg [7:0] trade_reason
);

wire builtin_trade_signal = (btc_price > (eth_price * strategy_params[15:0]));
wire host_buy_trigger = (strategy_mode[0] && market_data_valid && (btc_price <= host_buy_limit));
wire host_sell_trigger = (strategy_mode[1] && market_data_valid && (btc_price >= host_sell_limit));

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        trade_trigger <= 1'b0;
        trade_price <= 32'h0;
        trade_quantity <= 32'h1;
        trade_direction <= 1'b0;
        trade_reason <= 8'h00;
    end else if (market_data_valid) begin
        if (host_buy_trigger) begin
            trade_trigger <= 1'b1;
            trade_price <= btc_price;
            trade_quantity <= host_buy_qty;
            trade_direction <= 1'b0;
            trade_reason <= 8'h10;
        end else if (host_sell_trigger) begin
            trade_trigger <= 1'b1;
            trade_price <= btc_price;
            trade_quantity <= host_sell_qty;
            trade_direction <= 1'b1;
            trade_reason <= 8'h20;
        end else if ((strategy_mode == 8'h00) && builtin_trade_signal) begin
            trade_trigger <= 1'b1;
            trade_price <= eth_price;
            trade_quantity <= 32'h1;
            trade_direction <= 1'b0;
            trade_reason <= 8'h01;
        end else begin
            trade_trigger <= 1'b0;
        end
    end else begin
        trade_trigger <= 1'b0;
    end
end

endmodule
