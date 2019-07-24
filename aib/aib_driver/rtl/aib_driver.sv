
// *****************************************************************************
// Filename : aib_driver.sv
//
// Description :
//
// Notes :
// *****************************************************************************

`ifndef SYNTHESIS
module aib_driver
(
  inout  wire               PAD,

  input  logic              PU_N,
  input  logic              PD,

  input  logic  [   3 : 0 ] DRVEN,
  input  logic              TXD,
  output logic              RXD
);
  // Pull resistors
  bufif0 (pull1, pull0) (PAD, 1'b1, PU_N);
  bufif1 (pull1, pull0) (PAD, 1'b0, PD);

  // Output driver
  bufif1 (strong1, strong0) (PAD, TXD, DRVEN[0]);
  bufif1 (strong1, strong0) (PAD, TXD, DRVEN[1]);
  bufif1 (strong1, strong0) (PAD, TXD, DRVEN[2]);
  bufif1 (strong1, strong0) (PAD, TXD, DRVEN[3]);

  // Input buffer
  buf (RXD, PAD);

endmodule
`endif // SYNTHESIS

