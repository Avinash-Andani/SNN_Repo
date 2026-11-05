`timescale 1ns / 1ps

module snn_handshake_layer #(
    parameter N_INPUTS    = 2,
    parameter N_NEURONS   = 2,
    parameter DATA_WIDTH  = 8,
    parameter ADDR_WIDTH  = 8,
    parameter V_THRESHOLD = 8'sh10
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      ce,
    
    // Handshake upstream
    input  wire                      in_valid,
    output wire                      in_ready,
    input  wire [N_INPUTS-1:0]       s_in,
    
    // Handshake downstream
    output reg                       out_valid,
    input  wire                      out_ready,
    output wire [N_NEURONS-1:0]      s_out,
    
    // BRAM Programming Interface
    input  wire                      bram_we,
    input  wire [ADDR_WIDTH-1:0]     bram_waddr,
    input  wire [DATA_WIDTH-1:0]     bram_wdata,
    
    output wire                      active_flag
);

    assign in_ready = 1'b1;

    wire [N_NEURONS-1:0] layer_s_out;
    wire                 layer_active;

    snn_memory_mapped_layer #(
        .N_INPUTS(N_INPUTS),
        .N_NEURONS(N_NEURONS),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .V_THRESHOLD(V_THRESHOLD)
    ) mem_mapped_layer_inst (
        .clk(clk),
        .reset(reset),
        .ce(ce && in_valid),
        .s_in(s_in),
        .bram_we(bram_we),
        .bram_waddr(bram_waddr),
        .bram_wdata(bram_wdata),
        .s_out(layer_s_out),
        .active_flag(layer_active)
    );

    assign s_out = layer_s_out;
    assign active_flag = layer_active;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out_valid <= 1'b0;
        end else if (ce) begin
            out_valid <= in_valid;
        end
    end

endmodule
