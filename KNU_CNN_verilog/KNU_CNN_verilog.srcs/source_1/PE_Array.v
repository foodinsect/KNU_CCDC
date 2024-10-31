module PE_Array (
	input wire clk_i,
	input wire rstn_i,
	input wire PE_rstn_i,
	input wire valid_i,
	input wire clear_i,
	input wire acc_wr_en_i,
	input wire acc_rd_en_i,
	input wire signed [71:0] data_in,
	input wire signed [199:0] filter1_weights,
	input wire signed [199:0] filter2_weights,
	input wire signed [199:0] filter3_weights,
	input wire signed [23:0] bias_in,
	output reg valid_o,
	output wire acc_full_o,
	output wire signed [23:0] conv_out1,
	output wire signed [23:0] conv_out2,
	output wire signed [23:0] conv_out3
);
	
	genvar _gv_i_1;
	genvar _gv_j_1;

	reg [1:0] clear_d;
	reg [2:0] buffer_count;
	wire signed [39:0] pe_out1;
	wire signed [39:0] pe_out2;
	wire signed [39:0] pe_out3;
	wire signed [23:0] conv_sum1;
	wire signed [23:0] conv_sum2;
	wire signed [23:0] conv_sum3;

	wire signed [23:0] PE_Slice1;
	wire signed [23:0] PE_Slice2;
	wire signed [23:0] PE_Slice3;
	wire [2:0] acc_full;

	generate
		for (_gv_i_1 = 0; _gv_i_1 < 2; _gv_i_1 = _gv_i_1 + 1) begin : PE_ARRAY1
			localparam i = _gv_i_1;
			conv2d_pe Ch1(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.valid_i(valid_i),
				.clear_i(clear_i),
				.data_in(data_in[12 * (5 - (i >= (4 + i) ? i : (i + (i >= (4 + i) ? (i - (4 + i)) + 1 : ((4 + i) - i) + 1)) - 1))+:12 * (i >= (4 + i) ? (i - (4 + i)) + 1 : ((4 + i) - i) + 1)]),
				.weight_in(filter1_weights),
				.pe_out(pe_out1[(1 - i) * 20+:20])
			);
			assign PE_Slice1[(1 - i) * 12+:12] = (acc_wr_en_i ? $signed(pe_out1[((1 - i) * 20) + 19-:12]) : $signed(pe_out1[((1 - i) * 20) + 19-:12]) + $signed(bias_in[16+:8]));
		end

		for (_gv_i_1 = 0; _gv_i_1 < 2; _gv_i_1 = _gv_i_1 + 1) begin : PE_ARRAY2
			localparam i = _gv_i_1;
			conv2d_pe Ch2(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.valid_i(valid_i),
				.clear_i(clear_i),
				.data_in(data_in[12 * (5 - (i >= (4 + i) ? i : (i + (i >= (4 + i) ? (i - (4 + i)) + 1 : ((4 + i) - i) + 1)) - 1))+:12 * (i >= (4 + i) ? (i - (4 + i)) + 1 : ((4 + i) - i) + 1)]),
				.weight_in(filter2_weights),
				.pe_out(pe_out2[(1 - i) * 20+:20])
			);
			assign PE_Slice2[(1 - i) * 12+:12] = (acc_wr_en_i ? $signed(pe_out2[((1 - i) * 20) + 19-:12]) : $signed(pe_out2[((1 - i) * 20) + 19-:12]) + $signed(bias_in[8+:8]));
		end

		for (_gv_i_1 = 0; _gv_i_1 < 2; _gv_i_1 = _gv_i_1 + 1) begin : PE_ARRAY3
			localparam i = _gv_i_1;
			conv2d_pe Ch3(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.valid_i(valid_i),
				.clear_i(clear_i),
				.data_in(data_in[12 * (5 - (i >= (4 + i) ? i : (i + (i >= (4 + i) ? (i - (4 + i)) + 1 : ((4 + i) - i) + 1)) - 1))+:12 * (i >= (4 + i) ? (i - (4 + i)) + 1 : ((4 + i) - i) + 1)]),
				.weight_in(filter3_weights),
				.pe_out(pe_out3[(1 - i) * 20+:20])
			);
			assign PE_Slice3[(1 - i) * 12+:12] = (acc_wr_en_i ? $signed(pe_out3[((1 - i) * 20) + 19-:12]) : $signed(pe_out3[((1 - i) * 20) + 19-:12]) + $signed(bias_in[0+:8]));
		end
	endgenerate

	always @(posedge clk_i) begin
		clear_d[0] <= clear_i;
		clear_d[1] <= clear_d[0];
	end

	always @(posedge clk_i)
		if (!(rstn_i & ~PE_rstn_i)) begin
			valid_o <= 1'b0;
			buffer_count <= 0;
		end

		else begin
			if (valid_i) begin
				if (buffer_count > 4)
					valid_o <= 1'b1;
				else
					buffer_count <= buffer_count + 1;
			end
			if (clear_d[0]) begin
				valid_o <= 1'b0;
				buffer_count <= 3'b001;
			end
		end

	Accumulator ACC_Ch1(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.valid_i(valid_o & acc_wr_en_i),
		.rd_en_i(acc_rd_en_i),
		.bias_i(bias_in[16+:8]),
		.conv_in(pe_out1),
		.conv_sum(conv_sum1),
		.acc_full_o(acc_full[0])
	);
	Accumulator #(.BIAS(8'hff)) ACC_Ch2(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.valid_i(valid_o & acc_wr_en_i),
		.rd_en_i(acc_rd_en_i),
		.bias_i(bias_in[8+:8]),
		.conv_in(pe_out2),
		.conv_sum(conv_sum2),
		.acc_full_o(acc_full[1])
	);
	Accumulator #(.BIAS(8'hf6)) ACC_Ch3(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.valid_i(valid_o & acc_wr_en_i),
		.rd_en_i(acc_rd_en_i),
		.bias_i(bias_in[0+:8]),
		.conv_in(pe_out3),
		.conv_sum(conv_sum3),
		.acc_full_o(acc_full[2])
	);

	assign acc_full_o = &acc_full;
	assign conv_out1 = (acc_rd_en_i ? conv_sum1 : PE_Slice1);
	assign conv_out2 = (acc_rd_en_i ? conv_sum2 : PE_Slice2);
	assign conv_out3 = (acc_rd_en_i ? conv_sum3 : PE_Slice3);
	
endmodule
