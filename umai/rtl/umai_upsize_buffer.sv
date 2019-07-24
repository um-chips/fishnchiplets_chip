
// *****************************************************************************
// Filename : umai_upsize_buffer.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module umai_upsize_buffer
(
  input  logic              i_clk,
  input  logic              i_rst_n,

  input  logic              i_wvalid,
  output logic              o_wready,
  input  logic  [   2 : 0 ] i_woffset,
  input  logic  [   2 : 0 ] i_wsize,
  input  logic              i_wdata_valid [7:0],
  input  logic  [  63 : 0 ] i_wdata       [7:0],

  input  logic              i_rvalid,
  output logic              o_rready,
  output logic  [ 511 : 0 ] o_rdata
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic [   511 : 0 ] buffer_d [2], buffer_q[2];
  logic [  1023 : 0 ] buffer;

  logic [     3 : 0 ] wptr_d, wptr_q;
  logic               rptr_d, rptr_q;

  logic [     4 : 0 ] empty_word_cnt_d, empty_word_cnt_q;
  logic [     4 : 0 ] valid_word_cnt;

  logic [     3 : 0 ] act_wsize;

  logic               do_write;
  logic               do_read;

  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_wready = (empty_word_cnt_q >= (i_wsize+1));

  assign /*output*/ o_rready = (empty_word_cnt_q <= 8);

  assign /*output*/ o_rdata = buffer_q[ rptr_q ];

  // ---------------------------------------------------------------------------
  assign do_write = i_wvalid & o_wready;
  assign do_read  = i_rvalid & o_rready;

  always_comb begin
    act_wsize = '{default: 0};

    if (i_wvalid)
      for (int i = 0; i < 8; i++)
        act_wsize += i_wdata_valid[i];
  end

  always_comb begin
    buffer = wptr_q[3] ? {buffer_q[0], buffer_q[1]} :
                         {buffer_q[1], buffer_q[0]};
    buffer_d = buffer_q;

    wptr_d = wptr_q;

    if (do_write) begin
      for (int i = 0; i < 8; i++)
        if (act_wsize > i)
          buffer[ 64*(wptr_q[2:0]+i)+:64 ] = i_wdata[ (i+i_woffset)%8 ];

      if (wptr_q[3]) begin
        buffer_d[1] = buffer[ 511:  0];
        buffer_d[0] = buffer[1023:512];
      end
      else begin
        buffer_d[1] = buffer[1023:512];
        buffer_d[0] = buffer[ 511:  0];
      end

      wptr_d = wptr_q + act_wsize;
    end
  end

  assign valid_word_cnt = 16 - empty_word_cnt_q;

  always_comb begin
    if (do_read)
      rptr_d = rptr_q + 1;
    else
      rptr_d = rptr_q;

    empty_word_cnt_d = empty_word_cnt_q
                     - (do_write ? act_wsize : 0)
                     + (do_read ? 8 : 0);
  end

  // Flip-flops
  // ---------------------------------------------------------------------------
  always_ff @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      buffer_q         <= '{default: 0};
      wptr_q           <= '{default: 0};
      rptr_q           <= 1'b0;
      empty_word_cnt_q <= 5'd16;
    end
    else begin
      buffer_q         <= buffer_d;
      wptr_q           <= wptr_d;
      rptr_q           <= rptr_d;
      empty_word_cnt_q <= empty_word_cnt_d;
    end

endmodule

