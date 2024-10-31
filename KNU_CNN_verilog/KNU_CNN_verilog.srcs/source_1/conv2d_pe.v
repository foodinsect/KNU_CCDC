module conv2d_pe (
	input wire clk_i,
	input wire rstn_i,
	input wire valid_i,
	input wire clear_i,
	input wire signed [59:0] data_in,
	input wire signed [199:0] weight_in,
	output reg signed [19:0] pe_out
);
	
	reg [11:0] line_buffer1 [0:4];
	reg [11:0] line_buffer2 [0:4];
	reg [11:0] line_buffer3 [0:4];
	reg [11:0] line_buffer4 [0:4];
	reg [11:0] line_buffer5 [0:4];
	reg signed [19:0] partial_sum;
	integer i;

	always @(posedge clk_i)
		if (~rstn_i)
			for (i = 0; i < 5; i = i + 1)
				begin
					line_buffer1[i] <= 12'hxxx;
					line_buffer2[i] <= 12'hxxx;
					line_buffer3[i] <= 12'hxxx;
					line_buffer4[i] <= 12'hxxx;
					line_buffer5[i] <= 12'hxxx;
				end

		else begin
			if (valid_i) begin
				line_buffer1[4] <= data_in[48+:12];
				line_buffer2[4] <= data_in[36+:12];
				line_buffer3[4] <= data_in[24+:12];
				line_buffer4[4] <= data_in[12+:12];
				line_buffer5[4] <= data_in[0+:12];

				for (i = 0; i < 4; i = i + 1)
					begin
						line_buffer1[i] <= line_buffer1[i + 1];
						line_buffer2[i] <= line_buffer2[i + 1];
						line_buffer3[i] <= line_buffer3[i + 1];
						line_buffer4[i] <= line_buffer4[i + 1];
						line_buffer5[i] <= line_buffer5[i + 1];
					end
				partial_sum = 0;

				for (i = 0; i < 5; i = i + 1)
					partial_sum = ((((partial_sum + ($signed(line_buffer1[i]) * $signed(weight_in[(24 - i) * 8+:8]))) + ($signed(line_buffer2[i]) * $signed(weight_in[(24 - (i + 5)) * 8+:8]))) + ($signed(line_buffer3[i]) * $signed(weight_in[(24 - (i + 10)) * 8+:8]))) + ($signed(line_buffer4[i]) * $signed(weight_in[(24 - (i + 15)) * 8+:8]))) + ($signed(line_buffer5[i]) * $signed(weight_in[(24 - (i + 20)) * 8+:8]));
					pe_out <= $signed(partial_sum);
			end

			if (clear_i)
				for (i = 0; i < 4; i = i + 1)
					begin
						line_buffer1[i] <= 12'hxxx;
						line_buffer2[i] <= 12'hxxx;
						line_buffer3[i] <= 12'hxxx;
						line_buffer4[i] <= 12'hxxx;
						line_buffer5[i] <= 12'hxxx;
					end
		end
endmodule