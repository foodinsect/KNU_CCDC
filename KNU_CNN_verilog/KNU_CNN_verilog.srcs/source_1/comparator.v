module comparator (
	input wire signed [23:0] data_in_i,
	output reg signed [11:0] data_out_o
);
	// Convert two 12-bit parts to signed values for comparison
	wire signed [11:0] upper;
	wire signed [11:0] lower;
	assign upper  = data_in_i[12+:12];
	assign lower = data_in_i[0+:12];
	
	always @(*) begin
		if (upper >= lower)
			data_out_o = upper;
		else
			data_out_o = lower;
	end
endmodule