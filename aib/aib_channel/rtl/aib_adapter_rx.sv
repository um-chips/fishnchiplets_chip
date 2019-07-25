
// *****************************************************************************
// Filename : aib_adapter_rx.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_adapter_rx
(
  input  logic              i_aib_tx_clk,
  input  logic              i_bus_clk,

  input  logic              i_rst_n,

  output logic              o_rx_valid,
  input  logic              i_rx_ready,
  output logic  [  71 : 0 ] o_rx_data,

  output logic              o_ns_fifo_full,
  output logic              o_fs_fifo_full,

  input  logic  [  19 : 0 ] i_rx_data0,
  input  logic  [  19 : 0 ] i_rx_data1
);
  // ---------------------------------------------------------------------------
  typedef enum {
    IDLE,
    ALIGN_WORD,
    ALIGNED
  } state;

  logic             fifo_wr;
  logic             fifo_wr_almost_full;
  logic [  35 : 0 ] fifo_wr_data;

  logic             fifo_rd;
  logic             fifo_rd_empty;
  logic [  71 : 0 ] fifo_rd_data;

  state             cs, ns;
  logic             fifo_rd_en;
  logic [   5 : 0 ] word_mark_d, word_mark_q;
  logic             rx_data_valid;

  // ---------------------------------------------------------------------------
  assign /*output*/ o_rx_valid = !fifo_rd_empty;
  assign /*output*/ o_rx_data = fifo_rd_data;

  assign /*output*/ o_ns_fifo_full = fifo_wr_almost_full;
  assign /*output*/ o_fs_fifo_full = i_rx_data1[18];

  // ---------------------------------------------------------------------------
  assign fifo_wr = (cs == ALIGNED) & rx_data_valid;

  always_comb
    for (int i = 0; i < 18; i++) begin
      fifo_wr_data[2*i+1] = i_rx_data1[i];
      fifo_wr_data[2*i+0] = i_rx_data0[i];
    end

  assign fifo_rd_en = i_rx_ready;
  assign fifo_rd = !fifo_rd_empty & fifo_rd_en;

  assign rx_data_valid = i_rx_data0[19];

  // ---------------------------------------------------------------------------
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (36),
    .data_out_width (72),
    .depth          (16),
    //.push_ae_lvl    (),
    .push_af_lvl    (2),
    //.pop_ae_lvl     (),
    //.pop_af_lvl     (),
    .err_mode       (0),
    .push_sync      (3),
    .pop_sync       (3),
    .rst_mode       (0),
    .byte_order     (1)
  )
  u_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_aib_tx_clk),
    .push_req_n (~fifo_wr),
    .flush_n    (1'b1),
    .data_in    (fifo_wr_data),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (fifo_wr_almost_full),
    .push_full  (fifo_wr_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_bus_clk),
    .pop_req_n  (~fifo_rd),
    .data_out   (fifo_rd_data),
    .pop_empty  (fifo_rd_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),
    .pop_error  ()
  );

  // ---------------------------------------------------------------------------
  always_comb begin
    ns = cs;
    word_mark_d = word_mark_q;

    case (cs)
      IDLE:
        ns = ALIGN_WORD;

      ALIGN_WORD: begin
        word_mark_d = {word_mark_q[4:0], i_rx_data1[19]};

        if (word_mark_q == 6'b101010)
          ns = ALIGNED;
      end
    endcase
  end

  // ---------------------------------------------------------------------------
  always_ff @(posedge i_aib_tx_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      cs            <= IDLE;
      word_mark_q   <= 6'b0;
    end
    else begin
      cs            <= ns;
      word_mark_q   <= word_mark_d;
    end

endmodule

