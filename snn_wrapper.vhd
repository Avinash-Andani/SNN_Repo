library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snn_wrapper is
    Port (
        clk                 : in  STD_LOGIC;
        reset               : in  STD_LOGIC;
        ce                  : in  STD_LOGIC;
        in_valid            : in  STD_LOGIC;
        in_ready            : out STD_LOGIC;
        s_in                : in  STD_LOGIC_VECTOR(1 downto 0);
        out_valid           : out STD_LOGIC;
        out_ready           : in  STD_LOGIC;
        s_out               : out STD_LOGIC_VECTOR(0 downto 0);
        l1_bram_we          : in  STD_LOGIC;
        l1_bram_waddr       : in  STD_LOGIC_VECTOR(7 downto 0);
        l1_bram_wdata       : in  STD_LOGIC_VECTOR(7 downto 0);
        l2_bram_we          : in  STD_LOGIC;
        l2_bram_waddr       : in  STD_LOGIC_VECTOR(7 downto 0);
        l2_bram_wdata       : in  STD_LOGIC_VECTOR(7 downto 0);
        network_active_flag : out STD_LOGIC
    );
end snn_wrapper;

architecture rtl of snn_wrapper is
    -- Component declaration for the synthesized EDIF netlist
    component snn_network_top_handshake is
        Port (
            clk                 : in  STD_LOGIC;
            reset               : in  STD_LOGIC;
            ce                  : in  STD_LOGIC;
            in_valid            : in  STD_LOGIC;
            in_ready            : out STD_LOGIC;
            s_in                : in  STD_LOGIC_VECTOR(1 downto 0);
            out_valid           : out STD_LOGIC;
            out_ready           : in  STD_LOGIC;
            s_out               : out STD_LOGIC_VECTOR(0 downto 0);
            l1_bram_we          : in  STD_LOGIC;
            l1_bram_waddr       : in  STD_LOGIC_VECTOR(7 downto 0);
            l1_bram_wdata       : in  STD_LOGIC_VECTOR(7 downto 0);
            l2_bram_we          : in  STD_LOGIC;
            l2_bram_waddr       : in  STD_LOGIC_VECTOR(7 downto 0);
            l2_bram_wdata       : in  STD_LOGIC_VECTOR(7 downto 0);
            network_active_flag : out STD_LOGIC
        );
    end component;
begin
    u_snn_top : snn_network_top_handshake
        port map (
            clk                 => clk,
            reset               => reset,
            ce                  => ce,
            in_valid            => in_valid,
            in_ready            => in_ready,
            s_in                => s_in,
            out_valid           => out_valid,
            out_ready           => out_ready,
            s_out               => s_out,
            l1_bram_we          => l1_bram_we,
            l1_bram_waddr       => l1_bram_waddr,
            l1_bram_wdata       => l1_bram_wdata,
            l2_bram_we          : in_bram_we, -- map accordingly
            l2_bram_waddr       => l2_bram_waddr,
            l2_bram_wdata       => l2_bram_wdata,
            network_active_flag => network_active_flag
        );
end rtl;