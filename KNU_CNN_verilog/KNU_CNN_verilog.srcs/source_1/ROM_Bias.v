module ROM_Bias #(
	parameter DATA_WIDTH = 8,
	parameter WEIGHT_FILE_bias_1 = "",
	parameter WEIGHT_FILE_bias_2 = ""
) (
	output wire signed [(3 * DATA_WIDTH) - 1:0] oDAT_bias_1,
	output wire signed [(3 * DATA_WIDTH) - 1:0] oDAT_bias_2
);
	
	reg signed [DATA_WIDTH - 1:0] rBias_conv1 [0:2];
	reg signed [DATA_WIDTH - 1:0] rBias_conv2 [0:2];

	initial begin
		if (WEIGHT_FILE_bias_1 != "")
			$readmemh(WEIGHT_FILE_bias_1, rBias_conv1);
		else
			$display("Error [%0t] ROM_Bias.sv\n msg: ", $time, "Weight file conv1_1 not specified.");
		if (WEIGHT_FILE_bias_1 != "")
			$readmemh(WEIGHT_FILE_bias_2, rBias_conv2);
		else
			$display("Error [%0t] ROM_Bias.sv\n msg: ", $time, "Weight file conv1_2 not specified.");
	end

	assign oDAT_bias_1 = {rBias_conv1[0], rBias_conv1[1], rBias_conv1[2]};
	assign oDAT_bias_2 = {rBias_conv2[0], rBias_conv2[1], rBias_conv2[2]};
endmodule