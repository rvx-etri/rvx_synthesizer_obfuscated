`ifndef SIMULATE_OFFCHIP_MRAM_BEHAVIOR

ERVP_MEMORY_CELL_1R1W
#(
	.DEPTH(CELL_DEPTH),
	.WIDTH(CELL_WIDTH),
	.BW_INDEX(BW_CELL_INDEX),
	.USE_SINGLE_INDEX(1),
	.USE_SUBWORD_ENABLE(1),
	.BW_SUBWORD(8)
)
i_cell
(
	.clk(clk),
	.rstnn(rstnn),
	.index(cell_index[0]),
	.windex(cell_index[0]),
	.wenable(cell_wenable[0]),
	.wpermit(cell_wenable_byte[0]),
	.wdata(cell_wdata[0]),
	.rindex(cell_index[0]),
	.rdata_asynch(),
	.renable(cell_renable[0]),
	.rdata_synch(cell_rdata[0])
);

`else // SIMULATE_OFFCHIP_MRAM_BEHAVIOR

reg [(21)-1:0] extmr_a_reg;
reg extmr_e_n_reg;
reg extmr_w_n_reg;
reg extmr_g_n_reg;
reg [(4)-1:0] extmr_be_n_reg;
reg [(32)-1:0] extmr_dq_sod_reg;
reg [(32)-1:0] extmr_wdata;
reg [(32)-1:0] extmr_rdata;

always@(posedge clk, negedge rstnn)
begin
  if(rstnn==0)
  begin
    extmr_a_reg <= 0;
    extmr_e_n_reg <= 1;
    extmr_w_n_reg <= 1;
    extmr_g_n_reg <= 1;
    extmr_be_n_reg <= -1;
    extmr_dq_sod_reg <= -1;
    extmr_wdata <= 0;
    extmr_rdata <= 0;
  end
  else if(cell_enable[0])
  begin
    if(is_last_cell_state)
    begin
      extmr_e_n_reg <= 1;
      extmr_w_n_reg <= 1;
      extmr_g_n_reg <= 1;
      extmr_be_n_reg <= -1;
      // extmr_dq_sod_reg <= -1;
      if(cell_renable[0])
        extmr_rdata <= EXTMR_DQ_sival;
    end
    else if(cell_state[WRITE_RECOVERY_CYCLE])
    begin
      extmr_a_reg <= cell_index[0];
      extmr_e_n_reg <= 0;
      extmr_w_n_reg <= ~cell_wenable[0];
      extmr_g_n_reg <= ~cell_renable[0];
      extmr_dq_sod_reg <= ~cell_wenable_bit[0];
      if(cell_wenable[0])
        extmr_wdata <= cell_wdata[0];
    end
    else if(cell_state[WRITE_RECOVERY_CYCLE+1])
    begin
      extmr_be_n_reg <= (cell_renable[0])? 0 : ~cell_wenable_byte[0];
    end
  end
end

assign EXTMR_A = extmr_a_reg;
assign EXTMR_E_N = extmr_e_n_reg;
assign EXTMR_W_N = extmr_w_n_reg;
assign EXTMR_G_N = extmr_g_n_reg;
assign EXTMR_BE_N = extmr_be_n_reg;
assign EXTMR_DQ_sod = extmr_dq_sod_reg;
assign EXTMR_LS_OE_P = ~extmr_w_n_reg;
assign EXTMR_LS_CE_N = 0;

assign EXTMR_DQ_soval = extmr_wdata;
assign cell_rdata[0] = extmr_rdata;

`endif // SIMULATE_OFFCHIP_MRAM_BEHAVIOR
