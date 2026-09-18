# UART-on-FPGA
# FPGA-to-FPGA UART Transceiver with 7-Segment Display

VHDL implementation of a UART link between two Digilent Nexys A7-100T
boards: one board transmits a byte on command, the second board receives
it, converts it to decimal, and shows it live on an 8-digit 7-segment
display. Written from scratch in VHDL (no Vivado IP Catalog UART core),
targeting Vivado 2025.1.

## Overview

Board A (**TX**) holds a byte selected by onboard switches. Pressing a
button (or flipping a switch) sends that byte out over a single UART
wire. Board B (**RX**) continuously listens on that same wire, and the
moment a byte arrives, stores it, converts it from binary to decimal,
and multiplexes it out across all 8 digits of the onboard 7-segment
display.

```
   TX BOARD                                    RX BOARD
┌───────────────┐                          ┌───────────────────┐
│  switches /    │                          │                    │
│  button        │                          │                    │
│      │         │                          │                    │
│      ▼         │      single UART wire    │                    │
│  UART_SEND     │ ───────────────────────▶ │  UART_RECEIVE      │
│      │         │      (+ shared GND)      │       │            │
│      ▼         │                          │       ▼            │
│ uart_tx_byte   │                          │  uart_rx_byte      │
└───────────────┘                          │       │            │
                                             │       ▼            │
                                             │  Data_Storage       │
                                             │       │            │
                                             │       ▼            │
                                             │  bin_to_bcd16        │
                                             │  (binary -> 5 BCD    │
                                             │   digits, double     │
                                             │   dabble algorithm)  │
                                             │       │            │
                                             │       ▼            │
                                             │ display_module_for8│
                                             │  (an_generator +    │
                                             │   bcd_decoder +      │
                                             │   data_controller)   │
                                             │       │            │
                                             │       ▼            │
                                             │  8-digit 7-segment  │
                                             │  display             │
                                             └───────────────────┘
```

## Features

- UART transmitter and receiver built from first principles in VHDL —
  no vendor IP core, standard 8N1 framing, 16x oversampling on the
  receive side with a double-flip-flop synchronizer for safe clock
  domain crossing
- Debounced, edge-detected trigger logic on the TX side, so a single
  button press or switch flip sends exactly one byte, no matter how
  long the input is held
- Full binary-to-BCD conversion (double dabble algorithm) so any 8-bit
  value displays correctly in decimal, not just as raw binary/hex
- Active-low, common-anode 7-segment display driver with its own
  digit-scan generator, segment decoder, and per-digit BCD multiplexer
- Extensively simulated with GHDL — every module individually verified,
  plus a full end-to-end simulation exercising the complete TX-to-RX
  chain with every real module (no stubs)

## Hardware

- 2x Digilent Nexys A7-100T (or Nexys4 DDR — same board, different
  branding)
- 1x jumper wire, board-to-board, Pmod JA pin 1 on each board
- 1x shared ground wire between the two boards

## Repository structure

| File | Description |
|---|---|
| `uart_tx_byte.vhd` | Single-byte UART transmitter core |
| `UART_SEND.vhd` | TX wrapper: debounced trigger, holds `data_to_send` |
| `Data_TB_Send.vhd` | Reads 8 switches into an 8-bit value to send |
| `uart_rx_byte.vhd` | Single-byte UART receiver core (16x oversampling) |
| `UART_RECEIVE.vhd` | RX wrapper: exposes the last received byte + valid pulse |
| `Data_Storage.vhd` | Generic capture-and-hold register |
| `bin_to_bcd16.vhd` | 16-bit binary to 5-digit BCD converter (double dabble) |
| `an_generator.vhd` | 7-segment digit-scan (anode) timing generator |
| `bcd_decoder.vhd` | BCD digit to 7-segment pattern decoder |
| `data_controller_for8.vhd` | Selects which digit's BCD value is active per scan cycle |
| `display_module_for8.vhd` | Top-level 8-digit display driver |
| `UART_RECEIVE_DISPLAY.vhd` | **RX board top-level** — full receive-and-display pipeline |

## Getting started

1. Open two Vivado projects, one per board (or one project targeting
   two separate bitstreams).
2. **TX project:** add `uart_tx_byte.vhd`, `UART_SEND.vhd`, and
   optionally `Data_TB_Send.vhd`; set `UART_SEND` as top.
3. **RX project:** add every file except the TX-side ones above; set
   `UART_RECEIVE_DISPLAY` as top.
4. Apply the provided constraints (`.xdc`) for each board — clock,
   reset switch, trigger button/switch, Pmod JA1, and the 7-segment
   display pins.
5. Generate bitstreams, program both boards, wire Pmod JA1-to-JA1 plus
   a shared ground between them.
6. Set the byte to send on the TX board's switches, trigger a send, and
   watch it appear on the RX board's display.

Default baud rate is 115200 (`CLKS_PER_BIT = 868` at a 100MHz system
clock) — adjust the `CLKS_PER_BIT` generic on both boards together if
you change it.

## Verification

Every module in this repository has been simulated independently with
GHDL before integration, and the complete TX-to-RX chain has been
verified in one continuous simulation with every real sub-module
connected exactly as on hardware (no stand-ins) — covering baud timing,
start/stop bit framing, the binary-to-BCD conversion, and the full
8-digit display scan.

## Status

Logic design complete and fully simulation-verified end-to-end.
Hardware bring-up in progress.

## Author

Sereyvicheka — M2 ESECA, Toulouse INP – ENSEEIHT
