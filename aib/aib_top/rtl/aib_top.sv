
// *****************************************************************************
// Filename : aib_top.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_top #(NumChannels = 6)
(
  // External (off-chip) interface
  // ---------------------------------------------------------------------------

  // Micro bumps
  output logic  [   1 : 0 ] pad_aib_devdet,
  inout  wire   [  95 : 0 ] pad_aib_io            [NumChannels-1:0],

  // C4 bumps
  input  logic              pad_rst_n,

  input  logic              pad_bypass,
  input  logic              pad_bypass_clk,
  output logic              pad_slow_clk,

  output logic              pad_conf_done,

  output logic              pad_uart_tx,
  input  logic              pad_uart_rx,

  // Internal (on-chip) interface
  // ---------------------------------------------------------------------------

  input  logic              i_ip_clk              [1:0],

  // UMAI master interface
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
  output logic  [ 511 : 0 ] o_umai_slv_rdata      [1:0]
);
  // ---------------------------------------------------------------------------
  logic             sys_rst_n;

  logic             aib_clk;
  logic             bus_clk;

  logic             tx_valid [NumChannels-1:0];
  logic             tx_ready [NumChannels-1:0];
  logic [  71 : 0 ] tx_data  [NumChannels-1:0];

  logic             rx_valid [NumChannels-1:0];
  logic             rx_ready [NumChannels-1:0];
  logic [  71 : 0 ] rx_data  [NumChannels-1:0];

  logic             c_chn_rotated       [NumChannels-1:0];
  logic             c_chn_mst_mode      [NumChannels-1:0];

  logic             c_io_tx_en          [NumChannels-1:0][95:0];
  logic             c_io_ddr_mode       [NumChannels-1:0][95:0];
  logic             c_io_async_mode     [NumChannels-1:0][95:0];

  logic [   3 : 0 ] c_drv_strength      [NumChannels-1:0][95:0];
  logic             c_drv_pull_up       [NumChannels-1:0][95:0];
  logic             c_drv_pull_down     [NumChannels-1:0][95:0];

  logic             c_ns_adapter_rstn   [NumChannels-1:0];
  logic             c_ns_mac_rdy        [NumChannels-1:0];

  logic             c_bypass_word_align [NumChannels-1:0];

  logic             c_ip_sel;
  logic [   2 : 0 ] c_mst_first_chn_id;
  logic [   2 : 0 ] c_mst_last_chn_id;
  logic [   2 : 0 ] c_slv_first_chn_id;
  logic [   2 : 0 ] c_slv_last_chn_id;

  // ---------------------------------------------------------------------------
  aib_top_control u_aib_top_control (
    .i_rst_n        (pad_rst_n),

    .o_sys_rst_n    (sys_rst_n),

    .i_bypass       (pad_bypass),
    .i_bypass_clk   (pad_bypass_clk),

    .o_aib_clk      (aib_clk),
    .o_bus_clk      (bus_clk),

    .o_slow_clk     (pad_slow_clk)
  );

  // ---------------------------------------------------------------------------
  aib_top_reg u_aib_top_reg (
    .i_clk                (bus_clk),
    .i_rst_n              (sys_rst_n),

    .o_uart_tx            (pad_uart_tx),
    .i_uart_rx            (pad_uart_rx),

    .c_io_tx_en           (c_io_tx_en),
    .c_io_ddr_mode        (c_io_ddr_mode),
    .c_io_async_mode      (c_io_async_mode),
    .c_drv_strength       (c_drv_strength),
    .c_drv_pull_up        (c_drv_pull_up),
    .c_drv_pull_down      (c_drv_pull_down),

    .c_chn_rotated        (c_chn_rotated),
    .c_chn_mst_mode       (c_chn_mst_mode),
    .c_ns_adapter_rstn    (c_ns_adapter_rstn),
    .c_ns_mac_rdy         (c_ns_mac_rdy),
    .c_bypass_word_align  (c_bypass_word_align),

    .c_ip_sel             (c_ip_sel),
    .c_mst_first_chn_id   (c_mst_first_chn_id),
    .c_mst_last_chn_id    (c_mst_last_chn_id),
    .c_slv_first_chn_id   (c_slv_first_chn_id),
    .c_slv_last_chn_id    (c_slv_last_chn_id)
  );

  // ---------------------------------------------------------------------------
  umai #(.NumChannels(NumChannels)) u_umai (
    .i_rst_n                  (sys_rst_n),

    .i_ip_clk                 (i_ip_clk),
    .i_bus_clk                (bus_clk),

    .c_ip_sel                 (c_ip_sel),

    // UMAI master interface
    .c_umai_mst_first_chn_id  (c_mst_first_chn_id),
    .c_umai_mst_last_chn_id   (c_mst_last_chn_id),

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
    .c_umai_slv_first_chn_id  (c_slv_first_chn_id),
    .c_umai_slv_last_chn_id   (c_slv_last_chn_id),

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
        .pad_aib_io           (pad_aib_io       [gi]),

        .i_rst_n              (sys_rst_n),

        .c_chn_rotated        (c_chn_rotated        [gi]),
        .c_chn_mst_mode       (c_chn_mst_mode       [gi]),

        .c_io_tx_en           (c_io_tx_en           [gi]),
        .c_io_ddr_mode        (c_io_ddr_mode        [gi]),
        .c_io_async_mode      (c_io_async_mode      [gi]),

        .c_drv_strength       (c_drv_strength       [gi]),
        .c_drv_pull_up        (c_drv_pull_up        [gi]),
        .c_drv_pull_down      (c_drv_pull_down      [gi]),

        .c_ns_adapter_rstn    (c_ns_adapter_rstn    [gi]),
        .c_ns_mac_rdy         (c_ns_mac_rdy         [gi]),

        .c_bypass_word_align  (c_bypass_word_align  [gi]),

        .i_aib_clk            (aib_clk),
        .i_bus_clk            (bus_clk),

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

