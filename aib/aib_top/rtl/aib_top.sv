
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

  input  logic              i_clk,
  input  logic              i_rst_n,

  output logic              o_uart_tx,
  input  logic              i_uart_rx,

  output logic              o_conf_done,

  // UMAI master interface
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
  output logic  [ 511 : 0 ] o_umai_slv_rdata
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

  logic             c_io_tx_en      [NumChannels-1:0][95:0];
  logic             c_io_ddr_mode   [NumChannels-1:0][95:0];
  logic             c_io_async_mode [NumChannels-1:0][95:0];

  logic [   3 : 0 ] c_drv_strength  [NumChannels-1:0][95:0];
  logic             c_drv_pull_up   [NumChannels-1:0][95:0];
  logic             c_drv_pull_down [NumChannels-1:0][95:0];

  // ---------------------------------------------------------------------------
  aib_top_reg u_aib_top_reg (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),

    .o_uart_tx  (o_uart_tx),
    .i_uart_rx  (i_uart_rx)
  );

  // ---------------------------------------------------------------------------
  umai #(.NumChannels(NumChannels)) u_umai (
    .i_clk                    (),
    .i_rst_n                  (i_rst_n),

    // UMAI master interface
    .c_umai_mst_first_chn_id  (),
    .c_umai_mst_last_chn_id   (),

    .o_umai_mst_wcmd_valid    (o_umai_mst_wcmd_valid),
    .i_umai_mst_wcmd_ready    (i_umai_mst_wcmd_ready),
    .o_umai_mst_wcmd_addr     (o_umai_mst_wcmd_addr),
    .o_umai_mst_wcmd_len      (o_umai_mst_wcmd_len),

    .o_umai_mst_rcmd_valid    (o_umai_mst_rcmd_valid),
    .i_umai_mst_rcmd_ready    (i_umai_mst_rcmd_ready),
    .o_umai_mst_rcmd_addr     (o_umai_mst_rcmd_addr),
    .o_umai_mst_rcmd_len      (o_umai_mst_rcmd_len),

    .o_umai_mst_wvalid        (o_umai_mst_wvalid),
    .i_umai_mst_wready        (i_umai_mst_wready),
    .o_umai_mst_wdata         (o_umai_mst_wdata),

    .i_umai_mst_rvalid        (i_umai_mst_rvalid),
    .o_umai_mst_rready        (o_umai_mst_rready),
    .i_umai_mst_rdata         (i_umai_mst_rdata),

    // UMAI slave interface
    .c_umai_slv_first_chn_id  (),
    .c_umai_slv_last_chn_id   (),

    .i_umai_slv_wcmd_valid    (i_umai_slv_wcmd_valid),
    .o_umai_slv_wcmd_ready    (o_umai_slv_wcmd_ready),
    .i_umai_slv_wcmd_addr     (i_umai_slv_wcmd_addr),
    .i_umai_slv_wcmd_len      (i_umai_slv_wcmd_len),

    .i_umai_slv_rcmd_valid    (i_umai_slv_rcmd_valid),
    .o_umai_slv_rcmd_ready    (o_umai_slv_rcmd_ready),
    .i_umai_slv_rcmd_addr     (i_umai_slv_rcmd_addr),
    .i_umai_slv_rcmd_len      (i_umai_slv_rcmd_len),

    .i_umai_slv_wvalid        (i_umai_slv_wvalid),
    .o_umai_slv_wready        (o_umai_slv_wready),
    .i_umai_slv_wdata         (i_umai_slv_wdata),

    .o_umai_slv_rvalid        (o_umai_slv_rvalid),
    .i_umai_slv_rready        (i_umai_slv_rready),
    .o_umai_slv_rdata         (o_umai_slv_rdata),

    // AIB interface
    .o_tx_valid               (tx_valid),
    .i_tx_ready               (tx_ready),
    .o_tx_data                (tx_data),

    .i_rx_valid               (rx_valid),
    .o_rx_ready               (rx_ready),
    .i_rx_data                (rx_data)
  );

  // ---------------------------------------------------------------------------
  generate
    for (genvar gi = 0; gi < NumChannels; gi++) begin: u_aib_channels
      aib_channel inst (
        .iopad                (iopad            [gi]),

        .i_rst_n              (i_rst_n),

        .c_chn_rotated        (c_chn_rotated    [gi]),
        .c_chn_mst_mode       (c_chn_mst_mode   [gi]),

        .c_io_tx_en           (c_io_tx_en       [gi]),
        .c_io_ddr_mode        (c_io_ddr_mode    [gi]),
        .c_io_async_mode      (c_io_async_mode  [gi]),

        .c_drv_strength       (c_drv_strength   [gi]),
        .c_drv_pull_up        (c_drv_pull_up    [gi]),
        .c_drv_pull_down      (c_drv_pull_down  [gi]),

        .c_ns_adapter_rstn    (),
        .c_ns_mac_rdy         (),

        .c_bypass_word_align  (),

        .i_aib_clk            (),
        .i_bus_clk            (),

        .i_tx_valid           (tx_valid [gi]),
        .o_tx_ready           (tx_ready [gi]),
        .i_tx_data            (tx_data  [gi]),

        .o_rx_valid           (rx_valid [gi]),
        .i_rx_ready           (rx_ready [gi]),
        .o_rx_data            (rx_data  [gi])
      );
    end
  endgenerate

endmodule

