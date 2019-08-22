
// *****************************************************************************
// Filename : aib_io_buffer.sv
//
// Description :
//   Implementation of the I/O buffer in the original AIB spec
//
// Notes :
//   Muxes in this design should be manually instantiated with glitch-free type
//   standard cell, and they need to be preserved (e.g. size only) in synthesis
// *****************************************************************************

module aib_io_buffer
(
  inout  wire               pad_aib_io,

  // Configuration signals
  input  logic              c_io_tx_en,
  input  logic              c_io_ddr_mode,
  input  logic              c_io_async_mode,
  input  logic  [   3 : 0 ] c_drv_strength,
  input  logic              c_drv_pull_up,
  input  logic              c_drv_pull_down,

  // Tx datapath
  input  logic              i_tx_clk,
  input  logic              i_tx_data0,
  input  logic              i_tx_data1,
  input  logic              i_tx_data_async,

  // Rx datapath
  input  logic              i_rx_sample_clk,
  input  logic              i_rx_retime_clk,
  output logic              o_rx_data0,
  output logic              o_rx_data1,
  output logic              o_rx_data_async
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic [   3 : 0 ] drv_strength;
  logic             drv_pull_up_n;
  logic             drv_pull_down;

  // Naming convention for the following signals
  //   _q  : positive edge flip-flop output
  //   _nq : negative edge flip-flop output
  //   _l  : positive level latch output
  //   _nl : negative level latch output

  logic             tx_data0_q;
  logic             tx_data1_q;
  logic             tx_data_ddr;
  logic             tx_data_ddr_nl;
  logic             tx_data_sync;
  logic             tx_data;

  logic             rx_data;
  logic             rx_data0_nq;
  logic             rx_data0_nq_l;
  logic             rx_data0_retime_q;
  logic             rx_data1_q;
  logic             rx_data1_retime_q;

  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_rx_data0 = rx_data0_retime_q;
  assign /*output*/ o_rx_data1 = rx_data1_retime_q;

  assign /*output*/ o_rx_data_async = rx_data;

  // ---------------------------------------------------------------------------
  // Tx datapath
  // ---------------------------------------------------------------------------

  always_ff @(posedge i_tx_clk) begin
    tx_data0_q <= i_tx_data0;
    tx_data1_q <= i_tx_data1;
  end

  b15mbn022ah1n02x5 SO_tx_data_ddr (
    .a(tx_data1_q), .b(tx_data0_q), .sa(c_io_ddr_mode), .o(tx_data_ddr)
  );

  always_latch
    if (!i_tx_clk)
      tx_data_ddr_nl <= tx_data_ddr;

  // This one MUST be a glitch-free mux because the select input toggles all
  // the time, the other two muxes have static select input so they can use
  // normal mux, but let's make them all glitch-free muxes
  b15mbn022ah1n02x5 SO_tx_data_sync (
    .a(tx_data_ddr_nl), .b(tx_data0_q), .sa(i_tx_clk), .o(tx_data_sync)
  );

  b15mbn022ah1n02x5 SO_tx_data (
    .a(i_tx_data_async), .b(tx_data_sync), .sa(c_io_async_mode), .o(tx_data)
  );

  // ---------------------------------------------------------------------------
  // Rx datapath
  // ---------------------------------------------------------------------------

  always_ff @(negedge i_rx_sample_clk)
    rx_data0_nq <= rx_data;

  always_latch
    if (i_rx_sample_clk)
      rx_data0_nq_l <= rx_data0_nq;

  always_ff @(posedge i_rx_sample_clk)
    rx_data1_q <= rx_data;

  always_ff @(posedge i_rx_retime_clk) begin
    rx_data0_retime_q <= rx_data0_nq_l;
    rx_data1_retime_q <= rx_data1_q;
  end

  // ---------------------------------------------------------------------------
  // IO driver
  // ---------------------------------------------------------------------------

  assign drv_strength  = {4{c_io_tx_en}} & c_drv_strength;
  assign drv_pull_up_n = ~c_drv_pull_up;
  assign drv_pull_down =  c_drv_pull_down;

  aib_driver u_aib_driver (
    .PAD    (pad_aib_io),

    .PU_N   (drv_pull_up_n),
    .PD     (drv_pull_down),

    .DRVEN  (drv_strength),
    .TXD    (tx_data),
    .RXD    (rx_data)
  );

endmodule

