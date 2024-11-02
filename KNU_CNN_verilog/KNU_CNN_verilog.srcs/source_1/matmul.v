module matmul (
	input wire clk_i,
	input wire rstn_i,
	input wire clear_i,
	input wire en_i,
	input wire signed [11:0] flatten_i,
	input wire signed [79:0] weight_i,
	input wire signed [79:0] bias_i,
	output wire valid_out_o,
	output wire signed [119:0] data_out_o
);
	
	wire signed [19:0] mac_outputs [0:9];
	wire signed [19:0] final_outputs [0:9];
	genvar _gv_i_1;

	generate
		for (_gv_i_1 = 0; _gv_i_1 < 10; _gv_i_1 = _gv_i_1 + 1) begin : mac_inst
			localparam i = _gv_i_1;

			MAC MAC_inst(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.clr_i(clear_i),
				.mac_en_i(en_i),
				.weight_i(weight_i[(9 - i) * 8+:8]),
				.input_i(flatten_i),
				.mac_out_o(mac_outputs[i]),
				.valid_out_o(valid_out_o)
			);

			assign final_outputs[i] = (valid_out_o ? mac_outputs[i] + bias_i[(9 - i) * 8+:8] : 20'hxxxxx);
			assign data_out_o[(9 - i) * 12+:12] = final_outputs[i][19:8];

		end
	endgenerate
endmodule