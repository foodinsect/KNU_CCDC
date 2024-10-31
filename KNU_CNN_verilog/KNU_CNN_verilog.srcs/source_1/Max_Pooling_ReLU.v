module Max_Pooling_ReLU (
	input wire clk_i,
	input wire rstn_i,
	input wire valid_i,
	input wire signed [23:0] data_in,
	output wire [11:0] data_o,
	output reg valid_o
);

	reg relu_en;
	reg signed [11:0] max_value;
	reg signed [11:0] data_out;

	// Convert two 12-bit parts to signed values for comparison
	wire signed [11:0] upper;
	wire signed [11:0] lower;

	assign upper = data_in[12+:12];
	assign lower = data_in[0+:12];
	
	// Apply 3-state logic for output
	assign data_o = (valid_o ? data_out : 12'hzzz);

	always @(posedge clk_i) begin
		if (!rstn_i) begin
			data_out <= 12'b0;
			relu_en <= 1'b0;
		end
		else if (valid_i) begin
			// Store the maximum value after comparison
			max_value <= (upper > lower) ? upper : lower;
			relu_en <= 1'b1;
		end
		else if (relu_en) begin
			// Apply ReLU operation
			if (max_value < 0)
				data_out <= 12'b0;
			else
				data_out <= max_value;
			relu_en <= 1'b0;
		end
	end

	// Update valid_o based on relu_en
	always @(posedge clk_i) begin
		valid_o <= relu_en;
	end
endmodule