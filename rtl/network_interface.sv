`timescale 1ns/1ps

// 10 Gigabit Ethernet Interface for HFT ASIC
module network_interface (
    input wire clk_156mhz,          // 156.25MHz for 10GbE
    input wire clk_core,            // 2GHz core clock
    input wire rst_n,
    
    // Ethernet PHY Interface (simplified)
    input wire [63:0] rx_data,      // Incoming market data
    input wire rx_valid,            // Data valid
    output reg [63:0] tx_data,      // Outgoing orders
    output reg tx_valid,            // Order valid
    
    // Core Interface
    output reg [63:0] btc_price,    // Parsed BTC price
    output reg [63:0] eth_price,    // Parsed ETH price  
    output reg price_update,        // New price available
    input wire trade_trigger,       // Trade decision from core
    input wire [63:0] trade_price,  // Price from core
    
    // Performance Monitoring
    output reg [31:0] network_latency,  // Network processing cycles
    output reg [31:0] total_packets     // Packet counter
);

// Network packet parser state machine
typedef enum logic [2:0] {
    IDLE,
    PARSE_HEADER,
    EXTRACT_BTC,
    EXTRACT_ETH,
    SEND_ORDER
} net_state_t;

net_state_t current_state, next_state;

// Packet parsing registers
reg [63:0] packet_buffer;
reg [15:0] parse_counter;
reg [31:0] latency_counter;

// Clock domain crossing for price data
reg [63:0] btc_price_sync, eth_price_sync;
reg price_update_sync;

// State machine for packet processing
always_ff @(posedge clk_156mhz or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
        btc_price <= 64'h0;
        eth_price <= 64'h0;
        price_update <= 1'b0;
        parse_counter <= 16'h0;
        total_packets <= 32'h0;
        network_latency <= 32'h0;
        latency_counter <= 32'h0;
    end else begin
        current_state <= next_state;
        
        case (current_state)
            IDLE: begin
                price_update <= 1'b0;
                if (rx_valid) begin
                    packet_buffer <= rx_data;
                    parse_counter <= 16'h1;
                    latency_counter <= 32'h1;
                    total_packets <= total_packets + 1;
                end
            end
            
            PARSE_HEADER: begin
                parse_counter <= parse_counter + 1;
                // Simplified: assume fixed packet format
                if (parse_counter == 16'd2) begin
                    // Extract BTC price from packet (simplified)
                    btc_price <= {rx_data[31:0], 32'h0000_0000};
                end
            end
            
            EXTRACT_BTC: begin
                parse_counter <= parse_counter + 1;
                btc_price_sync <= btc_price;
            end
            
            EXTRACT_ETH: begin
                parse_counter <= parse_counter + 1;
                // Extract ETH price from packet (simplified)  
                eth_price <= {rx_data[47:16], 32'h0000_0000};
                eth_price_sync <= eth_price;
                price_update <= 1'b1;
                price_update_sync <= 1'b1;
                network_latency <= latency_counter;
            end
            
            SEND_ORDER: begin
                // Format and send trading order
                if (trade_trigger) begin
                    tx_data <= {32'hDEADBEEF, trade_price[63:32]};
                    tx_valid <= 1'b1;
                end else begin
                    tx_valid <= 1'b0;
                end
            end
        endcase
    end
end

// Next state logic
always_comb begin
    next_state = current_state;
    
    case (current_state)
        IDLE: 
            if (rx_valid) next_state = PARSE_HEADER;
            
        PARSE_HEADER: 
            if (parse_counter >= 16'd2) next_state = EXTRACT_BTC;
            
        EXTRACT_BTC: 
            next_state = EXTRACT_ETH;
            
        EXTRACT_ETH: 
            next_state = SEND_ORDER;
            
        SEND_ORDER: 
            next_state = IDLE;
            
        default: 
            next_state = IDLE;
    endcase
end

endmodule
