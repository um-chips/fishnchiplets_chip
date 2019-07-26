
// *****************************************************************************
// Filename : aib_adapter.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_adapter
(
  input  logic              i_rst_n,

  // Core side
  input  logic              i_bus_clk,

  input  logic              i_bus_tx_valid,
  output logic              o_bus_tx_ready,
  input  logic  [  71 : 0 ] i_bus_tx_data,

  output logic              o_bus_rx_valid,
  input  logic              i_bus_rx_ready,
  output logic  [  71 : 0 ] o_bus_rx_data,

  // AIB side
  input  logic              i_aib_tx_clk,
  input  logic              i_aib_rx_clk,

  output logic  [  19 : 0 ] o_aib_tx_data0,
  output logic  [  19 : 0 ] o_aib_tx_data1,

  input  logic  [  19 : 0 ] i_aib_rx_data0,
  input  logic  [  19 : 0 ] i_aib_rx_data1
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic ns_fifo_full;
  logic fs_fifo_full;

  // ---------------------------------------------------------------------------
  aib_adapter_tx u_aib_adapter_tx (
    .i_rst_n        (i_rst_n),

    .i_ns_fifo_full (ns_fifo_full),
    .i_fs_fifo_full (fs_fifo_full),

    .i_bus_clk      (i_bus_clk),

    .i_bus_tx_valid (i_bus_tx_valid),
    .o_bus_tx_ready (o_bus_tx_ready),
    .i_bus_tx_data  (i_bus_tx_data),

    .i_aib_tx_clk   (i_aib_tx_clk),

    .o_aib_tx_data0 (o_aib_tx_data0),
    .o_aib_tx_data1 (o_aib_tx_data1)
  );

  // ---------------------------------------------------------------------------
  aib_adapter_rx u_aib_adapter_rx (
    .i_rst_n        (i_rst_n),

    .o_ns_fifo_full (ns_fifo_full),
    .o_fs_fifo_full (fs_fifo_full),

    .i_bus_clk      (i_bus_clk),

    .o_bus_rx_valid (o_bus_rx_valid),
    .i_bus_rx_ready (i_bus_rx_ready),
    .o_bus_rx_data  (o_bus_rx_data),

    .i_aib_rx_clk   (i_aib_rx_clk),

    .i_aib_rx_data0 (i_aib_rx_data0),
    .i_aib_rx_data1 (i_aib_rx_data1)
  );

endmodule

