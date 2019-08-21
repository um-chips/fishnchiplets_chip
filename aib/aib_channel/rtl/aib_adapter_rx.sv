
// *****************************************************************************
// Filename : aib_adapter_rx.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_adapter_rx
(
  input  logic              i_rst_n,

  input  logic              c_bypass_word_align,

  // Core side
  input  logic              i_bus_clk,

  output logic              o_ns_fifo_full,
  output logic              o_fs_fifo_full,

  output logic              o_bus_rx_valid,
  input  logic              i_bus_rx_ready,
  output logic  [  71 : 0 ] o_bus_rx_data,

  // AIB side
  input  logic              i_aib_rx_clk,

  input  logic  [  19 : 0 ] i_aib_rx_data0,
  input  logic  [  19 : 0 ] i_aib_rx_data1
);
  // ---------------------------------------------------------------------------
  // FIFO write is in AIB rx clock domain
  // ---------------------------------------------------------------------------

  // Signal declarations
  // ---------------------------------------------------------------------------
  logic             fifo_wr;
  logic [  35 : 0 ] fifo_wr_data;

  typedef enum {IDLE, ALIGN_WORD, ALIGNED} state;

  state             cs, ns;
  logic [   5 : 0 ] word_align_d, word_align_q;

  wire              aib_word_mark  = i_aib_rx_data1[19];
  wire              aib_fifo_full  = i_aib_rx_data1[18];
  wire              aib_data_valid = i_aib_rx_data0[19];

  // ---------------------------------------------------------------------------
  assign fifo_wr = (cs == ALIGNED || c_bypass_word_align) & aib_data_valid;

  always_comb
    for (int i = 0; i < 18; i++) begin
      fifo_wr_data[2*i+1] = i_aib_rx_data1[i];
      fifo_wr_data[2*i+0] = i_aib_rx_data0[i];
    end

  // Word alignment FSM
  // ---------------------------------------------------------------------------
  always_comb begin
    ns = cs;
    word_align_d = word_align_q;

    case (cs)
      IDLE:
        ns = ALIGN_WORD;

      ALIGN_WORD: begin
        word_align_d = {word_align_q[4:0], aib_word_mark};

        if (word_align_q == 6'b101010)
          ns = ALIGNED;
      end
    endcase
  end

  // Flip-flops
  // ---------------------------------------------------------------------------
  always_ff @(posedge i_aib_rx_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      cs           <= IDLE;
      word_align_q <= 6'b0;
    end
    else begin
      cs           <= ns;
      word_align_q <= word_align_d;
    end

  // ---------------------------------------------------------------------------
  // FIFO read is in core bus clock domain
  // ---------------------------------------------------------------------------

  // Signal declarations
  // ---------------------------------------------------------------------------
  logic             fifo_rd;
  logic             fifo_rd_empty;
  logic             fifo_rd_full;
  logic [  71 : 0 ] fifo_rd_data;

  logic [   2 : 0 ] fs_fifo_full_sync_q;

  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_ns_fifo_full = fifo_rd_full;
  assign /*output*/ o_fs_fifo_full = fs_fifo_full_sync_q[2];

  assign /*output*/ o_bus_rx_valid = !fifo_rd_empty;
  assign /*output*/ o_bus_rx_data  =  fifo_rd_data;

  // ---------------------------------------------------------------------------
  assign fifo_rd = o_bus_rx_valid & i_bus_rx_ready;

  // Flip-flops
  // ---------------------------------------------------------------------------
  always_ff @(posedge i_bus_clk or negedge i_rst_n)
    if (!i_rst_n)
      fs_fifo_full_sync_q <= '{default: 0};
    else
      fs_fifo_full_sync_q <= {fs_fifo_full_sync_q[1:0], aib_fifo_full};

  // ---------------------------------------------------------------------------
  // FIFO
  // ---------------------------------------------------------------------------

  DW_asymfifo_s2_sf
  #(
    .data_in_width  (36),
    .data_out_width (72),
    .depth          (16),
    //.push_ae_lvl    (),
    //.push_af_lvl    (),
    //.pop_ae_lvl     (),
    //.pop_af_lvl     (),
    .err_mode       (0), // stay active until reset
    .push_sync      (2), // number of synchronizer stages from pop pointer
    .pop_sync       (2), // number of synchronizer stages from push pointer
    .rst_mode       (0), // async reset including memory
    .byte_order     (1)  // first byte in LSB
  )
  u_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_aib_rx_clk),
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

    .clk_pop    (i_bus_clk),
    .pop_req_n  (~fifo_rd),
    .data_out   (fifo_rd_data),
    .pop_empty  (fifo_rd_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (fifo_rd_full),
    .pop_error  ()
  );

endmodule

