module FC_layer (
	input wire clk_i,
	input wire rstn_i,
	input wire en_i,
	input wire clear_i,
	input wire signed [11:0] flatten_input_i,
	input wire signed [79:0] weight_input_i,
	input wire signed [79:0] bias_input_i,
	output wire [3:0] result_o,
	output wire done_o
);
	wire valid_out;
	wire signed [119:0] data_out;

	assign done_o = valid_out;

	matmul matmul_inst(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.clear_i(clear_i),
		.en_i(en_i),
		.flatten_i(flatten_input_i),
		.weight_i(weight_input_i),
		.bias_i(bias_input_i),
		.valid_out_o(valid_out),
		.data_out_o(data_out)
	);
	
	max_finder max_finder_inst(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.valid_i(valid_out),
		.inputs_i(data_out),
		.result_o(result_o)
	);
endmodule
