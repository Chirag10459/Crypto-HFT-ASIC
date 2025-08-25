# Crypto-HFT-ASIC

# Crypto HFT ASIC Project

## Overview  
This project implements an ultra-low latency cryptocurrency high-frequency trading ASIC. It processes 10 GbE market data feeds, performs single-cycle arbitrage detection, and generates trade orders in hardware, achieving an end-to-end latency of **90 ns** (100–500× faster than current solutions).

## Repository Structure  
```
crypto-hft-asic/
├── Makefile                      # Build and simulation automation
├── rtl/
│   ├── crypto_trading_core.sv    # Core trading algorithm (0.5 ns decision)
│   ├── crypto_hft_asic_top.sv    # Top-level system integration
│   └── network_interface.sv      # 10 GbE packet processing
├── verification/
│   ├── crypto_hft_system_tb.sv   # System-level testbench (end-to-end)
│   └── trading_core_tb.sv        # Core-only testbench
├── docs/
│   └── crypto-hft-asic-docs.md   # Detailed project documentation
└── presentation/
    ├── demo_slides.pptx          # Interview presentation deck
    └── waveform_screenshots.png  # Key simulation waveforms
```

## Key Features  
- End-to-end latency: **90 ns** (89 ns network + 0.5 ns core)  
- Core processing: **0.5 ns** arbitrage detection at 2 GHz  
- Network interface: 10 GbE packet parsing at 156 MHz  
- Throughput: **10 M+ trades/sec**  
- Power estimate: **~85 W**  
- Business impact: **$50–100 M** annual profit potential

## Getting Started

### Prerequisites  
- Icarus Verilog (≥ 10.0)  
- GTKWave (for waveform viewing)  
- GNU Make (or Windows batch/PowerShell scripts)

### Build & Simulate  
```bash
# From project root:
make sim        # Compile and run system simulation
make waves      # Open waveform viewer (crypto_hft_system.vcd)
```
_On Windows using batch file:_  
```cmd
build.bat       # Compiles and runs simulation
```

### Core-Only Simulation  
```bash
iverilog -g2012 -o core_sim \
  rtl/crypto_trading_core.sv \
  verification/trading_core_tb.sv
vvp core_sim
```

## Documentation  
Detailed documentation is available in **docs/crypto-hft-asic-docs.md**, including architecture diagrams, performance analysis, verification methodology, and business case.

## Contact  
For questions or collaboration, please reach out to Chirag V at chirag10459@gmail.com.
