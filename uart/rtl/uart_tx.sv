
`ifndef UART_TX_SV // this module may be included in multiple file lists
`define UART_TX_SV // use an include guard to avoid duplicated module declaration

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
module uart_tx #(parameter FifoDepth   = 4,
                 parameter BaudCycBits = 16)
(
  input  logic                       i_clk,
  input  logic                       i_rst_n,

  input  logic [ BaudCycBits-1 : 0 ] c_baud_cyc,

  output logic                       o_tx,

  output logic                       o_busy,

  output logic                       o_fifo_full,
  input  logic                       i_fifo_write,
  input  logic [             7 : 0 ] i_fifo_wdata
);
  // ---------------------------------------------------------------------------
  typedef enum logic [1:0] {
    FSM_IDLE,
    FSM_START_BIT,
    FSM_DATA_BITS,
    FSM_STOP_BIT
  } fsm_state;

  fsm_state fsm_ns, fsm_cs;

  // Signal declarations
  // ---------------------------------------------------------------------------
  logic                       tx_d, tx_q;

  logic                       tick_baud;

  logic [ BaudCycBits-1 : 0 ] cyc_cnt_d, cyc_cnt_q;
  logic [             2 : 0 ] bit_cnt_d, bit_cnt_q;

  logic [             7 : 0 ] data_d, data_q;

  logic                       fifo_empty;
  logic                       fifo_read;
  logic [             7 : 0 ] fifo_rdata;

  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_tx = tx_q;

  assign /*output*/ o_busy = (fsm_cs != FSM_IDLE);

  // ---------------------------------------------------------------------------
  assign tick_baud = (fsm_cs != FSM_IDLE) && (cyc_cnt_q == 0);

  // ---------------------------------------------------------------------------
  always_comb begin
    fsm_ns = fsm_cs;

    cyc_cnt_d = cyc_cnt_q;
    bit_cnt_d = bit_cnt_q;

    fifo_read = 1'b0;

    data_d = data_q;

    tx_d = tx_q;

    case (fsm_cs)
      FSM_IDLE:
        if (!fifo_empty) begin
          fsm_ns = FSM_START_BIT;

          cyc_cnt_d = c_baud_cyc;

          fifo_read = 1'b1;

          data_d = fifo_rdata;
        end

      FSM_START_BIT: begin
        tx_d = 1'b0;

        if (tick_baud) begin
          fsm_ns = FSM_DATA_BITS;

          cyc_cnt_d = c_baud_cyc;
        end
        else
          cyc_cnt_d = cyc_cnt_q - 1;
      end

      FSM_DATA_BITS: begin
        tx_d = data_q[0];

        if (tick_baud) begin
          if (bit_cnt_q == 7)
            fsm_ns = FSM_STOP_BIT;

          cyc_cnt_d = c_baud_cyc;
          bit_cnt_d = bit_cnt_q + 1;

          data_d = data_q>>1;
        end
        else
          cyc_cnt_d = cyc_cnt_q - 1;
      end

      FSM_STOP_BIT: begin
        tx_d = 1'b1;

        if (tick_baud) begin
          if (!fifo_empty) begin
            fsm_ns = FSM_START_BIT;

            cyc_cnt_d = c_baud_cyc;

            fifo_read = 1'b1;

            data_d = fifo_rdata;
          end
          else
            fsm_ns = FSM_IDLE;
        end
        else
          cyc_cnt_d = cyc_cnt_q - 1;
      end
    endcase
  end

  // ---------------------------------------------------------------------------
  fifo #(.Width(8), .Depth(FifoDepth)) u_fifo (
    .i_clk,
    .i_rst_n,

    .o_full  (o_fifo_full),
    .o_empty (fifo_empty),

    .i_write (i_fifo_write),
    .i_wdata (i_fifo_wdata),

    .i_read  (fifo_read),
    .o_rdata (fifo_rdata)
  );

  // Flip flops
  // ---------------------------------------------------------------------------
  always_ff @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      fsm_cs    <= FSM_IDLE;
      tx_q      <= 1'b1;
      cyc_cnt_q <= '{default: 0};
      bit_cnt_q <= '{default: 0};
      data_q    <= '{default: 0};
    end
    else begin
      fsm_cs    <= fsm_ns;
      tx_q      <= tx_d;
      cyc_cnt_q <= cyc_cnt_d;
      bit_cnt_q <= bit_cnt_d;
      data_q    <= data_d;
    end

endmodule

`endif // UART_TX_SV

