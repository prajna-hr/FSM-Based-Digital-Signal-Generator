// ============================================================
// Module: triangle_wave
// Generates an 8-bit triangle wave.
// Output ramps up from 0 to 254 then ramps down to 0.
// Step size = 2, Period = 256 clock cycles
// ============================================================

module triangle_wave (
    input  wire       clk,
    input  wire       rst,
    output reg  [7:0] wave_out
);

    reg dir; // 1 = counting up, 0 = counting down

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wave_out <= 8'd0;
            dir      <= 1'b1;
        end else begin
            if (dir) begin
                wave_out <= wave_out + 8'd2;
                if (wave_out >= 8'd252)   // will reach 254 next
                    dir <= 1'b0;
            end else begin
                wave_out <= wave_out - 8'd2;
                if (wave_out <= 8'd2)     // will reach 0 next
                    dir <= 1'b1;
            end
        end
    end

endmodule
