# FSM-Based Digital Signal Generator

> Finite State Machine Design in Verilog HDL — IEEE Student Branch, NITK Surathkal  
> *Digital Systems Design Laboratory | Envision Virtual Project Expo*

---

## Overview

An FSM-based digital signal generator implemented in Verilog HDL that produces four waveforms — **Square**, **Sawtooth**, **Triangle**, and **Sine** — as 8-bit digital outputs, selectable via a 2-bit control signal and verified through HDL simulation.

---

## Table of Contents

- [Features](#features)
- [System Architecture](#system-architecture)
- [Waveform Generation Strategy](#waveform-generation-strategy)
- [FSM State Diagram](#fsm-state-diagram)
- [Project Structure](#project-structure)
- [Simulation Results](#simulation-results)
- [Waveform Parameters](#waveform-parameters)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
- [Limitations & Future Scope](#limitations--future-scope)
- [References](#references)
- [Team](#team)

---

## Features

- Generates 4 waveforms from a single FSM-controlled module
- 8-bit output resolution (range: 0–255)
- 256-clock period per waveform cycle
- Glitch-free, synchronous Moore machine design
- Single clock domain — FPGA deployment ready
- Sine approximation via 64-entry ROM Look-Up Table (LUT)

---

## System Architecture

The top-level module instantiates a single FSM module with the following interface:

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1-bit | System clock |
| `rst` | Input | 1-bit | Active-high asynchronous reset |
| `wave_sel` | Input | 2-bit | Waveform selector |
| `wave_out` | Output | 8-bit | Waveform sample output |

An internal 8-bit counter increments on every clock cycle and drives all sample computations.

<!-- Insert FSM Block Diagram image here -->
> **Figure 1 — FSM Block Diagram** showing top-level signal flow

---

## Waveform Generation Strategy

| `wave_sel` | Waveform | Generation Logic |
|------------|----------|-----------------|
| `2'b00` | **Square** | `wave_out = 255` when `counter < 128`, else `0`. 50% duty cycle. |
| `2'b01` | **Sawtooth** | `wave_out = counter[7:0]`. Natural 8-bit rollover every 256 clocks. |
| `2'b10` | **Triangle** | Increments by +2 (0→252), then decrements by −2 (252→0). Peak = 254. |
| `2'b11` | **Sine** | 64-entry LUT indexed via `counter[7:2]`; each value held for 4 clock cycles. |

---

## FSM State Diagram

The FSM implements a **Moore machine** with four states (S0–S3), one per waveform, directly mapped from `wave_sel[1:0]`. State transitions occur when `wave_sel` changes. An asynchronous reset drives `wave_out` to `0` and resets the counter.

<!-- Insert FSM State Diagram image here -->
> **Figure 2 — FSM State Diagram** (Moore Machine, 4 states)

---

## Project Structure

```
FSM-Based-Digital-Signal-Generator/
├── srcs/
│   ├── fsm_controller.v           # Top-level FSM controller (Moore machine)
│   ├── top_signal_generator.v     # Top-level module instantiation
│   ├── square_wave.v              # Square wave generation logic
│   ├── sawtooth_wave.v            # Sawtooth wave generation logic
│   ├── triangle_wave.v            # Triangle wave generation logic
│   └── sine_wave.v                # Sine wave LUT-based generation
├── sim/
│   ├── tb_top_signal_generator.v  # Verilog testbench (512-sample verification)
│   ├── plot_waveforms.py          # Python script to plot simulation output
│   └── output_image.png           # Simulation waveform output
└── README.md
```

---

## Simulation Results

All four waveforms were captured over **512 samples** across the full 8-bit amplitude range using Verilog HDL simulation. Waveforms were plotted using `sim/plot_waveforms.py`.

![Simulation Output](sim/output_image.png)
> **Figure 3 — Simulation Output:** Square, Sawtooth, Triangle, and Sine waveforms (512 samples, 8-bit)

No spurious transients were observed at state transitions, confirming glitch-free operation.

---

## Waveform Parameters

| Waveform | Min | Max | Mean | Period (clk) |
|----------|-----|-----|------|--------------|
| Square | 0 | 255 | 127.5 | 256 |
| Sawtooth | 0 | 255 | 127.5 | 256 |
| Triangle | 0 | 254 | 126.1 | 256 |
| Sine | 0 | 255 | 127.5 | 256 |

> Triangle peaks at **254** (not 255) — intentional artefact of the ±2 step-size boundary.

---

## Technologies Used

- **Verilog HDL** (IEEE Std 1364) — RTL hardware description language
- **Moore FSM model** — registered state logic for glitch-free, deterministic outputs
- **8-bit unsigned arithmetic** — all waveform outputs in range [0–255]
- **64-entry ROM LUT** — sine approximation indexed via `counter[7:2]`
- **Verilog HDL simulation** — functional verification across 512 samples
- **Single-clock synchronous design** — no CDC logic required; FPGA-ready

---

## Getting Started

### Prerequisites

- Any Verilog HDL simulator, e.g.:
  - [Icarus Verilog](http://iverilog.icarus.com/) (free, open-source)
  - ModelSim / QuestaSim
  - Vivado Simulator (for Xilinx FPGAs)
- GTKWave (optional, for waveform viewing)

### Running the Simulation

```bash
# Clone the repository
git clone https://github.com/prajna-hr/FSM-Based-Digital-Signal-Generator.git
cd FSM-Based-Digital-Signal-Generator

# Compile (Icarus Verilog example)
iverilog -o sim.out srcs/top_signal_generator.v srcs/fsm_controller.v \
  srcs/square_wave.v srcs/sawtooth_wave.v srcs/triangle_wave.v srcs/sine_wave.v \
  sim/tb_top_signal_generator.v

# Run simulation
vvp sim.out

# View waveforms (if VCD dump is enabled in testbench)
gtkwave dump.vcd

# Or plot using the Python script
python3 sim/plot_waveforms.py
```

### Selecting a Waveform

Drive `wave_sel` as follows in your testbench or FPGA top-level:

```verilog
wave_sel = 2'b00; // Square
wave_sel = 2'b01; // Sawtooth
wave_sel = 2'b10; // Triangle
wave_sel = 2'b11; // Sine
```

---

## Limitations & Future Scope

### Known Limitations

- Triangle peak is **254** (not 255) — artefact of ±2 step-size constraint.
- Sine output is a 64-step staircase approximation; higher fidelity needs a larger LUT.
- One pipeline clock of latency between `wave_sel` change and `wave_out` update.

### Future Scope

- [ ] Increase sine LUT to 256 entries for smoother, lower-distortion output
- [ ] Add a PWM output stage with RC filter for analogue waveform reconstruction
- [ ] Parameterise frequency via a configurable clock divider
- [ ] Deploy on physical FPGA and verify outputs on an oscilloscope
- [ ] Add UART/SPI interface for run-time waveform and frequency selection

---

## References

1. IEEE Std 1364-2005 — *IEEE Standard for Verilog Hardware Description Language*
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley, 2008
3. Xilinx UG901 — *Vivado Design Suite User Guide: Synthesis*

---

## Team

**IEEE Student Branch — NITK Surathkal**  
  Envision Virtual Project Expo

### Mentors

- Prajna H R
- Malepati Yashaswi
- Gudise Divya Keerthi

### Mentees

- Aprameyan R
- Shravani Kolage
- [Mentee Name]
- [Mentee Name]

---

*Envision Virtual Project Expo | IEEE Student Branch, NITK Surathkal*
