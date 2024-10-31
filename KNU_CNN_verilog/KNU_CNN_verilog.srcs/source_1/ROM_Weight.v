module ROM_Weight #(
	parameter DATA_WIDTH = 8,
	parameter WEIGHT_FILE_conv1_1 = "",
	parameter WEIGHT_FILE_conv1_2 = "",
	parameter WEIGHT_FILE_conv1_3 = "",
	parameter WEIGHT_FILE_conv2_11 = "",
	parameter WEIGHT_FILE_conv2_12 = "",
	parameter WEIGHT_FILE_conv2_13 = "",
	parameter WEIGHT_FILE_conv2_21 = "",
	parameter WEIGHT_FILE_conv2_22 = "",
	parameter WEIGHT_FILE_conv2_23 = "",
	parameter WEIGHT_FILE_conv2_31 = "",
	parameter WEIGHT_FILE_conv2_32 = "",
	parameter WEIGHT_FILE_conv2_33 = ""
)(
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv1_1,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv1_2,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv1_3,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_11,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_12,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_13,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_21,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_22,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_23,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_31,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_32,
	output wire signed [(25 * DATA_WIDTH) - 1:0] oDAT_conv2_33
);
	
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv1_1 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv1_2 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv1_3 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_11 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_12 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_13 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_21 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_22 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_23 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_31 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_32 [0:24];
	reg signed [(DATA_WIDTH) - 1:0] rWeight_conv2_33 [0:24];

	initial begin
		if (WEIGHT_FILE_conv1_1 != "")
			$readmemh(WEIGHT_FILE_conv1_1, rWeight_conv1_1);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv1_1 not specified.");
		if (WEIGHT_FILE_conv1_2 != "")
			$readmemh(WEIGHT_FILE_conv1_2, rWeight_conv1_2);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv1_2 not specified.");
		if (WEIGHT_FILE_conv1_3 != "")
			$readmemh(WEIGHT_FILE_conv1_3, rWeight_conv1_3);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv1_3 not specified.");
		if (WEIGHT_FILE_conv2_11 != "")
			$readmemh(WEIGHT_FILE_conv2_11, rWeight_conv2_11);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv2_11 not specified.");
		if (WEIGHT_FILE_conv2_12 != "")
			$readmemh(WEIGHT_FILE_conv2_12, rWeight_conv2_12);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv2_12 not specified.");
		if (WEIGHT_FILE_conv2_13 != "")
			$readmemh(WEIGHT_FILE_conv2_13, rWeight_conv2_13);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv2_13 not specified.");
		if (WEIGHT_FILE_conv2_21 != "")
			$readmemh(WEIGHT_FILE_conv2_21, rWeight_conv2_21);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv2_21 not specified.");
		if (WEIGHT_FILE_conv2_22 != "")
			$readmemh(WEIGHT_FILE_conv2_22, rWeight_conv2_22);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv2_22 not specified.");
		if (WEIGHT_FILE_conv2_23 != "")
			$readmemh(WEIGHT_FILE_conv2_23, rWeight_conv2_23);
		else
			$display("Error [%0t] ROM_Weight.sv msg: ", $time, "Weight file conv2_23 not specified.");
		if (WEIGHT_FILE_conv2_31 != "")
			$readmemh(WEIGHT_FILE_conv2_31, rWeight_conv2_31);
		else
			$display("Error [%0t] ROM_Weight.sv: msg: ", $time, "Weight file conv2_31 not specified.");
		if (WEIGHT_FILE_conv2_32 != "")
			$readmemh(WEIGHT_FILE_conv2_32, rWeight_conv2_32);
		else
			$display("Error [%0t] ROM_Weight.sv: msg: ", $time, "Weight file conv2_32 not specified.");
		if (WEIGHT_FILE_conv2_33 != "")
			$readmemh(WEIGHT_FILE_conv2_33, rWeight_conv2_33);
		else
			$display("Error [%0t] ROM_Weight.sv: msg: ", $time, "Weight file conv2_33 not specified.");
	end

	// Concatenate array elements into a single wire output in reverse order
	assign oDAT_conv1_1 = {rWeight_conv1_1[0], rWeight_conv1_1[1], rWeight_conv1_1[2], rWeight_conv1_1[3], rWeight_conv1_1[4],
						rWeight_conv1_1[5], rWeight_conv1_1[6], rWeight_conv1_1[7], rWeight_conv1_1[8], rWeight_conv1_1[9],
						rWeight_conv1_1[10], rWeight_conv1_1[11], rWeight_conv1_1[12], rWeight_conv1_1[13], rWeight_conv1_1[14],
						rWeight_conv1_1[15], rWeight_conv1_1[16], rWeight_conv1_1[17], rWeight_conv1_1[18], rWeight_conv1_1[19],
						rWeight_conv1_1[20], rWeight_conv1_1[21], rWeight_conv1_1[22], rWeight_conv1_1[23], rWeight_conv1_1[24]};

	assign oDAT_conv1_2 = {rWeight_conv1_2[0], rWeight_conv1_2[1], rWeight_conv1_2[2], rWeight_conv1_2[3], rWeight_conv1_2[4],
						rWeight_conv1_2[5], rWeight_conv1_2[6], rWeight_conv1_2[7], rWeight_conv1_2[8], rWeight_conv1_2[9],
						rWeight_conv1_2[10], rWeight_conv1_2[11], rWeight_conv1_2[12], rWeight_conv1_2[13], rWeight_conv1_2[14],
						rWeight_conv1_2[15], rWeight_conv1_2[16], rWeight_conv1_2[17], rWeight_conv1_2[18], rWeight_conv1_2[19],
						rWeight_conv1_2[20], rWeight_conv1_2[21], rWeight_conv1_2[22], rWeight_conv1_2[23], rWeight_conv1_2[24]};

	assign oDAT_conv1_3 = {rWeight_conv1_3[0], rWeight_conv1_3[1], rWeight_conv1_3[2], rWeight_conv1_3[3], rWeight_conv1_3[4],
						rWeight_conv1_3[5], rWeight_conv1_3[6], rWeight_conv1_3[7], rWeight_conv1_3[8], rWeight_conv1_3[9],
						rWeight_conv1_3[10], rWeight_conv1_3[11], rWeight_conv1_3[12], rWeight_conv1_3[13], rWeight_conv1_3[14],
						rWeight_conv1_3[15], rWeight_conv1_3[16], rWeight_conv1_3[17], rWeight_conv1_3[18], rWeight_conv1_3[19],
						rWeight_conv1_3[20], rWeight_conv1_3[21], rWeight_conv1_3[22], rWeight_conv1_3[23], rWeight_conv1_3[24]};

	assign oDAT_conv2_11 = {rWeight_conv2_11[0], rWeight_conv2_11[1], rWeight_conv2_11[2], rWeight_conv2_11[3], rWeight_conv2_11[4],
							rWeight_conv2_11[5], rWeight_conv2_11[6], rWeight_conv2_11[7], rWeight_conv2_11[8], rWeight_conv2_11[9],
							rWeight_conv2_11[10], rWeight_conv2_11[11], rWeight_conv2_11[12], rWeight_conv2_11[13], rWeight_conv2_11[14],
							rWeight_conv2_11[15], rWeight_conv2_11[16], rWeight_conv2_11[17], rWeight_conv2_11[18], rWeight_conv2_11[19],
							rWeight_conv2_11[20], rWeight_conv2_11[21], rWeight_conv2_11[22], rWeight_conv2_11[23], rWeight_conv2_11[24]};

	assign oDAT_conv2_12 = {rWeight_conv2_12[0], rWeight_conv2_12[1], rWeight_conv2_12[2], rWeight_conv2_12[3], rWeight_conv2_12[4],
							rWeight_conv2_12[5], rWeight_conv2_12[6], rWeight_conv2_12[7], rWeight_conv2_12[8], rWeight_conv2_12[9],
							rWeight_conv2_12[10], rWeight_conv2_12[11], rWeight_conv2_12[12], rWeight_conv2_12[13], rWeight_conv2_12[14],
							rWeight_conv2_12[15], rWeight_conv2_12[16], rWeight_conv2_12[17], rWeight_conv2_12[18], rWeight_conv2_12[19],
							rWeight_conv2_12[20], rWeight_conv2_12[21], rWeight_conv2_12[22], rWeight_conv2_12[23], rWeight_conv2_12[24]};

	assign oDAT_conv2_13 = {rWeight_conv2_13[0], rWeight_conv2_13[1], rWeight_conv2_13[2], rWeight_conv2_13[3], rWeight_conv2_13[4],
							rWeight_conv2_13[5], rWeight_conv2_13[6], rWeight_conv2_13[7], rWeight_conv2_13[8], rWeight_conv2_13[9],
							rWeight_conv2_13[10], rWeight_conv2_13[11], rWeight_conv2_13[12], rWeight_conv2_13[13], rWeight_conv2_13[14],
							rWeight_conv2_13[15], rWeight_conv2_13[16], rWeight_conv2_13[17], rWeight_conv2_13[18], rWeight_conv2_13[19],
							rWeight_conv2_13[20], rWeight_conv2_13[21], rWeight_conv2_13[22], rWeight_conv2_13[23], rWeight_conv2_13[24]};

	assign oDAT_conv2_21 = {rWeight_conv2_21[0], rWeight_conv2_21[1], rWeight_conv2_21[2], rWeight_conv2_21[3], rWeight_conv2_21[4],
							rWeight_conv2_21[5], rWeight_conv2_21[6], rWeight_conv2_21[7], rWeight_conv2_21[8], rWeight_conv2_21[9],
							rWeight_conv2_21[10], rWeight_conv2_21[11], rWeight_conv2_21[12], rWeight_conv2_21[13], rWeight_conv2_21[14],
							rWeight_conv2_21[15], rWeight_conv2_21[16], rWeight_conv2_21[17], rWeight_conv2_21[18], rWeight_conv2_21[19],
							rWeight_conv2_21[20], rWeight_conv2_21[21], rWeight_conv2_21[22], rWeight_conv2_21[23], rWeight_conv2_21[24]};

	assign oDAT_conv2_22 = {rWeight_conv2_22[0], rWeight_conv2_22[1], rWeight_conv2_22[2], rWeight_conv2_22[3], rWeight_conv2_22[4],
							rWeight_conv2_22[5], rWeight_conv2_22[6], rWeight_conv2_22[7], rWeight_conv2_22[8], rWeight_conv2_22[9],
							rWeight_conv2_22[10], rWeight_conv2_22[11], rWeight_conv2_22[12], rWeight_conv2_22[13], rWeight_conv2_22[14],
							rWeight_conv2_22[15], rWeight_conv2_22[16], rWeight_conv2_22[17], rWeight_conv2_22[18], rWeight_conv2_22[19],
							rWeight_conv2_22[20], rWeight_conv2_22[21], rWeight_conv2_22[22], rWeight_conv2_22[23], rWeight_conv2_22[24]};

	assign oDAT_conv2_23 = {rWeight_conv2_23[0], rWeight_conv2_23[1], rWeight_conv2_23[2], rWeight_conv2_23[3], rWeight_conv2_23[4],
							rWeight_conv2_23[5], rWeight_conv2_23[6], rWeight_conv2_23[7], rWeight_conv2_23[8], rWeight_conv2_23[9],
							rWeight_conv2_23[10], rWeight_conv2_23[11], rWeight_conv2_23[12], rWeight_conv2_23[13], rWeight_conv2_23[14],
							rWeight_conv2_23[15], rWeight_conv2_23[16], rWeight_conv2_23[17], rWeight_conv2_23[18], rWeight_conv2_23[19],
							rWeight_conv2_23[20], rWeight_conv2_23[21], rWeight_conv2_23[22], rWeight_conv2_23[23], rWeight_conv2_23[24]};

	assign oDAT_conv2_31 = {rWeight_conv2_31[0], rWeight_conv2_31[1], rWeight_conv2_31[2], rWeight_conv2_31[3], rWeight_conv2_31[4],
							rWeight_conv2_31[5], rWeight_conv2_31[6], rWeight_conv2_31[7], rWeight_conv2_31[8], rWeight_conv2_31[9],
							rWeight_conv2_31[10], rWeight_conv2_31[11], rWeight_conv2_31[12], rWeight_conv2_31[13], rWeight_conv2_31[14],
							rWeight_conv2_31[15], rWeight_conv2_31[16], rWeight_conv2_31[17], rWeight_conv2_31[18], rWeight_conv2_31[19],
							rWeight_conv2_31[20], rWeight_conv2_31[21], rWeight_conv2_31[22], rWeight_conv2_31[23], rWeight_conv2_31[24]};

	assign oDAT_conv2_32 = {rWeight_conv2_32[0], rWeight_conv2_32[1], rWeight_conv2_32[2], rWeight_conv2_32[3], rWeight_conv2_32[4],
							rWeight_conv2_32[5], rWeight_conv2_32[6], rWeight_conv2_32[7], rWeight_conv2_32[8], rWeight_conv2_32[9],
							rWeight_conv2_32[10], rWeight_conv2_32[11], rWeight_conv2_32[12], rWeight_conv2_32[13], rWeight_conv2_32[14],
							rWeight_conv2_32[15], rWeight_conv2_32[16], rWeight_conv2_32[17], rWeight_conv2_32[18], rWeight_conv2_32[19],
							rWeight_conv2_32[20], rWeight_conv2_32[21], rWeight_conv2_32[22], rWeight_conv2_32[23], rWeight_conv2_32[24]};

	assign oDAT_conv2_33 = {rWeight_conv2_33[0], rWeight_conv2_33[1], rWeight_conv2_33[2], rWeight_conv2_33[3], rWeight_conv2_33[4],
							rWeight_conv2_33[5], rWeight_conv2_33[6], rWeight_conv2_33[7], rWeight_conv2_33[8], rWeight_conv2_33[9],
							rWeight_conv2_33[10], rWeight_conv2_33[11], rWeight_conv2_33[12], rWeight_conv2_33[13], rWeight_conv2_33[14],
							rWeight_conv2_33[15], rWeight_conv2_33[16], rWeight_conv2_33[17], rWeight_conv2_33[18], rWeight_conv2_33[19],
							rWeight_conv2_33[20], rWeight_conv2_33[21], rWeight_conv2_33[22], rWeight_conv2_33[23], rWeight_conv2_33[24]};

endmodule