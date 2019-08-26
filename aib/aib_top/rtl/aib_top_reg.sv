
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
  output logic              c_drv_pull_down [NumChannels-1:0][95:0],

  output logic              c_chn_rotated       [NumChannels-1:0],
  output logic              c_chn_mst_mode      [NumChannels-1:0],
  output logic              c_ns_adapter_rstn   [NumChannels-1:0],
  output logic              c_ns_mac_rdy        [NumChannels-1:0],
  output logic              c_bypass_word_align [NumChannels-1:0],

  output logic              c_ip_sel,
  output logic  [   2 : 0 ] c_mst_first_chn_id,
  output logic  [   2 : 0 ] c_mst_last_chn_id,
  output logic  [   2 : 0 ] c_slv_first_chn_id,
  output logic  [   2 : 0 ] c_slv_last_chn_id,

  output logic              c_conf_done
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

  logic [   4 : 0 ] chn_config_d [NumChannels-1:0];
  logic [   4 : 0 ] chn_config_q [NumChannels-1:0];

  logic [  12 : 0 ] umai_config_d, umai_config_q;

  logic [  31 : 0 ] chip_config_d, chip_config_q;

  // Output assignments
  // ---------------------------------------------------------------------------
  always_comb
    for (int c = 0; c < NumChannels; c++) begin
      for (int i = 0; i < 96; i++) begin
        /*output*/ c_io_tx_en      [c][i] = iob_config_q[c][i][8];
        /*output*/ c_io_ddr_mode   [c][i] = iob_config_q[c][i][7];
        /*output*/ c_io_async_mode [c][i] = iob_config_q[c][i][6];
        /*output*/ c_drv_pull_up   [c][i] = iob_config_q[c][i][5];
        /*output*/ c_drv_pull_down [c][i] = iob_config_q[c][i][4];
        /*output*/ c_drv_strength  [c][i] = iob_config_q[c][i][3:0];
      end

      /*output*/ c_ns_adapter_rstn   [c] = chn_config_q[c][4];
      /*output*/ c_ns_mac_rdy        [c] = chn_config_q[c][3];
      /*output*/ c_bypass_word_align [c] = chn_config_q[c][2];
      /*output*/ c_chn_rotated       [c] = chn_config_q[c][1];
      /*output*/ c_chn_mst_mode      [c] = chn_config_q[c][0];
    end

  assign /*output*/ c_mst_first_chn_id = umai_config_q[12:10];
  assign /*output*/ c_mst_last_chn_id  = umai_config_q[ 9: 7];
  assign /*output*/ c_slv_first_chn_id = umai_config_q[ 6: 4];
  assign /*output*/ c_slv_last_chn_id  = umai_config_q[ 3: 1];
  assign /*output*/ c_ip_sel           = umai_config_q[ 0];

  assign /*output*/ c_conf_done = chip_config_q[0];

  // Write data path
  // ---------------------------------------------------------------------------
  always_comb begin
    iob_config_d  = iob_config_q;
    chn_config_d  = chn_config_q;
    umai_config_d = umai_config_q;
    chip_config_d = chip_config_q;

    if (penable & pwrite)
      case (paddr[13:12])
        2'd0:
          iob_config_d[ paddr[11:9] ][ paddr[8:2] ] = pwdata;

        2'd1:
          chn_config_d[ paddr[11:9] ] = pwdata;

        2'd2:
          umai_config_d = pwdata;

        2'd3:
          chip_config_d = pwdata;
      endcase
  end

  // Read data path
  // ---------------------------------------------------------------------------
  always_comb begin
    prdata_d = prdata_q;

    if (penable & ~pwrite)
      case (paddr[13:12])
        2'd0:
          prdata_d = iob_config_q[ paddr[11:9] ][ paddr[8:2] ];

        2'd1:
          prdata_d = chn_config_q[ paddr[11:9] ];

        2'd2:
          prdata_d = umai_config_q;

        2'd3:
          prdata_d = chip_config_q;
      endcase
  end

  // ---------------------------------------------------------------------------
  // Pull down pready for 1 cycle for read
  assign pready_d = penable & !pwrite;
  assign pready = (penable & !pwrite) ? pready_q : 1'b1;

  dbg_port u_dbg_port (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),

    .c_baud_cyc (8'd1),

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

      iob_config_q  <= '{default: 0};
      chn_config_q  <= '{default: 0};
      umai_config_q <= '{default: 0};
      chip_config_q <= '{default: 0};
    end
    else begin
      pready_q <= pready_d;
      prdata_q <= prdata_d;

      iob_config_q  <= iob_config_d;
      chn_config_q  <= chn_config_d;
      umai_config_q <= umai_config_d;
      chip_config_q <= chip_config_d;
    end

endmodule

