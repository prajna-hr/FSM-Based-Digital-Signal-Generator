// ============================================================
// Module: square_wave
// Generates an 8-bit square wave using a counter.
// Output is HIGH (255) for first half period,
// LOW (0) for second half period.
// Period = 256 clock cycles
// ============================================================

module square_wave (
    input  wire       clk,
    input  wire       rst,
    output reg  [7:0] wave_out
);

    reg [7:0] counter;

    // ---- Counter ----
    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 8'd0;
        else
            counter <= counter + 1;
    end

    // ---- Output Logic ----
    always @(posedge clk or posedge rst) begin
        if (rst)
            wave_out <= 8'd0;
        else
            wave_out <= (counter < 8'd128) ? 8'd255 : 8'd0;
    end

endmodule
