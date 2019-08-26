
// *****************************************************************************
// Filename : umai_master.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module umai_master #(parameter NumChannels = 6)
(
  input  logic              i_clk,
  input  logic              i_rst_n,

  input  logic  [   2 : 0 ] c_first_chn_id,
  input  logic  [   2 : 0 ] c_last_chn_id,

  // UMAI master interface
  output logic              o_umai_wcmd_valid,
  input  logic              i_umai_wcmd_ready,
  output logic  [  31 : 0 ] o_umai_wcmd_addr,
  output logic  [   5 : 0 ] o_umai_wcmd_len,

  output logic              o_umai_rcmd_valid,
  input  logic              i_umai_rcmd_ready,
  output logic  [  31 : 0 ] o_umai_rcmd_addr,
  output logic  [   5 : 0 ] o_umai_rcmd_len,

  output logic              o_umai_wvalid,
  input  logic              i_umai_wready,
  output logic  [ 511 : 0 ] o_umai_wdata,

  input  logic              i_umai_rvalid,
  output logic              o_umai_rready,
  input  logic  [ 511 : 0 ] i_umai_rdata,

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

  logic             wdata_all_channels_valid;

  logic             wdata_buffer_wvalid;
  logic             wdata_buffer_wready;
  logic [   2 : 0 ] wdata_buffer_woffset;
  logic [   2 : 0 ] wdata_buffer_wsize;
  logic             wdata_buffer_wdata_valid [7:0];
  logic [  63 : 0 ] wdata_buffer_wdata       [7:0];
  logic             wdata_buffer_rvalid;
  logic             wdata_buffer_rready;

  logic             rdata_all_channels_ready;

  logic             rdata_buffer_rvalid;
  logic             rdata_buffer_rready;
  logic [   2 : 0 ] rdata_buffer_roffset;
  logic [   2 : 0 ] rdata_buffer_rsize;
  logic             rdata_buffer_rdata_valid [7:0];
  logic [  63 : 0 ] rdata_buffer_rdata       [7:0];

  // Write command buffer
  // ---------------------------------------------------------------------------
  assign /*output*/ o_umai_wcmd_valid = !wcmd_buffer_empty;
  assign /*output*/ o_umai_wcmd_addr  = wcmd_buffer_rdata[31: 0];
  assign /*output*/ o_umai_wcmd_len   = wcmd_buffer_rdata[37:32];

  assign wcmd_buffer_read = o_umai_wcmd_valid & i_umai_wcmd_ready;

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
  assign /*output*/ o_umai_rcmd_valid = !rcmd_buffer_empty;
  assign /*output*/ o_umai_rcmd_addr  = rcmd_buffer_rdata[31: 0];
  assign /*output*/ o_umai_rcmd_len   = rcmd_buffer_rdata[37:32];

  assign rcmd_buffer_read = o_umai_rcmd_valid & i_umai_rcmd_ready;

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
  assign /*output*/ o_umai_wvalid = wdata_buffer_rready;

  assign wdata_buffer_rvalid = o_umai_wvalid & i_umai_wready;

  umai_upsize_buffer u_wdata_buffer (
    .i_clk         (i_clk),
    .i_rst_n       (i_rst_n),

    .i_wvalid      (wdata_buffer_wvalid),
    .o_wready      (wdata_buffer_wready),
    .i_woffset     (wdata_buffer_woffset),
    .i_wsize       (wdata_buffer_wsize),
    .i_wdata_valid (wdata_buffer_wdata_valid),
    .i_wdata       (wdata_buffer_wdata),

    .i_rvalid      (wdata_buffer_rvalid),
    .o_rready      (wdata_buffer_rready),
    .o_rdata       (o_umai_wdata)
  );

  // Read data buffer
  // ---------------------------------------------------------------------------
  umai_dnsize_buffer u_rdata_buffer (
    .i_clk         (i_clk),
    .i_rst_n       (i_rst_n),

    .i_wvalid      (i_umai_rvalid),
    .o_wready      (o_umai_rready),
    .i_wdata       (i_umai_rdata),

    .i_rvalid      (rdata_buffer_rvalid),
    .o_rready      (rdata_buffer_rready),
    .i_roffset     (rdata_buffer_roffset),
    .i_rsize       (rdata_buffer_rsize),
    .o_rdata_valid (rdata_buffer_rdata_valid),
    .o_rdata       (rdata_buffer_rdata)
  );

  // ---------------------------------------------------------------------------
  // Command and write data
  // ---------------------------------------------------------------------------

  always_comb begin
    // Default values
    first_chn_id = c_first_chn_id;
    last_chn_id  = c_last_chn_id;

    o_rx_ready = '{default: 0};

    wcmd_buffer_write = 1'b0;
    wcmd_buffer_wdata = '{default: 0};

    rcmd_buffer_write = 1'b0;
    rcmd_buffer_wdata = '{default: 0};

    wdata_all_channels_valid = 1'b1;

    wdata_buffer_wvalid      = 1'b0;
    wdata_buffer_woffset     = 3'd0;
    wdata_buffer_wsize       = 3'd0;
    wdata_buffer_wdata_valid = '{default: 0};
    wdata_buffer_wdata       = '{default: 0};

    // Check if there's an incoming command
    // -------------------------------------------------------------------------
    if (i_rx_valid[c_first_chn_id] && i_rx_data[c_first_chn_id][71]) begin
      first_chn_id = c_first_chn_id + 1;

      unique case (i_rx_data[c_first_chn_id][70])
        // Read command
        1'b0: begin
          if (!rcmd_buffer_full) begin
            o_rx_ready[c_first_chn_id] = 1'b1;

            rcmd_buffer_write = 1'b1;
            rcmd_buffer_wdata = i_rx_data[c_first_chn_id][37:0];
          end
        end

        // Write command
        1'b1: begin
          if (!wcmd_buffer_full) begin
            o_rx_ready[c_first_chn_id] = 1'b1;

            wcmd_buffer_write = 1'b1;
            wcmd_buffer_wdata = i_rx_data[c_first_chn_id][37:0];
          end
        end
      endcase
    end

    // -------------------------------------------------------------------------
    wdata_buffer_woffset = first_chn_id;
    wdata_buffer_wsize   = last_chn_id - first_chn_id;

    // If we have only one channel and it's used to send command, then there will
    // be no channel for data
    //if (first_chn_id > last_chn_id)
    //  wdata_all_channels_valid = 1'b0;
    // This is added to disable packing command with data, as a workaround to a
    // known bug that happens when a command is read but the data buffer is full
    if (i_rx_valid[c_first_chn_id] && i_rx_data[c_first_chn_id][71])
      wdata_all_channels_valid = 1'b0;
    else
      // Otherwise check if all the channels for write data are valid
      for (int i = 0; i < NumChannels; i++)
        if (i >= first_chn_id && i <= last_chn_id)
          wdata_all_channels_valid &= i_rx_valid[i];

    // There's incoming write data
    if (wdata_all_channels_valid) begin
      // And there's room in the write data buffer
      if (wdata_buffer_wready) begin
        for (int i = 0; i < NumChannels; i++)
          if (i >= first_chn_id && i <= last_chn_id)
            o_rx_ready[i] = 1'b1;

        wdata_buffer_wvalid = 1'b1;
      end

      for (int i = 0; i < NumChannels; i++)
        if (i >= first_chn_id && i <= last_chn_id) begin
          wdata_buffer_wdata_valid[i] = i_rx_data[i][64];
          wdata_buffer_wdata      [i] = i_rx_data[i][63:0];
        end
    end
  end

  // ---------------------------------------------------------------------------
  // Read data
  // ---------------------------------------------------------------------------

  always_comb begin
    o_tx_valid = '{default: 0};
    o_tx_data  = '{default: 0};

    rdata_all_channels_ready = 1'b1;

    rdata_buffer_rvalid  = 1'b0;
    rdata_buffer_roffset = c_first_chn_id;
    rdata_buffer_rsize   = c_last_chn_id - c_first_chn_id;

    // Check if all the channels for read data are ready
    for (int i = 0; i < NumChannels; i++)
      if (i >= c_first_chn_id && i <= c_last_chn_id)
        rdata_all_channels_ready &= i_tx_ready[i];

    // We have read data to send
    if (rdata_buffer_rready) begin
      for (int i = 0; i < NumChannels; i++)
        if (i >= c_first_chn_id && i <= c_last_chn_id) begin
          o_tx_valid[i] = 1'b1;
          o_tx_data [i] = {7'b0, rdata_buffer_rdata_valid[i], rdata_buffer_rdata[i]};
        end

      // And all channels are ready
      if (rdata_all_channels_ready)
        rdata_buffer_rvalid = 1'b1;
    end
  end

endmodule

