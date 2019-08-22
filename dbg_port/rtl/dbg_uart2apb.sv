
`ifndef DBG_UART2APB_SV // this module may be included in multiple file lists
`define DBG_UART2APB_SV // use an include guard to avoid duplicated module declaration

// *****************************************************************************
// Filename : dbg_uart2apb.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module dbg_uart2apb
(
  input  logic            i_clk,
  input  logic            i_rst_n,

  // UART FIFO interface
  input  logic            i_fifo_empty,
  output logic            o_fifo_read,
  input  logic [  7 : 0 ] i_fifo_rdata,

  input  logic            i_fifo_full,
  output logic            o_fifo_write,
  output logic [  7 : 0 ] o_fifo_wdata,

  // APB interface
  output logic            o_penable,
  output logic            o_pwrite,
  output logic [ 31 : 0 ] o_paddr,
  output logic [ 31 : 0 ] o_pwdata,
  input  logic            i_pready,
  input  logic [ 31 : 0 ] i_prdata
);
  // ---------------------------------------------------------------------------
  typedef enum logic [2:0] {
    FSM_IDLE,
    FSM_ADDR,
    FSM_WDATA,
    FSM_WAIT_RDATA,
    FSM_SEND_RDATA
  } fsm_state;

  fsm_state ns, cs;

  // Signal declarations
  // ---------------------------------------------------------------------------
  logic [   1 : 0 ] byte_cnt_d, byte_cnt_q;

  logic             write_d,     write_q;
  logic             fix_addr_d,  fix_addr_q;
  logic [   7 : 0 ] burst_cnt_d, burst_cnt_q;
  logic [  31 : 0 ] addr_d,      addr_q;
  logic [  31 : 0 ] data_d,      data_q;

  logic             penable_d, penable_q;

  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_fifo_wdata = data_q[31:24];

  assign /*output*/ o_penable = penable_q;
  assign /*output*/ o_pwrite  = write_q;
  assign /*output*/ o_paddr   = addr_q;
  assign /*output*/ o_pwdata  = data_q;

  // ---------------------------------------------------------------------------
  always_comb begin
    ns = cs;

    byte_cnt_d = byte_cnt_q;

    write_d     = write_q;
    fix_addr_d  = fix_addr_q;
    burst_cnt_d = burst_cnt_q;
    addr_d      = addr_q;
    data_d      = data_q;

    o_fifo_read  = 1'b0;
    o_fifo_write = 1'b0;

    penable_d = 1'b0;

    unique case (cs)
      // -----------------------------------------------------------------------
      FSM_IDLE:
      // -----------------------------------------------------------------------
      // Write 2 UART data to start the FSM, the first data is the command, and
      // the second data is the burst size
      // -----------------------------------------------------------------------
        if (!i_fifo_empty) begin
          o_fifo_read = 1'b1;

          // Receive the first UART data
          if (byte_cnt_q == 0) begin
            byte_cnt_d = byte_cnt_q + 1;

            write_d    = i_fifo_rdata[7];
            fix_addr_d = i_fifo_rdata[6];
          end
          // Receive the second UART data, switch to address state
          else begin
            ns = FSM_ADDR;

            byte_cnt_d = 0;

            burst_cnt_d = i_fifo_rdata;
          end
        end

      // -----------------------------------------------------------------------
      FSM_ADDR:
      // -----------------------------------------------------------------------
        if (!i_fifo_empty) begin
          o_fifo_read = 1'b1;

          byte_cnt_d = byte_cnt_q + 1;

          addr_d = {addr_q[23:0], i_fifo_rdata};

          if (byte_cnt_q == 2'd3) begin
            if (write_q)
              ns = FSM_WDATA;
            else begin
              ns = FSM_WAIT_RDATA;

              penable_d = 1'b1;
            end
          end
        end

      // -----------------------------------------------------------------------
      FSM_WDATA: begin
      // -----------------------------------------------------------------------
        if (!i_fifo_empty) begin
          o_fifo_read = 1'b1;

          byte_cnt_d = byte_cnt_q + 1;

          data_d = {data_q[23:0], i_fifo_rdata};

          if (byte_cnt_q == 2'd3) begin
            if (burst_cnt_q == 0)
              ns = FSM_IDLE;

            burst_cnt_d = burst_cnt_q - 1;

            penable_d = 1'b1;
          end
        end

        if (penable_q)
          if (!fix_addr_q)
            addr_d = addr_q + 4;
      end

      // -----------------------------------------------------------------------
      FSM_WAIT_RDATA:
      // -----------------------------------------------------------------------
        if (!i_pready)
          penable_d = 1'b1;
        else begin
          ns = FSM_SEND_RDATA;

          data_d = i_prdata;
        end

      // -----------------------------------------------------------------------
      FSM_SEND_RDATA:
      // -----------------------------------------------------------------------
        if (!i_fifo_full) begin
          o_fifo_write = 1'b1;

          byte_cnt_d = byte_cnt_q + 1;

          data_d = {data_q[23:0], 8'b0};

          if (byte_cnt_q == 2'd3) begin
            if (burst_cnt_q == 0)
              ns = FSM_IDLE;
            else begin
              ns = FSM_WAIT_RDATA;

              burst_cnt_d = burst_cnt_q - 1;

              penable_d = 1'b1;

              if (!fix_addr_q)
                addr_d = addr_q + 4;
            end
          end
        end
    endcase
  end

  // Flip flops
  // ---------------------------------------------------------------------------
  always_ff @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      cs          <= FSM_IDLE;
      byte_cnt_q  <= '{default: 0};
      write_q     <= 1'b0;
      fix_addr_q  <= 1'b0;
      burst_cnt_q <= '{default: 0};
      addr_q      <= '{default: 0};
      data_q      <= '{default: 0};
      penable_q   <= 1'b0;
    end
    else begin
      cs          <= ns;
      byte_cnt_q  <= byte_cnt_d;
      write_q     <= write_d;
      fix_addr_q  <= fix_addr_d;
      burst_cnt_q <= burst_cnt_d;
      addr_q      <= addr_d;
      data_q      <= data_d;
      penable_q   <= penable_d;
    end

endmodule

`endif // DBG_UART2APB_SV

