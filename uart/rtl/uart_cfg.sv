
`ifndef UART_CFG_SV // this module may be included in multiple file lists
`define UART_CFG_SV // use an include guard to avoid duplicated module declaration

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
module uart_cfg #(parameter BaudCycBits = 16)
(
  input  logic                       i_clk,
  input  logic                       i_rst_n,

  input  logic                       i_tx_busy,
  input  logic                       i_rx_busy,

  input  logic [ BaudCycBits-1 : 0 ] c_baud_cyc,

  output logic [ BaudCycBits-1 : 0 ] o_baud_cyc
);
  // ---------------------------------------------------------------------------
  typedef enum logic {
    FSM_IDLE,
    FSM_UPDATE
  } fsm_state;

  fsm_state fsm_ns, fsm_cs;

  // Signal declarations
  // ---------------------------------------------------------------------------
  logic [ BaudCycBits-1 : 0 ] baud_cyc_d, baud_cyc_q;

  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_baud_cyc = baud_cyc_q;

  // ---------------------------------------------------------------------------
  always_comb begin
    fsm_ns = fsm_cs;

    baud_cyc_d = baud_cyc_q;

    unique case (fsm_cs)
      FSM_IDLE:
        if (c_baud_cyc != baud_cyc_q)
          fsm_ns = FSM_UPDATE;

      default: // FSM_UPDATE
        if (!i_tx_busy && !i_rx_busy) begin
          fsm_ns = FSM_IDLE;

          baud_cyc_d = c_baud_cyc;
        end
    endcase
  end

  // Flip flops
  // ---------------------------------------------------------------------------
  always_ff @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      fsm_cs      <= FSM_IDLE;
      baud_cyc_q  <= '{default: 0};
    end
    else begin
      fsm_cs      <= fsm_ns;
      baud_cyc_q  <= baud_cyc_d;
    end

endmodule

`endif // UART_CFG_SV

