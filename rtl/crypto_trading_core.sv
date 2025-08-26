`timescale 1ns/1ps

module crypto_trading_core (
    input wire clk,
    input wire rst_n,
    input wire [63:0] btc_price,
    input wire [63:0] eth_price,
    output reg trade_trigger,
    output reg [63:0] trade_price
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        trade_trigger <= 1'b0;
        trade_price <= 64'h0;
    end else begin
        if (btc_price > (eth_price << 4)) begin  // BTC > ETH*16
            trade_trigger <= 1'b1;
            trade_price <= eth_price;
        end else begin
            trade_trigger <= 1'b0;
        end
    end
end

endmodule
