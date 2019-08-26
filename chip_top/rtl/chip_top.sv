
// *****************************************************************************
// Filename : chip_top.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module chip_top #(parameter NumChannels = 6)
(
  // External (off-chip) interface
  // ---------------------------------------------------------------------------

  // Micro bumps
  output logic  [   1 : 0 ] pad_aib_devdet,
  inout  wire   [  95 : 0 ] pad_aib_io            [NumChannels-1:0],

  // C4 bumps
  inout  wire               pad_conf_done,

  input  logic              pad_rst_n,

  input  logic              pad_bypass,
  input  logic              pad_bypass_clk,
  output logic              pad_slow_clk,

  output logic              pad_uart_tx,
  input  logic              pad_uart_rx
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic             ip_clk              [1:0];

  // UMAI master interface
  logic             umai_mst_wcmd_valid [1:0];
  logic             umai_mst_wcmd_ready [1:0] `ifdef SIM = '{default: 1} `endif;
  logic [  31 : 0 ] umai_mst_wcmd_addr  [1:0];
  logic [   5 : 0 ] umai_mst_wcmd_len   [1:0];

  logic             umai_mst_rcmd_valid [1:0];
  logic             umai_mst_rcmd_ready [1:0] `ifdef SIM = '{default: 1} `endif;
  logic [  31 : 0 ] umai_mst_rcmd_addr  [1:0];
  logic [   5 : 0 ] umai_mst_rcmd_len   [1:0];

  logic             umai_mst_wvalid     [1:0];
  logic             umai_mst_wready     [1:0] `ifdef SIM = '{default: 1} `endif;
  logic [ 511 : 0 ] umai_mst_wdata      [1:0];

  logic             umai_mst_rvalid     [1:0] `ifdef SIM = '{default: 0} `endif;
  logic             umai_mst_rready     [1:0];
  logic [ 511 : 0 ] umai_mst_rdata      [1:0] `ifdef SIM = '{default: 0} `endif;

  // UMAI slave interface
  logic             umai_slv_wcmd_valid [1:0] `ifdef SIM = '{default: 0} `endif;
  logic             umai_slv_wcmd_ready [1:0];
  logic [  31 : 0 ] umai_slv_wcmd_addr  [1:0] `ifdef SIM = '{default: 0} `endif;
  logic [   5 : 0 ] umai_slv_wcmd_len   [1:0] `ifdef SIM = '{default: 0} `endif;

  logic             umai_slv_rcmd_valid [1:0] `ifdef SIM = '{default: 0} `endif;
  logic             umai_slv_rcmd_ready [1:0];
  logic [  31 : 0 ] umai_slv_rcmd_addr  [1:0] `ifdef SIM = '{default: 0} `endif;
  logic [   5 : 0 ] umai_slv_rcmd_len   [1:0] `ifdef SIM = '{default: 0} `endif;

  logic             umai_slv_wvalid     [1:0] `ifdef SIM = '{default: 0} `endif;
  logic             umai_slv_wready     [1:0];
  logic [ 511 : 0 ] umai_slv_wdata      [1:0] `ifdef SIM = '{default: 0} `endif;

  logic             umai_slv_rvalid     [1:0];
  logic             umai_slv_rready     [1:0] `ifdef SIM = '{default: 1} `endif;
  logic [ 511 : 0 ] umai_slv_rdata      [1:0];

  // ---------------------------------------------------------------------------
  aib_top #(.NumChannels(NumChannels)) u_aib_top (

    // External (off-chip) interface
    // ---------------------------------------------------------------------------
    // Micro bumps
    .pad_aib_devdet         (pad_aib_devdet),
    .pad_aib_io             (pad_aib_io),

    // C4 bumps
    .pad_conf_done          (pad_conf_done),

    .pad_rst_n              (pad_rst_n),

    .pad_bypass             (pad_bypass),
    .pad_bypass_clk         (pad_bypass_clk),
    .pad_slow_clk           (pad_slow_clk),

    .pad_uart_tx            (pad_uart_tx),
    .pad_uart_rx            (pad_uart_rx),

    // Internal (on-chip) interface
    // ---------------------------------------------------------------------------
    .i_ip_clk               (ip_clk),

    // UMAI master interface
    .o_umai_mst_wcmd_valid  (umai_mst_wcmd_valid),
    .i_umai_mst_wcmd_ready  (umai_mst_wcmd_ready),
    .o_umai_mst_wcmd_addr   (umai_mst_wcmd_addr),
    .o_umai_mst_wcmd_len    (umai_mst_wcmd_len),

    .o_umai_mst_rcmd_valid  (umai_mst_rcmd_valid),
    .i_umai_mst_rcmd_ready  (umai_mst_rcmd_ready),
    .o_umai_mst_rcmd_addr   (umai_mst_rcmd_addr),
    .o_umai_mst_rcmd_len    (umai_mst_rcmd_len),

    .o_umai_mst_wvalid      (umai_mst_wvalid),
    .i_umai_mst_wready      (umai_mst_wready),
    .o_umai_mst_wdata       (umai_mst_wdata),

    .i_umai_mst_rvalid      (umai_mst_rvalid),
    .o_umai_mst_rready      (umai_mst_rready),
    .i_umai_mst_rdata       (umai_mst_rdata),

    // UMAI slave interface
    .i_umai_slv_wcmd_valid  (umai_slv_wcmd_valid),
    .o_umai_slv_wcmd_ready  (umai_slv_wcmd_ready),
    .i_umai_slv_wcmd_addr   (umai_slv_wcmd_addr),
    .i_umai_slv_wcmd_len    (umai_slv_wcmd_len),

    .i_umai_slv_rcmd_valid  (umai_slv_rcmd_valid),
    .o_umai_slv_rcmd_ready  (umai_slv_rcmd_ready),
    .i_umai_slv_rcmd_addr   (umai_slv_rcmd_addr),
    .i_umai_slv_rcmd_len    (umai_slv_rcmd_len),

    .i_umai_slv_wvalid      (umai_slv_wvalid),
    .o_umai_slv_wready      (umai_slv_wready),
    .i_umai_slv_wdata       (umai_slv_wdata),

    .o_umai_slv_rvalid      (umai_slv_rvalid),
    .i_umai_slv_rready      (umai_slv_rready),
    .o_umai_slv_rdata       (umai_slv_rdata)
  );

  // ---------------------------------------------------------------------------
`ifdef SIM
  assign ip_clk = '{u_aib_top.u_aib_top_control.o_bus_clk,
                    u_aib_top.u_aib_top_control.o_bus_clk};

  initial begin
    @(posedge pad_conf_done);

    @(posedge u_aib_top.u_aib_top_control.o_bus_clk); #0.1;
      umai_slv_wcmd_valid[0] = 1'b1;
      umai_slv_wcmd_addr [0] = 32'hdeadbeef;
      umai_slv_wcmd_len  [0] = 6'd0;

    @(posedge u_aib_top.u_aib_top_control.o_bus_clk); #0.1;
      umai_slv_wcmd_valid[0] = 1'b0;

    @(posedge u_aib_top.u_aib_top_control.o_bus_clk); #0.1;
      umai_slv_wvalid[0] = 1'b1;
      umai_slv_wdata [0] = {16{32'hdeadbee0}};

    @(posedge u_aib_top.u_aib_top_control.o_bus_clk); #0.1;
      umai_slv_wvalid[0] = 1'b0;
  end
`endif

endmodule

