`include "ervp_global.vh"
`include "ervp_axi_define.vh"
`include "hw_info.vh"
`include "sim_info.vh"
`include "munoc_network_include.vh"

module "${MODULE_NAME}"
(
	clk,
	rstnn,

  control_rmx_core_config,
  control_rmx_core_status,
  control_rmx_clear_request,
  control_rmx_clear_finish,
  control_rmx_log_fifo_wready,
  control_rmx_log_fifo_wrequest,
  control_rmx_log_fifo_wdata,
  control_rmx_inst_fifo_rready,
  control_rmx_inst_fifo_rdata,
  control_rmx_inst_fifo_rrequest,
  control_rmx_operation_finish,
  control_rmx_input_fifo_rready,
  control_rmx_input_fifo_rdata,
  control_rmx_input_fifo_rrequest,
  control_rmx_output_fifo_wready,
  control_rmx_output_fifo_wrequest,
  control_rmx_output_fifo_wdata,

	rlxqdready,
  rlxqvalid,
  rlxqlast,
  rlxqwrite,
  rlxqlen,
  rlxqsize,
  rlxqburst,
  rlxqwstrb,
  rlxqwdata,
  rlxqaddr,
  rlxqburden,
  rlxydready,
  rlxyvalid,
  rlxylast,
  rlxywreply,
  rlxyresp,
  rlxyrdata,
  rlxyburden,

  EXTMR_E_N,
  EXTMR_W_N,
  EXTMR_G_N,
  EXTMR_BE_N,
  EXTMR_A,
  EXTMR_DQ_sod,
  EXTMR_DQ_soval,
  EXTMR_DQ_sival,
  EXTMR_LS_OE_P,
  EXTMR_LS_CE_N
);

////////////////////////////
/* parameter input output */
////////////////////////////

localparam CAPACITY = 32'h 8000000;  // in bytes
localparam BW_ADDR = "${BW_ADDR}";
localparam BW_DATA = 32;
localparam BW_LPI_BURDEN = `REQUIRED_BW_OF_SLAVE_TID;
localparam CELL_SIZE = CAPACITY;  // in bytes
localparam CELL_WIDTH = 32; // MUST greater than or equal to BW_DATA
localparam CLK_HZ = "${CLK_HZ}";

`include "ervp_log_util.vf"
`include "ervp_bitwidth_util.vf"

localparam BW_CONFIG = `BW_OFFCHIP_MRAM_MMIOX_CONFIG;
localparam BW_STATUS = 1;
localparam BW_LOG = 1;
localparam BW_INST = `BW_OFFCHIP_MRAM_MMIOX_INST;
localparam BW_INPUT = 1;
localparam BW_OUTPUT = `BW_OFFCHIP_MRAM_MMIOX_OUTPUT;

input wire [(BW_CONFIG)-1:0] control_rmx_core_config;
output wire [(BW_STATUS)-1:0] control_rmx_core_status;
input wire control_rmx_clear_request;
output wire control_rmx_clear_finish;
input wire control_rmx_log_fifo_wready;
output wire control_rmx_log_fifo_wrequest;
output wire [(BW_LOG)-1:0] control_rmx_log_fifo_wdata;
input wire control_rmx_inst_fifo_rready;
input wire [(BW_INST)-1:0] control_rmx_inst_fifo_rdata;
output wire control_rmx_inst_fifo_rrequest;
output wire control_rmx_operation_finish;
input wire control_rmx_input_fifo_rready;
input wire [(BW_INPUT)-1:0] control_rmx_input_fifo_rdata;
output wire control_rmx_input_fifo_rrequest;
input wire control_rmx_output_fifo_wready;
output wire control_rmx_output_fifo_wrequest;
output wire [(BW_OUTPUT)-1:0] control_rmx_output_fifo_wdata;

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
input wire rlxqlast;
input wire rlxqwrite;
input wire [`BW_AXI_ALEN-1:0] rlxqlen;
input wire [`BW_AXI_ASIZE-1:0] rlxqsize;
input wire [`BW_AXI_ABURST-1:0] rlxqburst;
input wire [`BW_AXI_WSTRB(BW_AXI_DATA)-1:0] rlxqwstrb;
input wire [BW_AXI_DATA-1:0] rlxqwdata;
input wire [BW_AXI_ADDR-1:0] rlxqaddr;
input wire [BW_LPI_BURDEN-1:0] rlxqburden;
input wire [(2)-1:0] rlxydready;
output wire rlxyvalid;
output wire rlxylast;
output wire rlxywreply;
output wire [`BW_AXI_RESP-1:0] rlxyresp;
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
output wire EXTMR_LS_OE_P;
output wire EXTMR_LS_CE_N;

/////////////
/* signals */
/////////////

genvar i;

`include "lpit_function.vb"
`include "lpixm_function.vb"

localparam BW_LPIXM_ADDR = BW_AXI_ADDR;
localparam BW_LPIXM_DATA = BW_AXI_DATA;

`include "lpixm_lpara.vb"

wire [2-1:0] lqdready;
wire lqvalid;
wire lqhint;
wire lqlast;
wire lqafy;
wire [BW_LPI_QDATA-1:0] lqdata;

wire [BW_LPI_BURDEN-1:0] lqburden;
wire [BW_LPI_QPARCEL-1:0] lqparcel;

wire [2-1:0] lydready;
wire lyvalid;
wire lyhint;
wire lylast;
wire [BW_LPI_YDATA-1:0] lydata;

wire [BW_LPI_BURDEN-1:0] lyburden;
wire [BW_LPI_YPARCEL-1:0] lyparcel;

wire [NUM_CELL-1:0] cell_select_list;
wire [BW_CELL_INDEX*NUM_CELL-1:0] cell_index_list;
wire [NUM_CELL-1:0] cell_enable_list;
wire [NUM_CELL-1:0] cell_wenable_list;
wire [BW_BYTE_WEN*NUM_CELL-1:0] cell_wenable_byte_list;
wire [BW_DATA*NUM_CELL-1:0] cell_wenable_bit_list;
wire [BW_DATA*NUM_CELL-1:0] cell_wdata_list;
wire [NUM_CELL-1:0] cell_renable_list;
wire [BW_DATA*NUM_CELL-1:0] cell_rdata_list;
wire [NUM_CELL-1:0] cell_stall_list;

wire [BW_CELL_INDEX-1:0] cell_index [NUM_CELL-1:0];
wire cell_enable [NUM_CELL-1:0];
wire cell_wenable [NUM_CELL-1:0];
wire [BW_BYTE_WEN-1:0] cell_wenable_byte [NUM_CELL-1:0];
wire [BW_DATA-1:0] cell_wenable_bit [NUM_CELL-1:0];
wire [BW_DATA-1:0] cell_wdata [NUM_CELL-1:0];
wire cell_renable [NUM_CELL-1:0];
wire [BW_DATA-1:0] cell_rdata [NUM_CELL-1:0];

localparam BW_STATE = BW_CONFIG;

reg [BW_STATE-1:0] cell_state;
wire is_last_cell_state;

////////////
/* logics */
////////////

assign control_rmx_core_status = 0;
assign control_rmx_clear_finish = 0;
assign control_rmx_log_fifo_wrequest = 0;
assign control_rmx_log_fifo_wdata = 0;
assign control_rmx_inst_fifo_rrequest = 0;
assign control_rmx_operation_finish = 0;
assign control_rmx_input_fifo_rrequest = 0;
assign control_rmx_output_fifo_wrequest = 0;
assign control_rmx_output_fifo_wdata = 0;

MUNOC_LPIXM2SCELL
#(
  .BW_ADDR(BW_ADDR),
  .BW_DATA(BW_DATA),
  .BW_LPI_BURDEN(BW_LPI_BURDEN),
  .BASEADDR(0),
  .BW_CELL_INDEX(BW_CELL_INDEX),
  .CELL_WIDTH(CELL_WIDTH),
  .NUM_CELL(NUM_CELL)
)
i_lpixm2scell
(
	.clk(clk),
	.rstnn(rstnn),
  .clear(1'b 0),
  .enable(1'b 1),

  .rlqdready(lqdready),
  .rlqvalid(lqvalid),
  .rlqhint(lqhint),
  .rlqlast(lqlast),
  .rlqafy(lqafy),
  .rlqdata(lqdata),

  .rlydready(lydready),
  .rlyvalid(lyvalid),
  .rlyhint(lyhint),
  .rlylast(lylast),
  .rlydata(lydata),

  .sscell_select_list(cell_select_list),
	.sscell_index_list(cell_index_list),
	.sscell_enable_list(cell_enable_list),
	.sscell_wenable_list(cell_wenable_list),
	.sscell_wenable_byte_list(cell_wenable_byte_list),
	.sscell_wenable_bit_list(cell_wenable_bit_list),
	.sscell_wdata_list(cell_wdata_list),
	.sscell_renable_list(cell_renable_list),
	.sscell_rdata_list(cell_rdata_list),
	.sscell_stall_list(cell_stall_list)
);

assign rlxqdready = lqdready;
assign lqvalid = rlxqvalid;
assign lqhint = 0;
assign lqlast = rlxqlast;
assign lqafy = (~rlxqwrite) | rlxqlast;
assign lqdata = {lqburden,lqparcel};

assign lqburden = rlxqburden;
assign lqparcel = {rlxqlast,rlxqwrite,rlxqlen,rlxqsize,rlxqburst,rlxqwstrb,rlxqwdata,rlxqaddr};

assign lydready = rlxydready;
assign rlxyvalid = lyvalid;
assign rlxylast = lylast;
assign {lyburden,lyparcel} = lydata;
assign rlxyburden = lyburden;
assign {rlxywreply,rlxyresp,rlxyrdata} = lyparcel;

generate
for(i=0; i<NUM_CELL; i=i+1)
begin : generate_cell_signals
  assign cell_index[i] = cell_index_list[BW_CELL_INDEX*(i+1)-1 -:BW_CELL_INDEX];
  assign cell_enable[i] = cell_enable_list[i];
  assign cell_wenable[i] = cell_wenable_list[i];
  assign cell_wenable_byte[i] = cell_wenable_byte_list[BW_BYTE_WEN*(i+1)-1 -:BW_BYTE_WEN];
  assign cell_wenable_bit[i] = cell_wenable_bit_list[BW_DATA*(i+1)-1 -:BW_DATA];
  assign cell_wdata[i] = cell_wdata_list[BW_DATA*(i+1)-1 -:BW_DATA];
  assign cell_renable[i] = cell_renable_list[i];
  assign cell_rdata_list[BW_DATA*(i+1)-1 -:BW_DATA] = cell_rdata[i];
  assign cell_stall_list[i] = ~is_last_cell_state;
end
endgenerate

localparam [64-1:0] WRITE_RECOVERY_TIME_NS = 12;
localparam [32-1:0] WRITE_RECOVERY_CYCLE = ((WRITE_RECOVERY_TIME_NS-1)*CLK_HZ/1000000000) + 1;

always@(posedge clk, negedge rstnn)
begin
  if(rstnn==0)
    cell_state <= 1;
  else if(cell_enable[0])
  begin
    if(is_last_cell_state)
    begin
      if(cell_renable[0])
        cell_state <= (1 << WRITE_RECOVERY_CYCLE);
      else
        cell_state <= 1;
    end
    else
      cell_state <= {cell_state,cell_state[BW_STATE-1]};
  end
end

assign is_last_cell_state = cell_state[BW_STATE-1] | (cell_state==control_rmx_core_config);
