`timescale 1ns / 1ps

module lif_neuron #(
    parameter DATA_WIDTH  = 8,
    parameter V_THRESHOLD = 8'sh10  // Threshold = 1.0 (Q4.4)
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      ce,
    input  wire signed [DATA_WIDTH-1:0] i_syn,
    output reg                       s_out
);

    // Leak factor alpha = 0.5 (Q4.4 format -> 8'sh08)
    localparam signed [DATA_WIDTH-1:0] ALPHA = 8'sh08;

    reg signed [DATA_WIDTH-1:0] v_mem;
    wire signed [2*DATA_WIDTH-1:0] v_decayed_full;
    wire signed [DATA_WIDTH-1:0]   v_decayed;

    // Decay calculation: V_decayed = V_mem * 0.5 (shift right by 4 bits for Q4.4)
    assign v_decayed_full = v_mem * ALPHA;
    assign v_decayed      = v_decayed_full[DATA_WIDTH+3 : 4];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            v_mem <= {DATA_WIDTH{1'b0}};
            s_out <= 1'b0;
        end else if (ce) begin
            // Check if membrane potential meets or exceeds threshold
            if ((v_decayed + i_syn) >= V_THRESHOLD) begin
                s_out <= 1'b1;
                v_mem <= {DATA_WIDTH{1'b0}}; // Hard Reset
            end else begin
                s_out <= 1'b0;
                v_mem <= v_decayed + i_syn;
            end
        end else begin
            // Idle state: Maintain state when clock enable is low
            s_out <= 1'b0;
        end
    end

endmodule
