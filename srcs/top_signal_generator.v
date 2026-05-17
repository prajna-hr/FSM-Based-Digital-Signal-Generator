// ============================================================
// Module: top_signal_generator  (TOP LEVEL)
//
// Hierarchy:
//
//   top_signal_generator
//   ├── u_square    : square_wave
//   ├── u_sawtooth  : sawtooth_wave
//   ├── u_triangle  : triangle_wave
//   ├── u_sine      : sine_wave
//   └── u_fsm       : fsm_controller
//
// All four waveform modules run simultaneously.
// The FSM controller selects which output is forwarded.
//
// wave_sel encoding:
//   2'b00 → Square
//   2'b01 → Sawtooth
//   2'b10 → Triangle
//   2'b11 → Sine
// ============================================================

module top_signal_generator (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] wave_sel,
    output wire [7:0] wave_out,
    output wire [1:0] current_state   // optional: exposes FSM state
);

    // ---- Internal wires from each waveform module ----
    wire [7:0] sq_out;
    wire [7:0] saw_out;
    wire [7:0] tri_out;
    wire [7:0] sin_out;

    // ---- Instantiate: Square Wave ----
    square_wave u_square (
        .clk      (clk),
        .rst      (rst),
        .wave_out (sq_out)
    );

    // ---- Instantiate: Sawtooth Wave ----
    sawtooth_wave u_sawtooth (
        .clk      (clk),
        .rst      (rst),
        .wave_out (saw_out)
    );

    // ---- Instantiate: Triangle Wave ----
    triangle_wave u_triangle (
        .clk      (clk),
        .rst      (rst),
        .wave_out (tri_out)
    );

    // ---- Instantiate: Sine Wave ----
    sine_wave u_sine (
        .clk      (clk),
        .rst      (rst),
        .wave_out (sin_out)
    );

    // ---- Instantiate: FSM Controller ----
    fsm_controller u_fsm (
        .clk           (clk),
        .rst           (rst),
        .wave_sel      (wave_sel),
        .in_square     (sq_out),
        .in_sawtooth   (saw_out),
        .in_triangle   (tri_out),
        .in_sine       (sin_out),
        .wave_out      (wave_out),
        .current_state (current_state)
    );

endmodule
