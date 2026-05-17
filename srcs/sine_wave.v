// ============================================================
// Module: sine_wave
// Generates an 8-bit sine wave using a 64-entry LUT.
// Full sine cycle mapped over 256 clock cycles.
// Output range: 0–255 (DC offset = 128)
// ============================================================

module sine_wave (
    input  wire       clk,
    input  wire       rst,
    output reg  [7:0] wave_out
);

    // ---- Phase counter (0–255) ----
    reg [7:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 8'd0;
        else
            counter <= counter + 1;
    end

    // ---- 64-entry Sine LUT (full cycle, 0-255 amplitude) ----
    // sin(2*pi*i/64)*127 + 128, i = 0..63
    reg [7:0] sine_lut [0:63];

    initial begin
        sine_lut[0]  = 8'd128; sine_lut[1]  = 8'd140; sine_lut[2]  = 8'd152;
        sine_lut[3]  = 8'd165; sine_lut[4]  = 8'd176; sine_lut[5]  = 8'd188;
        sine_lut[6]  = 8'd198; sine_lut[7]  = 8'd208; sine_lut[8]  = 8'd218;
        sine_lut[9]  = 8'd226; sine_lut[10] = 8'd234; sine_lut[11] = 8'd240;
        sine_lut[12] = 8'd245; sine_lut[13] = 8'd250; sine_lut[14] = 8'd253;
        sine_lut[15] = 8'd254; sine_lut[16] = 8'd255; sine_lut[17] = 8'd254;
        sine_lut[18] = 8'd253; sine_lut[19] = 8'd250; sine_lut[20] = 8'd245;
        sine_lut[21] = 8'd240; sine_lut[22] = 8'd234; sine_lut[23] = 8'd226;
        sine_lut[24] = 8'd218; sine_lut[25] = 8'd208; sine_lut[26] = 8'd198;
        sine_lut[27] = 8'd188; sine_lut[28] = 8'd176; sine_lut[29] = 8'd165;
        sine_lut[30] = 8'd152; sine_lut[31] = 8'd140; sine_lut[32] = 8'd128;
        sine_lut[33] = 8'd115; sine_lut[34] = 8'd103; sine_lut[35] = 8'd90;
        sine_lut[36] = 8'd79;  sine_lut[37] = 8'd67;  sine_lut[38] = 8'd57;
        sine_lut[39] = 8'd47;  sine_lut[40] = 8'd37;  sine_lut[41] = 8'd29;
        sine_lut[42] = 8'd21;  sine_lut[43] = 8'd15;  sine_lut[44] = 8'd10;
        sine_lut[45] = 8'd5;   sine_lut[46] = 8'd2;   sine_lut[47] = 8'd1;
        sine_lut[48] = 8'd0;   sine_lut[49] = 8'd1;   sine_lut[50] = 8'd2;
        sine_lut[51] = 8'd5;   sine_lut[52] = 8'd10;  sine_lut[53] = 8'd15;
        sine_lut[54] = 8'd21;  sine_lut[55] = 8'd29;  sine_lut[56] = 8'd37;
        sine_lut[57] = 8'd47;  sine_lut[58] = 8'd57;  sine_lut[59] = 8'd67;
        sine_lut[60] = 8'd79;  sine_lut[61] = 8'd90;  sine_lut[62] = 8'd103;
        sine_lut[63] = 8'd115;
    end

    // ---- LUT Lookup: counter[7:2] maps 256 phases → 64 entries ----
    always @(posedge clk or posedge rst) begin
        if (rst)
            wave_out <= 8'd128;
        else
            wave_out <= sine_lut[counter[7:2]];
    end

endmodule
