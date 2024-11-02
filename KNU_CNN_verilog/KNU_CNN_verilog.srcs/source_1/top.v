module top (
	input wire clk_i,
	input wire rstn_i,
	input wire start_i,
	input wire [71:0] image_6rows,
	input wire [79:0] weight_input_packed,
	input wire signed [79:0] fc_bias,
	input wire signed [199:0] conv1_weight_1,
	input wire signed [199:0] conv1_weight_2,
	input wire signed [199:0] conv1_weight_3,
	input wire signed [23:0] bias_1,
	output wire weight_enable,
	output wire [5:0] weight_indexing,
	output wire [5:0] cycle,
	output wire [9:0] image_idx,
	output wire image_rom_en,
	output wire [1:0] weight_sel,
	output wire [1:0] bias_sel,
	output wire ready,
	output wire done,
	output wire [3:0] result
);
	
	wire buf_valid_en;
	wire buffer1_we;
	wire buf_adr_clr;
	wire [1:0] buf_rd_mod;
	wire PE_rstn;
	wire PE_valid_o;
	wire PE_clr_o;
	wire PE_valid_i;
	wire [1:0] PE_mux_sel;
	wire acc_wr_en;
	wire acc_rd_en;
	wire FIFO_valid;
	wire shift_en;
	wire conv_done;
	wire [71:0] PE_data_i;
	wire signed [23:0] conv_out1;
	wire signed [23:0] conv_out2;
	wire signed [23:0] conv_out3;
	wire signed [11:0] conv_sum_1 [0:1];
	wire signed [11:0] conv_sum_2 [0:1];
	wire signed [11:0] conv_sum_3 [0:1];
	wire signed [23:0] oFIFO_1;
	wire signed [23:0] oFIFO_2;
	wire signed [23:0] oFIFO_3;
	wire oMAX_En_1;
	wire oMAX_En_2;
	wire oMAX_En_3;
	wire signed [11:0] oMAX_1;
	wire signed [11:0] oMAX_2;
	wire signed [11:0] oMAX_3;
	wire oBuf_En_1;
	wire oBuf_En_2;
	wire oBuf_En_3;
	wire [71:0] buffer1_out;
	wire [71:0] buffer2_out;
	wire [71:0] buffer3_out;
	wire signed [11:0] shiftBuffer1_out;
	wire signed [11:0] shiftBuffer2_out;
	wire signed [11:0] shiftBuffer3_out;
	wire [2:0] shifter_en_decoded;

	assign PE_data_i = (PE_mux_sel == 2'b00 ? image_6rows : (PE_mux_sel == 2'b01 ? buffer1_out : (PE_mux_sel == 2'b10 ? buffer2_out : buffer3_out)));

	global_controller controller(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.start_i(start_i),
		.iPE_valid_o(PE_valid_o),
		.fc_done_i(done),
		.oacc_wr_en(acc_wr_en),
		.obuf_rd_mod(buf_rd_mod),
		.oPE_rstn(PE_rstn),
		.weight_sel(weight_sel),
		.bias_sel(bias_sel),
		.o_PE_mux_sel(PE_mux_sel),
		.oBuf1_we(buffer1_we),
		.oBuf_adr_clr(buf_adr_clr),
		.oBuf_valid_en(buf_valid_en),
		.oPE_clr(PE_clr_o),
		.oPE_valid_i(PE_valid_i),
		.oimage_rom_en(image_rom_en),
		.oimage_idx(image_idx),
		.ocycle(cycle),
		.acc_rd_en(acc_rd_en),
		.FIFO_valid(FIFO_valid),
		.shift_en(shift_en),
		.conv_done(conv_done),
		.ready(ready)
	);
	PE_Array PE_inst(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~done),
		.PE_rstn_i(PE_rstn),
		.valid_i(PE_valid_i),
		.clear_i(PE_clr_o),
		.acc_wr_en_i(acc_wr_en),
		.acc_rd_en_i(acc_rd_en),
		.data_in(PE_data_i),
		.filter1_weights(conv1_weight_1),
		.filter2_weights(conv1_weight_2),
		.filter3_weights(conv1_weight_3),
		.bias_in(bias_1),
		.valid_o(PE_valid_o),
		.acc_full_o(),
		.conv_out1(conv_out1),
		.conv_out2(conv_out2),
		.conv_out3(conv_out3)
	);
	FIFO FIFO_Ch1(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~ready),
		.data_in_i(conv_out1),
		.valid_in_i(PE_valid_o | FIFO_valid),
		.data_out_o(oFIFO_1),
		.valid_out_o(oMAX_En_1)
	);
	FIFO FIFO_Ch2(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~ready),
		.data_in_i(conv_out2),
		.valid_in_i(PE_valid_o | FIFO_valid),
		.data_out_o(oFIFO_2),
		.valid_out_o(oMAX_En_2)
	);
	FIFO FIFO_Ch3(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~ready),
		.data_in_i(conv_out3),
		.valid_in_i(PE_valid_o | FIFO_valid),
		.data_out_o(oFIFO_3),
		.valid_out_o(oMAX_En_3)
	);
	Max_Pooling_ReLU MaxPooling_Ch1(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~ready),
		.valid_i(oMAX_En_1),
		.data_in(oFIFO_1),
		.data_o(oMAX_1),
		.valid_o(oBuf_En_1)
	);
	Max_Pooling_ReLU MaxPooling_Ch2(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~ready),
		.valid_i(oMAX_En_2),
		.data_in(oFIFO_2),
		.data_o(oMAX_2),
		.valid_o(oBuf_En_2)
	);
	Max_Pooling_ReLU MaxPooling_Ch3(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~ready),
		.valid_i(oMAX_En_3),
		.data_in(oFIFO_3),
		.data_o(oMAX_3),
		.valid_o(oBuf_En_3)
	);
	buffer1 BUF1(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~buf_adr_clr),
		.clear_i(ready),
		.din_i(oMAX_1),
		.valid_i(oBuf_En_1 | buf_valid_en),
		.buffer1_we(buffer1_we),
		.rd_mod(buf_rd_mod),
		.dout_o(buffer1_out)
	);
	buffer1 BUF2(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~buf_adr_clr),
		.clear_i(ready),
		.din_i(oMAX_2),
		.valid_i(oBuf_En_2 | buf_valid_en),
		.buffer1_we(buffer1_we),
		.rd_mod(buf_rd_mod),
		.dout_o(buffer2_out)
	);
	buffer1 BUF3(
		.clk_i(clk_i),
		.rstn_i(rstn_i & ~buf_adr_clr),
		.clear_i(ready),
		.din_i(oMAX_3),
		.valid_i(oBuf_En_3 | buf_valid_en),
		.buffer1_we(buffer1_we),
		.rd_mod(buf_rd_mod),
		.dout_o(buffer3_out)
	);

	shiftBuffer shiftBuffer1(
		.clk_i(clk_i),
		.data_i(oMAX_1),
		.shift_en((oBuf_En_1 & shift_en) | shifter_en_decoded[0]),
		.data_o(shiftBuffer1_out)
	);

	shiftBuffer shiftBuffer2(
		.clk_i(clk_i),
		.data_i(oMAX_2),
		.shift_en((oBuf_En_2 & shift_en) | shifter_en_decoded[1]),
		.data_o(shiftBuffer2_out)
	);

	shiftBuffer shiftBuffer3(
		.clk_i(clk_i),
		.data_i(oMAX_3),
		.shift_en((oBuf_En_3 & shift_en) | shifter_en_decoded[2]),
		.data_o(shiftBuffer3_out)
	);

	wire en;
	wire clear;
	wire next_step;
	wire signed [11:0] fc_data;
	wire [1:0] fc_data_sel;
	wire [79:0] weight_input_unpacked;

	genvar _gv_k_1;
	generate
		for (_gv_k_1 = 0; _gv_k_1 < 10; _gv_k_1 = _gv_k_1 + 1) begin : genblk1
			localparam k = _gv_k_1;
			assign weight_input_unpacked[k * 8+:8] = weight_input_packed[k * 8+:8];
		end
	endgenerate

	assign fc_data = (fc_data_sel == 2'b01 ? shiftBuffer1_out : (fc_data_sel == 2'b10 ? shiftBuffer2_out : (fc_data_sel == 2'b11 ? shiftBuffer3_out : 12'hxxx)));
	assign shifter_en_decoded = (fc_data_sel == 2'b00 ? 3'b000 : (fc_data_sel == 2'b01 ? 3'b001 : (fc_data_sel == 2'b10 ? 3'b010 : 3'b100)));
	
	FC_layer fc_layer(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.en_i(en),
		.clear_i(clear),
		.flatten_input_i(fc_data),
		.weight_input_i(weight_input_unpacked),
		.bias_input_i(fc_bias),
		.result_o(result),
		.done_o(next_step)
	);
	FC_controller fc_controller(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.start_i(conv_done),
		.next_i(next_step),
		.select_o(fc_data_sel),
		.clear_o(clear),
		.en_o(en),
		.weight_en(weight_enable),
		.weight_idx(weight_indexing),
		.done(done)
	);
endmodule
