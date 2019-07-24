
// *****************************************************************************
// Filename : aib_adapter.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_adapter
(
  input  logic              i_aib_clk,
  input  logic              i_aib_clk_div2,

  input  logic              i_rst_n,

  // Core side
  input  logic              i_tx_valid,
  output logic              o_tx_ready,
  input  logic  [  71 : 0 ] i_tx_data,

  output logic              o_rx_valid,
  input  logic              i_rx_ready,
  output logic  [  71 : 0 ] o_rx_data,

  // AIB side
  output logic  [  19 : 0 ] o_tx_data0,
  output logic  [  19 : 0 ] o_tx_data1,

  input  logic  [  19 : 0 ] i_rx_data0,
  input  logic  [  19 : 0 ] i_rx_data1
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic ns_fifo_full;
  logic fs_fifo_full;

  // ---------------------------------------------------------------------------
  aib_adapter_tx u_aib_adapter_tx (
    .i_aib_clk      (i_aib_clk),
    .i_aib_clk_div2 (i_aib_clk_div2),

    .i_rst_n        (i_rst_n),

    .i_tx_valid     (i_tx_valid),
    .o_tx_ready     (o_tx_ready),
    .i_tx_data      (i_tx_data),

    .i_ns_fifo_full (ns_fifo_full),
    .i_fs_fifo_full (fs_fifo_full),

    .o_tx_data0     (o_tx_data0),
    .o_tx_data1     (o_tx_data1)
  );

  // ---------------------------------------------------------------------------
  aib_adapter_rx u_aib_adapter_rx (
    .i_aib_clk      (i_aib_clk),
    .i_aib_clk_div2 (i_aib_clk_div2),

    .i_rst_n        (i_rst_n),

    .o_rx_valid     (o_rx_valid),
    .i_rx_ready     (i_rx_ready),
    .o_rx_data      (o_rx_data),

    .o_ns_fifo_full (ns_fifo_full),
    .o_fs_fifo_full (fs_fifo_full),

    .i_rx_data0     (i_rx_data0),
    .i_rx_data1     (i_rx_data1)
  );

endmodule

