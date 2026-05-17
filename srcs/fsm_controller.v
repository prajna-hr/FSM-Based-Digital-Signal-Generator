// ============================================================
// Module: fsm_controller
// Moore FSM — selects which waveform module's output
// to pass through based on wave_sel input.
// States: S_SQUARE, S_SAWTOOTH, S_TRIANGLE, S_SINE
// ============================================================

module fsm_controller (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] wave_sel,       // selector input
    input  wire [7:0] in_square,      // from square_wave module
    input  wire [7:0] in_sawtooth,    // from sawtooth_wave module
    input  wire [7:0] in_triangle,    // from triangle_wave module
    input  wire [7:0] in_sine,        // from sine_wave module
    output reg  [7:0] wave_out,       // selected waveform output
    output reg  [1:0] current_state   // expose state for debug/monitor
);

    // ---- State Encoding ----
    localparam S_SQUARE   = 2'b00;
    localparam S_SAWTOOTH = 2'b01;
    localparam S_TRIANGLE = 2'b10;
    localparam S_SINE     = 2'b11;

    reg [1:0] state;

    // ---- State Register ----
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S_SQUARE;
        else
            state <= wave_sel;   // direct transition to selected wave
    end

    // ---- Output MUX (Moore: output depends only on state) ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wave_out      <= 8'd0;
            current_state <= S_SQUARE;
        end else begin
            current_state <= state;
            case (state)
                S_SQUARE:   wave_out <= in_square;
                S_SAWTOOTH: wave_out <= in_sawtooth;
                S_TRIANGLE: wave_out <= in_triangle;
                S_SINE:     wave_out <= in_sine;
                default:    wave_out <= 8'd0;
            endcase
        end
    end

endmodule
