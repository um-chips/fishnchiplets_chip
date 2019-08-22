
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

  output logic              o_umai_mst_wcmd_valid [1:0],
  input  logic              i_umai_mst_wcmd_ready [1:0],
  output logic  [  31 : 0 ] o_umai_mst_wcmd_addr  [1:0],
  output logic  [   5 : 0 ] o_umai_mst_wcmd_len   [1:0],

  output logic              o_umai_mst_rcmd_valid [1:0],
  input  logic              i_umai_mst_rcmd_ready [1:0],
  output logic  [  31 : 0 ] o_umai_mst_rcmd_addr  [1:0],
  output logic  [   5 : 0 ] o_umai_mst_rcmd_len   [1:0],

  output logic              o_umai_mst_wvalid     [1:0],
  input  logic              i_umai_mst_wready     [1:0],
  output logic  [ 511 : 0 ] o_umai_mst_wdata      [1:0],

  input  logic              i_umai_mst_rvalid     [1:0],
  output logic              o_umai_mst_rready     [1:0],
  input  logic  [ 511 : 0 ] i_umai_mst_rdata      [1:0],

  // UMAI slave interface
  input  logic  [   2 : 0 ] c_umai_slv_first_chn_id,
  input  logic  [   2 : 0 ] c_umai_slv_last_chn_id,

  input  logic              i_umai_slv_wcmd_valid [1:0],
  output logic              o_umai_slv_wcmd_ready [1:0],
  input  logic  [  31 : 0 ] i_umai_slv_wcmd_addr  [1:0],
  input  logic  [   5 : 0 ] i_umai_slv_wcmd_len   [1:0],

  input  logic              i_umai_slv_rcmd_valid [1:0],
  output logic              o_umai_slv_rcmd_ready [1:0],
  input  logic  [  31 : 0 ] i_umai_slv_rcmd_addr  [1:0],
  input  logic  [   5 : 0 ] i_umai_slv_rcmd_len   [1:0],

  input  logic              i_umai_slv_wvalid     [1:0],
  output logic              o_umai_slv_wready     [1:0],
  input  logic  [ 511 : 0 ] i_umai_slv_wdata      [1:0],

  output logic              o_umai_slv_rvalid     [1:0],
  input  logic              i_umai_slv_rready     [1:0],
  output logic  [ 511 : 0 ] o_umai_slv_rdata      [1:0],

  // AIB interface
  output logic              o_tx_valid [NumChannels-1:0],
  input  logic              i_tx_ready [NumChannels-1:0],
  output logic  [  71 : 0 ] o_tx_data  [NumChannels-1:0],

  input  logic              i_rx_valid [NumChannels-1:0],
  output logic              o_rx_ready [NumChannels-1:0],
  input  logic  [  71 : 0 ] i_rx_data  [NumChannels-1:0]
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic             umai_mst_wcmd_valid;
  logic             umai_mst_wcmd_ready;
  logic [  31 : 0 ] umai_mst_wcmd_addr;
  logic [   5 : 0 ] umai_mst_wcmd_len;

  logic             umai_mst_rcmd_valid;
  logic             umai_mst_rcmd_ready;
  logic [  31 : 0 ] umai_mst_rcmd_addr;
  logic [   5 : 0 ] umai_mst_rcmd_len;

  logic             umai_mst_wvalid;
  logic             umai_mst_wready;
  logic [ 511 : 0 ] umai_mst_wdata;

  logic             umai_mst_rvalid;
  logic             umai_mst_rready;
  logic [ 511 : 0 ] umai_mst_rdata;

  logic             umai_slv_wcmd_valid;
  logic             umai_slv_wcmd_ready;
  logic [  31 : 0 ] umai_slv_wcmd_addr;
  logic [   5 : 0 ] umai_slv_wcmd_len;

  logic             umai_slv_rcmd_valid;
  logic             umai_slv_rcmd_ready;
  logic [  31 : 0 ] umai_slv_rcmd_addr;
  logic [   5 : 0 ] umai_slv_rcmd_len;

  logic             umai_slv_wvalid;
  logic             umai_slv_wready;
  logic [ 511 : 0 ] umai_slv_wdata;

  logic             umai_slv_rvalid;
  logic             umai_slv_rready;
  logic [ 511 : 0 ] umai_slv_rdata;

  // ---------------------------------------------------------------------------
  umai_arb_afifo #(.NumChannels(NumChannels)) u_umai_arb_afifo (
    .i_clk                (i_clk),

    .i_rst_n              (i_rst_n),

    // External interface - connected to the two designs
    // -------------------------------------------------------------------------

    // UMAI master
    .o_ext_mst_wcmd_valid (o_umai_mst_wcmd_valid),
    .i_ext_mst_wcmd_ready (i_umai_mst_wcmd_ready),
    .o_ext_mst_wcmd_addr  (o_umai_mst_wcmd_addr),
    .o_ext_mst_wcmd_len   (o_umai_mst_wcmd_len),

    .o_ext_mst_rcmd_valid (o_umai_mst_rcmd_valid),
    .i_ext_mst_rcmd_ready (i_umai_mst_rcmd_ready),
    .o_ext_mst_rcmd_addr  (o_umai_mst_rcmd_addr),
    .o_ext_mst_rcmd_len   (o_umai_mst_rcmd_len),

    .o_ext_mst_wvalid     (o_umai_mst_wvalid),
    .i_ext_mst_wready     (i_umai_mst_wready),
    .o_ext_mst_wdata      (o_umai_mst_wdata),

    .i_ext_mst_rvalid     (i_umai_mst_rvalid),
    .o_ext_mst_rready     (o_umai_mst_rready),
    .i_ext_mst_rdata      (i_umai_mst_rdata),

    // UMAI slave
    .i_ext_slv_wcmd_valid (i_umai_slv_wcmd_valid),
    .o_ext_slv_wcmd_ready (o_umai_slv_wcmd_ready),
    .i_ext_slv_wcmd_addr  (i_umai_slv_wcmd_addr),
    .i_ext_slv_wcmd_len   (i_umai_slv_wcmd_len),

    .i_ext_slv_rcmd_valid (i_umai_slv_rcmd_valid),
    .o_ext_slv_rcmd_ready (o_umai_slv_rcmd_ready),
    .i_ext_slv_rcmd_addr  (i_umai_slv_rcmd_addr),
    .i_ext_slv_rcmd_len   (i_umai_slv_rcmd_len),

    .i_ext_slv_wvalid     (i_umai_slv_wvalid),
    .o_ext_slv_wready     (o_umai_slv_wready),
    .i_ext_slv_wdata      (i_umai_slv_wdata),

    .o_ext_slv_rvalid     (o_umai_slv_rvalid),
    .i_ext_slv_rready     (i_umai_slv_rready),
    .o_ext_slv_rdata      (o_umai_slv_rdata),

    // Internal interface - connected to the umai_master/slave module
    // -------------------------------------------------------------------------

    // UMAI master
    .i_int_mst_wcmd_valid (umai_mst_wcmd_valid),
    .o_int_mst_wcmd_ready (umai_mst_wcmd_ready),
    .i_int_mst_wcmd_addr  (umai_mst_wcmd_addr),
    .i_int_mst_wcmd_len   (umai_mst_wcmd_len),

    .i_int_mst_rcmd_valid (umai_mst_rcmd_valid),
    .o_int_mst_rcmd_ready (umai_mst_rcmd_ready),
    .i_int_mst_rcmd_addr  (umai_mst_rcmd_addr),
    .i_int_mst_rcmd_len   (umai_mst_rcmd_len),

    .i_int_mst_wvalid     (umai_mst_wvalid),
    .o_int_mst_wready     (umai_mst_wready),
    .i_int_mst_wdata      (umai_mst_wdata),

    .o_int_mst_rvalid     (umai_mst_rvalid),
    .i_int_mst_rready     (umai_mst_rready),
    .o_int_mst_rdata      (umai_mst_rdata),

    // UMAI slave
    .o_int_slv_wcmd_valid (umai_slv_wcmd_valid),
    .i_int_slv_wcmd_ready (umai_slv_wcmd_ready),
    .o_int_slv_wcmd_addr  (umai_slv_wcmd_addr),
    .o_int_slv_wcmd_len   (umai_slv_wcmd_len),

    .o_int_slv_rcmd_valid (umai_slv_rcmd_valid),
    .i_int_slv_rcmd_ready (umai_slv_rcmd_ready),
    .o_int_slv_rcmd_addr  (umai_slv_rcmd_addr),
    .o_int_slv_rcmd_len   (umai_slv_rcmd_len),

    .o_int_slv_wvalid     (umai_slv_wvalid),
    .i_int_slv_wready     (umai_slv_wready),
    .o_int_slv_wdata      (umai_slv_wdata),

    .i_int_slv_rvalid     (umai_slv_rvalid),
    .o_int_slv_rready     (umai_slv_rready),
    .i_int_slv_rdata      (umai_slv_rdata)
  );

  // ---------------------------------------------------------------------------
  umai_master #(.NumChannels(NumChannels)) u_umai_master (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),

    .c_first_chn_id     (c_umai_mst_first_chn_id),
    .c_last_chn_id      (c_umai_mst_last_chn_id),

    // UMAI master interface
    .o_umai_wcmd_valid  (umai_mst_wcmd_valid),
    .i_umai_wcmd_ready  (umai_mst_wcmd_ready),
    .o_umai_wcmd_addr   (umai_mst_wcmd_addr),
    .o_umai_wcmd_len    (umai_mst_wcmd_len),

    .o_umai_rcmd_valid  (umai_mst_rcmd_valid),
    .i_umai_rcmd_ready  (umai_mst_rcmd_ready),
    .o_umai_rcmd_addr   (umai_mst_rcmd_addr),
    .o_umai_rcmd_len    (umai_mst_rcmd_len),

    .o_umai_wvalid      (umai_mst_wvalid),
    .i_umai_wready      (umai_mst_wready),
    .o_umai_wdata       (umai_mst_wdata),

    .i_umai_rvalid      (umai_mst_rvalid),
    .o_umai_rready      (umai_mst_rready),
    .i_umai_rdata       (umai_mst_rdata),

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
    .i_umai_wcmd_valid  (umai_slv_wcmd_valid),
    .o_umai_wcmd_ready  (umai_slv_wcmd_ready),
    .i_umai_wcmd_addr   (umai_slv_wcmd_addr),
    .i_umai_wcmd_len    (umai_slv_wcmd_len),

    .i_umai_rcmd_valid  (umai_slv_rcmd_valid),
    .o_umai_rcmd_ready  (umai_slv_rcmd_ready),
    .i_umai_rcmd_addr   (umai_slv_rcmd_addr),
    .i_umai_rcmd_len    (umai_slv_rcmd_len),

    .i_umai_wvalid      (umai_slv_wvalid),
    .o_umai_wready      (umai_slv_wready),
    .i_umai_wdata       (umai_slv_wdata),

    .o_umai_rvalid      (umai_slv_rvalid),
    .i_umai_rready      (umai_slv_rready),
    .o_umai_rdata       (umai_slv_rdata),

    // AIB interface
    .o_tx_valid         (),
    .i_tx_ready         (),
    .o_tx_data          (),

    .i_rx_valid         (),
    .o_rx_ready         (),
    .i_rx_data          ()
  );

endmodule

