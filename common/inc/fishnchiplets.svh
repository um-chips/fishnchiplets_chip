
`ifndef FISHNCHIPLETS_SVH
`define FISHNCHIPLETS_SVH

  `define REG_IOB_BASE_ADDR     (32'h0 | 0<<12)
  `define REG_CHN_BASE_ADDR     (32'h0 | 1<<12)
  `define REG_UMAI_BASE_ADDR    (32'h0 | 2<<12)
  `define REG_CHIP_BASE_ADDR    (32'h0 | 3<<12)

  `define REG_IO_TX_EN          8
  `define REG_IO_DDR_MODE       7
  `define REG_IO_ASYNC_MODE     6
  `define REG_DRV_PULL_UP       5
  `define REG_DRV_PULL_DOWN     4
  `define REG_DRV_STRENGTH      0

  `define REG_CHN_MST_MODE      0

  `define REG_MST_FIRST_CHN_ID 10
  `define REG_MST_LAST_CHN_ID   7
  `define REG_SLV_FIRST_CHN_ID  4
  `define REG_SLV_LAST_CHN_ID   1
  `define REG_IP_SEL            0

  `define REG_CONF_DONE         0

`endif // FISHNCHIPLETS_SVH

