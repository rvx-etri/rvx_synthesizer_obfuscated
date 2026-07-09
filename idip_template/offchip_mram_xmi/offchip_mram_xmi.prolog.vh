`include "ervp_global.vh"
`include "ervp_axi_define.vh"
`include "hw_info.vh"
`include "sim_info.vh"
`include "munoc_network_include.vh"
`include "ervp_offchip_mram_memorymap_offset.vh"

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
integer j;

`include "lpit_function.vb"
`include "lpixm_function.vb"

localparam BW_LPIXM_ADDR = BW_AXI_ADDR;
localparam BW_LPIXM_DATA = BW_AXI_DATA;

`include "lpixm_lpara.vb"

wire [2-1:0] lpixm_qdready;
wire lpixm_qvalid;
wire lpixm_qhint;
wire lpixm_qlast;
wire lpixm_qafy;
wire [BW_LPI_QDATA-1:0] lpixm_qdata;

wire [BW_LPI_BURDEN-1:0] lpixm_qburden;
wire [BW_LPI_QPARCEL-1:0] lpixm_qparcel;

wire [2-1:0] lpixm_ydready;
wire lpixm_yvalid;
wire lpixm_yhint;
wire lpixm_ylast;
wire [BW_LPI_YDATA-1:0] lpixm_ydata;

wire [BW_LPI_BURDEN-1:0] lpixm_yburden;
wire [BW_LPI_YPARCEL-1:0] lpixm_yparcel;

wire [2-1:0] lpixs_qdready;
wire lpixs_qvalid;
wire lpixs_qhint;
wire lpixs_qlast;
wire lpixs_qafy;
wire [BW_LPI_QDATA-1:0] lpixs_qdata;

wire [2-1:0] lpixs_ydready;
wire lpixs_yvalid;
wire lpixs_yhint;
wire lpixs_ylast;
wire [BW_LPI_YDATA-1:0] lpixs_ydata;

wire [2-1:0] filtered_lqdready;
wire filtered_lqvalid;
wire filtered_lqhint;
wire filtered_lqlast;
wire filtered_lqafy;
wire [BW_LPI_QDATA-1:0] filtered_lqdata;

wire [2-1:0] filtered_lydready;
wire filtered_lyvalid;
wire filtered_lyhint;
wire filtered_lylast;
wire [BW_LPI_YDATA-1:0] filtered_lydata;

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

wire [`OFFCHIP_MRAM_MMIOX_INST_BW_OPCODE-1:0] inst_opcode;
wire [`OFFCHIP_MRAM_MMIOX_INST_BW_OPERAND-1:0] inst_operand;

//
localparam I_PROFILER_HAS_PROFILER = (`NUM_OFFCHIP_MRAM_PROFILE_COUNTER!=0);
localparam I_PROFILER_NUM_PROFILER = (`NUM_OFFCHIP_MRAM_PROFILE_COUNTER==0)? 1 : `NUM_OFFCHIP_MRAM_PROFILE_COUNTER;
localparam I_PROFILER_BW_COUNTER = `BW_OFFCHIP_MRAM_PROFILE_COUNTER;

wire is_opcode_for_profile;
wire [`OFFCHIP_MRAM_MMIOX_INST_BW_OPCODE-1:0] profile_valid_opcode;
wire [I_PROFILER_NUM_PROFILER-1:0] profile_select;
reg profile_inst_rrequest;

wire [I_PROFILER_NUM_PROFILER-1:0] i_profiler_start_list;
wire [I_PROFILER_NUM_PROFILER-1:0] i_profiler_finish_list;
wire [I_PROFILER_NUM_PROFILER-1:0] i_profiler_clear_list;
wire [I_PROFILER_NUM_PROFILER-1:0] i_profiler_count_list;
wire [I_PROFILER_NUM_PROFILER*I_PROFILER_BW_COUNTER-1:0] i_profiler_count_amount_list;
wire [I_PROFILER_NUM_PROFILER*I_PROFILER_BW_COUNTER-1:0] i_profiler_value_list;

reg [I_PROFILER_NUM_PROFILER-1:0] profiler_include_filtered;

wire profiler_count_original;
reg [BW_BYTE_WEN-1:0] profiler_count_amount_original;

wire profiler_count_filtered;
reg [BW_BYTE_WEN-1:0] profiler_count_amount_filtered;

localparam I_MUX_PROFILE_OUTPUT_BW_DATA = I_PROFILER_BW_COUNTER;
localparam I_MUX_PROFILE_OUTPUT_NUM_DATA = I_PROFILER_NUM_PROFILER;

wire [I_MUX_PROFILE_OUTPUT_BW_DATA*I_MUX_PROFILE_OUTPUT_NUM_DATA-1:0] i_mux_profile_output_data_input_list;
wire [I_MUX_PROFILE_OUTPUT_NUM_DATA-1:0] i_mux_profile_output_select;
wire [I_MUX_PROFILE_OUTPUT_BW_DATA-1:0] i_mux_profile_output_data_output;

wire i_cache_inst_rready;
wire [`OFFCHIP_MRAM_MMIOX_INST_BW_OPCODE-1:0] i_cache_inst_opcode;
wire [`OFFCHIP_MRAM_MMIOX_INST_BW_OPERAND-1:0] i_cache_inst_operand;
wire i_cache_inst_rrequest;

////////////
/* logics */
////////////

assign control_rmx_core_status = 0;
assign control_rmx_clear_finish = 0;
assign control_rmx_log_fifo_wrequest = 0;
assign control_rmx_log_fifo_wdata = 0;
// assign control_rmx_inst_fifo_rrequest = 0;
// assign control_rmx_operation_finish = 0;
assign control_rmx_input_fifo_rrequest = 0;
// assign control_rmx_output_fifo_wrequest = 0;
// assign control_rmx_output_fifo_wdata = 0;

assign {inst_operand, inst_opcode} = control_rmx_inst_fifo_rdata;
assign control_rmx_inst_fifo_rrequest = profile_inst_rrequest | i_cache_inst_rrequest;
assign control_rmx_operation_finish = control_rmx_inst_fifo_rrequest;

//
assign is_opcode_for_profile = (inst_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_EXCLUDE_FILTERED:`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_START]!=0);
assign profile_valid_opcode = (control_rmx_inst_fifo_rready & is_opcode_for_profile & (I_PROFILER_HAS_PROFILER==1))? inst_opcode : 0;
assign profile_select = $unsigned(inst_operand);

always@(*)
begin
  profile_inst_rrequest = 0;
  //
  if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_START])
    profile_inst_rrequest = 1;
  if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_FINISH])
    profile_inst_rrequest = 1;
  if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_OUTPUT])
    profile_inst_rrequest = control_rmx_output_fifo_wrequest & control_rmx_output_fifo_wready;
  if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_CLEAR])
    profile_inst_rrequest = 1;
  if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_INCLUDE_FILTERED])
    profile_inst_rrequest = 1;
  if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_EXCLUDE_FILTERED])
    profile_inst_rrequest = 1;
end

ERVP_PROFILER
#(
  .HAS_PROFILER(I_PROFILER_HAS_PROFILER),
  .NUM_PROFILER(I_PROFILER_NUM_PROFILER),
  .BW_COUNTER(I_PROFILER_BW_COUNTER)
)
i_profiler
(
	.clk(clk),
	.rstnn(rstnn),
  .clear(1'b 0),
  .enable(1'b 1),

  .start_list(i_profiler_start_list),
  .finish_list(i_profiler_finish_list),
  .clear_list(i_profiler_clear_list),

  .count_list(i_profiler_count_list),
  .count_amount_list(i_profiler_count_amount_list),
  .value_list(i_profiler_value_list)
);

assign i_profiler_start_list = profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_START]? profile_select : 0;
assign i_profiler_finish_list = profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_FINISH]? profile_select : 0;
assign i_profiler_clear_list = profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_CLEAR]? profile_select : 0;

always@(posedge clk, negedge rstnn)
begin
  if(rstnn==0)
    profiler_include_filtered <= 0;
  else if(I_PROFILER_HAS_PROFILER==1)
  begin
    if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_CLEAR])
      profiler_include_filtered <= profiler_include_filtered & (~profile_select);
    else if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_EXCLUDE_FILTERED])
      profiler_include_filtered <= profiler_include_filtered & (~profile_select);
    else if(profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_INCLUDE_FILTERED])
      profiler_include_filtered <= profiler_include_filtered | profile_select;
  end
end

assign profiler_count_original = rlxqvalid & rlxqdready[0] & rlxqwrite;
always@(*)
begin
  profiler_count_amount_original = 0;
  for(j=0; j<BW_BYTE_WEN; j=j+1)
    profiler_count_amount_original = profiler_count_amount_original + rlxqwstrb[j];
end

assign profiler_count_filtered = cell_wenable[0] & (~cell_stall_list[0]);
always@(*)
begin
  profiler_count_amount_filtered = 0;
  for(j=0; j<BW_BYTE_WEN; j=j+1)
    profiler_count_amount_filtered = profiler_count_amount_filtered + cell_wenable_byte[0][j];
end

generate
for(i=0; i<I_PROFILER_NUM_PROFILER; i=i+1)
begin : i_generate_profiler_count
  assign i_profiler_count_list[i] = profiler_include_filtered[i]? profiler_count_original : profiler_count_filtered;
  assign i_profiler_count_amount_list[I_PROFILER_BW_COUNTER*(i+1)-1-:I_PROFILER_BW_COUNTER] = profiler_include_filtered[i]? $unsigned(profiler_count_amount_original) : $unsigned(profiler_count_amount_filtered);
end
endgenerate

ERVP_MUX_WITH_ONEHOT_ENCODED_SELECT
#(
  .BW_DATA(I_MUX_PROFILE_OUTPUT_BW_DATA),
  .NUM_DATA(I_MUX_PROFILE_OUTPUT_NUM_DATA)
)
i_mux_profile_output
(
	.data_input_list(i_mux_profile_output_data_input_list),
	.select(i_mux_profile_output_select),
	.data_output(i_mux_profile_output_data_output)
);

assign i_mux_profile_output_data_input_list = i_profiler_value_list;
assign i_mux_profile_output_select = profile_select;

assign control_rmx_output_fifo_wrequest = profile_valid_opcode[`OFFCHIP_MRAM_MMIOX_INST_OPCODE_INDEX_PROFILE_OUTPUT];
assign control_rmx_output_fifo_wdata = i_mux_profile_output_data_output;

// interface

MUNOC_LPIXM2LPIXS_WER
#(
  .BW_AXI_ADDR(BW_AXI_ADDR),
  .BW_AXI_DATA(BW_AXI_DATA),
  .BW_LPI_BURDEN(BW_LPI_BURDEN)
)
i_lpixm2lpixs
(
	.clk(clk),
	.rstnn(rstnn),
  .clear(1'b 0),
  .enable(1'b 1),

  .rlqdready(lpixm_qdready),
  .rlqvalid(lpixm_qvalid),
  .rlqhint(lpixm_qhint),
  .rlqlast(lpixm_qlast),
  .rlqafy(lpixm_qafy),
  .rlqdata(lpixm_qdata),

  .rlydready(lpixm_ydready),
  .rlyvalid(lpixm_yvalid),
  .rlyhint(lpixm_yhint),
  .rlylast(lpixm_ylast),
  .rlydata(lpixm_ydata),

  .slqdready(lpixs_qdready),
  .slqvalid(lpixs_qvalid),
  .slqhint(lpixs_qhint),
  .slqlast(lpixs_qlast),
  .slqafy(lpixs_qafy),
  .slqdata(lpixs_qdata),

  .slydready(lpixs_ydready),
  .slyvalid(lpixs_yvalid),
  .slyhint(lpixs_yhint),
  .slylast(lpixs_ylast),
  .slydata(lpixs_ydata)
);

assign rlxqdready = lpixm_qdready;
assign lpixm_qvalid = rlxqvalid;
assign lpixm_qhint = 0;
assign lpixm_qlast = rlxqlast;
assign lpixm_qafy = (~rlxqwrite) | rlxqlast;
assign lpixm_qdata = {lpixm_qburden,lpixm_qparcel};

assign lpixm_qburden = rlxqburden;
assign lpixm_qparcel = {rlxqlast,rlxqwrite,rlxqlen,rlxqsize,rlxqburst,rlxqwstrb,rlxqwdata,rlxqaddr};

assign lpixm_ydready = rlxydready;
assign rlxyvalid = lpixm_yvalid;
assign rlxylast = lpixm_ylast;
assign {lpixm_yburden,lpixm_yparcel} = lpixm_ydata;
assign rlxyburden = lpixm_yburden;
assign {rlxywreply,rlxyresp,rlxyrdata} = lpixm_yparcel;

ERVP_OFFCHIP_MRAM_CACHE
#(
  .BW_AXI_ADDR(BW_AXI_ADDR),
  .BW_AXI_DATA(BW_AXI_DATA),
  .BW_LPI_BURDEN(BW_LPI_BURDEN)
)
i_cache
(
	.clk(clk),
	.rstnn(rstnn),
  .clear(1'b 0),
  .enable(1'b 1),

  .inst_rready(i_cache_inst_rready),
  .inst_opcode(i_cache_inst_opcode),
  .inst_operand(i_cache_inst_operand),
  .inst_rrequest(i_cache_inst_rrequest),

  .rlqdready(lpixs_qdready),
  .rlqvalid(lpixs_qvalid),
  .rlqhint(lpixs_qhint),
  .rlqlast(lpixs_qlast),
  .rlqafy(lpixs_qafy),
  .rlqdata(lpixs_qdata),

  .rlydready(lpixs_ydready),
  .rlyvalid(lpixs_yvalid),
  .rlyhint(lpixs_yhint),
  .rlylast(lpixs_ylast),
  .rlydata(lpixs_ydata),

  .slqdready(filtered_lqdready),
  .slqvalid(filtered_lqvalid),
  .slqhint(filtered_lqhint),
  .slqlast(filtered_lqlast),
  .slqafy(filtered_lqafy),
  .slqdata(filtered_lqdata),

  .slydready(filtered_lydready),
  .slyvalid(filtered_lyvalid),
  .slyhint(filtered_lyhint),
  .slylast(filtered_lylast),
  .slydata(filtered_lydata)
);

assign i_cache_inst_rready = control_rmx_inst_fifo_rready;
assign i_cache_inst_opcode = inst_opcode;
assign i_cache_inst_operand = inst_operand;

MUNOC_LPIXS2SCELL
#(
  .BW_ADDR(BW_ADDR),
  .BW_DATA(BW_DATA),
  .BW_LPI_BURDEN(BW_LPI_BURDEN),
  .BASEADDR(0),
  .BW_CELL_INDEX(BW_CELL_INDEX),
  .CELL_WIDTH(CELL_WIDTH),
  .NUM_CELL(NUM_CELL)
)
i_lpixs2scell
(
	.clk(clk),
	.rstnn(rstnn),
  .clear(1'b 0),
  .enable(1'b 1),

  .rlqdready(filtered_lqdready),
  .rlqvalid(filtered_lqvalid),
  .rlqhint(filtered_lqhint),
  .rlqlast(filtered_lqlast),
  .rlqafy(filtered_lqafy),
  .rlqdata(filtered_lqdata),

  .rlydready(filtered_lydready),
  .rlyvalid(filtered_lyvalid),
  .rlyhint(filtered_lyhint),
  .rlylast(filtered_lylast),
  .rlydata(filtered_lydata),

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
