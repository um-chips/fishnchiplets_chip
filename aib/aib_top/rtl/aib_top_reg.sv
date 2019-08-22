
// *****************************************************************************
// Filename : aib_top_reg.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_top_reg #(parameter NumChannels = 6)
(
  input  logic              i_clk,
  input  logic              i_rst_n,

  output logic              o_uart_tx,
  input  logic              i_uart_rx,

  // ---------------------------------------------------------------------------
  output logic              c_io_tx_en      [NumChannels-1:0][95:0],
  output logic              c_io_ddr_mode   [NumChannels-1:0][95:0],
  output logic              c_io_async_mode [NumChannels-1:0][95:0],

  output logic  [   3 : 0 ] c_drv_strength  [NumChannels-1:0][95:0],
  output logic              c_drv_pull_up   [NumChannels-1:0][95:0],
  output logic              c_drv_pull_down [NumChannels-1:0][95:0]
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic             penable;
  logic             pwrite;
  logic [  31 : 0 ] paddr;
  logic [  31 : 0 ] pwdata;
  logic             pready;
  logic             pready_d, pready_q;
  logic [  31 : 0 ] prdata_d, prdata_q;

  logic [   8 : 0 ] iob_config_d [NumChannels-1:0][95:0];
  logic [   8 : 0 ] iob_config_q [NumChannels-1:0][95:0];

  // ---------------------------------------------------------------------------
  always_comb
    for (int c = 0; c < NumChannels; c++)
      for (int i = 0; i < 96; i++) begin
        c_io_tx_en      [c][i] /*output*/ = iob_config_q[c][i][ 8];
        c_io_ddr_mode   [c][i] /*output*/ = iob_config_q[c][i][ 7];
        c_io_async_mode [c][i] /*output*/ = iob_config_q[c][i][ 6];

        c_drv_pull_up   [c][i] /*output*/ = iob_config_q[c][i][ 5];
        c_drv_pull_down [c][i] /*output*/ = iob_config_q[c][i][ 4];
        c_drv_strength  [c][i] /*output*/ = iob_config_q[c][i][ 3: 0];
      end

  // Write data path
  // ---------------------------------------------------------------------------
  always_comb begin
    iob_config_d = iob_config_q;

    if (penable & pwrite)
      case (paddr[13:12])
        2'd2:
          iob_config_d[ paddr[11:9] ][ paddr[8:2] ] = pwdata;
      endcase
  end

  // Read data path
  // ---------------------------------------------------------------------------
  always_comb begin
    prdata_d = prdata_q;

    if (penable & ~pwrite)
      case (paddr[13:12])
        2'd2:
          prdata_d = iob_config_q[ paddr[11:9] ][ paddr[8:2] ];
      endcase
  end

  // ---------------------------------------------------------------------------
  // Pull down pready for 1 cycle for read
  assign pready_d = penable & !pwrite;
  assign pready = (penable & !pwrite) ? pready_q : 1'b1;

  dbg_port u_dbg_port (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),

    .c_baud_cyc (8'd3),

    .o_uart_tx  (o_uart_tx),
    .i_uart_rx  (i_uart_rx),

    .o_penable  (penable),
    .o_pwrite   (pwrite),
    .o_paddr    (paddr),
    .o_pwdata   (pwdata),
    .i_pready   (pready),
    .i_prdata   (prdata_q)
  );

  // ---------------------------------------------------------------------------
  always_ff @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      pready_q <= 1'b0;
      prdata_q <= '{default: 0};

      iob_config_q <= '{default: 0};
    end
    else begin
      pready_q <= pready_d;
      prdata_q <= prdata_d;

      iob_config_q <= iob_config_d;
    end

endmodule

