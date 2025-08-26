`timescale 1ns/1ps

module dynamic_complete_system_tb;
    reg clk, rst_n;
    reg spi_sclk, spi_mosi, spi_cs_n;
    wire spi_miso;
    reg [63:0] market_data;
    reg market_valid;
    wire [63:0] trade_order;
    wire trade_valid;
    wire trade_buy_sell;
    wire [7:0] execution_reason;

    // Instantiate complete system
    hft_asic_complete dut (
        .clk(clk), .rst_n(rst_n),
        .spi_sclk(spi_sclk), .spi_mosi(spi_mosi), .spi_miso(spi_miso), .spi_cs_n(spi_cs_n),
        .market_data(market_data), .market_valid(market_valid),
        .trade_order(trade_order), .trade_valid(trade_valid),
        .trade_buy_sell(trade_buy_sell), .execution_reason(execution_reason)
    );

    // Clock generation
    initial clk = 0;
    always #0.5 clk = ~clk;  // 1GHz
    
    initial spi_sclk = 0;
    always #5 spi_sclk = ~spi_sclk;  // 100MHz SPI

    // VCD generation
    initial begin
        $dumpfile("dynamic_complete_system.vcd");
        $dumpvars(0, dynamic_complete_system_tb);
    end

    // Variables for dynamic price generation
    integer btc_price, eth_price;
    
    // Dynamic Market Data & SPI Control
    initial begin
        $display("=== DYNAMIC HFT ASIC DEMONSTRATION ===");
        rst_n = 0; spi_cs_n = 1; market_valid = 0; spi_mosi = 0;
        btc_price = 43000; eth_price = 2600;
        #20; rst_n = 1;

        // Run concurrent processes
        fork
            // Process 1: Dynamic Market Data
            begin
                repeat(20) begin
                    // Vary BTC price ±$2000, ETH price ±$200
                    btc_price = 43000 + ($random % 4000) - 2000;
                    eth_price = 2600 + ($random % 400) - 200;
                    market_data = {btc_price[31:0], eth_price[31:0]};
                    market_valid = 1;
                    $display("[%0t] Market Update: BTC=$%0d, ETH=$%0d", $time, btc_price, eth_price);
                    #20;
                    market_valid = 0;
                    #20;
                end
            end
            
            // Process 2: SPI Host Commands
            begin
                #50; // Wait for system to stabilize
                $display("[%0t] Host Setting Buy Order: $42,500 for 3 units", $time);
                spi_write(8'h00, 32'd42500); // Buy limit
                spi_write(8'h02, 32'd3);     // Quantity
                spi_write(8'h04, 8'h01);     // Host buy mode
                
                #200;
                $display("[%0t] Host Setting Sell Order: $45,000 for 2 units", $time);
                spi_write(8'h01, 32'd45000); // Sell limit
                spi_write(8'h03, 32'd2);     // Quantity
                spi_write(8'h04, 8'h02);     // Host sell mode
                
                #200;
                $display("[%0t] Host Enabling Built-in Strategy", $time);
                spi_write(8'h05, 16'd18);    // Multiplier = 18
                spi_write(8'h04, 8'h00);     // Built-in mode
            end
        join

        #100;
        $display("=== DYNAMIC SIMULATION COMPLETE ===");
        $finish;
    end

    // SPI Write Task (Improved)
    task spi_write(input [7:0] addr, input [31:0] data);
        integer i;
        begin
            $display("  SPI Write: Addr=0x%02X, Data=0x%08X", addr, data);
            spi_cs_n = 0;
            #10;
            
            // Send address byte
            for (i = 7; i >= 0; i = i - 1) begin
                spi_mosi = addr[i];
                @(posedge spi_sclk);
            end
            
            // Send data (32 bits)
            for (i = 31; i >= 0; i = i - 1) begin
                spi_mosi = data[i];
                @(posedge spi_sclk);
            end
            
            spi_cs_n = 1;
            #20;
        end
    endtask

    // Enhanced Trade Monitoring
    always @(posedge clk) begin
        if (trade_valid) begin
            case (execution_reason)
                8'h01: $display("  🤖 BUILT-IN ARBITRAGE: %s $%0d Qty:%0d", 
                               trade_buy_sell ? "SELL" : "BUY", 
                               trade_order[63:32], trade_order[31:0]);
                8'h10: $display("  💰 HOST BUY ORDER: $%0d Qty:%0d", 
                               trade_order[63:32], trade_order[31:0]);
                8'h20: $display("  💸 HOST SELL ORDER: $%0d Qty:%0d", 
                               trade_order[63:32], trade_order[31:0]);
                default: $display("  ❓ UNKNOWN TRADE: Reason=%02h", execution_reason);
            endcase
        end
    end

    // Price Analysis Display
    always @(posedge market_valid) begin
        #1; // Small delay for clean display
        if (btc_price > (eth_price * 16))
            $display("    ✅ Arbitrage Opportunity: %0d > %0d", btc_price, eth_price * 16);
        else
            $display("    ❌ No Arbitrage: %0d ≤ %0d", btc_price, eth_price * 16);
    end

endmodule
