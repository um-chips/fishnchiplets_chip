
// *****************************************************************************
// Filename : umai_dnsize_buffer.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module umai_dnsize_buffer
(
  input  logic              i_clk,
  input  logic              i_rst_n,

  input  logic              i_wvalid,
  output logic              o_wready,
  input  logic  [ 511 : 0 ] i_wdata,

  input  logic              i_rvalid,
  output logic              o_rready,
  input  logic  [   2 : 0 ] i_roffset,
  input  logic  [   2 : 0 ] i_rsize,
  output logic              o_rdata_valid [7:0],
  output logic  [  63 : 0 ] o_rdata       [7:0]
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic [   511 : 0 ] buffer_d [2], buffer_q[2];
  logic [  1023 : 0 ] buffer;

  logic               wptr_d, wptr_q;
  logic [     3 : 0 ] rptr_d, rptr_q;

  logic [     4 : 0 ] empty_word_cnt_d, empty_word_cnt_q;
  logic [     4 : 0 ] valid_word_cnt;

  logic [     3 : 0 ] act_rsize;

  logic               do_write;
  logic               do_read;

  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_wready = (empty_word_cnt_q >= 8);

  assign /*output*/ o_rready = (empty_word_cnt_q != 16);

  always_comb begin
    o_rdata_valid = '{default: 0};
    o_rdata       = '{default: 0};

    for (int i = 0; i < 8; i++)
      if (act_rsize > i) begin
        o_rdata_valid[ (i_roffset+i)%8 ] = 1'b1;
        o_rdata      [ (i_roffset+i)%8 ] = buffer[ 64*(rptr_q[2:0]+i)+:64 ];
      end
  end

  // ---------------------------------------------------------------------------
  assign do_write = i_wvalid & o_wready;
  assign do_read  = i_rvalid & o_rready;

  assign buffer = rptr_q[3] ? {buffer_q[0], buffer_q[1]} :
                              {buffer_q[1], buffer_q[0]};

  always_comb begin
    buffer_d = buffer_q;

    wptr_d = wptr_q;

    if (do_write) begin
      buffer_d[ wptr_q ] = i_wdata;

      wptr_d = wptr_q + 1;
    end
  end

  assign valid_word_cnt = 16 - empty_word_cnt_q;

  assign act_rsize = i_rvalid ?
                       ((i_rsize+1) > valid_word_cnt) ? valid_word_cnt : (i_rsize+1) :
                       '{default: 0};

  always_comb begin
    if (do_read)
      rptr_d = rptr_q + act_rsize;
    else
      rptr_d = rptr_q;

    empty_word_cnt_d = empty_word_cnt_q
                     - (do_write ? 8 : 0)
                     + (do_read ? act_rsize : 0);
  end

  // Flip-flops
  // ---------------------------------------------------------------------------
  always_ff @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      buffer_q         <= '{default: 0};
      wptr_q           <= 1'b0;
      rptr_q           <= '{default: 0};
      empty_word_cnt_q <= 5'd16;
    end
    else begin
      buffer_q         <= buffer_d;
      wptr_q           <= wptr_d;
      rptr_q           <= rptr_d;
      empty_word_cnt_q <= empty_word_cnt_d;
    end

endmodule

