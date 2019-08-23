
// *****************************************************************************
// Filename : aib_top_control.sv
//
// Description :
//
// Notes :
// *****************************************************************************

module aib_top_control
(
  input  logic              i_rst_n,

  //output logic              o_io_rst_n,
  output logic              o_sys_rst_n,
  //output logic              o_adapt_rst_n,

  input  logic              i_bypass,
  input  logic              i_bypass_clk,

  output logic              o_aib_clk,
  output logic              o_bus_clk,

  output logic              o_slow_clk
);
  // Output assignments
  // ---------------------------------------------------------------------------
  assign /*output*/ o_sys_rst_n = i_rst_n;

  // ---------------------------------------------------------------------------
  clkgen u_clkgen (
    .i_cfg_en       (1'b0),//i_rst_n & aib_clkgen_cfg[10]),
    .i_cfg_chg      (1'b0),//cfg_chg),
    .i_cfg_osc_sel  (4'd15),//aib_clkgen_cfg[7:4]),
    .i_cfg_div_sel  (2'd3),//aib_clkgen_cfg[1:0]),

    .i_osc_en       (1'b0),//i_rst_n & aib_clkgen_cfg[11]),
    .o_osc_clk      (o_aib_clk),
    .o_osc_slow_clk (o_slow_clk),

    .i_bypass       (i_bypass),//i_bypass | aib_clkgen_cfg[9]),
    .i_bypass_clk   (i_bypass_clk),//i_bypass_clk),

    .i_forward      (1'b0),//aib_clkgen_cfg[8]),
    .i_forward_clk  (1'b0) //i_fwd_clk)
  );

  // TODO use clock divider
  always_ff @(posedge o_aib_clk or negedge i_rst_n)
    if (!i_rst_n)
      o_bus_clk <= 1'b0;
    else
      o_bus_clk <= ~o_bus_clk;

endmodule

