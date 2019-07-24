
// *****************************************************************************
// Filename : umai_slave.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module umai_slave #(parameter NumChannels = 6)
(
  input  logic              i_clk,
  input  logic              i_rst_n,

  input  logic  [   2 : 0 ] c_first_chn_id,
  input  logic  [   2 : 0 ] c_last_chn_id,

  // UMAI slave interface
  input  logic              i_umai_wcmd_valid,
  output logic              o_umai_wcmd_ready,
  input  logic  [  31 : 0 ] i_umai_wcmd_addr,
  input  logic  [   5 : 0 ] i_umai_wcmd_len,

  input  logic              i_umai_rcmd_valid,
  output logic              o_umai_rcmd_ready,
  input  logic  [  31 : 0 ] i_umai_rcmd_addr,
  input  logic  [   5 : 0 ] i_umai_rcmd_len,

  input  logic              i_umai_wvalid,
  output logic              o_umai_wready,
  input  logic  [ 511 : 0 ] i_umai_wdata,

  output logic              o_umai_rvalid,
  input  logic              i_umai_rready,
  output logic  [ 511 : 0 ] o_umai_rdata,

  // AIB interface
  output logic              o_tx_valid [NumChannels-1:0],
  input  logic              i_tx_ready [NumChannels-1:0],
  output logic  [  71 : 0 ] o_tx_data  [NumChannels-1:0],

  input  logic              i_rx_valid [NumChannels-1:0],
  output logic              o_rx_ready [NumChannels-1:0],
  input  logic  [  71 : 0 ] i_rx_data  [NumChannels-1:0]
);
  // Signal declarations
  // ---------------------------------------------------------------------------
  logic [   2 : 0 ] first_chn_id;
  logic [   2 : 0 ] last_chn_id;

  logic             wcmd_buffer_full;
  logic             wcmd_buffer_empty;
  logic             wcmd_buffer_write;
  logic [  37 : 0 ] wcmd_buffer_wdata;
  logic             wcmd_buffer_read;
  logic [  37 : 0 ] wcmd_buffer_rdata;

  logic             rcmd_buffer_full;
  logic             rcmd_buffer_empty;
  logic             rcmd_buffer_write;
  logic [  37 : 0 ] rcmd_buffer_wdata;
  logic             rcmd_buffer_read;
  logic [  37 : 0 ] rcmd_buffer_rdata;

  logic             wdata_all_channels_ready;

  logic             wdata_buffer_rvalid;
  logic             wdata_buffer_rready;
  logic [   2 : 0 ] wdata_buffer_roffset;
  logic [   2 : 0 ] wdata_buffer_rsize;
  logic             wdata_buffer_rdata_valid [7:0];
  logic [  63 : 0 ] wdata_buffer_rdata       [7:0];

  logic             rdata_all_channels_valid;

  logic             rdata_buffer_wvalid;
  logic             rdata_buffer_wready;
  logic [   2 : 0 ] rdata_buffer_woffset;
  logic [   2 : 0 ] rdata_buffer_wsize;
  logic             rdata_buffer_wdata_valid [7:0];
  logic [  63 : 0 ] rdata_buffer_wdata       [7:0];
  logic             rdata_buffer_rvalid;
  logic             rdata_buffer_rready;

  // Write command buffer
  // ---------------------------------------------------------------------------
  assign /*output*/ o_umai_wcmd_ready = !wcmd_buffer_full;

  assign wcmd_buffer_write = i_umai_wcmd_valid & o_umai_wcmd_ready;
  assign wcmd_buffer_wdata = {i_umai_wcmd_len, i_umai_wcmd_addr};

  fifo #(.Width(38), .Depth(2)) u_wcmd_buffer (
    .i_clk   (i_clk),
    .i_rst_n (i_rst_n),

    .o_full  (wcmd_buffer_full),
    .o_empty (wcmd_buffer_empty),

    .i_write (wcmd_buffer_write),
    .i_wdata (wcmd_buffer_wdata),

    .i_read  (wcmd_buffer_read),
    .o_rdata (wcmd_buffer_rdata)
  );

  // Read command buffer
  // ---------------------------------------------------------------------------
  assign /*output*/ o_umai_rcmd_ready = !rcmd_buffer_full;

  assign rcmd_buffer_write = i_umai_rcmd_valid & o_umai_rcmd_ready;
  assign rcmd_buffer_wdata = {i_umai_rcmd_len, i_umai_rcmd_addr};

  fifo #(.Width(38), .Depth(2)) u_rcmd_buffer (
    .i_clk   (i_clk),
    .i_rst_n (i_rst_n),

    .o_full  (rcmd_buffer_full),
    .o_empty (rcmd_buffer_empty),

    .i_write (rcmd_buffer_write),
    .i_wdata (rcmd_buffer_wdata),

    .i_read  (rcmd_buffer_read),
    .o_rdata (rcmd_buffer_rdata)
  );

  // Write data buffer
  // ---------------------------------------------------------------------------
  umai_dnsize_buffer u_wdata_buffer (
    .i_clk         (i_clk),
    .i_rst_n       (i_rst_n),

    .i_wvalid      (i_umai_wvalid),
    .o_wready      (o_umai_wready),
    .i_wdata       (i_umai_wdata),

    .i_rvalid      (wdata_buffer_rvalid),
    .o_rready      (wdata_buffer_rready),
    .i_roffset     (wdata_buffer_roffset),
    .i_rsize       (wdata_buffer_rsize),
    .o_rdata_valid (wdata_buffer_rdata_valid),
    .o_rdata       (wdata_buffer_rdata)
  );

  // Read data buffer
  // ---------------------------------------------------------------------------
  assign /*output*/ o_umai_rvalid = rdata_buffer_rready;

  assign rdata_buffer_rvalid = o_umai_rvalid & i_umai_rready;

  umai_upsize_buffer u_rdata_buffer (
    .i_clk         (i_clk),
    .i_rst_n       (i_rst_n),

    .i_wvalid      (rdata_buffer_wvalid),
    .o_wready      (rdata_buffer_wready),
    .i_woffset     (rdata_buffer_woffset),
    .i_wsize       (rdata_buffer_wsize),
    .i_wdata_valid (rdata_buffer_wdata_valid),
    .i_wdata       (rdata_buffer_wdata),

    .i_rvalid      (rdata_buffer_rvalid),
    .o_rready      (rdata_buffer_rready),
    .o_rdata       (o_umai_rdata)
  );

  // ---------------------------------------------------------------------------
  // Command and write data
  // ---------------------------------------------------------------------------

  always_comb begin
    // Default values
    first_chn_id = c_first_chn_id;
    last_chn_id  = c_last_chn_id;

    o_tx_valid = '{default: 0};
    o_tx_data  = '{default: 0};

    wcmd_buffer_read = 1'b0;

    rcmd_buffer_read = 1'b0;

    wdata_all_channels_ready = 1'b1;

    wdata_buffer_rvalid  = 1'b0;
    wdata_buffer_roffset = 3'd0;
    wdata_buffer_rsize   = 3'd0;

    // Check if we need to send a command
    // -------------------------------------------------------------------------
    if (!wcmd_buffer_empty | !rcmd_buffer_empty) begin
      first_chn_id = c_first_chn_id + 1;

      o_tx_valid[c_first_chn_id] = 1'b1;

      if (!wcmd_buffer_empty)
        o_tx_data[c_first_chn_id] = {1'b1, 1'b1, 32'b0, wcmd_buffer_rdata};
      else if (!rcmd_buffer_empty)
        o_tx_data[c_first_chn_id] = {1'b1, 1'b0, 32'b0, rcmd_buffer_rdata};

      if (i_tx_ready[c_first_chn_id]) begin
        if (!wcmd_buffer_empty)
          wcmd_buffer_read = 1'b1;
        else if (!rcmd_buffer_empty)
          rcmd_buffer_read = 1'b1;
      end
    end

    // -------------------------------------------------------------------------
    wdata_buffer_roffset = first_chn_id;
    wdata_buffer_rsize   = last_chn_id - first_chn_id;

    // If we have only one channel and it's used to send command, then there will
    // be no channel for data
    if (first_chn_id > last_chn_id)
      wdata_all_channels_ready = 1'b0;
    else
      // Otherwise check if all the channels for write data are ready
      for (int i = 0; i < NumChannels; i++)
        if (i >= first_chn_id && i <= last_chn_id)
          wdata_all_channels_ready &= i_tx_ready[i];

    // We have write data to send
    if (wdata_buffer_rready) begin
      for (int i = 0; i < NumChannels; i++)
        if (i >= first_chn_id && i <= last_chn_id) begin
          o_tx_valid[i] = 1'b1;
          o_tx_data [i] = {7'b0, wdata_buffer_rdata_valid[i], wdata_buffer_rdata[i]};
        end

      // And all channels are ready
      if (wdata_all_channels_ready)
        wdata_buffer_rvalid = 1'b1;
    end
  end

  // ---------------------------------------------------------------------------
  // Read data
  // ---------------------------------------------------------------------------

  always_comb begin
    o_rx_ready = '{default: 0};

    rdata_all_channels_valid = 1'b1;

    rdata_buffer_wvalid      = 1'b0;
    rdata_buffer_woffset     = c_first_chn_id;
    rdata_buffer_wsize       = c_last_chn_id - c_first_chn_id;
    rdata_buffer_wdata_valid = '{default: 0};
    rdata_buffer_wdata       = '{default: 0};

    // Check if all the channels for read data are valid
    for (int i = 0; i < NumChannels; i++)
      if (i >= c_first_chn_id && i <= c_last_chn_id)
        rdata_all_channels_valid &= i_rx_valid[i];

    // There's incoming read data, and there's room in the read data buffer
    if (rdata_all_channels_valid & rdata_buffer_wready) begin
      for (int i = 0; i < NumChannels; i++)
        if (i >= c_first_chn_id && i <= c_last_chn_id)
          o_rx_ready[i] = 1'b1;

      rdata_buffer_wvalid = 1'b1;
    end

    for (int i = 0; i < NumChannels; i++)
      if (i >= c_first_chn_id && i <= c_last_chn_id) begin
        rdata_buffer_wdata_valid[i] = i_rx_data[i][64];
        rdata_buffer_wdata      [i] = i_rx_data[i][63:0];
      end
  end

endmodule

