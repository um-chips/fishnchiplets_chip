
// *****************************************************************************
// Filename : umai_model_2chiplets.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module umai_model_2chiplets
(
  input  logic              i_clk,
  input  logic              i_rst_n,

  // UMAI slave port on chiplet 0
  input  logic              i_umai_chiplet0_wcmd_valid,
  output logic              o_umai_chiplet0_wcmd_ready,
  input  logic  [  31 : 0 ] i_umai_chiplet0_wcmd_addr,
  input  logic  [   5 : 0 ] i_umai_chiplet0_wcmd_len,

  input  logic              i_umai_chiplet0_rcmd_valid,
  output logic              o_umai_chiplet0_rcmd_ready,
  input  logic  [  31 : 0 ] i_umai_chiplet0_rcmd_addr,
  input  logic  [   5 : 0 ] i_umai_chiplet0_rcmd_len,

  input  logic              i_umai_chiplet0_wvalid,
  output logic              o_umai_chiplet0_wready,
  input  logic  [ 511 : 0 ] i_umai_chiplet0_wdata,

  output logic              o_umai_chiplet0_rvalid,
  input  logic              i_umai_chiplet0_rready,
  output logic  [ 511 : 0 ] o_umai_chiplet0_rdata,

  // UMAI master port on chiplet 1
  output logic              o_umai_chiplet1_wcmd_valid,
  input  logic              i_umai_chiplet1_wcmd_ready,
  output logic  [  31 : 0 ] o_umai_chiplet1_wcmd_addr,
  output logic  [   5 : 0 ] o_umai_chiplet1_wcmd_len,

  output logic              o_umai_chiplet1_rcmd_valid,
  input  logic              i_umai_chiplet1_rcmd_ready,
  output logic  [  31 : 0 ] o_umai_chiplet1_rcmd_addr,
  output logic  [   5 : 0 ] o_umai_chiplet1_rcmd_len,

  output logic              o_umai_chiplet1_wvalid,
  input  logic              i_umai_chiplet1_wready,
  output logic  [ 511 : 0 ] o_umai_chiplet1_wdata,

  input  logic              i_umai_chiplet1_rvalid,
  output logic              o_umai_chiplet1_rready,
  input  logic  [ 511 : 0 ] i_umai_chiplet1_rdata
);
  // Parameters
  // ---------------------------------------------------------------------------

  localparam NumChiplets = 2;
  localparam NumChannels = 6;

  localparam FirstChannelId = 3'd0;
  localparam LastChannelId  = 3'd5;

  // Signal declarations
  // ---------------------------------------------------------------------------

  logic             aib_valid [NumChiplets-1:0] [NumChannels-1:0];
  logic             aib_ready [NumChiplets-1:0] [NumChannels-1:0];
  logic [  71 : 0 ] aib_data  [NumChiplets-1:0] [NumChannels-1:0];

  // ---------------------------------------------------------------------------
  // UMAI on chiplet 0 is a slave port
  // ---------------------------------------------------------------------------

  umai_slave #(.NumChannels(NumChannels)) u_umai_chiplet0 (
    .i_clk             (i_clk),
    .i_rst_n           (i_rst_n),

    .c_first_chn_id    (FirstChannelId),
    .c_last_chn_id     (LastChannelId),

    .i_umai_wcmd_valid (i_umai_chiplet0_wcmd_valid),
    .o_umai_wcmd_ready (o_umai_chiplet0_wcmd_ready),
    .i_umai_wcmd_addr  (i_umai_chiplet0_wcmd_addr),
    .i_umai_wcmd_len   (i_umai_chiplet0_wcmd_len),

    .i_umai_rcmd_valid (i_umai_chiplet0_rcmd_valid),
    .o_umai_rcmd_ready (o_umai_chiplet0_rcmd_ready),
    .i_umai_rcmd_addr  (i_umai_chiplet0_rcmd_addr),
    .i_umai_rcmd_len   (i_umai_chiplet0_rcmd_len),

    .i_umai_wvalid     (i_umai_chiplet0_wvalid),
    .o_umai_wready     (o_umai_chiplet0_wready),
    .i_umai_wdata      (i_umai_chiplet0_wdata),

    .o_umai_rvalid     (o_umai_chiplet0_rvalid),
    .i_umai_rready     (i_umai_chiplet0_rready),
    .o_umai_rdata      (o_umai_chiplet0_rdata),

    .o_tx_valid        (aib_valid[0]),
    .i_tx_ready        (aib_ready[0]),
    .o_tx_data         (aib_data [0]),

    .i_rx_valid        (aib_valid[1]),
    .o_rx_ready        (aib_ready[1]),
    .i_rx_data         (aib_data [1])
  );

  // ---------------------------------------------------------------------------
  // UMAI on chiplet 1 is a master port
  // ---------------------------------------------------------------------------

  umai_master #(.NumChannels(NumChannels)) u_umai_chiplet1 (
    .i_clk             (i_clk),
    .i_rst_n           (i_rst_n),

    .c_first_chn_id    (FirstChannelId),
    .c_last_chn_id     (LastChannelId),

    .o_umai_wcmd_valid (o_umai_chiplet1_wcmd_valid),
    .i_umai_wcmd_ready (i_umai_chiplet1_wcmd_ready),
    .o_umai_wcmd_addr  (o_umai_chiplet1_wcmd_addr),
    .o_umai_wcmd_len   (o_umai_chiplet1_wcmd_len),

    .o_umai_rcmd_valid (o_umai_chiplet1_rcmd_valid),
    .i_umai_rcmd_ready (i_umai_chiplet1_rcmd_ready),
    .o_umai_rcmd_addr  (o_umai_chiplet1_rcmd_addr),
    .o_umai_rcmd_len   (o_umai_chiplet1_rcmd_len),

    .o_umai_wvalid     (o_umai_chiplet1_wvalid),
    .i_umai_wready     (i_umai_chiplet1_wready),
    .o_umai_wdata      (o_umai_chiplet1_wdata),

    .i_umai_rvalid     (i_umai_chiplet1_rvalid),
    .o_umai_rready     (o_umai_chiplet1_rready),
    .i_umai_rdata      (i_umai_chiplet1_rdata),

    .o_tx_valid        (aib_valid[1]),
    .i_tx_ready        (aib_ready[1]),
    .o_tx_data         (aib_data [1]),

    .i_rx_valid        (aib_valid[0]),
    .o_rx_ready        (aib_ready[0]),
    .i_rx_data         (aib_data [0])
  );

endmodule

