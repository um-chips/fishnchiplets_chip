
// *****************************************************************************
// Filename : aib_channel.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_channel
(
  inout  wire   [  95 : 0 ] iopad,

  input  logic              i_rst_n,

  // Configuration interface
  // ---------------------------------------------------------------------------
  // Channel configurations
  input  logic              c_chn_rotated,
  input  logic              c_chn_mst_mode,

  // AIB IO buffer configurations
  input  logic              c_io_tx_en      [95:0],
  input  logic              c_io_ddr_mode   [95:0],
  input  logic              c_io_async_mode [95:0],

  // AIB IO driver configurations
  input  logic  [   3 : 0 ] c_drv_strength  [95:0],
  input  logic              c_drv_pull_up   [95:0],
  input  logic              c_drv_pull_down [95:0],

  input  logic              c_ns_adapter_rstn,
  input  logic              c_ns_mac_rdy,

  // ---------------------------------------------------------------------------
  input  logic              i_aib_tx_clk,

  input  logic              i_bus_clk,

  // Tx datapath
  input  logic              i_tx_valid,
  output logic              o_tx_ready,
  input  logic  [  71 : 0 ] i_tx_data,

  // Rx datapath
  output logic              o_rx_valid,
  input  logic              i_rx_ready,
  output logic  [  71 : 0 ] o_rx_data
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic             aib_rx_clk;

  logic [  19 : 0 ] tx_data0;
  logic [  19 : 0 ] tx_data1;

  logic [  19 : 0 ] rx_data0;
  logic [  19 : 0 ] rx_data1;

  // ---------------------------------------------------------------------------
  aib_adapter u_aib_adapter (
    .i_rst_n      (i_rst_n),

    .i_bus_clk    (i_bus_clk),

    .i_tx_valid   (i_tx_valid),
    .o_tx_ready   (o_tx_ready),
    .i_tx_data    (i_tx_data),

    .o_rx_valid   (o_rx_valid),
    .i_rx_ready   (i_rx_ready),
    .o_rx_data    (o_rx_data),

    .i_aib_tx_clk (i_aib_tx_clk),
    .i_aib_rx_clk (aib_rx_clk),

    .o_tx_data0   (tx_data0),
    .o_tx_data1   (tx_data1),

    .i_rx_data0   (rx_data0),
    .i_rx_data1   (rx_data1)
  );

  // ---------------------------------------------------------------------------
  aib_io_mapping u_aib_io_mapping (
    .iopad             (iopad),

    .c_chn_rotated     (c_chn_rotated),
    .c_chn_mst_mode    (c_chn_mst_mode),

    .c_io_tx_en        (c_io_tx_en),
    .c_io_ddr_mode     (c_io_ddr_mode),
    .c_io_async_mode   (c_io_async_mode),

    .c_drv_strength    (c_drv_strength),
    .c_drv_pull_up     (c_drv_pull_up),
    .c_drv_pull_down   (c_drv_pull_down),

    .c_ns_adapter_rstn (c_ns_adapter_rstn),
    .c_ns_mac_rdy      (c_ns_mac_rdy),

    .i_tx_clk          (i_aib_tx_clk),
    .i_tx_clk_div2     (i_bus_clk),
    .i_tx_data0        (tx_data0),
    .i_tx_data1        (tx_data1),

    .o_rx_clk          (aib_rx_clk),
    .o_rx_data0        (rx_data0),
    .o_rx_data1        (rx_data1)
  );

endmodule

