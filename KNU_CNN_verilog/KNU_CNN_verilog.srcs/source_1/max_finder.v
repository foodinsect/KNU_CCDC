module max_finder (
	input wire clk_i,
	input wire rstn_i,
	input wire valid_i,
	input wire signed [12*10-1:0] inputs_i,
	output reg [3:0] result_o
);

	// Split inputs_i into 10 separate 12-bit wires
	wire signed [11:0] input_wires [0:9];
	
	// Assign each 12-bit segment of inputs_i to an element in input_wires in reverse
	genvar j;
	generate
		for (j = 0; j < 10; j = j + 1) begin
			assign input_wires[j] = inputs_i[(9 - j) * 12 +: 12];
		end
	endgenerate

	// Registers to hold max value and index
	reg signed [11:0] max_value;
	reg [3:0] max_index;
	integer i;

	always @(posedge clk_i) begin
		if (!rstn_i) begin
			// Reset max_value and max_index
			max_value <= -12'sd2048;  // Initialize to a low value
			max_index <= 4'd0;
			result_o <= 4'd0;
		end else if (valid_i) begin
			// Initialize max_value with the first element in input_wires
			max_value = input_wires[0];
			max_index = 4'd0;
			
			// Iterate over the 10 elements in input_wires to find the max value
			for (i = 1; i < 10; i = i + 1) begin
				if (input_wires[i] > max_value) begin
					max_value = input_wires[i];
					max_index = i;
				end
			end
			// Output the index of the max value
			result_o <= max_index;
		end
	end

endmodule
