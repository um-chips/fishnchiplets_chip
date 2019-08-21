
// *****************************************************************************
// Filename : umai.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module umai #(NumChannels = 6)
(
  input  logic              i_clk,
  input  logic              i_rst_n,

  // UMAI master interface
  input  logic  [   2 : 0 ] c_umai_mst_first_chn_id,
  input  logic  [   2 : 0 ] c_umai_mst_last_chn_id,

  output logic              o_umai_mst_wcmd_valid,
  input  logic              i_umai_mst_wcmd_ready,
  output logic  [  31 : 0 ] o_umai_mst_wcmd_addr,
  output logic  [   5 : 0 ] o_umai_mst_wcmd_len,

  output logic              o_umai_mst_rcmd_valid,
  input  logic              i_umai_mst_rcmd_ready,
  output logic  [  31 : 0 ] o_umai_mst_rcmd_addr,
  output logic  [   5 : 0 ] o_umai_mst_rcmd_len,

  output logic              o_umai_mst_wvalid,
  input  logic              i_umai_mst_wready,
  output logic  [ 511 : 0 ] o_umai_mst_wdata,

  input  logic              i_umai_mst_rvalid,
  output logic              o_umai_mst_rready,
  input  logic  [ 511 : 0 ] i_umai_mst_rdata,

  // UMAI slave interface
  input  logic  [   2 : 0 ] c_umai_slv_first_chn_id,
  input  logic  [   2 : 0 ] c_umai_slv_last_chn_id,

  input  logic              i_umai_slv_wcmd_valid,
  output logic              o_umai_slv_wcmd_ready,
  input  logic  [  31 : 0 ] i_umai_slv_wcmd_addr,
  input  logic  [   5 : 0 ] i_umai_slv_wcmd_len,

  input  logic              i_umai_slv_rcmd_valid,
  output logic              o_umai_slv_rcmd_ready,
  input  logic  [  31 : 0 ] i_umai_slv_rcmd_addr,
  input  logic  [   5 : 0 ] i_umai_slv_rcmd_len,

  input  logic              i_umai_slv_wvalid,
  output logic              o_umai_slv_wready,
  input  logic  [ 511 : 0 ] i_umai_slv_wdata,

  output logic              o_umai_slv_rvalid,
  input  logic              i_umai_slv_rready,
  output logic  [ 511 : 0 ] o_umai_slv_rdata,

  // AIB interface
  output logic              o_tx_valid [NumChannels-1:0],
  input  logic              i_tx_ready [NumChannels-1:0],
  output logic  [  71 : 0 ] o_tx_data  [NumChannels-1:0],

  input  logic              i_rx_valid [NumChannels-1:0],
  output logic              o_rx_ready [NumChannels-1:0],
  input  logic  [  71 : 0 ] i_rx_data  [NumChannels-1:0]
);

  // ---------------------------------------------------------------------------
  umai_master #(.NumChannels(NumChannels)) u_umai_master (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),

    .c_first_chn_id     (c_umai_mst_first_chn_id),
    .c_last_chn_id      (c_umai_mst_last_chn_id),

    // UMAI master interface
    .o_umai_wcmd_valid  (o_umai_mst_wcmd_valid),
    .i_umai_wcmd_ready  (i_umai_mst_wcmd_ready),
    .o_umai_wcmd_addr   (o_umai_mst_wcmd_addr),
    .o_umai_wcmd_len    (o_umai_mst_wcmd_len),

    .o_umai_rcmd_valid  (o_umai_mst_rcmd_valid),
    .i_umai_rcmd_ready  (i_umai_mst_rcmd_ready),
    .o_umai_rcmd_addr   (o_umai_mst_rcmd_addr),
    .o_umai_rcmd_len    (o_umai_mst_rcmd_len),

    .o_umai_wvalid      (o_umai_mst_wvalid),
    .i_umai_wready      (i_umai_mst_wready),
    .o_umai_wdata       (o_umai_mst_wdata),

    .i_umai_rvalid      (i_umai_mst_rvalid),
    .o_umai_rready      (o_umai_mst_rready),
    .i_umai_rdata       (i_umai_mst_rdata),

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
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),

    .c_first_chn_id     (c_umai_slv_first_chn_id),
    .c_last_chn_id      (c_umai_slv_last_chn_id),

    // UMAI slave interface
    .i_umai_wcmd_valid  (i_umai_slv_wcmd_valid),
    .o_umai_wcmd_ready  (o_umai_slv_wcmd_ready),
    .i_umai_wcmd_addr   (i_umai_slv_wcmd_addr),
    .i_umai_wcmd_len    (i_umai_slv_wcmd_len),

    .i_umai_rcmd_valid  (i_umai_slv_rcmd_valid),
    .o_umai_rcmd_ready  (o_umai_slv_rcmd_ready),
    .i_umai_rcmd_addr   (i_umai_slv_rcmd_addr),
    .i_umai_rcmd_len    (i_umai_slv_rcmd_len),

    .i_umai_wvalid      (i_umai_slv_wvalid),
    .o_umai_wready      (o_umai_slv_wready),
    .i_umai_wdata       (i_umai_slv_wdata),

    .o_umai_rvalid      (o_umai_slv_rvalid),
    .i_umai_rready      (i_umai_slv_rready),
    .o_umai_rdata       (o_umai_slv_rdata),

    // AIB interface
    .o_tx_valid         (),
    .i_tx_ready         (),
    .o_tx_data          (),

    .i_rx_valid         (),
    .o_rx_ready         (),
    .i_rx_data          ()
  );

endmodule

