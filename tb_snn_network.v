`timescale 1ns / 1ps

module tb_snn;

    parameter N_INPUTS_L1  = 2;
    parameter N_NEURONS_L1 = 2;
    parameter N_NEURONS_L2 = 1;
    parameter DATA_WIDTH   = 8;
    parameter ADDR_WIDTH   = 8;
    parameter V_THRESHOLD  = 8'sh10;

    reg                     clk;
    reg                     reset;
    reg                     ce;
    reg                     in_valid;
    wire                    in_ready;
    reg  [N_INPUTS_L1-1:0]  s_in;
    
    wire                    out_valid;
    reg                     out_ready;
    wire [N_NEURONS_L2-1:0] s_out;
    
    // BRAM programming signals
    reg                     l1_bram_we;
    reg  [ADDR_WIDTH-1:0]     l1_bram_waddr;
    reg  [DATA_WIDTH-1:0]     l1_bram_wdata;
    reg                     l2_bram_we;
    reg  [ADDR_WIDTH-1:0]     l2_bram_waddr;
    reg  [DATA_WIDTH-1:0]     l2_bram_wdata;
    
    wire                    network_active_flag;

    // Instantiate Top Handshake Module
    snn_network_top_handshake #(
        .N_INPUTS_L1(N_INPUTS_L1),
        .N_NEURONS_L1(N_NEURONS_L1),
        .N_NEURONS_L2(N_NEURONS_L2),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .V_THRESHOLD(V_THRESHOLD)
    ) uut (
        .clk(clk),
        .reset(reset),
        .ce(ce),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .s_in(s_in),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .s_out(s_out),
        .l1_bram_we(l1_bram_we),
        .l1_bram_waddr(l1_bram_waddr),
        .l1_bram_wdata(l1_bram_wdata),
        .l2_bram_we(l2_bram_we),
        .l2_bram_waddr(l2_bram_waddr),
        .l2_bram_wdata(l2_bram_wdata),
        .network_active_flag(network_active_flag)
    );

    // Clock Generation (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Configure VCD output for GTKWave
        $dumpfile("snn_waveform.vcd");
        $dumpvars(0, tb_snn);

        // Initialize signals
        clk = 0;
        reset = 1;
        ce = 1;
        in_valid = 0;
        s_in = 2'b00;
        out_ready = 1;
        
        l1_bram_we = 0;
        l1_bram_waddr = 0;
        l1_bram_wdata = 0;
        l2_bram_we = 0;
        l2_bram_waddr = 0;
        l2_bram_wdata = 0;

        #20;
        reset = 0;
        #20;

        // Step A: Load weights into Layer 1 BRAM storage[cite: 1, 3]
        @(posedge clk);
        l1_bram_we = 1;
        l1_bram_waddr = 8'd0; l1_bram_wdata = 8'sh08;
        @(posedge clk);
        l1_bram_waddr = 8'd1; l1_bram_wdata = 8'sh08;
        @(posedge clk);
        l1_bram_we = 0;

        // Step B: Stream random input bit patterns into the network
        #20;
        @(posedge clk);
        in_valid = 1;
        s_in = 2'b10; // First random bitstream chunk
        
        @(posedge clk);
        s_in = 2'b01; // Second chunk
        
        @(posedge clk);
        s_in = 2'b11; // Third chunk (accumulates potential past threshold)
        
        @(posedge clk);
        s_in = 2'b00;
        
        #100;
        in_valid = 0;
        
        #200;
        $finish;
    end

endmodule