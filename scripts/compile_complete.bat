@echo off
echo === COMPLETE HFT ASIC SYSTEM BUILD ===

if not exist results mkdir results
if not exist results\waveforms mkdir results\waveforms

echo Cleaning previous builds...
del results\*.vcd results\*.vvp 2>nul

echo Compiling complete system...
iverilog -g2012 -o results\complete_sim ^
    rtl\spi_interface.sv ^
    rtl\hybrid_trading_core.sv ^
    rtl\hft_asic_complete.sv ^
    rtl\network_interface.sv ^
    rtl\crypto_trading_core.sv ^
    verification\complete_system_tb.sv

if %errorlevel% neq 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)

echo ✅ Compilation successful!
echo Running simulation...
cd results
vvp complete_sim

if exist complete_system.vcd (
    echo ✅ Simulation complete! Opening waveforms...
    move complete_system.vcd waveforms\
    start gtkwave waveforms\complete_system.vcd
) else (
    echo ⚠️ No waveform file generated
)

cd ..
echo === BUILD COMPLETE ===
pause
