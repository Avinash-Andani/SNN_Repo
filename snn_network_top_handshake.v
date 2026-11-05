`timescale 1ns / 1ps

module snn_network_top_handshake #(
    parameter N_INPUTS_L1  = 2,
    parameter N_NEURONS_L1 = 2,
    parameter N_NEURONS_L2 = 1,
    parameter DATA_WIDTH   = 8,
    parameter ADDR_WIDTH   = 8,
    parameter V_THRESHOLD  = 8'sh10
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      ce,

    // Upstream Network Interface
    input  wire                      in_valid,
    output wire                      in_ready,
    input  wire [N_INPUTS_L1-1:0]    s_in,

    // Downstream Network Interface
    output wire                      out_valid,
    input  wire                      out_ready,
    output wire [N_NEURONS_L2-1:0]   s_out,

    // BRAM Programming - Layer 1
    input  wire                      l1_bram_we,
    input  wire [ADDR_WIDTH-1:0]     l1_bram_waddr,
    input  wire [DATA_WIDTH-1:0]     l1_bram_wdata,

    // BRAM Programming - Layer 2
    input  wire                      l2_bram_we,
    input  wire [ADDR_WIDTH-1:0]     l2_bram_waddr,
    input  wire [DATA_WIDTH-1:0]     l2_bram_wdata,

    output wire                      network_active_flag
);

    // Inter-layer Handshake and Data Wires
    wire                     l1_l2_valid;
    wire                     l1_l2_ready;
    wire [N_NEURONS_L1-1:0]  l1_s_out;
    wire                     l1_active_flag;
    wire                     l2_active_flag;

    assign network_active_flag = l1_active_flag || l2_active_flag;

    // Layer 1 Instance (Hidden Recurrent Layer)
    snn_handshake_layer #(
        .N_INPUTS(N_INPUTS_L1),
        .N_NEURONS(N_NEURONS_L1),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .V_THRESHOLD(V_THRESHOLD)
    ) layer1_inst (
        .clk(clk),
        .reset(reset),
        .ce(ce),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .s_in(s_in),
        .out_valid(l1_l2_valid),
        .out_ready(l1_l2_ready),
        .s_out(l1_s_out),
        .bram_we(l1_bram_we),
        .bram_waddr(l1_bram_waddr),
        .bram_wdata(l1_bram_wdata),
        .active_flag(l1_active_flag)
    );

    // Layer 2 Instance (Output Layer)
    snn_handshake_layer #(
        .N_INPUTS(N_NEURONS_L1),
        .N_NEURONS(N_NEURONS_L2),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .V_THRESHOLD(V_THRESHOLD)
    ) layer2_inst (
        .clk(clk),
        .reset(reset),
        .ce(ce),
        .in_valid(l1_l2_valid),
        .in_ready(l1_l2_ready),
        .s_in(l1_s_out),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .s_out(s_out),
        .bram_we(l2_bram_we),
        .bram_waddr(l2_bram_waddr),
        .bram_wdata(l2_bram_wdata),
        .active_flag(l2_active_flag)
    );

endmodule
