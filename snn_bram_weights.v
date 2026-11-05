`timescale 1ns / 1ps

module snn_bram_weights #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8   // Supports up to 256 weight locations
)(
    input  wire                  clk,
    input  wire                  we,          // Write Enable (for loading weights)
    input  wire                  re,          // Read Enable (event-driven)
    input  wire [ADDR_WIDTH-1:0] addr,        // Calculated index: (neuron_idx * N_INPUTS) + input_idx
    input  wire [DATA_WIDTH-1:0] din,         // Data in (during weight loading)
    output reg  [DATA_WIDTH-1:0] dout         // Data out (weight served to LIF neuron)
);

    // Memory array inferred as FPGA Block RAM
    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= din;
        end
        if (re) begin
            dout <= ram[addr];
        end
    end

endmodule