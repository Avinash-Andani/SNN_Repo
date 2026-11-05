`timescale 1ns / 1ps

module snn_memory_mapped_layer #(
    parameter N_INPUTS    = 4,
    parameter N_NEURONS   = 4,
    parameter DATA_WIDTH  = 8,
    parameter ADDR_WIDTH  = 8,
    parameter V_THRESHOLD = 8'sh10
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      ce,
    input  wire [N_INPUTS-1:0]       s_in,
    
    // BRAM Programming Interface
    input  wire                      bram_we,
    input  wire [ADDR_WIDTH-1:0]     bram_waddr,
    input  wire [DATA_WIDTH-1:0]     bram_wdata,
    
    // Outputs
    output wire [N_NEURONS-1:0]      s_out,
    output wire                      active_flag
);

    genvar n, i;
    wire [DATA_WIDTH-1:0] weight [0:N_NEURONS-1][0:N_INPUTS-1];
    wire [DATA_WIDTH-1:0] syn_current [0:N_NEURONS-1];
    
    assign active_flag = |s_out;

    generate
        for (n = 0; n < N_NEURONS; n = n + 1) begin : gen_neurons
            
            // Accumulate weighted inputs for neuron n
            reg signed [DATA_WIDTH-1:0] acc;
            always @(*) begin
                acc = 0;
                for (integer k = 0; k < N_INPUTS; k = k + 1) begin
                    if (s_in[k]) begin
                        acc = acc + weight[n][k];
                    end
                end
            end

            assign syn_current[n] = acc;

            // Instantiate LIF Neuron
            lif_neuron #(
                .DATA_WIDTH(DATA_WIDTH),
                .V_THRESHOLD(V_THRESHOLD)
            ) neuron_inst (
                .clk(clk),
                .reset(reset),
                .ce(ce),
                .i_syn(syn_current[n]),
                .s_out(s_out[n])
            );

            // Instantiate BRAM Weights for each input of neuron n
            for (i = 0; i < N_INPUTS; i = i + 1) begin : gen_bram
                wire [ADDR_WIDTH-1:0] calc_addr = (n * N_INPUTS) + i;
                wire is_target_addr = (bram_waddr == calc_addr);
                
                snn_bram_weights #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ADDR_WIDTH(ADDR_WIDTH)
                ) weight_bram (
                    .clk(clk),
                    .we(bram_we && is_target_addr),
                    .re(1'b1),
                    .addr(calc_addr),
                    .din(bram_wdata),
                    .dout(weight[n][i])
                );
            end
        end
    endgenerate

endmodule
