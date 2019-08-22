
// *****************************************************************************
// Filename : umai_arb_afifo.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module umai_arb_afifo #(NumChannels = 6)
(
  input  logic              i_clk,

  input  logic              i_ip_clk,
  input  logic              i_bus_clk,

  input  logic              i_rst_n,

  input  logic              c_ip_sel,

  // External interface - connected to the two designs
  // ---------------------------------------------------------------------------

  // UMAI master
  output logic              o_ext_mst_wcmd_valid [1:0],
  input  logic              i_ext_mst_wcmd_ready [1:0],
  output logic  [  31 : 0 ] o_ext_mst_wcmd_addr  [1:0],
  output logic  [   5 : 0 ] o_ext_mst_wcmd_len   [1:0],

  output logic              o_ext_mst_rcmd_valid [1:0],
  input  logic              i_ext_mst_rcmd_ready [1:0],
  output logic  [  31 : 0 ] o_ext_mst_rcmd_addr  [1:0],
  output logic  [   5 : 0 ] o_ext_mst_rcmd_len   [1:0],

  output logic              o_ext_mst_wvalid     [1:0],
  input  logic              i_ext_mst_wready     [1:0],
  output logic  [ 511 : 0 ] o_ext_mst_wdata      [1:0],

  input  logic              i_ext_mst_rvalid     [1:0],
  output logic              o_ext_mst_rready     [1:0],
  input  logic  [ 511 : 0 ] i_ext_mst_rdata      [1:0],

  // UMAI slave
  input  logic              i_ext_slv_wcmd_valid [1:0],
  output logic              o_ext_slv_wcmd_ready [1:0],
  input  logic  [  31 : 0 ] i_ext_slv_wcmd_addr  [1:0],
  input  logic  [   5 : 0 ] i_ext_slv_wcmd_len   [1:0],

  input  logic              i_ext_slv_rcmd_valid [1:0],
  output logic              o_ext_slv_rcmd_ready [1:0],
  input  logic  [  31 : 0 ] i_ext_slv_rcmd_addr  [1:0],
  input  logic  [   5 : 0 ] i_ext_slv_rcmd_len   [1:0],

  input  logic              i_ext_slv_wvalid     [1:0],
  output logic              o_ext_slv_wready     [1:0],
  input  logic  [ 511 : 0 ] i_ext_slv_wdata      [1:0],

  output logic              o_ext_slv_rvalid     [1:0],
  input  logic              i_ext_slv_rready     [1:0],
  output logic  [ 511 : 0 ] o_ext_slv_rdata      [1:0],

  // Internal interface - connected to the umai_master/slave module
  // ---------------------------------------------------------------------------

  // UMAI master
  input  logic              i_int_mst_wcmd_valid,
  output logic              o_int_mst_wcmd_ready,
  input  logic  [  31 : 0 ] i_int_mst_wcmd_addr,
  input  logic  [   5 : 0 ] i_int_mst_wcmd_len,

  input  logic              i_int_mst_rcmd_valid,
  output logic              o_int_mst_rcmd_ready,
  input  logic  [  31 : 0 ] i_int_mst_rcmd_addr,
  input  logic  [   5 : 0 ] i_int_mst_rcmd_len,

  input  logic              i_int_mst_wvalid,
  output logic              o_int_mst_wready,
  input  logic  [ 511 : 0 ] i_int_mst_wdata,

  output logic              o_int_mst_rvalid,
  input  logic              i_int_mst_rready,
  output logic  [ 511 : 0 ] o_int_mst_rdata,

  // UMAI slave
  output logic              o_int_slv_wcmd_valid,
  input  logic              i_int_slv_wcmd_ready,
  output logic  [  31 : 0 ] o_int_slv_wcmd_addr,
  output logic  [   5 : 0 ] o_int_slv_wcmd_len,

  output logic              o_int_slv_rcmd_valid,
  input  logic              i_int_slv_rcmd_ready,
  output logic  [  31 : 0 ] o_int_slv_rcmd_addr,
  output logic  [   5 : 0 ] o_int_slv_rcmd_len,

  output logic              o_int_slv_wvalid,
  input  logic              i_int_slv_wready,
  output logic  [ 511 : 0 ] o_int_slv_wdata,

  input  logic              i_int_slv_rvalid,
  output logic              o_int_slv_rready,
  input  logic  [ 511 : 0 ] i_int_slv_rdata
);
  // Master wcmd
  // ---------------------------------------------------------------------------
  logic             mst_wcmd_fifo_write;
  logic             mst_wcmd_fifo_full;
  logic [  37 : 0 ] mst_wcmd_fifo_wdata;

  logic             mst_wcmd_fifo_read;
  logic             mst_wcmd_fifo_empty;
  logic [  37 : 0 ] mst_wcmd_fifo_rdata;

  // FIFO write part
  assign o_int_mst_wcmd_ready = !mst_wcmd_fifo_full;

  assign mst_wcmd_fifo_write = i_int_mst_wcmd_valid & o_int_mst_wcmd_ready;
  assign mst_wcmd_fifo_wdata = {i_int_mst_wcmd_len, i_int_mst_wcmd_addr};

  // FIFO read part
  always_comb begin
    o_ext_mst_wcmd_valid = '{default: 0};
    o_ext_mst_wcmd_addr  = '{default: 0};
    o_ext_mst_wcmd_len   = '{default: 0};

    o_ext_mst_wcmd_valid [c_ip_sel] = ~mst_wcmd_fifo_empty;
    o_ext_mst_wcmd_addr  [c_ip_sel] = mst_wcmd_fifo_rdata[31: 0];
    o_ext_mst_wcmd_len   [c_ip_sel] = mst_wcmd_fifo_rdata[37:32];

    mst_wcmd_fifo_read = !mst_wcmd_fifo_empty & i_ext_mst_wcmd_ready[c_ip_sel];
  end

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (38),
    .data_out_width (38),
    .depth          (8),
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
  u_mst_wcmd_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_bus_clk),
    .push_req_n (~mst_wcmd_fifo_write),
    .flush_n    (1'b1),
    .data_in    (mst_wcmd_fifo_wdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (mst_wcmd_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_ip_clk),
    .pop_req_n  (~mst_wcmd_fifo_read),
    .data_out   (mst_wcmd_fifo_rdata),
    .pop_empty  (mst_wcmd_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

  // Master rcmd
  // ---------------------------------------------------------------------------
  logic             mst_rcmd_fifo_write;
  logic             mst_rcmd_fifo_full;
  logic [  37 : 0 ] mst_rcmd_fifo_wdata;

  logic             mst_rcmd_fifo_read;
  logic             mst_rcmd_fifo_empty;
  logic [  37 : 0 ] mst_rcmd_fifo_rdata;

  // FIFO write part
  assign o_int_mst_rcmd_ready = !mst_rcmd_fifo_full;

  assign mst_rcmd_fifo_write = i_int_mst_rcmd_valid & o_int_mst_rcmd_ready;
  assign mst_rcmd_fifo_wdata = {i_int_mst_rcmd_len, i_int_mst_rcmd_addr};

  // FIFO read part
  always_comb begin
    o_ext_mst_rcmd_valid = '{default: 0};
    o_ext_mst_rcmd_addr  = '{default: 0};
    o_ext_mst_rcmd_len   = '{default: 0};

    o_ext_mst_rcmd_valid [c_ip_sel] = ~mst_rcmd_fifo_empty;
    o_ext_mst_rcmd_addr  [c_ip_sel] = mst_rcmd_fifo_rdata[31: 0];
    o_ext_mst_rcmd_len   [c_ip_sel] = mst_rcmd_fifo_rdata[37:32];

    mst_rcmd_fifo_read = !mst_rcmd_fifo_empty & i_ext_mst_rcmd_ready[c_ip_sel];
  end

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (38),
    .data_out_width (38),
    .depth          (8),
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
  u_mst_rcmd_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_bus_clk),
    .push_req_n (~mst_rcmd_fifo_write),
    .flush_n    (1'b1),
    .data_in    (mst_rcmd_fifo_wdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (mst_rcmd_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_ip_clk),
    .pop_req_n  (~mst_rcmd_fifo_read),
    .data_out   (mst_rcmd_fifo_rdata),
    .pop_empty  (mst_rcmd_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

  // Master wdata
  // ---------------------------------------------------------------------------
  logic             mst_wdata_fifo_write;
  logic             mst_wdata_fifo_full;
  logic [ 511 : 0 ] mst_wdata_fifo_wdata;

  logic             mst_wdata_fifo_read;
  logic             mst_wdata_fifo_empty;
  logic [ 511 : 0 ] mst_wdata_fifo_rdata;

  // FIFO write part
  assign o_int_mst_wready = !mst_wdata_fifo_full;

  assign mst_wdata_fifo_write = i_int_mst_wvalid & o_int_mst_wready;
  assign mst_wdata_fifo_wdata = i_int_mst_wdata;

  // FIFO read part
  always_comb begin
    o_ext_mst_wvalid = '{default: 0};
    o_ext_mst_wdata  = '{default: 0};

    o_ext_mst_wvalid [c_ip_sel] = ~mst_wdata_fifo_empty;
    o_ext_mst_wdata  [c_ip_sel] = mst_wdata_fifo_rdata;

    mst_wdata_fifo_read = !mst_wdata_fifo_empty & i_ext_mst_wready[c_ip_sel];
  end

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (512),
    .data_out_width (512),
    .depth          (4),
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
  u_mst_wdata_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_bus_clk),
    .push_req_n (~mst_wdata_fifo_write),
    .flush_n    (1'b1),
    .data_in    (mst_wdata_fifo_wdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (mst_wdata_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_ip_clk),
    .pop_req_n  (~mst_wdata_fifo_read),
    .data_out   (mst_wdata_fifo_rdata),
    .pop_empty  (mst_wdata_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

  // Master rdata
  // ---------------------------------------------------------------------------
  logic             mst_rdata_fifo_write;
  logic             mst_rdata_fifo_full;
  logic [ 511 : 0 ] mst_rdata_fifo_wdata;

  logic             mst_rdata_fifo_read;
  logic             mst_rdata_fifo_empty;
  logic [ 511 : 0 ] mst_rdata_fifo_rdata;

  // FIFO write part
  always_comb begin
    o_ext_mst_rready = '{default: 0};

    o_ext_mst_rready [c_ip_sel] = ~mst_rdata_fifo_full;

    mst_rdata_fifo_write = i_ext_mst_rvalid[c_ip_sel] & o_ext_mst_rready[c_ip_sel];
    mst_rdata_fifo_wdata = i_ext_mst_rdata[c_ip_sel];
  end

  // FIFO read part
  assign o_int_mst_rvalid = !mst_rdata_fifo_empty;
  assign o_int_mst_rdata  = mst_rdata_fifo_rdata;

  assign mst_rdata_fifo_read = o_int_mst_rvalid & i_int_mst_rready;

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (512),
    .data_out_width (512),
    .depth          (4),
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
  u_mst_rdata_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_ip_clk),
    .push_req_n (~mst_rdata_fifo_write),
    .flush_n    (1'b1),
    .data_in    (mst_rdata_fifo_rdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (mst_rdata_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_bus_clk),
    .pop_req_n  (~mst_rdata_fifo_read),
    .data_out   (mst_rdata_fifo_rdata),
    .pop_empty  (mst_rdata_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

  // Slave wcmd
  // ---------------------------------------------------------------------------
  logic             slv_wcmd_fifo_write;
  logic             slv_wcmd_fifo_full;
  logic [  37 : 0 ] slv_wcmd_fifo_wdata;

  logic             slv_wcmd_fifo_read;
  logic             slv_wcmd_fifo_empty;
  logic [  37 : 0 ] slv_wcmd_fifo_rdata;

  // FIFO write part
  always_comb begin
    o_ext_slv_wcmd_ready = '{default: 0};

    o_ext_slv_wcmd_ready [c_ip_sel] = ~slv_wcmd_fifo_full;

    slv_wcmd_fifo_write = i_ext_slv_wcmd_valid[c_ip_sel] & o_ext_slv_wcmd_ready[c_ip_sel];
    slv_wcmd_fifo_wdata = {i_ext_slv_wcmd_len[c_ip_sel], i_ext_slv_wcmd_addr[c_ip_sel]};
  end

  // FIFO read part
  assign o_int_slv_wcmd_valid = !slv_wcmd_fifo_empty;
  assign o_int_slv_wcmd_addr  = slv_wcmd_fifo_rdata[31: 0];
  assign o_int_slv_wcmd_len   = slv_wcmd_fifo_rdata[37:32];

  assign slv_wcmd_fifo_read = o_int_slv_wcmd_valid & i_int_slv_wcmd_ready;

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (38),
    .data_out_width (38),
    .depth          (8),
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
  u_slv_wcmd_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_ip_clk),
    .push_req_n (~slv_wcmd_fifo_write),
    .flush_n    (1'b1),
    .data_in    (slv_wcmd_fifo_rdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (slv_wcmd_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_bus_clk),
    .pop_req_n  (~slv_wcmd_fifo_read),
    .data_out   (slv_wcmd_fifo_rdata),
    .pop_empty  (slv_wcmd_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

  // Slave rcmd
  // ---------------------------------------------------------------------------
  logic             slv_rcmd_fifo_write;
  logic             slv_rcmd_fifo_full;
  logic [  37 : 0 ] slv_rcmd_fifo_wdata;

  logic             slv_rcmd_fifo_read;
  logic             slv_rcmd_fifo_empty;
  logic [  37 : 0 ] slv_rcmd_fifo_rdata;

  // FIFO write part
  always_comb begin
    o_ext_slv_rcmd_ready = '{default: 0};

    o_ext_slv_rcmd_ready [c_ip_sel] = ~slv_rcmd_fifo_full;

    slv_rcmd_fifo_write = i_ext_slv_rcmd_valid[c_ip_sel] & o_ext_slv_rcmd_ready[c_ip_sel];
    slv_rcmd_fifo_wdata = {i_ext_slv_rcmd_len[c_ip_sel], i_ext_slv_rcmd_addr[c_ip_sel]};
  end

  // FIFO read part
  assign o_int_slv_rcmd_valid = !slv_rcmd_fifo_empty;
  assign o_int_slv_rcmd_addr  = slv_rcmd_fifo_rdata[31: 0];
  assign o_int_slv_rcmd_len   = slv_rcmd_fifo_rdata[37:32];

  assign slv_rcmd_fifo_read = o_int_slv_rcmd_valid & i_int_slv_rcmd_ready;

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (38),
    .data_out_width (38),
    .depth          (8),
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
  u_slv_rcmd_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_ip_clk),
    .push_req_n (~slv_rcmd_fifo_write),
    .flush_n    (1'b1),
    .data_in    (slv_rcmd_fifo_rdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (slv_rcmd_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_bus_clk),
    .pop_req_n  (~slv_rcmd_fifo_read),
    .data_out   (slv_rcmd_fifo_rdata),
    .pop_empty  (slv_rcmd_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

  // Slave wdata
  // ---------------------------------------------------------------------------
  logic             slv_wdata_fifo_write;
  logic             slv_wdata_fifo_full;
  logic [ 511 : 0 ] slv_wdata_fifo_wdata;

  logic             slv_wdata_fifo_read;
  logic             slv_wdata_fifo_empty;
  logic [ 511 : 0 ] slv_wdata_fifo_rdata;

  // FIFO write part
  always_comb begin
    o_ext_slv_wready = '{default: 0};

    o_ext_slv_wready [c_ip_sel] = ~slv_wdata_fifo_full;

    slv_wdata_fifo_write = i_ext_slv_wvalid[c_ip_sel] & o_ext_slv_wready[c_ip_sel];
    slv_wdata_fifo_wdata = i_ext_slv_wdata[c_ip_sel];
  end

  // FIFO read part
  assign o_int_slv_wvalid = !slv_wdata_fifo_empty;
  assign o_int_slv_wdata  = slv_wdata_fifo_rdata;

  assign slv_wdata_fifo_read = o_int_slv_wvalid & i_int_slv_wready;

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (512),
    .data_out_width (512),
    .depth          (4),
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
  u_slv_wdata_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_ip_clk),
    .push_req_n (~slv_wdata_fifo_write),
    .flush_n    (1'b1),
    .data_in    (slv_wdata_fifo_rdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (slv_wdata_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_bus_clk),
    .pop_req_n  (~slv_wdata_fifo_read),
    .data_out   (slv_wdata_fifo_rdata),
    .pop_empty  (slv_wdata_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

  // Slave rdata
  // ---------------------------------------------------------------------------
  logic             slv_rdata_fifo_write;
  logic             slv_rdata_fifo_full;
  logic [ 511 : 0 ] slv_rdata_fifo_wdata;

  logic             slv_rdata_fifo_read;
  logic             slv_rdata_fifo_empty;
  logic [ 511 : 0 ] slv_rdata_fifo_rdata;

  // FIFO write part
  assign o_int_slv_rready = !slv_rdata_fifo_full;

  assign slv_rdata_fifo_write = i_int_slv_rvalid & o_int_slv_rready;
  assign slv_rdata_fifo_wdata = i_int_slv_rdata;

  // FIFO read part
  always_comb begin
    o_ext_slv_rvalid = '{default: 0};
    o_ext_slv_rdata  = '{default: 0};

    o_ext_slv_rvalid [c_ip_sel] = ~slv_rdata_fifo_empty;
    o_ext_slv_rdata  [c_ip_sel] = slv_rdata_fifo_rdata;

    slv_rdata_fifo_read = !slv_rdata_fifo_empty & i_ext_slv_rready[c_ip_sel];
  end

  // FIFO
  DW_asymfifo_s2_sf
  #(
    .data_in_width  (512),
    .data_out_width (512),
    .depth          (4),
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
  u_slv_rdata_fifo (
    .rst_n      (i_rst_n),

    .clk_push   (i_bus_clk),
    .push_req_n (~slv_rdata_fifo_write),
    .flush_n    (1'b1),
    .data_in    (slv_rdata_fifo_rdata),
    .push_empty (),
    .push_ae    (),
    .push_hf    (),
    .push_af    (),
    .push_full  (slv_rdata_fifo_full),
    .ram_full   (),
    .part_wd    (),
    .push_error (),

    .clk_pop    (i_ip_clk),
    .pop_req_n  (~slv_rdata_fifo_read),
    .data_out   (slv_rdata_fifo_rdata),
    .pop_empty  (slv_rdata_fifo_empty),
    .pop_ae     (),
    .pop_hf     (),
    .pop_af     (),
    .pop_full   (),//fifo_rd_full),
    .pop_error  ()
  );

endmodule

