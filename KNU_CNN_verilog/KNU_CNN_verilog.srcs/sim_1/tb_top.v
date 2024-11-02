module tb_top;
	reg clk;
	reg rstn;
	reg start_i;
	reg [7:0] pixels [0:783];
	wire signed [199:0] conv1_weight_1;
	wire signed [199:0] conv1_weight_2;
	wire signed [199:0] conv1_weight_3;
	wire signed [199:0] conv2_weight_11;
	wire signed [199:0] conv2_weight_12;
	wire signed [199:0] conv2_weight_13;
	wire signed [199:0] conv2_weight_21;
	wire signed [199:0] conv2_weight_22;
	wire signed [199:0] conv2_weight_23;
	wire signed [199:0] conv2_weight_31;
	wire signed [199:0] conv2_weight_32;
	wire signed [199:0] conv2_weight_33;
	reg [71:0] image_6rows;
	reg signed [23:0] zero_bias;

	wire [5:0] cycle;
	wire [9:0] image_idx;
	wire [1:0] weight_sel;
	wire [1:0] bias_sel;
	wire image_rom_en;
	wire [79:0] weight_input_packed;
	wire weight_enable;
	wire [5:0] weight_indexing;
	wire signed [79:0] fc_bias;
	wire signed [23:0] bias_in;
	wire signed [23:0] conv1_bias;
	wire signed [23:0] conv2_bias;
	wire signed [199:0] conv_weight_in1;
	wire signed [199:0] conv_weight_in2;
	wire signed [199:0] conv_weight_in3;
	wire done;
	wire ready;
	wire [3:0] result;

	top TOP_inst(
		.clk_i(clk),
		.rstn_i(rstn),
		.start_i(start_i),
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
		$readmemh("./data/0_03.txt", pixels);
		clk <= 1'b0;
		rstn <= 1'b1;
		start_i = 1'b0;
		#(3) rstn <= 1'b0;
		#(2) rstn <= 1'b1;
		#(2) start_i = 1'b1;
		#(2) start_i = 1'b0;
		wait (done == 1);
		$finish;
	end

	integer i;

	always @(posedge clk)
		if (!rstn | done)
			for (i = 0; i < 6; i = i + 1)
				image_6rows[(5 - i) * 12+:12] <= 12'hxxx;
		else if (image_rom_en)
			for (i = 0; i < 6; i = i + 1)
				image_6rows[(5 - i) * 12+:12] <= {4'h0, pixels[((i + (cycle * 2)) * 28) + image_idx]};
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

	fc_weight_ROM #(.WEIGHT_FILE("./data/fc_weight_transposed.txt")) fc_weight_ROM_inst(
		.clk_i(clk),
		.weight_rom_en(weight_enable),
		.weight_idx(weight_indexing),
		.oDAT(weight_input_packed)
	);

	fc_bias_ROM #(.BIAS_FILE("./data/fc_bias.txt")) fc_bias_ROM_inst(
		.clk_i(clk),
		.bias_rom_en(weight_enable),
		.bias_idx(weight_indexing),
		.oDAT(fc_bias)
	);

	ROM_Weight #(
		.DATA_WIDTH(8),
		.WEIGHT_FILE_conv1_1("./data/conv1_weight_1.txt"),
		.WEIGHT_FILE_conv1_2("./data/conv1_weight_2.txt"),
		.WEIGHT_FILE_conv1_3("./data/conv1_weight_3.txt"),
		.WEIGHT_FILE_conv2_11("./data/conv2_weight_11.txt"),
		.WEIGHT_FILE_conv2_12("./data/conv2_weight_12.txt"),
		.WEIGHT_FILE_conv2_13("./data/conv2_weight_13.txt"),
		.WEIGHT_FILE_conv2_21("./data/conv2_weight_21.txt"),
		.WEIGHT_FILE_conv2_22("./data/conv2_weight_22.txt"),
		.WEIGHT_FILE_conv2_23("./data/conv2_weight_23.txt"),
		.WEIGHT_FILE_conv2_31("./data/conv2_weight_31.txt"),
		.WEIGHT_FILE_conv2_32("./data/conv2_weight_32.txt"),
		.WEIGHT_FILE_conv2_33("./data/conv2_weight_33.txt")
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
		.WEIGHT_FILE_bias_1("./data/conv1_bias.txt"),
		.WEIGHT_FILE_bias_2("./data/conv2_bias.txt")
	) bias_rom(
		.oDAT_bias_1(conv1_bias),
		.oDAT_bias_2(conv2_bias)
	);

endmodule