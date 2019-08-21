
// *****************************************************************************
// Filename : aib_top.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_top #(NumChannels = 6)
(
  inout  wire   [  95 : 0 ] iopad [NumChannels-1:0],

  input  logic              i_rst_n,

  // UMAI master interface
  output logic  [  31 : 0 ] o_umai_mst_caddr,
  output logic  [   5 : 0 ] o_umai_mst_clen,
  output logic              o_umai_mst_ctype,
  output logic              o_umai_mst_cvalid,
  input  logic              i_umai_mst_cready,

  output logic  [ 511 : 0 ] o_umai_mst_wdata,
  output logic              o_umai_mst_wvalid,
  input  logic              i_umai_mst_wready,

  input  logic  [ 511 : 0 ] i_umai_mst_rdata,
  input  logic              i_umai_mst_rvalid,
  output logic              o_umai_mst_rready,

  // UMAI slave interface
  input  logic  [  31 : 0 ] i_umai_slv_caddr,
  input  logic  [   5 : 0 ] i_umai_slv_clen,
  input  logic              i_umai_slv_ctype,
  input  logic              i_umai_slv_cvalid,
  output logic              o_umai_slv_cready,

  input  logic  [ 511 : 0 ] i_umai_slv_wdata,
  input  logic              i_umai_slv_wvalid,
  output logic              o_umai_slv_wready,

  output logic  [ 511 : 0 ] o_umai_slv_rdata,
  output logic              o_umai_slv_rvalid,
  input  logic              i_umai_slv_rready
);
  // ---------------------------------------------------------------------------
  logic             tx_valid [NumChannels-1:0];
  logic             tx_ready [NumChannels-1:0];
  logic [  71 : 0 ] tx_data  [NumChannels-1:0];

  logic             rx_valid [NumChannels-1:0];
  logic             rx_ready [NumChannels-1:0];
  logic [  71 : 0 ] rx_data  [NumChannels-1:0];

  logic             c_chn_rotated   [NumChannels-1:0];
  logic             c_chn_mst_mode  [NumChannels-1:0];
  logic             c_chn_ddr_mode  [NumChannels-1:0];
  logic             c_io_tx_en      [NumChannels-1:0][95:0];
  logic             c_io_ddr_mode   [NumChannels-1:0][95:0];
  logic             c_io_async_mode [NumChannels-1:0][95:0];
  logic [   3 : 0 ] c_drv_strength  [NumChannels-1:0][95:0];
  logic             c_drv_pull_up   [NumChannels-1:0][95:0];
  logic             c_drv_pull_down [NumChannels-1:0][95:0];

  umai_master #(.NumChannels(NumChannels)) u_umai_master (
    .i_clk              (),
    .i_rst_n            (i_rst_n),

    .c_first_chn_id     (),
    .c_last_chn_id      (),

    // UMAI master interface
    .o_umai_wcmd_valid  (),
    .i_umai_wcmd_ready  (),
    .o_umai_wcmd_addr   (),
    .o_umai_wcmd_len    (),

    .o_umai_rcmd_valid  (),
    .i_umai_rcmd_ready  (),
    .o_umai_rcmd_addr   (),
    .o_umai_rcmd_len    (),

    .o_umai_wvalid      (),
    .i_umai_wready      (),
    .o_umai_wdata       (),

    .i_umai_rvalid      (),
    .o_umai_rready      (),
    .i_umai_rdata       (),

    // AIB interface
    .o_tx_valid         (),
    .i_tx_ready         (),
    .o_tx_data          (),

    .i_rx_valid         (),
    .o_rx_ready         (),
    .i_rx_data          ()
  );

  // ---------------------------------------------------------------------------
  umai_slave #(.NumChannels(NumChannels)) u_umai_slave (
    .i_clk              (),
    .i_rst_n            (i_rst_n),

    .c_first_chn_id     (),
    .c_last_chn_id      (),

    // UMAI slave interface
    .i_umai_wcmd_valid  (),
    .o_umai_wcmd_ready  (),
    .i_umai_wcmd_addr   (),
    .i_umai_wcmd_len    (),

    .i_umai_rcmd_valid  (),
    .o_umai_rcmd_ready  (),
    .i_umai_rcmd_addr   (),
    .i_umai_rcmd_len    (),

    .i_umai_wvalid      (),
    .o_umai_wready      (),
    .i_umai_wdata       (),

    .o_umai_rvalid      (),
    .i_umai_rready      (),
    .o_umai_rdata       (),

    // AIB interface
    .o_tx_valid         (),
    .i_tx_ready         (),
    .o_tx_data          (),

    .i_rx_valid         (),
    .o_rx_ready         (),
    .i_rx_data          ()
  );

  // ---------------------------------------------------------------------------
  aib_channel u_aib_channels [NumChannels-1:0] (
    .iopad                (iopad),

    .i_rst_n              (i_rst_n),

    .c_chn_rotated        (c_chn_rotated),
    .c_chn_mst_mode       (c_chn_mst_mode),

    .c_io_tx_en           (c_io_tx_en),
    .c_io_ddr_mode        (c_io_ddr_mode),
    .c_io_async_mode      (c_io_async_mode),

    .c_drv_strength       (c_drv_strength),
    .c_drv_pull_up        (c_drv_pull_up),
    .c_drv_pull_down      (c_drv_pull_down),

    .c_ns_adapter_rstn    (),
    .c_ns_mac_rdy         (),

    .c_bypass_word_align  (),

    .i_aib_clk            (),
    .i_bus_clk            (),

    .i_tx_valid           (tx_valid),
    .o_tx_ready           (tx_ready),
    .i_tx_data            (tx_data),

    .o_rx_valid           (rx_valid),
    .i_rx_ready           (rx_ready),
    .o_rx_data            (rx_data)
  );

endmodule

