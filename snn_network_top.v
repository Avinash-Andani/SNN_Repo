`timescale 1ns / 1ps

module snn_network_top #(
    parameter N_INPUTS_L1  = 4,
    parameter N_NEURONS_L1 = 4,
    parameter N_NEURONS_L2 = 2,
    parameter DATA_WIDTH   = 8,
    parameter ADDR_WIDTH   = 8,
    parameter V_THRESHOLD  = 8'sh10
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      ce,
    input  wire [N_INPUTS_L1-1:0]    s_in,

    // BRAM Write Interface - Layer 1
    input  wire                      l1_bram_we,
    input  wire [ADDR_WIDTH-1:0]     l1_bram_waddr,
    input  wire [DATA_WIDTH-1:0]     l1_bram_wdata,

    // BRAM Write Interface - Layer 2
    input  wire                      l2_bram_we,
    input  wire [ADDR_WIDTH-1:0]     l2_bram_waddr,
    input  wire [DATA_WIDTH-1:0]     l2_bram_wdata,

    // Outputs
    output wire [N_NEURONS_L2-1:0]   s_out,
    output wire                      network_active_flag
);

    // Inter-layer connection signals
    wire [N_NEURONS_L1-1:0] l1_s_out;
    wire                    l1_active_flag;
    wire                    l2_active_flag;

    // Overall network activity is high if EITHER layer is processing spikes
    assign network_active_flag = l1_active_flag || l2_active_flag;

    // Instance: Layer 1 (Hidden Recurrent Layer)
    snn_memory_mapped_layer #(
        .N_INPUTS(N_INPUTS_L1),
        .N_NEURONS(N_NEURONS_L1),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .V_THRESHOLD(V_THRESHOLD)
    ) layer1_inst (
        .clk(clk),
        .reset(reset),
        .ce(ce),
        .s_in(s_in),
        .bram_we(l1_bram_we),
        .bram_waddr(l1_bram_waddr),
        .bram_wdata(l1_bram_wdata),
        .s_out(l1_s_out),
        .active_flag(l1_active_flag)
    );

    // Instance: Layer 2 (Output Layer)
    snn_memory_mapped_layer #(
        .N_INPUTS(N_NEURONS_L1), // Inputs match Layer 1 outputs
        .N_NEURONS(N_NEURONS_L2),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .V_THRESHOLD(V_THRESHOLD)
    ) layer2_inst (
        .clk(clk),
        .reset(reset),
        .ce(ce && l1_active_flag), // Gate Layer 2 clock enable if Layer 1 has no activity
        .s_in(l1_s_out),
        .bram_we(l2_bram_we),
        .bram_waddr(l2_bram_waddr),
        .bram_wdata(l2_bram_wdata),
        .s_out(s_out),
        .active_flag(l2_active_flag)
    );

endmodule