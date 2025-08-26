#!/usr/bin/env python3
"""
Crypto HFT ASIC Host Controller
Controls trading strategies via SPI interface
"""

import time
import struct

class HFT_ASIC_Controller:
    def __init__(self, device_path="/dev/spi0.0"):
        """Initialize SPI connection to HFT ASIC"""
        try:
            import spidev
            self.spi = spidev.SpiDev()
            self.spi.open(0, 0)  # Bus 0, Device 0
            self.spi.max_speed_hz = 1000000  # 1MHz
            print("✅ Connected to HFT ASIC via SPI")
        except ImportError:
            print("⚠️ SPI library not available, using simulation mode")
            self.spi = None
        
    def write_register(self, addr, value):
        """Write 32-bit value to ASIC register"""
        if self.spi:
            cmd = [addr] + [(value >> (8*i)) & 0xFF for i in range(4)]
            self.spi.xfer2(cmd)
        else:
            print(f"SIM: Write 0x{addr:02X} = 0x{value:08X}")
        time.sleep(0.001)  # 1ms delay
        
    def set_buy_order(self, price, quantity):
        """Host command: Buy at specific price and quantity"""
        print(f"💰 Setting BUY order: ${price:,} for {quantity} units")
        self.write_register(0x00, int(price))     # Buy price limit
        self.write_register(0x02, int(quantity))  # Buy quantity
        self.write_register(0x04, 0x01)          # Enable host buy mode
        
    def set_sell_order(self, price, quantity):
        """Host command: Sell at specific price and quantity"""
        print(f"💸 Setting SELL order: ${price:,} for {quantity} units")
        self.write_register(0x01, int(price))     # Sell price limit
        self.write_register(0x03, int(quantity))  # Sell quantity
        self.write_register(0x04, 0x02)          # Enable host sell mode
        
    def enable_builtin_strategy(self, multiplier=16):
        """Enable ASIC built-in arbitrage strategy"""
        print(f"🤖 Enabling built-in arbitrage: BTC > ETH×{multiplier}")
        self.write_register(0x05, multiplier)    # Strategy parameter
        self.write_register(0x04, 0x00)          # Built-in mode
        
    def set_range_trading(self, buy_below, sell_above, quantity):
        """Range trading: Buy below X, sell above Y"""
        print(f"📊 Range trading: Buy<${buy_below:,}, Sell>${sell_above:,}")
        self.write_register(0x00, int(buy_below))
        self.write_register(0x01, int(sell_above))
        self.write_register(0x02, int(quantity))
        self.write_register(0x03, int(quantity))
        self.write_register(0x04, 0x03)          # Both buy and sell mode

def demo_trading_scenarios():
    """Demonstrate different trading scenarios"""
    print("=== CRYPTO HFT ASIC CONTROLLER DEMO ===\n")
    
    asic = HFT_ASIC_Controller()
    
    # Scenario 1: Manual buy order
    print("🎯 SCENARIO 1: Manual Buy Order")
    asic.set_buy_order(price=42000, quantity=5)  # Buy 5 BTC at $42K
    time.sleep(3)
    
    # Scenario 2: Manual sell order
    print("\n🎯 SCENARIO 2: Manual Sell Order")
    asic.set_sell_order(price=45000, quantity=3) # Sell 3 BTC at $45K
    time.sleep(3)
    
    # Scenario 3: Built-in strategy
    print("\n🎯 SCENARIO 3: Built-in Arbitrage Strategy")
    asic.enable_builtin_strategy(multiplier=18)  # More aggressive
    time.sleep(5)
    
    # Scenario 4: Range trading
    print("\n🎯 SCENARIO 4: Range Trading Strategy")
    asic.set_range_trading(buy_below=41000, sell_above=46000, quantity=2)
    time.sleep(5)
    
    print("\n✅ Demo complete! ASIC configured and ready for trading.")

if __name__ == "__main__":
    demo_trading_scenarios()
