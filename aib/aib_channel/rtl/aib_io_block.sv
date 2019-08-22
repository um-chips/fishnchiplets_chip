
// *****************************************************************************
// Filename : aib_io_block.sv
//
// Description :
//   This is just a wrapper for the IO buffers
//
// Notes :
// *****************************************************************************

module aib_io_block #(parameter NumIo = 96)
(
  inout  wire   [ NumIo-1 : 0 ] pad_aib_io,

  // Configuration signals
  input  logic                  c_io_tx_en      [NumIo-1:0],
  input  logic                  c_io_ddr_mode   [NumIo-1:0],
  input  logic                  c_io_async_mode [NumIo-1:0],
  input  logic  [       3 : 0 ] c_drv_strength  [NumIo-1:0],
  input  logic                  c_drv_pull_up   [NumIo-1:0],
  input  logic                  c_drv_pull_down [NumIo-1:0],

  // Tx datapath
  input  logic                  i_tx_clk        [NumIo-1:0],
  input  logic                  i_tx_data0      [NumIo-1:0],
  input  logic                  i_tx_data1      [NumIo-1:0],
  input  logic                  i_tx_data_async [NumIo-1:0],

  // Rx datapath
  input  logic                  i_rx_sample_clk [NumIo-1:0],
  input  logic                  i_rx_retime_clk [NumIo-1:0],
  output logic                  o_rx_data0      [NumIo-1:0],
  output logic                  o_rx_data1      [NumIo-1:0],
  output logic                  o_rx_data_async [NumIo-1:0]
);
  // ---------------------------------------------------------------------------
  generate
    for (genvar gi = 0; gi < NumIo; gi++) begin : io
      aib_io_buffer inst (
        .pad_aib_io       (pad_aib_io      [gi]),

        .c_io_tx_en       (c_io_tx_en      [gi]),
        .c_io_ddr_mode    (c_io_ddr_mode   [gi]),
        .c_io_async_mode  (c_io_async_mode [gi]),
        .c_drv_strength   (c_drv_strength  [gi]),
        .c_drv_pull_up    (c_drv_pull_up   [gi]),
        .c_drv_pull_down  (c_drv_pull_down [gi]),

        .i_tx_clk         (i_tx_clk        [gi]),
        .i_tx_data0       (i_tx_data0      [gi]),
        .i_tx_data1       (i_tx_data1      [gi]),
        .i_tx_data_async  (i_tx_data_async [gi]),

        .i_rx_sample_clk  (i_rx_sample_clk [gi]),
        .i_rx_retime_clk  (i_rx_retime_clk [gi]),
        .o_rx_data0       (o_rx_data0      [gi]),
        .o_rx_data1       (o_rx_data1      [gi]),
        .o_rx_data_async  (o_rx_data_async [gi])
      );
    end
  endgenerate

endmodule

