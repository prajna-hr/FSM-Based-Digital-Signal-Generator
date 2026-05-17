// ============================================================
// Module: sawtooth_wave
// Generates an 8-bit sawtooth wave.
// Output rises linearly from 0 to 255 then resets.
// Period = 256 clock cycles
// ============================================================

module sawtooth_wave (
    input  wire       clk,
    input  wire       rst,
    output reg  [7:0] wave_out
);

    // Counter directly drives output — natural overflow = reset
    always @(posedge clk or posedge rst) begin
        if (rst)
            wave_out <= 8'd0;
        else
            wave_out <= wave_out + 1;
    end

endmodule
