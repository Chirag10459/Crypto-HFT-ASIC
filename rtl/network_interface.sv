`timescale 1ns/1ps

module network_interface (
    input wire clk_156mhz,
    input wire clk_core,
    input wire rst_n,
    input wire [63:0] rx_data,
    input wire rx_valid,
    output reg [63:0] tx_data,
    output reg tx_valid,
    output reg [63:0] btc_price,
    output reg [63:0] eth_price,
    output reg price_update,
    input wire trade_trigger,
    input wire [63:0] trade_price,
    output reg [31:0] network_latency,
    output reg [31:0] total_packets
);

reg [4:0] rx_state;
reg [63:0] last_btc_price;
reg [63:0] last_eth_price;
integer latency_counter;

always @(posedge clk_156mhz or negedge rst_n) begin
    if (!rst_n) begin
        btc_price <= 64'h0;
        eth_price <= 64'h0;
        price_update <= 1'b0;
        tx_valid <= 1'b0;
        last_btc_price <= 64'h0;
        last_eth_price <= 64'h0;
        latency_counter <= 0;
        network_latency <= 0;
        total_packets <= 0;
    end else begin
        price_update <= 1'b0;
        tx_valid <= 1'b0;
        latency_counter <= latency_counter + 1;

        if (rx_valid) begin
            btc_price <= {rx_data[63:32], 32'h0};
            eth_price <= {rx_data[31:0], 32'h0};
            price_update <= 1'b1;
            total_packets <= total_packets + 1;
            latency_counter <= 0;
        end

        if (trade_trigger) begin
            tx_data <= {32'hDEADBEEF, trade_price[31:0]};
            tx_valid <= 1'b1;
        end
        network_latency <= latency_counter;
    end
end

endmodule
