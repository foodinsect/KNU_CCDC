module tb_top_1000;
	parameter VIVADO_PROJECT_LOCATION = "D:/Git_repo/KNU_CCDC/KNU_CNN_verilog";

	reg clk;
	reg rstn;
	reg start_i;
	reg [7:0] pixels [0:783999];
	reg [3:0] true_labels [0:999];
	wire signed [199:0] conv1_weight_1;
	wire signed [199:0] conv1_weight_2;
	wire signed [199:0] conv1_weight_3;
	wire signed [3*8-1:0] bias_1;
	wire signed [199:0] conv2_weight_11;
	wire signed [199:0] conv2_weight_12;
	wire signed [199:0] conv2_weight_13;
	wire signed [199:0] conv2_weight_21;
	wire signed [199:0] conv2_weight_22;
	wire signed [199:0] conv2_weight_23;
	wire signed [199:0] conv2_weight_31;
	wire signed [199:0] conv2_weight_32;
	wire signed [199:0] conv2_weight_33;
	wire signed [3*8-1:0] bias_2;
	reg [71:0] image_6rows;
	reg [3:0] done_z;

	wire [5:0] cycle;
	wire [9:0] image_idx;
	wire [1:0] weight_sel;
	wire [1:0] bias_sel;
	wire image_rom_en;
	wire [79:0] weight_input_packed;
	wire weight_enable;
	wire [5:0] weight_indexing;
	wire signed [79:0] fc_bias;
	reg signed [23:0] zero_bias;
	wire signed [23:0] bias_in;
	wire signed [23:0] conv1_bias;
	wire signed [23:0] conv2_bias;
	wire signed [199:0] conv_weight_in1;
	wire signed [199:0] conv_weight_in2;
	wire signed [199:0] conv_weight_in3;
	wire done;
	wire ready;
	wire [3:0] result;

	integer img_offset;
	integer accuracy;
	integer img_count;

	always @(posedge clk) begin
		done_z[0] <= done;
		done_z[1] <= done_z[0];
		done_z[2] <= done_z[1];
		done_z[3] <= done_z[2];
	end

	top TOP_inst(
		.clk_i(clk),
		.rstn_i(rstn),
		.start_i(start_i | done_z[3]),
		.image_6rows(image_6rows),
		.weight_input_packed(weight_input_packed),
		.fc_bias(fc_bias),
		.conv1_weight_1(conv_weight_in1),
		.conv1_weight_2(conv_weight_in2),
		.conv1_weight_3(conv_weight_in3),
		.bias_1(bias_in),
		.weight_enable(weight_enable),
		.weight_indexing(weight_indexing),
		.cycle(cycle),
		.image_idx(image_idx),
		.image_rom_en(image_rom_en),
		.weight_sel(weight_sel),
		.bias_sel(bias_sel),
		.ready(ready),
		.result(result),
		.done(done)
	);

	always #(1) clk = ~clk;

	initial begin
		$readmemh({VIVADO_PROJECT_LOCATION, "/data/input_1000.txt"}, pixels);
		$readmemh({VIVADO_PROJECT_LOCATION, "/data/labels_1000.txt"}, true_labels);
		clk <= 1'b0;
		rstn <= 1'b1;
		start_i <= 1'b0;
		img_offset <= 0;
		accuracy <= 0;
		img_count <= 0;
		#(10) rstn <= 1'b0;
		#(10) rstn <= 1'b1;
		#(10) start_i <= 1'b1;
		#(10) start_i <= 1'b0;
	end

	always @(posedge clk or negedge rstn) begin
		if (!rstn)
			img_offset <= 0;
		else if (done) begin
			img_count <= img_count + 1;
			img_offset <= img_offset + 784;
			if (result == true_labels[img_count]) begin
				accuracy <= accuracy + 1;
				$display("Image %0d: Success, Prediction = %0d, True Label = %0d", img_count, result, true_labels[img_count]);
			end
			else
				$display("Image %0d: Fail, Prediction = %0d, True Label = %0d", img_count, result, true_labels[img_count]);
		end
		if (img_count == 10'd1000) begin
			$display("\n\n------ Final Accuracy for 1000 Input Image ------");
			$display("Accuracy : %3d%%", accuracy / 10);
			$stop;
		end
	end

	integer i;

	always @(posedge clk or negedge rstn)
		if (!rstn || done)
			for (i = 0; i < 6; i = i + 1)
				image_6rows[(5 - i) * 12+:12] <= 12'hxxx;
		else if (image_rom_en)
			for (i = 0; i < 6; i = i + 1)
				image_6rows[(5 - i) * 12+:12] <= {4'h0, pixels[(((i + (cycle * 2)) * 28) + image_idx) + img_offset]};
		else
			for (i = 0; i < 6; i = i + 1)
				image_6rows[(5 - i) * 12+:12] <= 12'hxxx;

	assign conv_weight_in1 = (weight_sel == 2'b00 ? conv1_weight_1 : (weight_sel == 2'b01 ? conv2_weight_11 : (weight_sel == 2'b10 ? conv2_weight_12 : conv2_weight_13)));
	assign conv_weight_in2 = (weight_sel == 2'b00 ? conv1_weight_2 : (weight_sel == 2'b01 ? conv2_weight_21 : (weight_sel == 2'b10 ? conv2_weight_22 : conv2_weight_23)));
	assign conv_weight_in3 = (weight_sel == 2'b00 ? conv1_weight_3 : (weight_sel == 2'b01 ? conv2_weight_31 : (weight_sel == 2'b10 ? conv2_weight_32 : conv2_weight_33)));
	assign bias_in = (bias_sel == 2'b00 ? conv1_bias : (bias_sel == 2'b01 ? conv2_bias : zero_bias));

	initial begin
		zero_bias[16+:8] = 8'd0;
		zero_bias[8+:8] = 8'd0;
		zero_bias[0+:8] = 8'd0;
	end

	fc_weight_ROM #(.WEIGHT_FILE({VIVADO_PROJECT_LOCATION, "/data/fc_weight_transposed.txt"})) fc_weight_ROM_inst(
		.clk_i(clk),
		.weight_rom_en(weight_enable),
		.weight_idx(weight_indexing),
		.oDAT(weight_input_packed)
	);

	fc_bias_ROM #(.BIAS_FILE({VIVADO_PROJECT_LOCATION, "/data/fc_bias.txt"})) fc_bias_ROM_inst(
		.clk_i(clk),
		.bias_rom_en(weight_enable),
		.bias_idx(weight_indexing),
		.oDAT(fc_bias)
	);

	ROM_Weight #(
		.DATA_WIDTH(8),
		.WEIGHT_FILE_conv1_1({VIVADO_PROJECT_LOCATION, "/data/conv1_weight_1.txt"}),
		.WEIGHT_FILE_conv1_2({VIVADO_PROJECT_LOCATION, "/data/conv1_weight_2.txt"}),
		.WEIGHT_FILE_conv1_3({VIVADO_PROJECT_LOCATION, "/data/conv1_weight_3.txt"}),
		.WEIGHT_FILE_conv2_11({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_11.txt"}),
		.WEIGHT_FILE_conv2_12({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_12.txt"}),
		.WEIGHT_FILE_conv2_13({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_13.txt"}),
		.WEIGHT_FILE_conv2_21({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_21.txt"}),
		.WEIGHT_FILE_conv2_22({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_22.txt"}),
		.WEIGHT_FILE_conv2_23({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_23.txt"}),
		.WEIGHT_FILE_conv2_31({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_31.txt"}),
		.WEIGHT_FILE_conv2_32({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_32.txt"}),
		.WEIGHT_FILE_conv2_33({VIVADO_PROJECT_LOCATION, "/data/conv2_weight_33.txt"})
	) weight_rom(
		.oDAT_conv1_1(conv1_weight_1),
		.oDAT_conv1_2(conv1_weight_2),
		.oDAT_conv1_3(conv1_weight_3),
		.oDAT_conv2_11(conv2_weight_11),
		.oDAT_conv2_12(conv2_weight_12),
		.oDAT_conv2_13(conv2_weight_13),
		.oDAT_conv2_21(conv2_weight_21),
		.oDAT_conv2_22(conv2_weight_22),
		.oDAT_conv2_23(conv2_weight_23),
		.oDAT_conv2_31(conv2_weight_31),
		.oDAT_conv2_32(conv2_weight_32),
		.oDAT_conv2_33(conv2_weight_33)
	);

	ROM_Bias #(
		.WEIGHT_FILE_bias_1({VIVADO_PROJECT_LOCATION, "/data/conv1_bias.txt"}),
		.WEIGHT_FILE_bias_2({VIVADO_PROJECT_LOCATION, "/data/conv2_bias.txt"})
	) bias_rom(
		.oDAT_bias_1(conv1_bias),
		.oDAT_bias_2(conv2_bias)
	);

endmodule