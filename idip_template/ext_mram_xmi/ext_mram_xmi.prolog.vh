`include "ervp_global.vh"
`include "ervp_axi_define.vh"
`include "sim_info.vh"
`include "munoc_network_include.vh"

module "${MODULE_NAME}"
(
	clk,
	rstnn,

	rlxqdready,
  rlxqvalid,
  rlxqxlast,
  rlxqxwrite,
  rlxqxlen,
  rlxqxsize,
  rlxqxburst,
  rlxqxwstrb,
  rlxqwdata,
  rlxqaddr,
  rlxqburden,
  rlxydready,
  rlxyvalid,
  rlxyxlast,
  rlxyxwreply,
  rlxyxresp,
  rlxyrdata,
  rlxyburden,

  EXTMR_E_N,
  EXTMR_W_N,
  EXTMR_G_N,
  EXTMR_BE_N,
  EXTMR_A,
  EXTMR_DQ_sod,
  EXTMR_DQ_soval,
  EXTMR_DQ_sival
);

////////////////////////////
/* parameter input output */
////////////////////////////

parameter BW_ADDR = "${BW_ADDR}";
parameter BW_LPI_BURDEN = `REQUIRED_BW_OF_SLAVE_TID;

localparam CAPACITY = 32'h 8000000;  // in bytes
localparam BW_DATA = 32;
localparam CELL_SIZE = CAPACITY;  // in bytes
localparam CELL_WIDTH = 32; // MUST greater than or equal to BW_DATA

`include "ervp_log_util.vf"
`include "ervp_bitwidth_util.vf"

localparam BW_BYTE_WEN = `NUM_BYTE(CELL_WIDTH);
localparam CELL_DEPTH = `DIVIDERU(CELL_SIZE,BW_BYTE_WEN);
localparam BW_CELL_INDEX = REQUIRED_BITWIDTH_INDEX(CELL_DEPTH);

localparam NUM_CELL = `DIVIDERU(CAPACITY,CELL_SIZE);

input wire clk, rstnn;

localparam BW_AXI_ADDR = BW_ADDR;
localparam BW_AXI_DATA = BW_DATA;
localparam BW_AXI_TID = BW_LPI_BURDEN;

output wire [(2)-1:0] rlxqdready;
input wire rlxqvalid;
input wire rlxqxlast;
input wire rlxqxwrite;
input wire [`BW_AXI_ALEN-1:0] rlxqxlen;
input wire [`BW_AXI_ASIZE-1:0] rlxqxsize;
input wire [`BW_AXI_ABURST-1:0] rlxqxburst;
input wire [`BW_AXI_WSTRB(BW_AXI_DATA)-1:0] rlxqxwstrb;
input wire [BW_AXI_DATA-1:0] rlxqwdata;
input wire [BW_AXI_ADDR-1:0] rlxqaddr;
input wire [BW_LPI_BURDEN-1:0] rlxqburden;
input wire [(2)-1:0] rlxydready;
output wire rlxyvalid;
output wire rlxyxlast;
output wire rlxyxwreply;
output wire [`BW_AXI_RESP-1:0] rlxyxresp;
output wire [BW_AXI_DATA-1:0] rlxyrdata;
output wire [BW_LPI_BURDEN-1:0] rlxyburden;

output wire EXTMR_E_N;
output wire EXTMR_W_N;
output wire EXTMR_G_N;
output wire [(4)-1:0] EXTMR_BE_N;
output wire [(21)-1:0] EXTMR_A;
output wire [(32)-1:0] EXTMR_DQ_sod;
output wire [(32)-1:0] EXTMR_DQ_soval;
input wire [(32)-1:0] EXTMR_DQ_sival;
