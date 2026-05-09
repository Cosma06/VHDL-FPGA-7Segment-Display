# FPGA 7-Segment Display Message Controller

This project implements a multi-mode message controller for an 8-digit 7-segment display using VHDL. It was designed to run on FPGA boards like Basys 3 or Nexys 4.

## 🚀 Features
- **Multiplexed Display Control**: Efficiently manages 8 common-anode digits.
- **Color Messages**: Select between 4 predefined messages (ALB, ROSU, VERDE, ALBASTRU) using hardware switches.
- **4 Operation Modes**:
  1. **Static**: Constant display of the selected word.
  2. **Blinking**: Flashing effect for the entire display.
  3. **Scroll Left**: Smooth marquee-style movement to the left.
  4. **Scroll Right**: Smooth marquee-style movement to the right.

## 🛠️ Tech Stack
- **Language**: VHDL
- **Tools**: Xilinx Vivado
- **Hardware**: FPGA (Basys 3 / Nexys 4 DDR)

## 🎮 How to use
- `sw2(1 downto 0)`: Select the message (00: Blue, 01: Red, 10: Green, 11: White).
- `sw(1 downto 0)`: Select the display mode (Static, Blink, Scroll L/R).
