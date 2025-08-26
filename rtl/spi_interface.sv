`timescale 1ns/1ps

module spi_interface (
    input wire clk,
    input wire rst_n,
    input wire spi_sclk,
    input wire spi_mosi,
    output reg spi_miso,
    input wire spi_cs_n,
    output reg [31:0] buy_price_limit,
    output reg [31:0] sell_price_limit,  
    output reg [31:0] buy_quantity,
    output reg [31:0] sell_quantity,
    output reg [7:0] strategy_mode,
    output reg [15:0] strategy_params,
    output reg config_updated
);

reg [4:0] bit_counter;
reg [7:0] spi_addr;
reg [31:0] shift_register;

always @(posedge spi_sclk or negedge rst_n) begin
    if (!rst_n) begin
        bit_counter <= 5'd0;
        shift_register <= 32'h0;
    end else if (!spi_cs_n) begin
        shift_register <= {shift_register[30:0], spi_mosi};
        bit_counter <= bit_counter + 1;
        if (bit_counter == 5'd7) begin
            spi_addr <= shift_register[7:0];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        buy_price_limit <= 32'h0000_A8C0;
        sell_price_limit <= 32'h0000_AF00;
        buy_quantity <= 32'h0000_0001;
        sell_quantity <= 32'h0000_0001;
        strategy_mode <= 8'h00;
        strategy_params <= 16'h0010;
        config_updated <= 1'b0;
    end else begin
        config_updated <= 1'b0;
        if (!spi_cs_n && bit_counter == 5'd31) begin
            case (spi_addr)
                8'h00: begin buy_price_limit <= shift_register; config_updated <= 1'b1; end
                8'h01: begin sell_price_limit <= shift_register; config_updated <= 1'b1; end
                8'h02: begin buy_quantity <= shift_register; config_updated <= 1'b1; end
                8'h03: begin sell_quantity <= shift_register; config_updated <= 1'b1; end
                8'h04: begin strategy_mode <= shift_register[7:0]; config_updated <= 1'b1; end
                8'h05: begin strategy_params <= shift_register[15:0]; config_updated <= 1'b1; end
            endcase
        end
    end
end

endmodule
