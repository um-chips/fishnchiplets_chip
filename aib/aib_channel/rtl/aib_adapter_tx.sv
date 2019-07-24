
// *****************************************************************************
// Filename : aib_adapter_tx.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_adapter_tx
(
  input  logic              i_aib_clk,
  input  logic              i_aib_clk_div2,

  input  logic              i_rst_n,

  input  logic              i_tx_valid,
  output logic              o_tx_ready,
  input  logic  [  71 : 0 ] i_tx_data,

  input  logic              i_ns_fifo_full,
  input  logic              i_fs_fifo_full,

  output logic  [  19 : 0 ] o_tx_data0,
  output logic  [  19 : 0 ] o_tx_data1
);
  // ---------------------------------------------------------------------------
  typedef enum {
    IDLE,
    LOWER_WORD,
    UPPER_WORD
  } state;

  logic             fifo_wr;
  logic             fifo_wr_full;
  logic [  71 : 0 ] fifo_wr_data;

  logic             fifo_rd;
  logic             fifo_rd_empty;
  logic [  35 : 0 ] fifo_rd_data;

  state             cs, ns;
  logic             fifo_rd_en;
  logic             fifo_rd_en_d, fifo_rd_en_q;

  // ---------------------------------------------------------------------------
  assign /*output*/ o_tx_ready = !fifo_wr_full;

  always_comb begin
    o_tx_data1[19] = (cs == UPPER_WORD);
    o_tx_data1[18] = i_ns_fifo_full;

    o_tx_data0[19] = fifo_rd;
    o_tx_data0[18] = 1'b0;

    for (int i = 0; i < 18; i++) begin
      o_tx_data1[i] = fifo_rd_data[2*i+1];
      o_tx_data0[i] = fifo_rd_data[2*i+0];
    end
  end

  // ---------------------------------------------------------------------------
  assign fifo_wr = i_tx_valid & !fifo_wr_full;
  assign fifo_wr_data = i_tx_data;

  assign fifo_rd_en = fifo_rd_en_d | fifo_rd_en_q;
  assign fifo_rd = !fifo_rd_empty & fifo_rd_en;

  // ---------------------------------------------------------------------------
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (72),
    .data_out_width (36),
    .depth          (8),
    //.push_ae_lvl    (),
    //.push_af_lvl    (),
    //.pop_ae_lvl     (),
    //.pop_af_lvl     (),
    .err_mode       (0),
    .push_sync      (1),
    .pop_sync       (1),
    .rst_mode       (0),
    .byte_order     (1)
  )
  u_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_aib_clk_div2),
    .push_req_n (~fifo_wr),
    .flush_n    (1'b1),
    .data_in    (fifo_wr_data),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (fifo_wr_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_aib_clk),
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
    fifo_rd_en_d = fifo_rd_en_q;

    case (cs)
      IDLE:
        ns = LOWER_WORD;

      LOWER_WORD: begin
        ns = UPPER_WORD;

        if (!fifo_rd_empty & !i_fs_fifo_full)
          fifo_rd_en_d = 1'b1;
        else
          fifo_rd_en_d = 1'b0;
      end

      UPPER_WORD: begin
        ns = LOWER_WORD;

        fifo_rd_en_d = 1'b0;
      end
    endcase
  end

  // ---------------------------------------------------------------------------
  always_ff @(posedge i_aib_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      cs            <= IDLE;
      fifo_rd_en_q  <= 1'b0;
    end
    else begin
      cs            <= ns;
      fifo_rd_en_q  <= fifo_rd_en_d;
    end

endmodule

