module MAC (
	input wire clk_i,
	input wire rstn_i,
	input wire clr_i,
	input wire mac_en_i,
	input wire signed [7:0] weight_i,
	input wire signed [11:0] input_i,
	output wire signed [19:0] mac_out_o,
	output wire valid_out_o
);

	reg signed [19:0] reg_accumlation;
	reg signed [7:0] weight_ff;
	reg signed [11:0] input_ff;
	reg mac_en2;
	reg acc_en;
	reg signed [19:0] mult_result;
	reg valid_out;
	reg clear1;

	assign valid_out_o = valid_out;

	always @(posedge clk_i) begin
		mac_en2 <= mac_en_i;
		acc_en <= mac_en2;
	end
	always @(posedge clk_i) 
		clear1 <= clr_i;

	always @(posedge clk_i)
		if (~rstn_i | clear1) begin
			reg_accumlation[19:0] <= 20'h00000;
			mult_result[19:0] <= 20'h00000;
			weight_ff <= 8'h00;
			input_ff <= 11'h000;
			valid_out <= 1'b0;
		end
		else begin
			if (mac_en_i) begin
				weight_ff[7:0] <= weight_i[7:0];
				input_ff[11:0] <= input_i[11:0];
				mult_result[19:0] <= $signed(input_ff) * $signed(weight_ff);
			end

			if (acc_en)
				reg_accumlation[19:0] <= $signed(reg_accumlation[19:0]) + $signed(mult_result[19:0]);

			if ((mac_en2 == 1'b1) && (mac_en_i == 1'b0))
				valid_out <= 1'b1;
		end

	assign mac_out_o[19:0] = (valid_out ? reg_accumlation[19:0] : 20'hzzzzz);

endmodule