// ============================================================
// Testbench: top_signal_generator
// Tests all 4 waveforms through the top-level module.
// Writes 512 samples per waveform to .txt files for Python.
// ============================================================

`timescale 1ns/1ps

module tb_top_signal_generator;

    // ---- DUT Signals ----
    reg        clk;
    reg        rst;
    reg  [1:0] wave_sel;
    wire [7:0] wave_out;
    wire [1:0] current_state;

    // ---- File Handles ----
    integer f_square, f_sawtooth, f_triangle, f_sine;
    integer i;

    // ---- State name for display ----
    reg [63:0] state_name;

    // ---- Instantiate Top Module ----
    top_signal_generator uut (
        .clk           (clk),
        .rst           (rst),
        .wave_sel      (wave_sel),
        .wave_out      (wave_out),
        .current_state (current_state)
    );

    // ---- Clock: 10ns period ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Task: reset system ----
    task do_reset;
        begin
            rst = 1;
            repeat(4) @(posedge clk);
            rst = 0;
            repeat(4) @(posedge clk); // settle
        end
    endtask

    // ---- Task: capture N samples to file ----
    task capture;
        input integer fh;
        input integer n_samples;
        integer k;
        begin
            for (k = 0; k < n_samples; k = k + 1) begin
                @(posedge clk); #1;
                $fwrite(fh, "%0d\n", wave_out);
            end
        end
    endtask

    // ---- Main Test ----
    initial begin
        $dumpfile("sim_waves.vcd");
        $dumpvars(0, tb_top_signal_generator);

        // Open output files
        f_square   = $fopen("square_out.txt",   "w");
        f_sawtooth = $fopen("sawtooth_out.txt", "w");
        f_triangle = $fopen("triangle_out.txt", "w");
        f_sine     = $fopen("sine_out.txt",     "w");

        $display("============================================");
        $display("  FSM Digital Signal Generator — Testbench ");
        $display("============================================");

        // ---- SQUARE WAVE ----
        $display("\n[1/4] Square Wave  (wave_sel=00)");
        do_reset;
        wave_sel = 2'b00;
        repeat(2) @(posedge clk);
        capture(f_square, 512);
        $display("      512 samples written → square_out.txt");

        // ---- SAWTOOTH WAVE ----
        $display("\n[2/4] Sawtooth Wave  (wave_sel=01)");
        do_reset;
        wave_sel = 2'b01;
        repeat(2) @(posedge clk);
        capture(f_sawtooth, 512);
        $display("      512 samples written → sawtooth_out.txt");

        // ---- TRIANGLE WAVE ----
        $display("\n[3/4] Triangle Wave  (wave_sel=10)");
        do_reset;
        wave_sel = 2'b10;
        repeat(2) @(posedge clk);
        capture(f_triangle, 512);
        $display("      512 samples written → triangle_out.txt");

        // ---- SINE WAVE ----
        $display("\n[4/4] Sine Wave  (wave_sel=11)");
        do_reset;
        wave_sel = 2'b11;
        repeat(2) @(posedge clk);
        capture(f_sine, 512);
        $display("      512 samples written → sine_out.txt");

        // ---- Close files ----
        $fclose(f_square);
        $fclose(f_sawtooth);
        $fclose(f_triangle);
        $fclose(f_sine);

        $display("\n============================================");
        $display("  Simulation complete! Run plot_waveforms.py");
        $display("============================================");
        $finish;
    end

    // ---- State monitor ----
    always @(posedge clk) begin
        case (current_state)
            2'b00: state_name = "SQUARE  ";
            2'b01: state_name = "SAWTOOTH";
            2'b10: state_name = "TRIANGLE";
            2'b11: state_name = "SINE    ";
        endcase
    end

endmodule
