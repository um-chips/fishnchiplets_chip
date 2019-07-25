
// *****************************************************************************
// Filename : aib_io_mapping.sv
//
// Description :
//
// Notes :
//   TODO cfg signals also need to be remapped
// *****************************************************************************

module aib_io_mapping
(
  inout  wire   [  95 : 0 ] iopad,

  input  logic              c_chn_rotated,
  input  logic              c_chn_mst_mode,

  input  logic              c_ns_adapter_rstn,
  input  logic              c_ns_mac_rdy,

  input  logic              c_io_tx_en      [95:0],
  input  logic              c_io_ddr_mode   [95:0],
  input  logic              c_io_async_mode [95:0],

  input  logic  [   3 : 0 ] c_drv_strength  [95:0],
  input  logic              c_drv_pull_up   [95:0],
  input  logic              c_drv_pull_down [95:0],

  input  logic              i_tx_clk,
  input  logic              i_tx_clk_div2,
  input  logic  [  19 : 0 ] i_tx_data0,
  input  logic  [  19 : 0 ] i_tx_data1,

  output logic              o_rx_clk,
  output logic  [  19 : 0 ] o_rx_data0,
  output logic  [  19 : 0 ] o_rx_data1
);
  // ---------------------------------------------------------------------------
  logic iob_tx_clk        [95:0];
  logic iob_tx_data0      [95:0];
  logic iob_tx_data1      [95:0];
  logic iob_tx_data_async [95:0];

  logic tx_clk_en         [95:0];

  logic iob_rx_sample_clk [95:0];
  logic iob_rx_retime_clk [95:0];
  logic iob_rx_data0      [95:0];
  logic iob_rx_data1      [95:0];
  logic iob_rx_data_async [95:0];

  logic rx_bump_clk;
  logic rx_sample_clk;
  logic rx_retime_clk;

  // ---------------------------------------------------------------------------
  assign /*output*/ o_rx_clk = rx_retime_clk;

  // ---------------------------------------------------------------------------
  // Tx I/O mapping
  // ---------------------------------------------------------------------------

  // TODO add free-running clock
  generate
    for (genvar gi = 0; gi < 96; gi++) begin : cg_tx_clk
      // [48]: ns_rcv_div2_clk / [55]: ns_rcv_div2_clkb
      // [53]: ns_fwd_div2_clk / [54]: ns_fwd_div2_clkb
      if (gi == 48 || gi == 55 || gi == 53 || gi == 54)
        b15cilb01ah1n02x3 inst (
          .clk(i_tx_clk_div2), .en(tx_clk_en[gi]), .te(1'b0), .clkout(iob_tx_clk[gi])
        );
      else
        b15cilb01ah1n02x3 inst (
          .clk(i_tx_clk), .en(tx_clk_en[gi]), .te(1'b0), .clkout(iob_tx_clk[gi])
        );
    end
  endgenerate

  always_comb begin
    tx_clk_en = '{default: 0};

    iob_tx_data0      = '{default: 0};
    iob_tx_data1      = '{default: 0};
    iob_tx_data_async = '{default: 0};

    if (!c_chn_rotated) begin
      // -----------------------------------------------------------------------
      // Not rotated, master mode
      // -----------------------------------------------------------------------
      if (c_chn_mst_mode) begin
        // [56]: ns_adapter_rstn
        iob_tx_data_async[56] = c_ns_adapter_rstn;

        // [45]: ns_mac_rdy
        iob_tx_data_async[45] = c_ns_mac_rdy;

        // [85]: ns_sr_clk / [84]: ns_sr_clkb
        tx_clk_en[85] = 1'b1; iob_tx_data0[85] = 1'b0; iob_tx_data1[85] = 1'b1;
        tx_clk_en[84] = 1'b1; iob_tx_data0[84] = 1'b1; iob_tx_data1[84] = 1'b0;
        // [95]: ns_sr_data
        iob_tx_data_async[95] = 1'b1; // faking it with a constant 1 since we're
                                      // not using the shift registers
        // [94]: ns_sr_load
        iob_tx_data_async[94] = 1'b1; // faking it with a constant 1 since we're
                                      // not using the shift registers

        // [87]: ns_rcv_clk / [86]: ns_rcv_clkb
        tx_clk_en[87] = 1'b1; iob_tx_data0[87] = 1'b0; iob_tx_data1[87] = 1'b1;
        tx_clk_en[86] = 1'b1; iob_tx_data0[86] = 1'b1; iob_tx_data1[86] = 1'b0;
        // [48]: ns_rcv_div2_clk / [55]: ns_rcv_div2_clkb
        tx_clk_en[48] = 1'b1; iob_tx_data0[48] = 1'b0; iob_tx_data1[48] = 1'b1;
        tx_clk_en[55] = 1'b1; iob_tx_data0[55] = 1'b1; iob_tx_data1[55] = 1'b0;

        // [41]: ns_fwd_clk / [40]: ns_fwd_clkb
        tx_clk_en[41] = 1'b1; iob_tx_data0[41] = 1'b0; iob_tx_data1[41] = 1'b1;
        tx_clk_en[40] = 1'b1; iob_tx_data0[40] = 1'b1; iob_tx_data1[40] = 1'b0;
        // [53]: ns_fwd_div2_clk / [54]: ns_fwd_div2_clkb
        tx_clk_en[53] = 1'b1; iob_tx_data0[53] = 1'b0; iob_tx_data1[53] = 1'b1;
        tx_clk_en[54] = 1'b1; iob_tx_data0[54] = 1'b1; iob_tx_data1[54] = 1'b0;

        // [19:0]: tx
        for (int i = 0; i < 20; i++) begin
          tx_clk_en[i] = 1'b1;

          iob_tx_data0[i] = i_tx_data0[i];
          iob_tx_data1[i] = i_tx_data1[i];
        end
      end
      // -----------------------------------------------------------------------
      // Not rotated, slave mode
      // -----------------------------------------------------------------------
      else begin
        // [43]: ns_fwd_clk / [42]: ns_fwd_clkb
        tx_clk_en[43] = 1'b1; iob_tx_data0[43] = 1'b0; iob_tx_data1[43] = 1'b1;
        tx_clk_en[42] = 1'b1; iob_tx_data0[42] = 1'b1; iob_tx_data1[42] = 1'b0;

        // [39:20]: tx
        for (int i = 20; i < 40; i++) begin
          tx_clk_en[i] = 1'b1;

          iob_tx_data0[i] = i_tx_data0[i-20];
          iob_tx_data1[i] = i_tx_data1[i-20];
        end
      end
    end
    // -------------------------------------------------------------------------
    // Rotated, slave mode only
    // -------------------------------------------------------------------------
    else begin
      // [79]: ns_fwd_clk / [78]: ns_fwd_clkb
      tx_clk_en[79] = 1'b1; iob_tx_data0[79] = 1'b0; iob_tx_data1[79] = 1'b1;
      tx_clk_en[78] = 1'b1; iob_tx_data0[78] = 1'b1; iob_tx_data1[78] = 1'b0;

      tx_clk_en[52] = 1'b1; iob_tx_data0[52] = i_tx_data0[ 0]; iob_tx_data1[52] = i_tx_data1[ 0];
      tx_clk_en[51] = 1'b1; iob_tx_data0[51] = i_tx_data0[ 1]; iob_tx_data1[51] = i_tx_data1[ 1];
      tx_clk_en[59] = 1'b1; iob_tx_data0[59] = i_tx_data0[ 2]; iob_tx_data1[59] = i_tx_data1[ 2];
      tx_clk_en[57] = 1'b1; iob_tx_data0[57] = i_tx_data0[ 3]; iob_tx_data1[57] = i_tx_data1[ 3];
      tx_clk_en[81] = 1'b1; iob_tx_data0[81] = i_tx_data0[ 4]; iob_tx_data1[81] = i_tx_data1[ 4];
      tx_clk_en[80] = 1'b1; iob_tx_data0[80] = i_tx_data0[ 5]; iob_tx_data1[80] = i_tx_data1[ 5];
      tx_clk_en[65] = 1'b1; iob_tx_data0[65] = i_tx_data0[ 6]; iob_tx_data1[65] = i_tx_data1[ 6];
      tx_clk_en[64] = 1'b1; iob_tx_data0[64] = i_tx_data0[ 7]; iob_tx_data1[64] = i_tx_data1[ 7];
      tx_clk_en[86] = 1'b1; iob_tx_data0[86] = i_tx_data0[ 8]; iob_tx_data1[86] = i_tx_data1[ 8];
      tx_clk_en[87] = 1'b1; iob_tx_data0[87] = i_tx_data0[ 9]; iob_tx_data1[87] = i_tx_data1[ 9];
      tx_clk_en[88] = 1'b1; iob_tx_data0[88] = i_tx_data0[10]; iob_tx_data1[88] = i_tx_data1[10];
      tx_clk_en[89] = 1'b1; iob_tx_data0[89] = i_tx_data0[11]; iob_tx_data1[89] = i_tx_data1[11];
      tx_clk_en[82] = 1'b1; iob_tx_data0[82] = i_tx_data0[12]; iob_tx_data1[82] = i_tx_data1[12];
      tx_clk_en[83] = 1'b1; iob_tx_data0[83] = i_tx_data0[13]; iob_tx_data1[83] = i_tx_data1[13];
      tx_clk_en[70] = 1'b1; iob_tx_data0[70] = i_tx_data0[14]; iob_tx_data1[70] = i_tx_data1[14];
      tx_clk_en[71] = 1'b1; iob_tx_data0[71] = i_tx_data0[15]; iob_tx_data1[71] = i_tx_data1[15];
      tx_clk_en[92] = 1'b1; iob_tx_data0[92] = i_tx_data0[16]; iob_tx_data1[92] = i_tx_data1[16];
      tx_clk_en[93] = 1'b1; iob_tx_data0[93] = i_tx_data0[17]; iob_tx_data1[93] = i_tx_data1[17];
      tx_clk_en[67] = 1'b1; iob_tx_data0[67] = i_tx_data0[18]; iob_tx_data1[67] = i_tx_data1[18];
      tx_clk_en[66] = 1'b1; iob_tx_data0[66] = i_tx_data0[19]; iob_tx_data1[66] = i_tx_data1[19];
    end
  end

  // ---------------------------------------------------------------------------
  // Rx I/O mapping
  // ---------------------------------------------------------------------------

  logic rx_bump_clk_not_rotated;
  logic rx_bump_clk_rotated;

  // If NOT rotated, slave mode uses [41]: mst->slv fwd_clk, master mode uses [43]: slv->mst fwd_clk
  b15mbn022ah1n02x5 DT_rx_bump_clk_not_rotated_mux (
    .a(iob_rx_data_async[43]), .b(iob_rx_data_async[41]), .sa(c_chn_mst_mode), .o(rx_bump_clk_not_rotated)
  );
  // If ROTATED, chiplet can only be in slave mode and uses [84]: mst->slv fwd_clk
  assign rx_bump_clk_rotated = iob_rx_data_async[84];

  b15mbn022ah1n02x5 DT_rx_bump_clk_mux (
    .a(rx_bump_clk_rotated), .b(rx_bump_clk_not_rotated), .sa(c_chn_rotated), .o(rx_bump_clk)
  );

  // TODO add delay cell for the retime clock
  assign rx_sample_clk = rx_bump_clk;
  assign rx_retime_clk = rx_bump_clk;

  always_comb
    // TODO only apply clock to those in need
    for (int i = 0; i < 96; i++) begin
      iob_rx_sample_clk[i] = rx_sample_clk;
      iob_rx_retime_clk[i] = rx_retime_clk;
    end

  always_comb begin
    o_rx_data0 = '{default: 0};
    o_rx_data1 = '{default: 0};

    if (!c_chn_rotated) begin
      // -----------------------------------------------------------------------
      // Not rotated, master mode
      // -----------------------------------------------------------------------
      if (c_chn_mst_mode) begin
        for (int i = 0; i < 20; i++) begin
          o_rx_data0[i] = iob_rx_data0[20+i];
          o_rx_data1[i] = iob_rx_data1[20+i];
        end
      end
      // -----------------------------------------------------------------------
      // Not rotated, slave mode
      // -----------------------------------------------------------------------
      else begin
        for (int i = 0; i < 20; i++) begin
          o_rx_data0[i] = iob_rx_data0[i];
          o_rx_data1[i] = iob_rx_data1[i];
        end
      end
    end
    // -------------------------------------------------------------------------
    // Rotated, slave mode only
    // -------------------------------------------------------------------------
    else begin
      o_rx_data0[ 0] = iob_rx_data0[54]; o_rx_data1[ 0] = iob_rx_data1[54];
      o_rx_data0[ 1] = iob_rx_data0[53]; o_rx_data1[ 1] = iob_rx_data1[53];
      o_rx_data0[ 2] = iob_rx_data0[55]; o_rx_data1[ 2] = iob_rx_data1[55];
      o_rx_data0[ 3] = iob_rx_data0[48]; o_rx_data1[ 3] = iob_rx_data1[48];
      o_rx_data0[ 4] = iob_rx_data0[60]; o_rx_data1[ 4] = iob_rx_data1[60];
      o_rx_data0[ 5] = iob_rx_data0[62]; o_rx_data1[ 5] = iob_rx_data1[62];
      o_rx_data0[ 6] = iob_rx_data0[63]; o_rx_data1[ 6] = iob_rx_data1[63];
      o_rx_data0[ 7] = iob_rx_data0[58]; o_rx_data1[ 7] = iob_rx_data1[58];
      o_rx_data0[ 8] = iob_rx_data0[77]; o_rx_data1[ 8] = iob_rx_data1[77];
      o_rx_data0[ 9] = iob_rx_data0[76]; o_rx_data1[ 9] = iob_rx_data1[76];
      o_rx_data0[10] = iob_rx_data0[94]; o_rx_data1[10] = iob_rx_data1[94];
      o_rx_data0[11] = iob_rx_data0[95]; o_rx_data1[11] = iob_rx_data1[95];
      o_rx_data0[12] = iob_rx_data0[90]; o_rx_data1[12] = iob_rx_data1[90];
      o_rx_data0[13] = iob_rx_data0[91]; o_rx_data1[13] = iob_rx_data1[91];
      o_rx_data0[14] = iob_rx_data0[74]; o_rx_data1[14] = iob_rx_data1[74];
      o_rx_data0[15] = iob_rx_data0[75]; o_rx_data1[15] = iob_rx_data1[75];
      o_rx_data0[16] = iob_rx_data0[73]; o_rx_data1[16] = iob_rx_data1[73];
      o_rx_data0[17] = iob_rx_data0[72]; o_rx_data1[17] = iob_rx_data1[72];
      o_rx_data0[18] = iob_rx_data0[50]; o_rx_data1[18] = iob_rx_data1[50];
      o_rx_data0[19] = iob_rx_data0[61]; o_rx_data1[19] = iob_rx_data1[61];
    end
  end

  // ---------------------------------------------------------------------------
  // AIB I/O block
  // ---------------------------------------------------------------------------

  aib_io_block #(.NumIo(96)) u_aib_io_block (
    .iopad           (iopad),

    .c_io_tx_en      (c_io_tx_en),
    .c_io_ddr_mode   (c_io_ddr_mode),
    .c_io_async_mode (c_io_async_mode),
    .c_drv_strength  (c_drv_strength),
    .c_drv_pull_up   (c_drv_pull_up),
    .c_drv_pull_down (c_drv_pull_down),

    .i_tx_clk        (iob_tx_clk),
    .i_tx_data0      (iob_tx_data0),
    .i_tx_data1      (iob_tx_data1),
    .i_tx_data_async (iob_tx_data_async),

    .i_rx_sample_clk (iob_rx_sample_clk),
    .i_rx_retime_clk (iob_rx_retime_clk),
    .o_rx_data0      (iob_rx_data0),
    .o_rx_data1      (iob_rx_data1),
    .o_rx_data_async (iob_rx_data_async)
  );

endmodule

